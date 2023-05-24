/**
* Company     : Plative
* Description : Batch class for Mass Activation Account/Contact
* History     : 
* [21.Aug.2020] Kunal - Code Creation 
*/

public class Plative_GSAMassActivationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    String sObjectApiName;
    
    public Plative_GSAMassActivationBatch(String sObjectApiName) {
        this.sObjectApiName = sObjectApiName.toLowerCase();
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query;
        if (sObjectApiName == 'account') {
            query = Label.GSA_MassActivation_AccountQuery;
        } else if (sObjectApiName == 'contact') {
            query = Label.GSA_MassActivation_ContactQuery;
        }
        //query = query + ' LIMIT 100 ';
        system.debug('query: ' + query);
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<SObject> scope) {
        system.debug('scope: ' + scope.size());
        List<SObject> sObjectUpdateList = new List<SObject> ();
        List<Integration_Log__c> integrationLogList = new List<Integration_Log__c> ();
        GSA_Platform__c platform = GSA_Platform__c.getOrgDefaults();
        String endpoint = '';
        String payload = '';
        //if sObjectApiName is Account
        if (sObjectApiName == 'account') {
            endpoint = platform.Company_Activation__c;
            //Get Product Lines for Account
            Map<Id, List<String>> accountIdVsProductLines = getProductLinesMap(scope);
            if (!accountIdVsProductLines.isEmpty()) {
                for (Account accnt : (List<Account>) scope) {
                    HttpResponse response = new HttpResponse();
                    try{
                        if (accountIdVsProductLines.containsKey(accnt.Id)) {
                            JSONGenerator gen = JSON.createGenerator(true);
                            gen.writeStartObject();
                            gen.writeFieldName('company');
                            gen.writeStartObject();
                            gen.writeStringField('gsCompanyID', String.valueOf(accnt.GSA_ID__c));
                            gen.writeObjectField('products', accountIdVsProductLines.get(accnt.Id));
                            gen.writeEndObject();  
                            gen.writeEndObject();
                            payload = gen.getAsString();  
                            response = makeCallout(endpoint, payload, 20000, platform.API_Key__c, 'POST'); 
                            system.debug('response status: ' + response.getStatusCode());
                            system.debug('response body: ' + response.getBody());
                            if ((response.getStatusCode() == 200 || response.getStatusCode() == 201) && String.isNotBlank(response.getBody()) && !response.getBody().contains('error')) {
                                if (fetchResponseStatus(response.getBody()) == 'success') {
                                    //Date activationDate = accnt.Activation_Date__c != null ? accnt.Activation_Date__c : System.today();
                                    Date activationDate = accnt.Account_Status__c != 'Active' ? System.today() : accnt.Activation_Date__c;
                                    activationDate = activationDate != null ? activationDate : System.today();
                                    sObjectUpdateList.add(new Account(Id = accnt.Id, Account_Status__c = 'Active', Activation_Date__c = activationDate));
                                } else {
                                    //Log Error
                                    GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Salesforce to Account GSA Bulk Activation', platform.API_Key__c, payload, String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false, accnt.Id);
                                    integrationLogList.add(intLog.logObject);
                                }
                            } else {
                                //Log Error
                                GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Salesforce to Account GSA Bulk Activation', platform.API_Key__c, payload, String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false, accnt.Id);
                                integrationLogList.add(intLog.logObject);
                            }
                        }
                    } catch(Exception ex){
                        System.debug('In Apex class clsName. At line number: ' + ex.getLineNumber() + '. Cause: ' + ex.getCause() + '. Message: ' + ex.getMessage());
                        GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Salesforce to Account GSA Bulk Activation', platform.API_Key__c, payload, String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false, null);
                        integrationLogList.add(intLog.logObject);
                    }   
                    
                }
            }
        } 
        
        //if sObjectApiName is Contact
        else if(sObjectApiName == 'contact') {
            HttpResponse response = new HttpResponse();
            try{
                endpoint = platform.User_Activation__c;
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeFieldName('users');
                gen.writeStartArray();
                Map<String,String> contactIdVsSinglePayload = new Map<String,String>();
                for (Contact cont : (List<Contact>) scope) {
                    gen.writeStartObject();
                    gen.writeStringField('gsContactID', cont.GSA_ID__c);
                    gen.writeStringField('gsCompanyID', cont.Account.GSA_ID__c);
                    gen.writeStringField('username', cont.Username__c);
                    gen.writeStringField('first_name', cont.FirstName);
                    gen.writeStringField('last_name', cont.LastName);
                    gen.writeBooleanField('website_only', cont.Website_Access_New__c);
                    gen.writeBooleanField('datalink_only', cont.Datalink_Access_New__c);
                    gen.writeEndObject(); 
                    
                    UserActivateWrapper userWrap = createUserActivationWrapper(cont);
                    contactIdVsSinglePayload.put(cont.Id, JSON.serialize(userWrap));
                }
                gen.writeEndArray();
                gen.writeEndObject();
                payload = gen.getAsString();  
                
                response = makeCallout(endpoint, payload, 40000, platform.API_Key__c, 'POST'); 
                Set<String> activatedGSAIdSet = new Set<String>();
                Map<String,String> parseContactDataErroredWebsiteMap = new Map<String,String>();
                Map<String,String> parseContactDataErroredDatalinkMap = new Map<String,String>();
                if ((response.getStatusCode() == 200 || response.getStatusCode() == 201) && String.isNotBlank(response.getBody())) {
                    if (fetchResponseStatus(response.getBody()) == 'success') {
                        Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                        if(responseMap.containsKey('data')){
                            Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(responseMap.get('data')));
                            
                            //website_users map
                            if(dataMap.containsKey('website_users')){
                                if(!(dataMap.get('website_users') instanceof List<Object>)){
                                    Map<String,Object> websiteUserMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(dataMap.get('website_users')));
                                    if(websiteUserMap.containsKey('created')){
                                        List<String> createdList = parseContactData(websiteUserMap.get('created'));
                                        activatedGSAIdSet.addAll(createdList);
                                    }
                                    
                                    if(websiteUserMap.containsKey('updated')){
                                        List<String> updateList = parseContactData(websiteUserMap.get('updated'));
                                        activatedGSAIdSet.addAll(updateList);
                                    }
                                    
                                    if(websiteUserMap.containsKey('errored')){
                                        parseContactDataErroredWebsiteMap = parseContactDataErrored(websiteUserMap.get('errored'));                                    
                                    }
                                }
                            }
                            
                            if(dataMap.containsKey('datalink_users')){
                                if(!(dataMap.get('datalink_users') instanceof List<Object>)){
                                    Map<String,Object> dataLinkUserMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(dataMap.get('datalink_users')));
                                    if(dataLinkUserMap.containsKey('created')){
                                        List<String> createdList = parseContactData(dataLinkUserMap.get('created'));
                                        activatedGSAIdSet.addAll(createdList);
                                    }
                                    
                                    if(dataLinkUserMap.containsKey('updated')){
                                        List<String> updateList = parseContactData(dataLinkUserMap.get('updated'));
                                        activatedGSAIdSet.addAll(updateList);
                                    }
                                    
                                    if(dataLinkUserMap.containsKey('errored')){
                                        parseContactDataErroredDatalinkMap = parseContactDataErrored(dataLinkUserMap.get('errored'));                                    
                                    }
                                }
                            }
                            
                            
                            //Process contacts to be updated
                            for (Contact cont : (List<Contact>) scope) {
                                if(activatedGSAIdSet.contains(cont.GSA_ID__c) && !parseContactDataErroredWebsiteMap.containsKey(cont.GSA_ID__c) && !parseContactDataErroredDatalinkMap.containsKey(cont.GSA_ID__c)){
                                    Date activationDate = cont.Contact_Status__c != 'Active' ? System.today() : cont.Activation_Date__c;
                                    activationDate = activationDate != null ? activationDate : System.today();
                                    sObjectUpdateList.add(new Contact(Id = cont.Id, Contact_Status__c = 'Active', Activation_Date__c=activationDate, Activate_Contact__c=true));
                                } else {
                                    //Log Error
                                    payload = contactIdVsSinglePayload.get(cont.Id);
                                    String responseBody = response.getBody().length() > 32768 ? response.getBody().substring(0, 32767) : response.getBody();
                                    GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Salesforce to Contact GSA Bulk Activation', platform.API_Key__c, payload , String.valueOf(response.getStatusCode()), responseBody, response.getStatus(), false, cont.Id);
                                    integrationLogList.add(intLog.logObject);
                                }
                            }
                        }
                    } else {
                        payload = payload.length() > 131072 ? payload.substring(0, 131071) : payload;
                        String responseBody = response.getBody().length() > 32768 ? response.getBody().substring(0, 32767) : response.getBody();
                        GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Salesforce to Contact GSA Bulk Activation', platform.API_Key__c, payload, String.valueOf(response.getStatusCode()), responseBody, response.getStatus(), false, null);
                        integrationLogList.add(intLog.logObject);
                    }
                } else {
                    payload = payload.length() > 131072 ? payload.substring(0, 131071) : payload;
                    String responseBody = response.getBody().length() > 32768 ? response.getBody().substring(0, 32767) : response.getBody();
                    GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Salesforce to Contact GSA Bulk Activation', platform.API_Key__c, payload, String.valueOf(response.getStatusCode()), responseBody, response.getStatus(), false, null);
                    integrationLogList.add(intLog.logObject);
                }
            } catch(Exception ex){
                System.debug('In Apex class clsName. At line number: ' + ex.getLineNumber() + '. Cause: ' + ex.getCause() + '. Message: ' + ex.getMessage());
                payload = payload.length() > 131072 ? payload.substring(0, 131071) : payload;
                String responseBody = response.getBody().length() > 32768 ? response.getBody().substring(0, 32767) : response.getBody();
                GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Salesforce to Contact GSA Bulk Activation', platform.API_Key__c, payload, String.valueOf(response.getStatusCode()), responseBody, response.getStatus(), false, null);
                integrationLogList.add(intLog.logObject);
            }
            
        }
        
        //update Sobject list
        update sObjectUpdateList;
        //update integration Log List;
        insert integrationLogList;
    }
    
    
    public void finish(Database.BatchableContext context) {
        
    }
    
    private Map<Id, List<String>> getProductLinesMap(List<SObject> sObjectList) {
        Map<Id, List<String>> accountIdVsProductLines = new Map<Id, List<String>> ();
        List<Account> accountList = (List<Account>) sObjectList;
        for (Account_Product_Line__c productLine : [Select Id, Product__r.Name,Product__r.Website_Product__c, Account__c from Account_Product_Line__c
                                                    where Account__c IN :accountList AND Product__c != null]) {
                                                        if (!accountIdVsProductLines.containsKey(productLine.Account__c)) {
                                                            accountIdVsProductLines.put(productLine.Account__c, new List<String> ());
                                                        }
                                                        accountIdVsProductLines.get(productLine.Account__c).add(productLine.Product__r.Website_Product__c);
                                                        
                                                    }        
        return accountIdVsProductLines;
    }
    
    //fetch response status
    private Static String fetchResponseStatus(String responseBody) {
        String status;
        Map<String, Object> serializedResponseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if (serializedResponseMap.containsKey('status') && String.isNotBlank((String) serializedResponseMap.get('status')) && ((String) serializedResponseMap.get('status') == 'success')) {
            status = 'success';
        }
        return status;
    }
    
    private HttpResponse makeCallout(String endpoint, String body, Integer timeoutValue, String apiKey, String method) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        request.setHeader('x-api-key', apiKey);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setBody(body);
        request.setTimeout(timeoutValue);
        response = Http.send(request);
        return response;
    }
    
    public static List<String> parseContactData(Object obj){
        List<String> gsaIdList = new List<String>();
        List<Object> objectList = (List<Object>) JSON.deserializeUntyped(JSON.serialize(obj));
        for(Object gsaObj: objectList){
            Map<String,Object> gsaObjectMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(gsaObj));
            if(gsaObjectMap.containsKey('gsContactID')){
                gsaIdList.add((String)gsaObjectMap.get('gsContactID'));
            }            
        }
        return gsaIdList;
    }
    
    public static Map<String,String> parseContactDataErrored(Object obj){
        Map<String,String> erroredMap = new Map<String,String>();
        List<Object> objectList = (List<Object>) JSON.deserializeUntyped(JSON.serialize(obj));
        for(Object gsaObj: objectList){
            Map<String,Object> gsaObjectMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(gsaObj));
            if(gsaObjectMap.containsKey('gsContactID') && gsaObjectMap.containsKey('error')){
                erroredMap.put((String)gsaObjectMap.get('gsContactID'), (String)gsaObjectMap.get('error'));
            }            
        }
        return erroredMap;
    }
    
    //Method to create User Activation request body
    private static UserActivateWrapper createUserActivationWrapper(Contact cont) {
        UserActivateWrapper userWrap = new UserActivateWrapper();
        userWrap.gsContactID = cont.GSA_ID__c;
        userWrap.gsCompanyID = cont.Account.GSA_ID__c;
        userWrap.username = cont.Username__c;
        userWrap.first_name = cont.FirstName;
        userWrap.last_name = cont.LastName;
        userWrap.website_only = cont.Website_Access_New__c;
        userWrap.datalink_only = cont.Datalink_Access_New__c;
        return userWrap;
    }
    
    //User Activation Wrapper
    private class UserActivateWrapper {
        public String gsContactID;
        public String gsCompanyID;
        public String username;
        public String first_name;
        public String last_name;
        public Boolean website_only;
        public Boolean datalink_only;
    }
    
    
}