/**
* Company     : Plative
* Description :  Test class for Plative_EmailDistributionGenCtrl
* History     : 
* [26.May.2020] Kunal - Code Creation 
*/
@isTest
public class Plative_EmailDistributionGenCtrlTest {
    
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
    static void getEmailDistributions(){
        Test.startTest();
        List<Email_Distribution__c> response = Plative_EmailDistributionGenCtrl.getEmailDistributions();
        System.assert(!response.isEmpty());
        Test.stopTest();
    }
    
    @isTest
    static void getRelatedContacts(){
        Contact contact = [Select Id,AccountId from Contact LIMIT 1];
        Contact_Email_Distribution__c ced = new Contact_Email_Distribution__c();
        ced.Account__c = contact.AccountId;
        ced.Contact__c = contact.Id;
        ced.Email_Distribution__c = Label.TestClass_ProductName;
        insert ced;   
        Test.startTest();
        List<Contact_Email_Distribution__c> cedList = Plative_EmailDistributionGenCtrl.getRelatedContacts('US Research + REIT Data');
        System.assert(!cedList.isEmpty());
        Test.stopTest();
    }

}