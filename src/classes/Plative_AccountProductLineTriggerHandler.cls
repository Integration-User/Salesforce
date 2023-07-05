/**
* Created by Kunal Jain on 29-04-2020.
*/

public without sharing class Plative_AccountProductLineTriggerHandler {
    
    public static boolean firstRun = false;
    //Call on After Insert
    public static void afterInsert(List<Account_Product_Line__c> triggerNew){
        Plative_AccountProductLineTriggerHelper.addEmailDistributions(triggerNew);
    }
    
    public static void updateProductLineOnPlatform(List<Account_Product_Line__c> triggerNew) {
        firstRun = true;
        Set<Id> accountIdSet = new Set<Id>();
        for (Account_Product_Line__c productLine : triggerNew) {
            accountIdSet.add(productLine.Account__c);
        }
        
        Map<Id, Account> accountMap = new Map<Id,Account>([Select Id from Account where Id IN :accountIdSet AND Account_Status__c = 'Active']);
        
        if (!accountMap.isEmpty()) {
            System.enqueueJob(new Plative_UpdateProductLineQueueable(accountMap.keySet()));
        }
    } 

    // Method is to update the product on Account and Contact once they have deleted from Account Product Line object
    public static void updateProductInAccountContact(List<Account_Product_Line__c> triggerNew){
        
        Account account = [SELECT id, Current_Products__c
                            FROM Account where id =: triggerNew[0].Account__c];

        for(Account_Product_Line__c productLine : triggerNew){
            if(account.Current_Products__c != null && account.Current_Products__c.contains(productLine.Name)){
                String prodName = account.Current_Products__c.replace(productLine.Name, '');
                account.Current_Products__c = prodName;
                account.Is_Contact_Update__c = true;
            }
        }

        update account;
        Database.executeBatch(new Batch_UpdateContactCurrentProduct(),50); 
    }
    
    
}