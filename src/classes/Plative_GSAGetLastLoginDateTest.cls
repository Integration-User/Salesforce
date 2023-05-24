@isTest
public class Plative_GSAGetLastLoginDateTest {
    
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
        platform.User_Get_Last_Login__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/users/{!gsaId}/last_login';
        platform.User_Get_Contact_Token__c = 'http://gsa-website-salesforce-api-stage.us-west-2.elasticbeanstalk.com/v1/users/datalink/{!gsaId}';
        //API Key
        platform.API_Key__c = 'SAL3sf0rc3_AP1';
        insert platform;
        
        Account accnt = new Account();
        accnt.Name = 'Test Accnt';
        accnt.Secondary_Name__c = 'Test Accnt Secondary';
        accnt.Phone = '123123123';
        accnt.Website = 'www.google.com';
        accnt.DataLink_Access__c = true;
        insert accnt;
        
        Contact cont = new Contact();
        cont.AccountId = accnt.Id;
        cont.FirstName = 'FName';
        cont.LastName = 'LName';
        cont.Email = 'test@email.com';
        cont.Phone = '123123123';
        cont.Contact_Status__c = 'Active';
        insert cont;        
    }
    
    
    @isTest
    static void getLastLoginDate(){
        Map<String,String> headers = new Map<String,String> {'Content-Type'=>'application/json','Accept'=>'application/json'};
        String responseBody = [Select Body from StaticResource where Name = 'GSA_GetLastLoginDate'].Body.toString();
        HttpMockFactory mock = new HttpMockFactory(200,'OK',responseBody, headers);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        Database.executeBatch(new Plative_GSAGetLastLoginDateBatch(),100);
        Test.stopTest();
    }
    
    @isTest
    static void getUserTokens(){
        Map<String,String> headers = new Map<String,String> {'Content-Type'=>'application/json','Accept'=>'application/json'};
        String responseBody = [Select Body from StaticResource where Name = 'GSA_GetDataLinkToken'].Body.toString();
        HttpMockFactory mock = new HttpMockFactory(200,'OK',responseBody, headers);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        Database.executeBatch(new Plative_GSAGetLastLoginDateBatch(),100);
        Test.stopTest();
    }
    
    @isTest
    static void getLastLoginDateCalloutFailure(){
        Map<String,String> headers = new Map<String,String> {'Content-Type'=>'application/json','Accept'=>'application/json'};
        String responseBody = [Select Body from StaticResource where Name = 'GSA_GetLastLoginDate'].Body.toString();
        HttpMockFactory mock = new HttpMockFactory(500,'OK',responseBody, headers);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        Database.executeBatch(new Plative_GSAGetLastLoginDateBatch(),100);
        Test.stopTest();
    }
    
    @isTest
    static void getLastLoginDateCalloutFailure2(){
        Map<String,String> headers = new Map<String,String> {'Content-Type'=>'application/json','Accept'=>'application/json'};
        String responseBody = [Select Body from StaticResource where Name = 'GSA_GetLastLoginDate'].Body.toString().replace('last_login','');
        HttpMockFactory mock = new HttpMockFactory(200,'OK',responseBody, headers);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        Database.executeBatch(new Plative_GSAGetLastLoginDateBatch(),100);
        Test.stopTest();
    }
    
     @isTest
    static void getLastLoginDateCalloutFailure3(){
        Map<String,String> headers = new Map<String,String> {'Content-Type'=>'application/json','Accept'=>'application/json'};
        String responseBody = [Select Body from StaticResource where Name = 'GSA_GetLastLoginDate'].Body.toString().replace('tos_sign_off','');
        HttpMockFactory mock = new HttpMockFactory(200,'OK',responseBody, headers);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        Database.executeBatch(new Plative_GSAGetLastLoginDateBatch(),100);
        Test.stopTest();
    }
    
    @isTest
    static void getLastLoginDateScheduler(){
        Test.startTest();
        Plative_GSAGetLastLoginDateScheduler scheduler = new Plative_GSAGetLastLoginDateScheduler();
		String sch = '0 0 0 ? * * *'; 
		system.schedule('Get Last Login Date', sch, scheduler);        
        Test.stopTest();
    }
    
    
    
    
}