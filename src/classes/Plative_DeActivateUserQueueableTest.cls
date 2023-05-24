@isTest
public class Plative_DeActivateUserQueueableTest {
    
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
        
        Trigger_Control_Setting__c setting = new Trigger_Control_Setting__c();
        setting.Contact__c = true;
        insert setting;
        
        Account accnt = new Account();
        accnt.Name = 'Test Account';
        accnt.Product_Line__c = 'NA REIT';
        accnt.Account_Status__c = 'Active';
        insert accnt;
        
        Contact cont = new Contact();
        cont.AccountId = accnt.Id;
        cont.FirstName = 'FName';
        cont.LastName = 'LName';
        cont.Email = 'test@email.com';
        cont.Phone = '9876543210';        
        insert cont; 
        
        List<Account_Email_Distribution__c> accntEd = new List<Account_Email_Distribution__c>();
        Account_Email_Distribution__c aed = new Account_Email_Distribution__c();
        aed.Account__c = accnt.Id;
        aed.Email_Distribution__c = 'Test';
        accntEd.add(aed);
        Account_Email_Distribution__c aed2 = new Account_Email_Distribution__c();
        aed2.Account__c = accnt.Id;
        aed2.Email_Distribution__c = 'Test2';
        accntEd.add(aed2);
        insert accntEd;
        
        Contact_Email_Distribution__c ced = new Contact_Email_Distribution__c();
        ced.Account__c = accnt.Id;
        ced.Contact__c = cont.Id;
        ced.Email_Distribution__c = 'Test';
        insert ced;
    }
    
    @isTest
    static void userNameChange(){
        Test.setMock(HttpCalloutMock.class, new Plative_GSAWebCalloutMock());  
        Contact cont = [Select Id from Contact LIMIT 1];
        cont.Username__c = 'test@gsaplatform.com1';
        cont.Contact_Status__c = 'Active';        
        Test.startTest();
        Plative_ContactTriggerHandler.afterUpdateRun = false;
        cont.Username__c = 'test@gsaplatform.com2';
        update cont;
        Test.stopTest();
    }
    
    
    @isTest
    static void userActivationWithUserName(){
        Test.setMock(HttpCalloutMock.class, new Plative_GSAWebCalloutMock());  
        Contact cont = [Select Id,AccountId from Contact LIMIT 1];
        cont.Username__c = 'test@gsaplatform.com';
        cont.Activate_Contact__c = true;        
        Test.startTest();
        Plative_ContactTriggerHandler.afterUpdateRun = false;
        Plative_ContactTriggerHelper.createContactED(cont.AccountId, cont.Id,'Testtest');
        update cont;
        Test.stopTest();
    }
    
    
    @isTest
    static void userDeActivationWithUserName(){
        Test.setMock(HttpCalloutMock.class, new Plative_GSAWebCalloutMock());  
        Contact cont = [Select Id from Contact LIMIT 1];
        cont.Activate_Contact__c = true; 
        cont.Contact_Status__c = 'Active';
        update cont;
        Test.startTest();
        Plative_ContactTriggerHandler.afterUpdateRun = false;
        cont.Activate_Contact__c = false;
        update cont;
        Test.stopTest();
    }
    
    
    
    
    
}