@isTest
public class StagingDataUploadBatch_Test {
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
        accnt.GSA_ID_Legacy__c = '76897';
        insert accnt;
        
        Product2 productREIT = new Product2();
        productREIT.Name = 'US Research + REIT Data';
        productREIT.IsActive = true;
        productREIT.Product_Line__c = true;
        insert productREIT;
        
        Account_Product_Line__c productLine = new Account_Product_Line__c();
        productLine.Account__c = accnt.Id;
        productLine.Product__c = productREIT.Id;
        insert productLine; 
        
        Contact cont = new Contact();
        cont.AccountId = accnt.Id;
        cont.FirstName = 'FName';
        cont.LastName = 'LName';
        cont.Email = 'test@email.com';
        cont.Phone = '9876543210';
         cont.GSA_Contact_ID__c  = '6786';
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
        
        Staging_Data_Upload__c stgRecord = new Staging_Data_Upload__c();
        stgRecord.Object_API_Name__c = 'Contact_Email_Distribution__c';
        stgRecord.Record_Id__c = '6786';
        insert stgRecord;
        Staging_Data_Upload__c stgRecord1 = new Staging_Data_Upload__c();
        stgRecord1.Object_API_Name__c = 'Account_Product_Lines__c';
        stgRecord1.Record_Id__c = '76897';
        insert stgRecord1;
    } 
    
    @isTest
    static void stagingDataUploadBatchtest(){
        Contact contact = [Select Id,AccountId from Contact LIMIT 1];
        Contact_Email_Distribution__c ced = new Contact_Email_Distribution__c();
        ced.Account__c = contact.AccountId;
        ced.Contact__c = contact.Id;
        ced.Email_Distribution__c = Label.TestClass_ProductName;
        insert ced;   
        Test.startTest();
        StagingDataUploadBatch batch = new StagingDataUploadBatch('Contact_Email_Distribution__c');
        Database.executeBatch(batch, 1);
        StagingDataUploadBatch accBatch = new StagingDataUploadBatch('Account_Product_Lines__c');
        Database.executeBatch(accBatch, 1);
        Test.stopTest();
    }

}