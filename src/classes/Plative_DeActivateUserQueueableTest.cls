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
        cont.Billing_Contact_Multi__c = 'Research';
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
        Contact cont = [Select Id, Billing_Contact_Multi__c,AccountId from Contact LIMIT 1];
        cont.Username__c = 'test@gsaplatform.com1';
        cont.Contact_Status__c = 'Active';        
        Test.startTest();
        Plative_ContactTriggerHandler.afterUpdateRun = false;
        cont.Username__c = 'test@gsaplatform.com2';
        update cont;
        
        Contact cont1 = new Contact();
        cont1.AccountId = cont.AccountId;
        cont1.FirstName = 'FName Advisory';
        cont1.LastName = 'LName Advisory';
        cont1.Email = 'testAdvisory@email.com';
        cont1.Phone = '98765432101'; 
        cont1.Billing_Contact_Multi__c = 'Advisory';
        insert cont1; 
        
        Map<Id, Contact> mapOld = new Map<Id, Contact>();
        mapOld.put(cont.Id, cont1);
        Map<Id, Contact> mapnew = new Map<Id, Contact>();
        mapnew.put(cont.Id, cont);
        Plative_ContactTriggerHelper.checkBillingContactChange(new List<Contact>{cont}, mapOld, mapnew);
        Plative_ContactTriggerHelper.addEmailDistributions(new Set<Id>{cont.id, cont1.Id});
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