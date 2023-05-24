/**
* Company     : Plative
* Description : Test class for Plative_GSAWebCalloutActionCtrl(Controller for lightning component Plative_GSAWebCalloutAction.cmp)
* History     :
* [21.Feb.2020] Kunal - Code Creation
*/

@isTest
public class Plative_GSAWebCalloutActionCtrlTest {
    
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
        accnt.Name = 'Test Accnt';
        accnt.Secondary_Name__c = 'Test Accnt Secondary';
        accnt.Phone = '123123123';
        accnt.Website = 'www.google.com';
        accnt.BillingCity = 'New York';
        accnt.BillingCountry = 'United States';
        accnt.BillingPostalCode = '4123123';
        accnt.BillingState = 'New York';
        accnt.BillingStreet = 'Madison Avenue';
        insert accnt;
        
        Contact cont = new Contact();
        cont.AccountId = accnt.Id;
        cont.FirstName = 'FName';
        cont.LastName = 'LName';
        cont.Email = 'test@email.com';
        cont.Phone = '123123123';
        insert cont;
        
    }
    
    @isTest
    static void activateAccount(){
        Id accountId = [Select Id from Account LIMIT 1].Id;
        String response;
        Test.startTest();
        response = Plative_GSAWebCalloutActionCtrl.fetchSObjectStatus(accountId,'activate');
        Test.stopTest();
        System.assertEquals('',response);
    }
    
    @isTest
    static void deactivateAccount(){
        Id accountId = [Select Id from Account LIMIT 1].Id;
        String response;
        Test.startTest();
        response = Plative_GSAWebCalloutActionCtrl.fetchSObjectStatus(accountId,'deactivate');
        Test.stopTest();
        System.assertEquals('deactivate', response);
    }
    
    @isTest
    static void activateContact(){
        Id contactId = [Select Id from Contact LIMIT 1].Id;
        String response;
        Test.startTest();
        response = Plative_GSAWebCalloutActionCtrl.fetchSObjectStatus(contactId,'activate');
        Test.stopTest();
        System.assertEquals('',response);
    }
    
    @isTest
    static void deactivateContact(){
        Id contactId = [Select Id from Contact LIMIT 1].Id;
        String response;
        Test.startTest();
        response = Plative_GSAWebCalloutActionCtrl.fetchSObjectStatus(contactId,'deactivate');
        Test.stopTest();
        System.assertEquals('deactivate', response);
    }
    
    @isTest
    static void resetPassword(){
        Contact cont = [Select Id from Contact LIMIT 1];
        cont.Contact_Status__c = 'Active';
        update cont;
        String response;
        Test.startTest();
        response = Plative_GSAWebCalloutActionCtrl.fetchSObjectStatus(cont.Id,'reset_password');
        Test.stopTest();
        System.assertEquals('activate', response);
    }
    
    @isTest
    static void fetchActiveContactCountAgainstAccount(){
        Contact cont = [Select Id,AccountId from Contact LIMIT 1];
        cont.Contact_Status__c = 'Active';
        update cont;
        Integer response;
        Test.startTest();
        response = Plative_GSAWebCalloutActionCtrl.fetchActiveContactCountAgainstAccount(cont.AccountId);
        Test.stopTest();
        System.assertEquals(1, response);
    }
    
    @isTest
    static void makeCallout(){
        Account accnt = [Select Id from Account LIMIT 1];
        String response;
        Test.startTest();
        response = Plative_GSAWebCalloutActionCtrl.makeCallout(accnt.Id,'account','activate');
        Test.stopTest();
        system.assertEquals('Error occurred while activating the Company. Product Line is required.', response);
    }
    
    

}