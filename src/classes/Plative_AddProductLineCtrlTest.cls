/**
* Company     : Plative
* Description : Test class for Plative_AddProductLineCtrl
* History     : 
* [04.May.2020] Kunal - Code Creation 
*/

@isTest
public class Plative_AddProductLineCtrlTest {

    @testSetup
    static void testSetup(){   
        
         GSA_Platform__c platform = GSA_Platform__c.getOrgDefaults();  
        //Company
        platform.Company_Activation__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/companies/activate';
        platform.Company_Deactivation__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/companies/';
        platform.Update_Downloads__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/companies/update_num_downloads';
        //User
        platform.User_Activation__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/users/activate';
        platform.User_Deactivation__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/companies/';
        platform.User_Password_Reset__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/users/';
        platform.Clear_Token__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/users/datalink/';
        platform.Update_Token__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/users/datalink/';
        Platform.User_Get_Last_Login__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/users/{!gsaId}/last_login';
        //API Key
        platform.API_Key__c = 'SAL3sf0rc3_AP1';
        insert platform;
        
        Account accnt = new Account();
        accnt.Name = 'Test Account';
        accnt.Account_Status__c = 'Active';        
        insert accnt;
        
        Contact cont = new Contact();
        cont.AccountId = accnt.Id;
        cont.FirstName = 'FName';
        cont.LastName = 'LName';
        cont.Email = 'test@email.com';
        cont.Phone = '9876543210'; 
        cont.Contact_Status__c = 'Active';
        insert cont;
        
        Product2 product = new Product2();
        product.Name = Label.TestClass_ProductName;
        product.IsActive = true;
        product.Product_Line__c = true;
        insert product;
        
        Product2 product2 = new Product2();
        product2.Name = 'Pan-European Research + Market Data & Deals';
        product2.IsActive = true;
        product2.Product_Line__c = true;
        insert product2;
    }
    
    @isTest
    static void getProductsTest(){
        Id accntId = [Select Id from Account LIMIT 1].Id;
        Test.startTest();
        List<Product2> productList = Plative_AddProductLineCtrl.getProducts(accntId);
        System.assertEquals(2, productList.size());
        Test.stopTest();
    }
    
    
    @isTest
    static void getProductLinesTest(){
        Test.setMock(HttpCalloutMock.class, new Plative_GSAWebCalloutMock());  
        Id accntId = [Select Id from Account LIMIT 1].Id;
        Account_Product_Line__c productLine = new Account_Product_Line__c();
        productLine.Account__c = accntId;
        productLine.Product__c = [Select Id from Product2 where Name =: Label.TestClass_ProductName LIMIT 1].Id;
        insert productLine; 
        
        Test.startTest();
        List<Account_Product_Line__c> productLineList = Plative_AddProductLineCtrl.getProductLines(accntId);
        System.assertEquals(1, productLineList.size());
        Test.stopTest();
    }
    
    
    @isTest
    static void saveProductLinesWithNewProductLinesEmpty(){
        Test.setMock(HttpCalloutMock.class, new Plative_GSAWebCalloutMock());  
        Id accntId = [Select Id from Account LIMIT 1].Id;
        Account_Product_Line__c productLine = new Account_Product_Line__c();
        productLine.Account__c = accntId;
        productLine.Product__c = [Select Id from Product2 where Name =: Label.TestClass_ProductName LIMIT 1].Id;
        insert productLine; 
        
        String message = 'Account Product Lines saved successfully!';
        Test.startTest();
        String response = Plative_AddProductLineCtrl.saveProductLines(accntId, new List<Account_Product_Line__c>());
        System.assertEquals(message,response);
        delete [select id from Account_Product_Line__c];        
        Test.stopTest();
    }
    
    @isTest
    static void saveProductLinesWithExistingProductLinesEmpty(){
        Test.setMock(HttpCalloutMock.class, new Plative_GSAWebCalloutMock());  
        Id accntId = [Select Id from Account LIMIT 1].Id;
        Id productId = [Select Id from Product2 LIMIT 1].Id;
        String message = 'Account Product Lines saved successfully!';        
        Test.startTest();
        String response = Plative_AddProductLineCtrl.saveProductLines(accntId, new List<Account_Product_Line__c>{new Account_Product_Line__c(Product__c=productId,Account__c=accntId)});
        System.assertEquals(message,response);
        Test.stopTest();
    }
    
    
    @isTest
    static void saveProductLinesWithUpsert(){
        Test.setMock(HttpCalloutMock.class, new Plative_GSAWebCalloutMock());  
        List<Account_Product_Line__c> accntProductLineInsert = new List<Account_Product_Line__c>();
        Id accntId = [Select Id from Account LIMIT 1].Id;
        for(Product2 product: [Select Id from Product2 where IsActive=true AND Product_Line__c=true]){
            Account_Product_Line__c prodLine = new Account_Product_Line__c();
            prodLine.Account__c = accntId;
            prodLine.Product__c = product.Id;
            accntProductLineInsert.add(prodLine);
        }
        insert accntProductLineInsert;
        String message = 'Account Product Lines saved successfully!'; 
        Test.startTest();
        String response = Plative_AddProductLineCtrl.saveProductLines(accntId, new List<Account_Product_Line__c>{accntProductLineInsert[0]});
        System.assertEquals(message,response);
        Test.stopTest();        
    }
    
    
    @isTest
    static void getAccountDetails(){
        Id recordId = [Select Id from Account LIMIT 1].Id;
        Test.startTest();
        Plative_AddProductLineCtrl.getAccountDetails(recordId);
        Test.stopTest();
    }
    
    @isTest
    static void saveAccountAccessDetails(){
        Id recordId = [Select Id from Account LIMIT 1].Id;
        Account accnt = new Account();
        accnt.DataLink_Access__c = true;
        accnt.Website_Access__c = false;
        accnt.Id = recordId;
        Test.startTest();
        Plative_AddProductLineCtrl.saveAccountAccessDetails(accnt);
        Test.stopTest();
    }
    
    @isTest
    static void saveAccountAccessDetailsException(){
        Id recordId = [Select Id from Account LIMIT 1].Id;
        Account accnt = new Account();
        accnt.DataLink_Access__c = true;
        accnt.Website_Access__c = false;
        Test.startTest();
        Plative_AddProductLineCtrl.saveAccountAccessDetails(accnt);
        Test.stopTest();
    }
    
    
    
}