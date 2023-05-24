/**
* Company     : Plative
* Description : Test class for Plative_SyncGSAWebsiteSubscriptionBatch          
* History     : 
* [22.Jul.2020] Kunal - Code Creation 
*/
@isTest
public class Plative_SyncGSAWebsiteSubscriptionTest {
    
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
        platform.Account_Get_Web_Bundle__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/companies/{!gsaId}/bundle';
        platform.User_Get_Contact_Token__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/users/datalink/{!gsaId}';
        platform.Batch_Sync_Email__c = 'test@email.com';
        platform.User_Get_Info__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/users/{!gsaId}/info';
        platform.User_Get_Datalink_User_Info__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/users/datalink/{!gsaId}';
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
        insert cont;
        
        Product2 product = new Product2();
        product.Name = Label.TestClass_ProductName;
        product.IsActive = true;
        insert product;
        
        Account_Product_Line__c productLine = new Account_Product_Line__c();
        productLine.Account__c = accnt.Id;
        productLine.Product__c = product.Id;
        insert productLine; 
    }
    
    
    @isTest
    static void getWebBundle(){
        Map<String,String> headers = new Map<String,String> {'Content-Type'=>'application/json','Accept'=>'application/json'};
        String responseBody = [Select Body from StaticResource where Name = 'GSA_GetCompanyBundle'].Body.toString();
        HttpMockFactory mock = new HttpMockFactory(200,'OK',responseBody, headers);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        Database.executeBatch(new Plative_SyncGSAWebsiteSubscriptionBatch(),50);
        Test.stopTest();        
    }
    
    @isTest
    static void getWebBundleSchedulable(){
        Map<String,String> headers = new Map<String,String> {'Content-Type'=>'application/json','Accept'=>'application/json'};
        String responseBody = [Select Body from StaticResource where Name = 'GSA_GetCompanyBundle'].Body.toString();
        HttpMockFactory mock = new HttpMockFactory(200,'OK',responseBody, headers);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        System.schedule('Product Sync Batch','0 0 0 ? * * *',new Plative_SyncGSAWebsiteSubscriptionSched());
        Test.stopTest();
    }
    
}