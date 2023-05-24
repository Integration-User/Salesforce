/**
* Company     : Plative
* Description :  Test class for Plative_EmailDistributionCtrl
* History     : 
* [17.May.2020] Kunal - Code Creation 
*/
@isTest
public class Plative_EmailDistributionCtrlTest {    
    
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
        
        Test.setMock(HttpCalloutMock.class, new Plative_GSAWebCalloutMock());  
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
        
        Account_Product_Line__c prodLine = new Account_Product_Line__c();
        prodLine.Account__c = accnt.Id;
        prodLine.Product__c = product.Id;
        insert prodLine; 
        
        Email_Distribution__c emailDistribution = new Email_Distribution__c();
        emailDistribution.Name = Label.TestClass_ProductName;
        emailDistribution.Subscription__c = Label.TestClass_ProductName;
        insert emailDistribution;
    } 
    
    @isTest
    static void getAccountStatus(){
        Id recordId = [Select Id from Account LIMIT 1].Id;
        Test.startTest();
        Plative_EmailDistributionCtrl.getAccountStatus(recordId);
        Test.stopTest();
    }
    
    
    @isTest
    static void getEmailDistributionList(){
        Account_Email_Distribution__c aed = new Account_Email_Distribution__c();
        aed.Account__c = [Select Id from Account LIMIT 1].Id;
        aed.Email_Distribution__c = Label.TestClass_ProductName;
        insert aed;
        Test.startTest();
        List<Object> responseList = Plative_EmailDistributionCtrl.getEmailDistributionList(aed.Account__c);
        System.assertEquals(responseList.size(),2);
        Test.stopTest();
    }
    
    @isTest
    static void saveEmailDistributionCase1(){
        Account_Email_Distribution__c aed = new Account_Email_Distribution__c();
        aed.Account__c = [Select Id from Account LIMIT 1].Id;
        aed.Email_Distribution__c = Label.TestClass_ProductName;
        insert aed;
        Test.startTest();
        String response = Plative_EmailDistributionCtrl.saveEmailDistribution(aed.Account__c, new List<String>());
        System.assertEquals('Success!', response);
        Test.stopTest();
    }
    
    @isTest
    static void saveEmailDistributionCase2(){
        Id recordId = [Select Id from Account LIMIT 1].Id;
        Test.startTest();
        String response = Plative_EmailDistributionCtrl.saveEmailDistribution(recordId, new List<String>{'Real Estate Analytics'});
        System.assertEquals('Success!', response);
        Test.stopTest();
    }
    
    
    @isTest
    static void saveEmailDistributionCase3(){
        Account_Email_Distribution__c aed = new Account_Email_Distribution__c();
        aed.Account__c = [Select Id from Account LIMIT 1].Id;
        aed.Email_Distribution__c = Label.TestClass_ProductName;
        insert aed;
        Test.startTest();
        String response = Plative_EmailDistributionCtrl.saveEmailDistribution(aed.Account__c, new List<String>{'Real Estate Analytics',Label.TestClass_ProductName});
        System.assertEquals('Success!', response);
        Test.stopTest();
    }
    
    
    @isTest
    static void saveEmailDistributionCase4(){
        Account_Email_Distribution__c aed = new Account_Email_Distribution__c();
        aed.Account__c = [Select Id from Account LIMIT 1].Id;
        aed.Email_Distribution__c = Label.TestClass_ProductName;
        insert aed;
        Test.startTest();
        String response = Plative_EmailDistributionCtrl.saveEmailDistribution(aed.Account__c, new List<String>{'Real Estate Analytics'});
        System.assertEquals('Success!', response);
        Test.stopTest();
    }
    

}