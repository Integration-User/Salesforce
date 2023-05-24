/**
* Created by Kunal Jain on 29-04-2020.
*/

public without sharing class Plative_UpdateProductLineQueueable implements Queueable, Database.AllowsCallouts {
    
    Set<Id> accountIdSetToProcess = new Set<Id>();
    Map<Id,List<String>> accountIdVsProductLinesMap = new Map<Id,List<String>>();
    Map<Id,String> accountIdVsGSAId = new Map<Id,String>();
    public Plative_UpdateProductLineQueueable(Set<Id> accountIdSet){
        
        Set<Id> accountIdSetToQueue = new Set<Id>();
        Map<Id,Account> mapAccounts = new Map<Id,Account>([Select id, GSA_ID__c From Account where id in: accountIdSet]);
        if(accountIdSet.size() <= 100){
            accountIdSetToProcess.addAll(accountIdSet);
        } else {
            Integer count = 0;
            for(Id accntId: accountIdSet){
                if (count <= 99) { accountIdSetToProcess.add(accntId); }
                else { accountIdSetToQueue.add(accntId); }
                count++;
            }
        }
        
        if(!accountIdSetToQueue.isEmpty()){
            System.enqueueJob(new Plative_UpdateProductLineQueueable(accountIdSetToQueue));
        }
        
        
        List<Account_Product_Line__c> productLineList = [Select Account__c,Product__r.Name,Product__r.Website_Product__c,Account__r.GSA_ID__c from Account_Product_Line__c where Account__c IN :accountIdSetToProcess];
        for(Account_Product_Line__c productLine: productLineList){
            if(!accountIdVsProductLinesMap.containsKey(productLine.Account__c)){
                accountIdVsProductLinesMap.put(productLine.Account__c, new List<String>());
            }            
            accountIdVsProductLinesMap.get(productLine.Account__c).add(productLine.Product__r.Website_Product__c);
            accountIdVsGSAId.put(productLine.Account__c,productLine.Account__r.GSA_ID__c);
        }
        for(Id accId : accountIdSet){
            if(!accountIdVsProductLinesMap.containskey(accId)){
                accountIdVsProductLinesMap.put(accId, new List<String>());
                accountIdVsGSAId.put(accId,mapAccounts.get(accId).GSA_ID__c);
            }
        }
    }
    
    public void execute(QueueableContext context) {
        GSA_Platform__c setting = GSA_Platform__c.getOrgDefaults();
        List<Integration_Log__c > integrationLogInsertList = new List<Integration_Log__c>();       
        //String endpoint = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1' + '/companies/edit';
        String endpoint = setting.Company_Edit__c;
        system.debug('endpoint: ' + endpoint);
        for(Id accntId: accountIdSetToProcess){
            
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();            
            request.setHeader('x-api-key', setting.API_Key__c);
            Http http = new Http();
            try{
                //Create payload for activating account using AccountActivateWrapper
                AccountActivateWrapper accntWrap = new AccountActivateWrapper();
                accntWrap.gsCompanyID  = accountIdVsGSAId.get(accntId);
                accntWrap.products = accountIdVsProductLinesMap.containsKey(accntId) ? accountIdVsProductLinesMap.get(accntId) : new List<String>();
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
                
                response = Http.send(request);
                system.debug('response: ' + response.getStatusCode());
                system.debug('response: ' + response.getBody());
                if ((response.getStatusCode() == 200 || response.getStatusCode() == 201) && String.isNotBlank(response.getBody())) {
                    if (fetchResponseStatus(response.getBody()) == 'success') {
                        GSD_IntegrationLog intLog = new GSD_IntegrationLog(request.getEndpoint(), 'Salesforce to GSA Product Line Update', request.getHeader('x-api-key'), request.getBody(), String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), true,'');
                        integrationLogInsertList.add(intLog.logObject);    
                    } else {
                        GSD_IntegrationLog intLog = new GSD_IntegrationLog(request.getEndpoint(), 'Salesforce to GSA Product Line Update', request.getHeader('x-api-key'), request.getBody(), String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false,'');
                        integrationLogInsertList.add(intLog.logObject);
                    }
                    
                } else {
                    GSD_IntegrationLog intLog = new GSD_IntegrationLog(request.getEndpoint(), 'Salesforce to GSA Product Line Update', request.getHeader('x-api-key'), request.getBody(), String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false,'');
                    integrationLogInsertList.add(intLog.logObject);
                }
                
            } catch(Exception ex){
                System.debug('In Apex class clsName. ' + 'At line number: ' + ex.getLineNumber() + '. Cause: ' + ex.getCause() + '. Message: ' + ex.getMessage());
                GSD_IntegrationLog intLog = new GSD_IntegrationLog(request.getEndpoint(), 'Salesforce to GSA Product Line Update', request.getHeader('x-api-key'), request.getBody(), String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false,'');
                integrationLogInsertList.add(intLog.logObject);
            }
        }
        
        if(!integrationLogInsertList.isEmpty()){
            insert integrationLogInsertList;
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
    
    //Company Activation Wrapper
    public class AccountActivateWrapper {
        public String gsCompanyID;
        public List<String> products;
    }
    
}