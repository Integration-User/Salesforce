/**
* Company     : Plative
* Description : Test class for Plative_GSAMassActivation
* History     : 
* [31.Aug.2020] Kunal - Code Creation 
*/
@isTest
public class Plative_GSAMassActivationTest {
    
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
        accnt.Bulk_Activation__c = true;
        accnt.News_ID__c = '123123';
        insert accnt;
        
        Product2 product = new Product2();
        product.Product_Line__c = true;
        product.IsActive = true;
        product.Name = Label.TestClass_ProductName;
        product.News_Product_Line__c = true;
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
        cont.Bulk_Activation__c = true;
        cont.News_ID__c = '123124';
        insert cont;
    }
    
    
    @isTest
    static void createAccountActivation(){
        Map<String,String> headers = new Map<String,String> {'Content-Type'=>'application/json','Accept'=>'application/json'};
            String responseBody = [Select Body from StaticResource where Name = 'GSA_AccountActivation'].Body.toString();
        HttpMockFactory mock = new HttpMockFactory(200,'OK',responseBody, headers);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        Plative_GSAMassActivationBatch batchable = new Plative_GSAMassActivationBatch('Account');
        Database.executeBatch(batchable,50);
        Test.stopTest();
    }
    
    @isTest
    static void createAccountActivationError(){
        Map<String,String> headers = new Map<String,String> {'Content-Type'=>'application/json','Accept'=>'application/json'};
            String responseBody = [Select Body from StaticResource where Name = 'GSA_AccountActivation'].Body.toString();
        HttpMockFactory mock = new HttpMockFactory(404,'OK',responseBody, headers);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        Plative_GSAMassActivationBatch batchable = new Plative_GSAMassActivationBatch('Account');
        Database.executeBatch(batchable,50);
        Test.stopTest();
    }
    
    @isTest
    static void createContactActivation(){
        Map<String,String> headers = new Map<String,String> {'Content-Type'=>'application/json','Accept'=>'application/json'};
            String responseBody = [Select Body from StaticResource where Name = 'GSA_ContactActivation'].Body.toString();
        HttpMockFactory mock = new HttpMockFactory(200,'OK',responseBody, headers);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        Plative_GSAMassActivationBatch batchable = new Plative_GSAMassActivationBatch('contact');
        Database.executeBatch(batchable,50);
        Test.stopTest();
    }
    
    @isTest
    static void createContactActivationError(){
        Map<String,String> headers = new Map<String,String> {'Content-Type'=>'application/json','Accept'=>'application/json'};
            String responseBody = [Select Body from StaticResource where Name = 'GSA_ContactActivation'].Body.toString();
        HttpMockFactory mock = new HttpMockFactory(404,'OK',responseBody, headers);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        Plative_GSAMassActivationBatch batchable = new Plative_GSAMassActivationBatch('contact');
        Database.executeBatch(batchable,50);
        Test.stopTest();
    }
    
    @isTest
    static void massActivationSchedulable(){
         Map<String,String> headers = new Map<String,String> {'Content-Type'=>'application/json','Accept'=>'application/json'};
            String responseBody = [Select Body from StaticResource where Name = 'GSA_ContactActivation'].Body.toString();
        HttpMockFactory mock = new HttpMockFactory(404,'OK',responseBody, headers);
        Test.setMock(HttpCalloutMock.class, mock);
        Plative_GSAMassActivationSchedulable schedulable = new Plative_GSAMassActivationSchedulable('Account');
        String sch = '20 30 8 10 2 ?';
        Test.startTest();
        system.schedule('Activation Job', sch, schedulable);
        Test.stopTest();
    }
    
}