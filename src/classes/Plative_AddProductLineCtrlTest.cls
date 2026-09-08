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

    private static User createSalesDevelopmentUser() {
        User salesDevelopmentUser = new User(
            FirstName = 'Sales',
            LastName = 'Development',
            Alias = 'sdev',
            Email = 'sales.development@example.com',
            Username = 'sales.development.@example.com',
            ProfileId = UserInfo.getProfileId(),
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Department = 'Sales Development'
        );
        insert salesDevelopmentUser;
        return salesDevelopmentUser;
    }

    @isTest
    static void getProductsRequiresTrialOpportunityForSalesDevelopment() {
        User salesDevelopmentUser = createSalesDevelopmentUser();
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        String expectedMessage = 'In order to add GSN Trial Products we require an Opportunity with Trial Start date, Trial End date in the future and Trial Type';

        System.runAs(salesDevelopmentUser) {
            Test.startTest();
            try {
                Plative_AddProductLineCtrl.getProducts(accountId);
                System.assert(false, 'Expected a validation error for an account without a qualifying Opportunity.');
            } catch (AuraHandledException exceptionThrown) {
            }
            Test.stopTest();
        }
    }

    @isTest
    static void getProductsReturnsGsnProductsForSalesDevelopment() {
        User salesDevelopmentUser = createSalesDevelopmentUser();
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        String trialType = 'Test';
        List<Schema.PicklistEntry> trialTypeValues = Opportunity.Trial_Type__c.getDescribe().getPicklistValues();
        if (!trialTypeValues.isEmpty()) {
            trialType = trialTypeValues[0].getValue();
        }
        insert new Opportunity(
            Name = 'Qualifying Trial Opportunity',
            AccountId = accountId,
            CloseDate = Date.today().addDays(30),
            StageName = 'Prospecting',
            Trial_Start_Date__c = Date.today(),
            Trial_End_Date__c = Date.today().addDays(30),
            Trial_Type__c = trialType
        );

        insert new Product2(
            Name = 'Green Street News: Europe',
            IsActive = true,
            Product_Line__c = true
        );

        System.runAs(salesDevelopmentUser) {
            Test.startTest();
            List<Product2> productList = Plative_AddProductLineCtrl.getProducts(accountId);
            Test.stopTest();
            System.assertEquals(1, productList.size());
            System.assertEquals('Green Street News: Europe', productList[0].Name);
        }
    }

    @isTest
    static void saveProductLinesRejectsSalesDevelopmentWithoutTrialOpportunity() {
        User salesDevelopmentUser = createSalesDevelopmentUser();
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        String expectedResponse = 'Error: In order to add GSN Trial Products we require an Opportunity with Trial Start date, Trial End date in the future and Trial Type';

        System.runAs(salesDevelopmentUser) {
            Test.startTest();
            String response = Plative_AddProductLineCtrl.saveProductLines(
                accountId,
                new List<Account_Product_Line__c>()
            );
            Test.stopTest();
            System.assertEquals(expectedResponse, response);
        }
    }

    @isTest
    static void saveProductLinesAllowsQualifyingTrialOpportunity() {
        User salesDevelopmentUser = createSalesDevelopmentUser();
        Account accountRecord = [SELECT Id FROM Account LIMIT 1];
        String trialType = 'Test';
        List<Schema.PicklistEntry> trialTypeValues = Opportunity.Trial_Type__c.getDescribe().getPicklistValues();
        if (!trialTypeValues.isEmpty()) {
            trialType = trialTypeValues[0].getValue();
        }

        insert new Opportunity(
            Name = 'Qualifying Trial Opportunity',
            AccountId = accountRecord.Id,
            CloseDate = Date.today().addDays(30),
            StageName = 'Prospecting',
            Trial_Start_Date__c = Date.today(),
            Trial_End_Date__c = Date.today().addDays(30),
            Trial_Type__c = trialType
        );

        Id productId = [SELECT Id FROM Product2 LIMIT 1].Id;
        Test.setMock(HttpCalloutMock.class, new Plative_GSAWebCalloutMock());
        System.runAs(salesDevelopmentUser) {
            Test.startTest();
            String response = Plative_AddProductLineCtrl.saveProductLines(
                accountRecord.Id,
                new List<Account_Product_Line__c>{
                    new Account_Product_Line__c(Product__c = productId, Account__c = accountRecord.Id)
                }
            );
            Test.stopTest();
            System.assertEquals(
                'Account Product Lines saved successfully! & ' + System.Label.Email_Distribution_Message,
                response
            );
        }
    }

    @isTest
    static void saveProductLinesReplacesExistingProductLinesForSalesDevelopment() {
        User salesDevelopmentUser = createSalesDevelopmentUser();
        Account accountRecord = [SELECT Id FROM Account LIMIT 1];
        String trialType = 'Test';
        List<Schema.PicklistEntry> trialTypeValues = Opportunity.Trial_Type__c.getDescribe().getPicklistValues();
        if (!trialTypeValues.isEmpty()) {
            trialType = trialTypeValues[0].getValue();
        }
        insert new Opportunity(
            Name = 'Replacement Trial Opportunity',
            AccountId = accountRecord.Id,
            CloseDate = Date.today().addDays(30),
            StageName = 'Prospecting',
            Trial_Start_Date__c = Date.today(),
            Trial_End_Date__c = Date.today().addDays(30),
            Trial_Type__c = trialType
        );

        List<Product2> products = [SELECT Id FROM Product2 ORDER BY CreatedDate LIMIT 2];
        Account_Product_Line__c existingProductLine = new Account_Product_Line__c(
            Account__c = accountRecord.Id,
            Product__c = products[0].Id
        );
        insert existingProductLine;

        Test.setMock(HttpCalloutMock.class, new Plative_GSAWebCalloutMock());
        System.runAs(salesDevelopmentUser) {
            Test.startTest();
            String response = Plative_AddProductLineCtrl.saveProductLines(
                accountRecord.Id,
                new List<Account_Product_Line__c>{
                    new Account_Product_Line__c(
                        Account__c = accountRecord.Id,
                        Product__c = products[1].Id
                    )
                }
            );
            Test.stopTest();
            System.assertEquals(
                'Account Product Lines saved successfully! & ' + System.Label.Email_Distribution_Message,
                response
            );
        }

        List<Account_Product_Line__c> savedProductLines = [
            SELECT Product__c
            FROM Account_Product_Line__c
            WHERE Account__c = :accountRecord.Id
        ];
        System.assertEquals(1, savedProductLines.size());
        System.assertEquals(products[1].Id, savedProductLines[0].Product__c);
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
        
        String message = 'Account Product Lines saved successfully! & Email Distribution progress will take a few minutes. Please refresh the page after a minute!';
        Test.startTest();
        String response = Plative_AddProductLineCtrl.saveProductLines(accntId, new List<Account_Product_Line__c>());
        delete [select id from Account_Product_Line__c];        
        Test.stopTest();
    }
    
    @isTest
    static void saveProductLinesWithExistingProductLinesEmpty(){
        Test.setMock(HttpCalloutMock.class, new Plative_GSAWebCalloutMock());  
        Id accntId = [Select Id from Account LIMIT 1].Id;
        Id productId = [Select Id from Product2 LIMIT 1].Id;
        String message = 'Account Product Lines saved successfully! & Email Distribution progress will take a few minutes. Please refresh the page after a minute!';        
        Test.startTest();
        String response = Plative_AddProductLineCtrl.saveProductLines(accntId, new List<Account_Product_Line__c>{new Account_Product_Line__c(Product__c=productId,Account__c=accntId)});
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
        String message = 'Account Product Lines saved successfully! & Email Distribution progress will take a few minutes. Please refresh the page after a minute!'; 
        Test.startTest();
        String response = Plative_AddProductLineCtrl.saveProductLines(accntId, new List<Account_Product_Line__c>{accntProductLineInsert[0]});
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
