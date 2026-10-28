/**
* Company     : Plative
* Description : Controller class for Plative_AddProductLine
* History     : 
* [30.Apr.2020] Kunal - Code Creation 
*/

public class Plative_AddProductLineCtrl {
    
    //Get DataLink & Website access details
    @AuraEnabled
    public static Account getAccountDetails(String recordId){
        Account accnt = new Account();
        accnt = [Select Id,DataLink_Access__c,Website_Access__c from Account where Id = :recordId];
        return accnt;
    }
    
    @AuraEnabled
    public static String saveAccountAccessDetails(Account accnt){
        String response = '';
        try{
            Account accntToUpdate = accnt;
            update accntToUpdate;
            response = 'Success!';            
        } catch(DMLException ex){
            response = 'Error: ' + ex.getDmlMessage(0);
        }
        
        return response;
    }
    
    //Method to get Product records
    @AuraEnabled
    public static List<Product2> getProducts(String recordId){
        List<Product2> productList = [Select Id,Name,Description from Product2 where IsActive=true AND Product_Line__c=true];
        return productList;
    }
    
    //Method to get Product Line records related to Account Id
    @AuraEnabled
    public static List<Account_Product_Line__c> getProductLines(String recordId){
        List<Account_Product_Line__c> productLines = [Select Id,Product__c,Product__r.Name,Start_Date__c,End_Date__c, Trial__c
                                                      from Account_Product_Line__c
                                                      where Account__c = :recordId];
        return productLines;
    }
    
    
    //Method to Upsert Account Product Lines
    @AuraEnabled
    public static String saveProductLines(String recordId, List<Account_Product_Line__c> newProductLines){
        
        String response = '';
        Savepoint sp;
        if(!Test.isRunningTest()) { sp = Database.setSavepoint(); }
        List<Account_Product_Line__c> productLinesToUpsert = new List<Account_Product_Line__c>();
        List<Account_Product_Line__c> productLinesToDelete = new List<Account_Product_Line__c>();
        
        //Get existing Product Lines
        List<Account_Product_Line__c> existingProductLines = [Select Id,Account__c,Product__c,Product__r.Name,Start_Date__c,End_Date__c 
                                                              from Account_Product_Line__c
                                                              where Account__c = :recordId];
        try{
            if(newProductLines.isEmpty()){
                //If new product lines are empty and existing product lines are found then
                //existing product lines are to be deleted
                if(!existingProductLines.isEmpty()){
                    productLinesToDelete.addAll(existingProductLines);
                } 
            } else {
                //If existing product lines are empty then the new ones to be simply inserted
                if(existingProductLines.isEmpty()){
                    for(Account_Product_Line__c productLine: newProductLines){
                        Account_Product_Line__c newProductLine = new Account_Product_Line__c();
                        newProductLine.Product__c = productLine.Product__c;
                        newProductLine.Start_Date__c = productLine.Start_Date__c;
                        newProductLine.End_Date__c = productLine.End_Date__c;
                        newProductLine.Account__c = recordId;
                        newProductLine.Trial__c  = productLine.Trial__c;
                        productLinesToUpsert.add(newProductLine);
                    }
                }                 
                //If there are new product lines and existing product lines then compare to upsert and delete
                else {
                    //Instantiate new product lines
                    for(Account_Product_Line__c productLine: newProductLines){
                        Account_Product_Line__c newProductLine = new Account_Product_Line__c();
                        newProductLine.Product__c = productLine.Product__c;
                        newProductLine.Start_Date__c = productLine.Start_Date__c;
                        newProductLine.End_Date__c = productLine.End_Date__c;
                        newProductLine.Account__c = recordId;
                        newProductLine.Trial__c  = productLine.Trial__c;
                        productLinesToUpsert.add(newProductLine);
                    }
                    
                    //Compare existing products with new product lines that are to be upserted.
                    for(Account_Product_Line__c existingProductLine: existingProductLines){
                        Boolean existingProductLineToBeRemoved = true;
                        for(Account_Product_Line__c newProductLine: productLinesToUpsert){
                            if(existingProductLine.Product__c == newProductLine.Product__c){
                                newProductLine.Id = existingProductLine.Id;
                                existingProductLineToBeRemoved = false;
                                break;
                            } 
                        }
                        
                        //If existing product is not found in the new list then product line is to be deleted
                        if(existingProductLineToBeRemoved){
                            productLinesToDelete.add(existingProductLine);
                        }
                    }
                }
            }
            
            //delete product lines
            if(!productLinesToDelete.isEmpty()){
                delete productLinesToDelete;
            }
            
            //upsert product lines
            if(!productLinesToUpsert.isEmpty()){
                upsert productLinesToUpsert;
            }
            
            response = 'Account Product Lines saved successfully! & ' + System.Label.Email_Distribution_Message;
            
        } catch(DMLException ex){
            if(!Test.isRunningTest()) { Database.rollback(sp); } 
            response = 'Error: ' + ex.getDmlMessage(0);
        }
        return response;
    }
    
}