/**
* Company     : Plative
* Description :  Test class for Plative_UpdateDownloadsCtrl
* History     : 
* [18.May.2020] Kunal - Code Creation 
*/

@isTest
public class Plative_UpdateDownloadsCtrlTest {    
    
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
        accnt.Name = 'Test Accnt';
        accnt.Secondary_Name__c = 'Test Accnt Secondary';
        accnt.Phone = '123123123';
        accnt.Website = 'http://www.website.com';
        accnt.BillingCity = 'New York';
        accnt.BillingCountry = 'United States';
        accnt.BillingPostalCode = '4123123';
        accnt.BillingState = 'New York';
        accnt.BillingStreet = 'Madison Avenue';
        accnt.Account_Status__c = 'Active';
        insert accnt;
    }
    
    
    @isTest
    static void fetchAccount(){
        Id recordId = [Select Id from Account LIMIT 1].Id;
        Test.startTest();
        Plative_UpdateDownloadsCtrl.fetchAccount(recordId);
        Test.stopTest();
    }
    
    @isTest
    static void updateDownload(){
        Id recordId = [Select Id from Account LIMIT 1].Id;
        Test.setMock(HttpCalloutMock.class, new Plative_UpdateDownloadsMock());
        Test.startTest();
        String response = Plative_UpdateDownloadsCtrl.updateDownload(recordId,200);
        system.assertEquals('Success!',response);
        Test.stopTest();
    }
    
    @isTest
    static void updateDownloadException(){
        Id recordId = [Select Id from Account LIMIT 1].Id;
        Test.setMock(HttpCalloutMock.class, new Plative_UpdateDownloadsMock());
        Test.startTest();
        String response = Plative_UpdateDownloadsCtrl.updateDownload(recordId,201);
        system.assert(response.toLowerCase().containsIgnoreCase('error'));
        Test.stopTest();
    }
    
    
    
}