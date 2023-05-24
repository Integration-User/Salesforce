@isTest
public class Plative_AccountProductLineTriggerTest {
    
    @testSetup
    static void testSetup(){

        GSA_Platform__c platform = GSA_Platform__c.getOrgDefaults();  
        //Company
        platform.Company_Activation__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/companies/activate';
        platform.Company_Deactivation__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/companies/';
        platform.Update_Downloads__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/companies/update_num_downloads';
        platform.Company_Edit__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/companies/edit';
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
        accnt.Subsidiary__c = '10 GSA LLC';
        insert accnt;
        
        Contact cont = new Contact();
        cont.AccountId = accnt.Id;
        cont.FirstName = 'FName';
        cont.LastName = 'LName';
        cont.Email = 'test@email.com';
        cont.Phone = '9876543210';        
        insert cont;
        
        List<Product2> productInsertList = new List<Product2>();
        
        Product2 product = new Product2();
        product.Name = Label.TestClass_ProductName;
        product.IsActive = true;
        productInsertList.add(product);
        
        Product2 newsProduct1 = new Product2();
        newsProduct1.Name = Label.TestClass_ProductName2;
        newsProduct1.IsActive = true;
        newsProduct1.News_Product_Line__c = true;
        productInsertList.add(newsProduct1);
        insert productInsertList;
        
        Email_Distribution__c emailDistribution = new Email_Distribution__c();
        emailDistribution.Name = 'Real Estate Alert';
        emailDistribution.Subscription__c = 'Real Estate Alert';
        insert emailDistribution;
    }
    
    @isTest
    static void companyActivation(){
        Test.setMock(HttpCalloutMock.class, new Plative_GSAWebCalloutMock());  
        Id recordId = [Select Id from Account LIMIT 1].Id;
        Test.startTest();
        Account_Product_Line__c productLine = new Account_Product_Line__c();
        productLine.Account__c = recordId;
        productLine.Product__c = [Select Id from Product2 where Name = 'US Research + REIT Data' LIMIT 1].Id;
        insert productLine; 
        Test.stopTest();
    }
    
    @isTest
    static void companyActivationDelete(){
        Test.setMock(HttpCalloutMock.class, new Plative_GSAWebCalloutMock());  
        Id recordId = [Select Id from Account LIMIT 1].Id;
        Account_Product_Line__c productLine = new Account_Product_Line__c();
        productLine.Account__c = recordId;
        productLine.Product__c = [Select Id from Product2 where Name = 'US Research + REIT Data' LIMIT 1].Id;
        insert productLine; 
        Test.startTest();
        delete productLine;
        Test.stopTest();
    }
    
    
    @isTest
    static void addEmailDistributions(){
        Id recordId = [Select Id from Account LIMIT 1].Id;
        Account_Product_Line__c productLine = new Account_Product_Line__c();
        productLine.Account__c = recordId;
        productLine.Product__c = [Select Id from Product2 where Name = 'Real Estate Alert' LIMIT 1].Id;
        Test.startTest();
        insert productLine;  
        Test.stopTest();
    }
    
    
    
    
}