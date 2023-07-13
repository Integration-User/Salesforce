/**
* Company     : Plative
* Description : Utility class for making callout to activate/deactivate the account/contact record or reset password for contact record(GSA Platform User)
* History     :
* [19.Feb.2020] Kunal - Code Creation
*/

public with sharing class Plative_GSAWebCalloutUtility {

    public Static Map<Id, Contact> contactIdMap = new Map<Id, Contact>();
    public Static Map<Id, Account> accountIdMap = new Map<Id, Account>();

    public Static String makeCallout(Id recordId, String sObjectApiName, String actionType) {

        String message = '';

        //Fetch field related to the recordId for either account or contact
        accountIdMap = new Map<Id, Account>([Select Id,Name,Product_Line__c,GSA_ID__c from Account where Id = :recordId]);
        contactIdMap = new Map<Id, Contact>([Select Id,Name,AccountId,Account.GSA_ID__c,Account.Account_Status__c,FirstName,LastName,Email,Username__c,Datalink_Access_New__c,Website_Access_New__c,GSA_ID__c, Left_this_Account__c, Contact_Status__c from Contact where Id = :recordId]);

        List<SObject> sObjectUpdateList = new List<SObject>();
        List<Integration_Log__c > integrationLogInsertList = new List<Integration_Log__c>();
        List<Contact> contactDeactivateList = new List<Contact>();
        Set<Id> contactIdSetForED = new Set<Id>();
        Set<Id> contactIdSetForEDRemoval = new Set<Id>();

        GSA_Platform__c platform = GSA_Platform__c.getOrgDefaults();
        String endpoint = '';
		
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('x-api-key', platform.API_Key__c);
        HttpResponse response;
        try {
            //Callout action type (activate/deactivate)
            String action = actionType.toLowerCase();

            //For Company
            if (sObjectApiName.toLowerCase() == 'account') {

                //For Company Activation
                if (action == 'activate') {
                    system.debug('Activate company!');
                    //endpoint += '/companies/' + action;
					endpoint = platform.Company_Activation__c;
                    Account accnt = accountIdMap.get(recordId);
                    List<Account_Product_Line__c> productLineList = [Select Id,Product__r.Name,Product__r.Website_Product__c from Account_Product_Line__c where Account__c = :accnt.Id];
                    String productLines = '';
                    for(Account_Product_Line__c productLine: productLineList){
                        productLines += productLine.Product__r.Website_Product__c + ';';                        
                    }
                    productLines = productLines.removeEnd(';');

                    //Create payload for activating account using AccountActivateWrapper
                    AccountActivateWrapper accntWrap = new AccountActivateWrapper();
                    accntWrap.gsCompanyID = accnt.GSA_ID__c;

                    //Product Line is mandatory
                    if (String.isBlank(productLines)) {
                        message = 'Error occurred while activating the Company. Product Line is required.';
                        return message;
                    }
                    accntWrap.products = String.isNotBlank(productLines) ? productLines.split(';') : new List<String>();
                    String requestBody = JSON.serialize(new Map<String, Object>{
                            'company' => accntWrap
                    });

                    request.setMethod('POST');
                    request.setEndpoint(endpoint);
                    request.setHeader('Content-Type', 'application/json');
                    request.setHeader('Accept', 'application/json');
                    request.setBody(requestBody);

                    system.debug('endpoint: ' + endpoint);
                    system.debug('body: ' + requestBody);
                }

                //For Company Deactivation
                else {
                    Account accnt = accountIdMap.get(recordId);
                    system.debug('Deactivate company!');
                    //endpoint += '/companies/' + accnt.GSA_ID__c + '/' + action;
                    /*String requestBody = JSON.serialize(new Map<String, Object>{
                            'gsCompanyID' => accnt.GSA_ID__c
                    });*/
                    endpoint = platform.Company_Deactivation__c + accnt.GSA_ID__c + '/' + action;
                    system.debug('system: ' + endpoint);
                    request.setMethod('POST');
                    request.setEndpoint(endpoint);

                    system.debug('endpoint: ' + endpoint);
                }
            }

            //For User
            if (sObjectApiName.toLowerCase() == 'contact') {

                //For User Activation
                if (action == 'activate') {
                    system.debug('activate user');
                    Contact cont = contactIdMap.get(recordId);
					
                    //Check if Account related to the Contact is active. If not return error
                    if (String.isBlank(cont.Account.Account_Status__c) || cont.Account.Account_Status__c != 'Active') {
                        message = 'Error: Cannot activate contact if company is not active. ';
                        return message;
                    }
                    endpoint = platform.User_Activation__c;
                    request.setEndpoint(endpoint);

                    //Username on Contact for GSA Platform user is mandatory
                    if (String.isBlank(cont.Username__c)) {
                        message = 'Error while activating User. Username is required.';
                        return message;
                    }
                    
                    if(!cont.Datalink_Access_New__c && !cont.Website_Access_New__c){
                        message = 'Error: Before activating a contact, access for at least one needs to be specified. Datalink or Website or both!';
                        return message;
                    }

                    //Create payload for activating contact using UserActivateWrapper
                    UserActivateWrapper userWrap = createUserActivationWrapper(cont);
                    String requestBody = JSON.serialize(new Map<String, Object>{
                            'users' => new List<UserActivateWrapper>{
                                    userWrap
                            }
                    });

                    request.setMethod('POST');
                    request.setEndpoint(endpoint);
                    request.setHeader('Content-Type', 'application/json');
                    request.setHeader('Accept', 'application/json');
                    request.setBody(requestBody);

                    system.debug('endpoint: ' + endpoint);
                    system.debug('body: ' + requestBody);
                }

                //For User Deactivation
                else if (action == 'deactivate') {
                    Contact cont = contactIdMap.get(recordId);
                    system.debug('activate user');
                    // SF-574 - Left this Account field 
                    if (String.isNotBlank(cont.Account.Account_Status__c) && cont.Account.Account_Status__c == 'Active'
                        && String.isBlank(cont.Left_this_Account__c) && cont.Contact_Status__c == 'Active') {
                        message = 'Error : Please update the field, “Left this Account” before deactivating this contact.';
                        return message;
                    }
                    endpoint = platform.User_Deactivation__c + cont.GSA_ID__c + '/' + action;
                    request.setEndpoint(endpoint);
                    JSONGenerator gen = JSON.createGenerator(true);
                    gen.writeStartObject();
                    if(cont.Datalink_Access_New__c){
                        gen.writeBooleanField('datalink_only',false);
                    } 
                    if(cont.Website_Access_New__c){
                        gen.writeBooleanField('website_only',false);
                    } 
                    gen.writeEndObject();
                    //String reqBody = gen.getAsString();
                    //system.debug('reqBody: ' + reqBody);
                    //request.setBody(reqBody);
                    request.setMethod('PUT');
                }

                //For Reset GSA Password
                else {
                    Contact cont = contactIdMap.get(recordId);
                    endpoint += platform.User_Password_Reset__c + cont.GSA_ID__c + '/' + action;
                    request.setEndpoint(endpoint);
                    request.setMethod('PUT');
                    system.debug('endpoint: ' + endpoint);

                }
            }

            request.setTimeout(30000);
            response = Http.send(request);
            //system.debug('Response Code: ' + response.getStatusCode());
            system.debug('Response Body: ' + response.getBody());
            if ((response.getStatusCode() == 200 || response.getStatusCode() == 201) && String.isNotBlank(response.getBody()) && !response.getBody().contains('error')) {

                /*Integer bundleId;
                //On Company activation get bundle id and store it on account record
                if (sObjectApiName.toLowerCase() == 'account' && action == 'activate') {

                    //Fetch bundle id
                    bundleId = fetchBundleIdFromAccountActivation(response.getBody());

                    //If bundle id found, update Bundle_ID__c, Activation_Date__c & Account Status to Active
                    if (bundleId != null) {
                        sObjectUpdateList.add(new Account(Id = recordId, Bundle_ID__c = bundleId, Account_Status__c = 'Active', Activation_Date__c = System.today()));
                    }

                    //If bundle id null, then create error log
                    else {
                        GSD_IntegrationLog intLog = new GSD_IntegrationLog(request.getEndpoint(), 'Salesforce to GSA', request.getHeader('x-api-key'), request.getBody(), String.valueOf(response.getStatusCode()), response.getBody(), 'Company Activation: Failed to Assign Bundle Id', false, recordId);
                        integrationLogInsertList.add(intLog.logObject);
                    }

                } else {*/
                    //Check if the response from the callout is a success or not
                    if (fetchResponseStatus(response.getBody()) == 'success') {

                        //If record is of account sobject & action is activate &&
                        //If bundle id not found, still update Activation_Date__c & Account Status to Active
                        if (sObjectApiName.toLowerCase() == 'account' && action == 'activate') {
                            sObjectUpdateList.add(new Account(Id = recordId, Account_Status__c = 'Active', Activation_Date__c = System.today()));
                        }

                        //If record is of account sobject & action is deactivate
                        else if (sObjectApiName.toLowerCase() == 'account' && action == 'deactivate') {

                            //Check if the account has been properly deactivated successfully
                            if (!fetchDeactivationStatus(response.getBody()).toLowerCase().contains('error')) {

                                //Update Account Status to Inactive & Update the Deactivation_Date__c
                                sObjectUpdateList.add(new Account(Id = recordId, Account_Status__c = 'Inactive', Deactivation_Date__c = System.today()));

                                //Deactivate all the Contacts related to the deactivated company
                                contactDeactivateList = fetchContactsToDeactivate(recordId);
                            }

                            //If account isn't deactivated successfully then log the error
                            else {
                                message = 'Error: ' + fetchDeactivationStatus(response.getBody());
                                GSD_IntegrationLog intLog = new GSD_IntegrationLog(request.getEndpoint(), 'Salesforce to GSA', request.getHeader('x-api-key'), request.getBody(), String.valueOf(response.getStatusCode()), response.getBody(), 'Company Deactivation: Error deactivating company!', false,recordId);
                            }
                        }

                        //If record is of contact sobject & action is activate
                        else if (sObjectApiName.toLowerCase() == 'contact' && action == 'activate') {
                            // SF-574 - Update Left_this_Account__c as null if contact is moved to a different account or activated
                            sObjectUpdateList.add(new Contact(Id = recordId, Contact_Status__c = 'Active', Activation_Date__c=System.today(), Activate_Contact__c=true, Left_this_Account__c = null));
                            contactIdSetForED.add(recordId);
                        }
 
                        //If record is of contact sobject & action is deactivate
                        else if (sObjectApiName.toLowerCase() == 'contact' && action == 'deactivate') {
                            sObjectUpdateList.add(new Contact(Id = recordId,Contact_Status__c = 'Inactive',Deactivation_Date__c=System.today(),Activate_Contact__c=false));
                            contactIdSetForEDRemoval.add(recordId);
                        }

                        //If record is of contact sobject & action is reset password for GSA Platform User
                        else if (sObjectApiName.toLowerCase() == 'contact' && action == 'reset_password') {
						message = 'GSA Password Reset Successfully!';
                            //Check if the password is reset successfully. If not log an error
                            /*if (fetchResetPasswordStatus(response.getBody()) == 'success') {
                                message = 'GSA Password Reset Successfully!';
                            }else {
                                message = 'Error! Failed to reset password!';
                                GSD_IntegrationLog intLog = new GSD_IntegrationLog(request.getEndpoint(), 'Salesforce to GSA', request.getHeader('x-api-key'), request.getBody(), String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false);
                                integrationLogInsertList.add(intLog.logObject);
                            }*/
                        }
                    }

                    //Log error if the response has an error
                    else {
                        message = 'Error! Status: ' + fetchResponseStatus(response.getBody());
                        GSD_IntegrationLog intLog = new GSD_IntegrationLog(request.getEndpoint(), 'Salesforce to GSA', request.getHeader('x-api-key'), request.getBody(), String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false, recordId);
                        integrationLogInsertList.add(intLog.logObject);
                    }
                //}

            }

            //Create error log if status code is not equal to 200,201 or there is issue with response body.
            else {
                GSD_IntegrationLog intLog = new GSD_IntegrationLog(request.getEndpoint(), 'Salesforce to GSA', request.getHeader('x-api-key'), request.getBody(), String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false, recordId);
                //message = 'Unknown Error! Kindly, contact your System Administrator!';
                ResponseBody resBody = (ResponseBody)JSON.deserialize(response.getBody(), ResponseBody.class);
                if(resBody.data.datalink_users != null && resBody.data.datalink_users.errored.size() > 0)
                    message = 'Error : '+ resBody.data.datalink_users.errored[0].error;
                else {
                    Map<String, Object> errorResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    Map<String, Object> errorData = (Map<String, Object>) errorResponse.get('data'); 
                    message = 'Error : GSA ID '+ errorData.get('gsCompanyID') + ': ' + errorData.get('error') + ' in website tables';
                }
                integrationLogInsertList.add(intLog.logObject);
            }

            //Insert Integration Logs
            if (!integrationLogInsertList.isEmpty()) {
                insert integrationLogInsertList;
            }

            //Update Account or Contact record on successfully activation or deactivation
            if (!sObjectUpdateList.isEmpty()) {
                update sObjectUpdateList;
            }

            //Update Contacts for Deactivation if the Contacts have been deactivated successfully
            if (!contactDeactivateList.isEmpty()) {
                update contactDeactivateList;
            }
            
            if(!contactIdSetForED.isEmpty()){
                Plative_ContactTriggerHelper.addEmailDistributions(contactIdSetForED);
            }
            
            if(!contactIdSetForEDRemoval.isEmpty()){
                Plative_ContactTriggerHelper.removeEmailDistributions(contactIdSetForEDRemoval);
            }

        } catch (Exception ex) {
            //Create error logs
            String errorMessage = 'In Apex class Plative_GSAWebCalloutUtility. ' + 'At line number: ' + ex.getLineNumber() + '. Cause: ' + ex.getCause() + '. Message: ' + ex.getMessage();
            system.debug('errorMessage: ' + errorMessage);
            GSD_IntegrationLog intLog = new GSD_IntegrationLog(request.getEndpoint(), 'Salesforce to GSA', request.getHeader('x-api-key'), request.getBody(), String.valueOf(response.getStatusCode()), response.getBody(), errorMessage, false, recordId);
            integrationLogInsertList.add(intLog.logObject);
            insert integrationLogInsertList;
            message = 'Error: ' + ex.getMessage();
        }
        return message;
    }

    //Fetch Contacts to Deactivate when Company Deactivated
    private static List<Contact> fetchContactsToDeactivate(String recordId) {
        List<Contact> contactList = [Select Id from Contact where AccountId = :recordId];
        for (Contact cont : contactList) {
            cont.Contact_Status__c = 'Inactive';
            cont.Activate_Contact__c = false;
        }
        return contactList;
    }

    //Fetch bundleId from the response body when an account is activated as a company
    /*private Static Integer fetchBundleIdFromAccountActivation(String responseBody) {
        //system.debug('responseBody:  ' + responseBody);
        Integer bundleId;
        Map<String, Object> serializedResponseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if (serializedResponseMap.containsKey('status') && String.isNotBlank((String) serializedResponseMap.get('status')) && ((String) serializedResponseMap.get('status') == 'success') && serializedResponseMap.containsKey('data') && serializedResponseMap.get('data') != null) {
            List<Object> dataObjectList = (List<Object>) JSON.deserializeUntyped(JSON.serialize(serializedResponseMap.get('data')));
            if(!dataObjectList.isEmpty()){
                Map<String, Object> serializedDataMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(dataObjectList[0]));
                if (serializedDataMap.containsKey('bundleID') && serializedDataMap.get('bundleID') != null) {
                    bundleId = (Integer) serializedDataMap.get('bundleID');
                }
            }
            
        }
        system.debug('bundleId: ' + bundleId);
        return bundleId;
    }*/

    //fetch response status
    private Static String fetchResponseStatus(String responseBody) {
        String status;
        Map<String, Object> serializedResponseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if (serializedResponseMap.containsKey('status') && String.isNotBlank((String) serializedResponseMap.get('status')) && ((String) serializedResponseMap.get('status') == 'success')) {
            status = 'success';
        }
        return status;
    }

    //Checks if a Company has been deactivated successfully
    private static String fetchDeactivationStatus(String responseBody) {
        String status = '';
        system.debug('responseBody: : ' + responseBody);
        Map<String, Object> serializedResponseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if (serializedResponseMap.containsKey('data') && serializedResponseMap.get('data') != null) {
            Map<String, Object> serializedDataMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(serializedResponseMap.get('data')));
            if (serializedDataMap.containsKey('error') && serializedDataMap.get('error') != null) {
                status = 'Error: ' + (String) serializedDataMap.get('error');
            }
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


    //Company Activation Wrapper
    public class AccountActivateWrapper {
        public String gsCompanyID;
        public List<String> products;
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
    
    public class ResponseBody{
        public String status;	//success
        public DataObject data;    
    }
    public class DataObject {
            public WebsiteUsers website_users;
            public DataLinkUSers datalink_users;
    }
    public class WebsiteUsers {
        public List<UpdatedAttributes> updated;
    }
    public class UpdatedAttributes {
        public String gsContactID;	//1151064
        public String gsCompanyID;	//106990
    }
    public class DataLinkUSers {
        public List<ErrorsOccured> errored;
    }
    public class ErrorsOccured {
        public String gsContactID;	//1151064
        public String gsCompanyID;	//106990
        public String username;	//ramesh.koduru@gs.com
        public String error;	//Datalink Username Already Exists: ramesh.koduru@gs.com
    }
}