/**
* Company      : Plative
* Description  : Queueable class for Bulk-Deactivation of User
* History      :
* 3rd June,2020: Kunal - Code Creation
*/
public class Plative_DeActivateUserQueueable implements Queueable,Database.AllowsCallouts {
    
    Set<Id> contactIdToProcess = new Set<Id>();
    
    public Plative_DeActivateUserQueueable(Set<Id> contactIdSet){
        
        if(contactIdSet.size() <= 100){
            contactIdToProcess.addAll(contactIdSet);            
        } else {
            Set<Id> contactIdToQueue = new Set<Id>(); Integer count = 0;            
            for(Id contactId: contactIdSet){
                if(count <= 99){ contactIdToProcess.add(contactId); } 
                else { contactIdToQueue.add(contactId); }
                count++;
            }
            
            if(!contactIdToQueue.isEmpty()){ System.enqueueJob(new Plative_DeActivateUserQueueable(contactIdToQueue)); }
        }
    }
    
    
    
    public void execute(QueueableContext context) {
        //Contact Id Set for Removal of Email Distributions
        Set<Id> contactIdSetForEDRemoval = new Set<Id>();
        //Contact Update List
        List<Contact> contactsToUpdate = new List<Contact>();
        //Integration Log insert list
        List<Integration_Log__c > integrationLogInsertList = new List<Integration_Log__c>();   
        
        List<Contact> contactList = [Select Id,GSA_ID__c,Datalink_Access_New__c,Website_Access_New__c from Contact where Id IN :contactIdToProcess AND Account.Account_Status__c = 'Active'];
        GSA_Platform__c platform = GSA_Platform__c.getOrgDefaults();
        //String endpoint = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/users/contactId/deactivate';
        Http http = new Http();
        HttpRequest request = new HttpRequest();        
        request.setMethod('PUT');
        request.setHeader('Accept', 'application/json');
        request.setHeader('x-api-key', platform.API_Key__c);            
        
        for(Contact contact: contactList){
            HttpResponse response = new HttpResponse();
            try{                
                String endpoint = platform.User_Deactivation__c + contact.GSA_ID__c + '/deactivate';
                system.debug('endpoint: ' + endpoint);
                request.setEndpoint(endpoint);
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                if(contact.Datalink_Access_New__c){
                    gen.writeBooleanField('datalink_only',false);
                } 
                if(contact.Website_Access_New__c){
                    gen.writeBooleanField('website_only',false);
                } 
                gen.writeEndObject();
                //String reqBody = gen.getAsString();
                //system.debug('reqBody: ' + reqBody);
                //request.setBody(reqBody);
                response = Http.send(request);
                system.debug('response : ' + response.getStatus());
                system.debug('response : ' + response.getStatusCode());
                system.debug('response : ' + response.getBody());
                if ((response.getStatusCode() == 200 || response.getStatusCode() == 201) && String.isNotBlank(response.getBody()) && !response.getBody().contains('error')) {
                    if (fetchResponseStatus(response.getBody()) == 'success') {
                        contact.Contact_Status__c = 'Inactive';
                        contact.Deactivation_Date__c = System.today();
                        contactsToUpdate.add(contact);
                        contactIdSetForEDRemoval.add(contact.Id);
                    } else{ //Log error
                        GSD_IntegrationLog intLog = new GSD_IntegrationLog(request.getEndpoint(), 'Salesforce to GSA Deactivate User', request.getHeader('x-api-key'), request.getBody(), String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false, ''); integrationLogInsertList.add(intLog.logObject); }
                    
                } else { //Log Error
                    GSD_IntegrationLog intLog = new GSD_IntegrationLog(request.getEndpoint(), 'Salesforce to GSA Deactivate User', request.getHeader('x-api-key'), request.getBody(), String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false,''); integrationLogInsertList.add(intLog.logObject); }
            } catch(Exception ex){
                String errorMessage = 'In Apex class Plative_DeActivateUserQueueable. ' + 'At line number: ' + ex.getLineNumber() + '. Cause: ' + ex.getCause() + '. Message: ' + ex.getMessage(); GSD_IntegrationLog intLog = new GSD_IntegrationLog(request.getEndpoint(), 'Salesforce to GSA Deactivate User', request.getHeader('x-api-key'), request.getBody(), String.valueOf(response.getStatusCode()), response.getBody(), errorMessage, false, ''); integrationLogInsertList.add(intLog.logObject); 
            }            
        }
        
        if(!integrationLogInsertList.isEmpty()){
            insert integrationLogInsertList;
        }
        
        if(!contactsToUpdate.isEmpty()){
            update contactsToUpdate;
        }
        
        if(!contactIdSetForEDRemoval.isEmpty()){
            Plative_ContactTriggerHelper.removeEmailDistributions(contactIdSetForEDRemoval);
        }
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
    
}