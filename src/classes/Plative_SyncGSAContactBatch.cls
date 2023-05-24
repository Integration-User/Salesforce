/**
* Company     : Plative
* Description : Batch class to check if Contacts have been provisioned correctly                
* History     : 
* [21.Jul.2020] Kunal - Code Creation 
*/
public class Plative_SyncGSAContactBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    
    //Columns headers for CSV file
    String csvColumnHeader = 'Contact Id,Contact Name,GSA_ID__c,SF Website Access,GSA Website Access,SF Datalink Access,GSA Datalink Access\n';
    //This list stores CSV of Contacts where discrepancy exists
    List<String> csvRowValues = new List<String>();
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        //Get Contacts
        String query = 'Select Id,Name,GSA_ID__c,Website_Access_New__c,Datalink_Access_New__c from Contact where GSA_ID__c != null AND Contact_Status__c = \'Active\'  and (NOT(Account.name like \'%Goldman Saches%\'))';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Integration_Log__c> logUpdateList = new List<Integration_Log__c>();
        GSA_Platform__c platform = GSA_Platform__c.getOrgDefaults();        
        HTTP http = new HTTP();
        HttpRequest request = new HttpRequest();
        HttpResponse response;
        request.setHeader('x-api-key',platform.API_Key__c);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setMethod('GET');
        
        for(Contact contact: scope){
            String endpoint = platform.User_Get_Info__c.replace('{!gsaId}',contact.GSA_ID__c);
            Boolean gsaWebsiteAccess = false;
            Boolean datalinkAccess = false;
            String row = contact.Id + ',' + contact.Name + ',' + contact.GSA_ID__c + ',';
            
            //Check for Website provisioning
            try{
                request.setEndpoint(endpoint);
                response = new HttpResponse();
                response = Http.send(request);
                system.debug('response.getBody(): ' + response.getBody());
                if ((response.getStatusCode() == 200 || response.getStatusCode() == 201) && String.isNotBlank(response.getBody())) {
                    String responseBody = response.getBody();
                    //Parse response body
                    Map<String, Object> serializedResponseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                    //Get Status
                    if(serializedResponseMap.containsKey('status') && serializedResponseMap.get('status') == 'success'){
                        //Get data
                        if(serializedResponseMap.containsKey('data') && serializedResponseMap.get('data') != null){
                            List<Object> objectList = (List<Object>) JSON.deserializeUntyped(JSON.serialize(serializedResponseMap.get('data')));
                            
                            for(Object obj: objectList){
                                //If visible equals t means website user exists!
                                Map<String,Object> objectMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(obj));
                                if(objectMap.containsKey('visible') && (String)objectMap.get('visible') == 't'){
                                    gsaWebsiteAccess = true;
                                    break;
                                }
                            }
                        }
                    } else {
                        if(responseBody.contains('No user found')){
                            gsaWebsiteAccess = false;
                        } else {
                            //Log error
                            GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Contact Sync Comparison','','', String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false,contact.Id);
                            logUpdateList.add(intLog.logObject);
                        }
                        
                    }
                } else {
                    //Log error
                    GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Contact Sync Comparison','','', String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false,contact.Id);
                    logUpdateList.add(intLog.logObject);
                }
            } catch(Exception ex){
                String message = 'In Apex class Plative_SyncGSAContactBatch. At line number: ' + ex.getLineNumber() + '. Cause: ' + ex.getCause() + '. Message: ' + ex.getMessage();
                system.debug('message: ' + message);
                GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Contact Sync Comparison','','', String.valueOf(response.getStatusCode()), response.getBody(), message, false,contact.Id);
                logUpdateList.add(intLog.logObject);
            }
            
            
            //Check for Datalink provisioning
            endpoint = platform.User_Get_Datalink_User_Info__c.replace('{!gsaId}',contact.GSA_ID__c);
            try{
                request.setEndpoint(endpoint);
                response = new HttpResponse();
                response = Http.send(request);
                system.debug('response.getBody(): ' + response.getBody());
                if ((response.getStatusCode() == 200 || response.getStatusCode() == 201) && String.isNotBlank(response.getBody())) {
                    //User exists 
                    datalinkAccess = true;                
                } else {
                    //User doesn't exist
                    datalinkAccess = false;
                }
            } catch(Exception ex){
                String message = 'In Apex class Plative_SyncGSAContactBatch. At line number: ' + ex.getLineNumber() + '. Cause: ' + ex.getCause() + '. Message: ' + ex.getMessage();
                system.debug('message: ' + message);
                GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Contact Sync Comparison','','', String.valueOf(response.getStatusCode()), response.getBody(), message, false,contact.Id);
                logUpdateList.add(intLog.logObject);
            }
            
            row += String.valueOf(contact.Website_Access_New__c) + ',' + String.valueOf(gsaWebsiteAccess) + ',' + String.valueOf(contact.Datalink_Access_New__c) + ',' + String.valueOf(datalinkAccess);
            //Add to excel only if discrepany exists
            if((contact.Website_Access_New__c != gsaWebsiteAccess) || contact.Datalink_Access_New__c != datalinkAccess){
                csvRowValues.add(row);
            }
            
        }
        
        //Insert error logs
        insert logUpdateList;
        
    }   
    
    public void finish(Database.BatchableContext BC) {
        GSA_Platform__c orgDefaults = GSA_Platform__c.getOrgDefaults();
        if(!csvRowValues.isEmpty()){
            //Join CSV header and rows
            String csvFile = csvColumnHeader  + String.join(csvRowValues,'\n');
            //Create Final Integration Log
            GSD_IntegrationLog intLog = new GSD_IntegrationLog('', 'Contact Sync Comparison Result','','', '','','',true,null);
            insert intLog.logObject;
            
            //Create File for tracking
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S';
            conVer.Title = 'Contact Sync Comparison ' + System.today().format();
            conVer.PathOnClient = conVer.Title + '.csv';
            conVer.VersionData = Blob.valueOf(csvFile);
            insert conVer;
            
            //Associate file with the integration record
            // First get the Content Document Id from ContentVersion Object
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
            
            //Create file and record association
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = intLog.logObject.Id;
            conDocLink.ContentDocumentId = conDoc;
            conDocLink.ShareType = 'V';
            insert conDocLink;
            
            //Create SingleEmailMessage
            EmailTemplate emailTemplate = [Select Id,HtmlValue,Subject,Body from EmailTemplate where DeveloperName = 'GSA_Contact_Comparison' LIMIT 1];
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject(emailTemplate.subject);
            email.setHtmlBody(emailTemplate.HtmlValue);
            email.setPlainTextBody(emailTemplate.HtmlValue.stripHtmlTags());
            email.setToAddresses(new List<String>{orgDefaults.Batch_Sync_Email__c});
            email.setSaveAsActivity(true);
            
            //Create Email Attachment
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(conVer.PathOnClient);
            efa.setBody(conVer.VersionData);
            efa.setContentType('application/vnd.ms-excel');
            email.setFileAttachments(new List<Messaging.EmailFileAttachment>{efa});
            
            //Send Email
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
        }
        
        
    }
    
}