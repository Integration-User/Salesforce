/**
* Company     : Plative
* Description :  Controller class for Plative_EmailDistributionLtng aura component
* History     : 
* [13.May.2020] Kunal - Code Creation 
*/
public class Plative_EmailDistributionCtrl { 
    
    //Checks whether the account is active or not
    @AuraEnabled
    public static String getAccountStatus(String recordId){
        String response = '';
        response = [Select Id,Account_Status__c from Account where Id = :recordId].Account_Status__c;
        return response;        
    }
    
    //Get Email Distributions 
    @AuraEnabled 
    public static List<Object> getEmailDistributionList(String recordId){
        List<Object> objectList = new List<Object>();
        //Get Account Product Lines
        List<Account_Product_Line__c> accountProductLines = [Select Id,Product__r.Name from Account_Product_Line__c where Account__c = :recordId];
        Set<String> subscriptionNameSet = new Set<String>();
        for(Account_Product_Line__c productLine: accountProductLines){
            subscriptionNameSet.add(productLine.Product__r.Name);
        }
   
        //Get Email Distributions from Subscriptions
        List<Email_Distribution__c> emailDistributions = [SELECT Id,Name FROM Email_Distribution__c WHERE Subscription__c IN: subscriptionNameSet ORDER BY Order_of_Email_DL_s__c DESC NULLS LAST];// "Order_of_Email_DL_s__c DESC NULLS LAST" added by vimal on 10-feb-2022   
        objectList.add(emailDistributions);
       
        //Get Related Email Distributions
        List<Account_Email_Distribution__c> accntEmailDistribution = [Select Id,Email_Distribution__c from Account_Email_Distribution__c where Account__c = :recordId ORDER BY Name ASC]; 
        objectList.add(accntEmailDistribution);

        return objectList;     
    }
    
    //Save Email Distributions
    @AuraEnabled
    public static String saveEmailDistribution(String recordId, List<String> emailDistributionList){
        String response = '';
        try{
            List<Account_Email_Distribution__c> upsertList = new List<Account_Email_Distribution__c>();
            List<Account_Email_Distribution__c> deleteList = new List<Account_Email_Distribution__c>();
            //Get Related Email Distributions
            List<Account_Email_Distribution__c> accntEmailDistributions = [Select Id,Email_Distribution__c from Account_Email_Distribution__c where Account__c = :recordId];
            if(emailDistributionList.isEmpty()){
                if(!accntEmailDistributions.isEmpty()){
                    delete accntEmailDistributions;
                }
            } else {
                if(accntEmailDistributions.isEmpty()){
                    //Create new email distributions
                    for(String emailDistribution: emailDistributionList){
                        Account_Email_Distribution__c accntEmailDistribution = new Account_Email_Distribution__c();
                        accntEmailDistribution.Account__c = recordId;
                        accntEmailDistribution.Email_Distribution__c = emailDistribution;
                        upsertList.add(accntEmailDistribution);
                    }
                } else {
                    //Create new email distributions
                    for(String emailDistribution: emailDistributionList){
                        Account_Email_Distribution__c accntEmailDistribution = new Account_Email_Distribution__c();
                        accntEmailDistribution.Account__c = recordId;
                        accntEmailDistribution.Email_Distribution__c = emailDistribution;
                        upsertList.add(accntEmailDistribution);
                    }
                    
                    //Compare existing and new email distributions to add and remove
                    for(Account_Email_Distribution__c existingEmailDistribution: accntEmailDistributions){
                        Boolean emailDistributionToBeRemoved = true;
                        for(Account_Email_Distribution__c accntEmailDistribution: upsertList){
                            if(existingEmailDistribution.Email_Distribution__c == accntEmailDistribution.Email_Distribution__c){
                                accntEmailDistribution.Id = existingEmailDistribution.Id;
                                emailDistributionToBeRemoved = false;
                                break;
                            }
                        }
                        
                        if(emailDistributionToBeRemoved){
                            deleteList.add(existingEmailDistribution);
                        }
                    }
                }
            }
            
            //Delete Email Distributions
            delete deleteList;
            //Insert Email Distributions
            //SF-798 - Bulkify Email Distro assignment upon Product Addition
            //upsert upsertList;
            if(upsertList.size() > 0){
                database.executeBatch(new AccountEmailDistributionInsertBatch(upsertList), 10); // Calling batch class.
            }
            response = System.Label.Email_Distribution_Message;
        } catch(DMLException ex){
            response = ex.getDmlMessage(0);
        }
        return response;
    }



}