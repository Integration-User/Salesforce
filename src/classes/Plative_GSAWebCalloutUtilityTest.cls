@isTest
public class Plative_GSAWebCalloutUtilityTest {
    
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
        //API Key
        platform.API_Key__c = 'SAL3sf0rc3_AP1';
        insert platform;
        
        Account accnt = new Account();
        accnt.Name = 'Test Account';
        accnt.Account_Status__c = 'Active';
        //accnt.Product_Line__c = 'Pan-European Research + REIT Data';
        insert accnt;
        
        Product2 product = new Product2();
        product.Product_Line__c = true;
        product.IsActive = true;
        product.Name = Label.TestClass_ProductName;
        insert product;
        
        Account_Product_Line__c productLine = new Account_Product_Line__c();
        productLine.Account__c = accnt.Id;
        productLine.Product__c = product.Id;
        insert productLine;
        
        Contact cont = new Contact();
        cont.AccountId = accnt.Id;
        cont.FirstName = 'FName';
        cont.LastName = 'LName';
        cont.Email = 'test@email.com';
        cont.Phone = '9876543210';        
        insert cont;
        
    }
    
    @isTest
    static void companyActivation(){
        Test.setMock(HttpCalloutMock.class, new Plative_GSAWebCalloutMock());  
        Id recordId = [Select Id from Account LIMIT 1].Id;
        Test.startTest();
        Plative_GSAWebCalloutUtility.makeCallout(recordId,'Account','activate');
        Test.stopTest();
    }
    
    @isTest
    static void companyDeactivation(){
        Test.setMock(HttpCalloutMock.class, new Plative_GSAWebCalloutMock());  
        Id recordId = [Select Id from Account LIMIT 1].Id;
        Test.startTest();
        Plative_GSAWebCalloutUtility.makeCallout(recordId,'Account','deactivate');
        Test.stopTest();
    }
    
    @isTest
    static void userActivationWithoutUserName(){
        Test.setMock(HttpCalloutMock.class, new Plative_GSAWebCalloutMock());  
        Id recordId = [Select Id from Contact LIMIT 1].Id;
        Test.startTest();
        Plative_GSAWebCalloutUtility.makeCallout(recordId, 'Contact','activate');
        Test.stopTest();
    }
    
    @isTest
    static void userActivationWithUserName(){
        Test.setMock(HttpCalloutMock.class, new Plative_GSAWebCalloutMock());  
        Contact cont = [Select Id from Contact LIMIT 1];
        cont.Username__c = 'test@gsaplatform.com';
        update cont;
        Test.startTest();
        Plative_GSAWebCalloutUtility.makeCallout(cont.Id, 'Contact','activate');
        Test.stopTest();
    }
    
    @isTest
    static void userDeactivation(){
        Test.setMock(HttpCalloutMock.class, new Plative_GSAWebCalloutMock());  
        Id recordId = [Select Id from Contact LIMIT 1].Id;
        Test.startTest();
        Plative_GSAWebCalloutUtility.makeCallout(recordId, 'Contact','deactivate');
        Test.stopTest();
    }
    
    @isTest
    static void userResetPassword(){
        Test.setMock(HttpCalloutMock.class, new Plative_GSAWebCalloutMock());  
        Id recordId = [Select Id from Contact LIMIT 1].Id;
        Test.startTest();
        Plative_GSAWebCalloutUtility.makeCallout(recordId, 'Contact','reset_password');
        Test.stopTest();
    }
    
}