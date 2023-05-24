/**
* Company     : Plative
* Description : Batch class to compare Account Product Lines & GSA Website Products for a Company
*               If products don't match an email is sent to a specified email address in the 
*               custom setting              
* History     : 
* [16.Jul.2020] Kunal - Code Creation 
*/
public class Plative_SyncGSAWebsiteSubscriptionBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    //Columns headers for CSV file
    String csvColumnHeader = 'Account Id,Account Name,GSA_ID__c,Products on Salesforce,Products on Website\n';
    //This list stores CSV of Accounts where discrepancy exists
    List<String> csvRowValues = new List<String>();
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        //Get all accounts where GSA_ID__c not null and Account Status equals active
        String query = 'Select Id,Name,GSA_ID__c,(Select Id,Product__r.Name,Product__r.Website_Product__c from Account_Product_Lines__r where Product__c != null) from Account where GSA_ID__c != null AND Account_Status__c = \'Active\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Integration_Log__c> logUpdateList = new List<Integration_Log__c>();
        GSA_Platform__c platform = GSA_Platform__c.getOrgDefaults();        
        HTTP http = new HTTP();
        HttpRequest request = new HttpRequest();
        HttpResponse response;
        request.setHeader('x-api-key',platform.API_Key__c);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setMethod('GET');
        
        for(Account accnt: scope){
            String endpoint = platform.Account_Get_Web_Bundle__c.replace('{!gsaId}',accnt.GSA_ID__c);
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
                            Map<String,Object> serializedDataMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(serializedResponseMap.get('data')));
                            //Get Products
                            if(serializedDataMap.containsKey('products') && serializedDataMap.get('products') != null){
                                //Get Account related Products from Web bundle
                                List<Object> responseObjectList = (List<Object>)serializedDataMap.get('products');
                                Set<String> responseProducts = new Set<String>();
                                for(Object obj: responseObjectList){
                                    // SR-417- Remove US/EUR Sales Comps from Website side of report
                                    if(String.valueOf(obj) != 'US Sales Comps' && String.valueOf(obj) != 'EUR Sales Comps') 
                                    responseProducts.add(String.valueOf(obj));
                                }
                                //Get Products related to Account
                                Set<String> accountProducts = new Set<String>();
                                if(!accnt.Account_Product_Lines__r.isEmpty()){
                                    for(Account_Product_Line__c accntProductLine: accnt.Account_Product_Lines__r){
                                        accountProducts.add(accntProductLine.Product__r.Website_Product__c);
                                    }
                                }
                                
                                //Compare. If not equal then add them to the excel sheet
                                if(responseProducts != accountProducts){
                                    system.debug('false');
                                    List<String> responseProductList = new List<String>();
                                    responseProductList.addAll(responseProducts);
                                    List<String> accountProductList = new List<String>();
                                    accountProductList.addAll(accountProducts);
                                    String modifiedAccName = accnt.Name.replaceall(',','');
                                    String row = accnt.Id + ',' + modifiedAccName + ',' + accnt.GSA_ID__c + ',' + String.join(accountProductList,';') + ',' + String.join(responseProductList,';');
                                    csvRowValues.add(row);
                                } 
                            } else {
                                //Log error
                                GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Get Company Web Bundle(Products)','','', String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false,accnt.Id);
                                logUpdateList.add(intLog.logObject);
                            }
                            
                        }
                    } else {
                        //Log error
                        GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Get Company Web Bundle(Products)','','', String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false,accnt.Id);
                        logUpdateList.add(intLog.logObject);
                    }
                } else {
                    //Log error
                    GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Get Company Web Bundle(Products)','','', String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false,accnt.Id);
                    logUpdateList.add(intLog.logObject);
                }
            } catch(Exception ex){
                String message = 'In Apex class Plative_SyncGSAWebsiteSubscriptionBatch. At line number: ' + ex.getLineNumber() + '. Cause: ' + ex.getCause() + '. Message: ' + ex.getMessage();
                system.debug('message: ' + message);
                GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Get Company Web Bundle(Products)','','', String.valueOf(response.getStatusCode()), response.getBody(), message, false,accnt.Id);
                logUpdateList.add(intLog.logObject);
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
            GSD_IntegrationLog intLog = new GSD_IntegrationLog('', 'Product Sync Comparison','','', '','','',true,null);
            insert intLog.logObject;
            
            //Create File for tracking
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S';
            conVer.Title = 'Product Sync Comparison ' + System.today().format();
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
            EmailTemplate emailTemplate = [Select Id,HtmlValue,Subject,Body from EmailTemplate where DeveloperName = 'GSA_Product_Comparison' LIMIT 1];
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