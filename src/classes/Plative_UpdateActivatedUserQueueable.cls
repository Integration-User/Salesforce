/**
* Company      : Plative
* Description  : Queueable class for bulk activation/username update of Contact
* History      :
* 3rd June,2020: Kunal - Code Creation
*/
public class Plative_UpdateActivatedUserQueueable implements Queueable,Database.AllowsCallouts {
    
    Set<Id> contactIdToProcess = new Set<Id>();
    
    public Plative_UpdateActivatedUserQueueable(Set<Id> contactIdSet){
        if(contactIdSet.size() <= 50){
            contactIdToProcess.addAll(contactIdSet);            
        } else {
            Set<Id> contactIdToQueue = new Set<Id>(); Integer count = 0;            
            for(Id contactId: contactIdSet){
                if(count <= 49){ contactIdToProcess.add(contactId); } 
                else { contactIdToQueue.add(contactId); }
                count++;
            }
            if(!contactIdToQueue.isEmpty()){ System.enqueueJob(new Plative_UpdateActivatedUserQueueable(contactIdToQueue)); }
        }
    }
    
    
    public void execute(QueueableContext context) {
        //Contact Id Set for Email Distributions
        Set<Id> contactIdSetForED = new Set<Id>();
        List<Contact> contactsToUpdate = new List<Contact>();
        //Integration Log insert list
        List<Integration_Log__c > integrationLogInsertList = new List<Integration_Log__c>();        
        List<Contact> contactList = [Select Id,Name,AccountId,Account.GSA_ID__c,Account.Account_Status__c,Contact_Status__c,
                                     FirstName,LastName,Email,Username__c,Datalink_Access_New__c,Website_Access_New__c,
                                     GSA_ID__c,Activation_Date__c
                                     from Contact where Id IN :contactIdToProcess AND Account.Account_Status__c = 'Active' ];
        system.debug('contactList: ' + contactList.size());
        if(!contactList.isEmpty()){
            //String endpoint = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/users/activate';
            GSA_Platform__c platform = GSA_Platform__c.getOrgDefaults();
            String endpoint = platform.User_Activation__c;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Accept', 'application/json');
            request.setHeader('x-api-key', platform.API_Key__c);            
            request.setHeader('Content-Type', 'application/json'); 
            HttpResponse response = new HttpResponse();
            try{
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeFieldName('users');
                gen.writeStartArray();
                Map<String,String> contactIdVsSinglePayload = new Map<String,String>();
                for (Contact cont : contactList) {
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
                String payload = gen.getAsString();
                request.setBody(payload);
                request.setTimeout(100000);
                response = Http.send(request);
                system.debug('response : ' + response.getStatus());
                system.debug('response : ' + response.getStatusCode());
                system.debug('response : ' + response.getBody());
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
                            for (Contact cont : contactList) {
                                if(activatedGSAIdSet.contains(cont.GSA_ID__c) && !parseContactDataErroredWebsiteMap.containsKey(cont.GSA_ID__c) && !parseContactDataErroredDatalinkMap.containsKey(cont.GSA_ID__c)){
                                    Date activationDate = cont.Contact_Status__c != 'Active' ? System.today() : cont.Activation_Date__c; activationDate = activationDate != null ? activationDate : System.today();
                                    contactsToUpdate.add(new Contact(Id = cont.Id, Contact_Status__c = 'Active', Activation_Date__c=activationDate, Activate_Contact__c=true)); contactIdSetForED.add(cont.Id);
                                } else {
                                    //Log Error
                                    payload = contactIdVsSinglePayload.get(cont.Id); String responseBody = response.getBody().length() > 32768 ? response.getBody().substring(0, 32767) : response.getBody();
                                    GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Salesforce to GSA Update User', platform.API_Key__c, payload , String.valueOf(response.getStatusCode()), responseBody, response.getStatus(), false, cont.Id); integrationLogInsertList.add(intLog.logObject);
                                }
                            }
                        }
                    } else {
                        payload = payload.length() > 131072 ? payload.substring(0, 131071) : payload; String responseBody = response.getBody().length() > 32768 ? response.getBody().substring(0, 32767) : response.getBody();                        
                        GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Salesforce to GSA Update User', platform.API_Key__c, payload, String.valueOf(response.getStatusCode()), responseBody, response.getStatus(), false, null); integrationLogInsertList.add(intLog.logObject);
                    }
                } else {
                    payload = payload.length() > 131072 ? payload.substring(0, 131071) : payload; String responseBody = response.getBody().length() > 32768 ? response.getBody().substring(0, 32767) : response.getBody();
                    GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Salesforce to GSA Update User', platform.API_Key__c, payload, String.valueOf(response.getStatusCode()), responseBody, response.getStatus(), false, null); integrationLogInsertList.add(intLog.logObject);
                }
                
            } catch(Exception ex){ 
                String errorMessage = 'In Apex class Plative_UpdateActivatedUserQueueable. ' + 'At line number: ' + ex.getLineNumber() + '. Cause: ' + ex.getCause() + '. Message: ' + ex.getMessage(); GSD_IntegrationLog intLog = new GSD_IntegrationLog(request.getEndpoint(), 'Salesforce to GSA Update User', request.getHeader('x-api-key'), request.getBody(), String.valueOf(response.getStatusCode()), response.getBody(), errorMessage, false, ''); 
                integrationLogInsertList.add(intLog.logObject);
            }
            
            system.debug('integrationLogInsertList: ' + integrationLogInsertList.size());
            if(!integrationLogInsertList.isEmpty()){
                insert integrationLogInsertList;
            }
            
            system.debug('contactsToUpdate: ' + contactsToUpdate.size());
            if(!contactsToUpdate.isEmpty()){
                update contactsToUpdate;
            }
            
            if(!contactIdSetForED.isEmpty()){
                Plative_ContactTriggerHelper.addEmailDistributions(contactIdSetForED);
            }
        }
        
        
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
        Map<String,String> erroredMap = new Map<String,String>(); List<Object> objectList = (List<Object>) JSON.deserializeUntyped(JSON.serialize(obj));
        for(Object gsaObj: objectList){
            Map<String,Object> gsaObjectMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(gsaObj));
            if(gsaObjectMap.containsKey('gsContactID') && gsaObjectMap.containsKey('error')){ erroredMap.put((String)gsaObjectMap.get('gsContactID'), (String)gsaObjectMap.get('error')); }            
        }
        return erroredMap;
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
    public class UserActivateWrapper {
        public String gsContactID;
        public String gsCompanyID;
        public String username;
        public String first_name;
        public String last_name;
        public Boolean website_only;
        public Boolean datalink_only;
    }
    
}