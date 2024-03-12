/**
* Company     : Plative
* Description : Trigger for Opportunity object
* History     :
* [18.Jun.2020] Kunal - Code Creation
*/
@isTest
public class Plative_OpportunityTriggerTest {
    
    @testSetup
    static void testSetup(){
        Trigger_Control_Setting__c setting = new Trigger_Control_Setting__c();
        setting.Opportunity__c = true;
        insert setting;
        Account parentAccnt = new Account();
        parentAccnt.Name = 'Test parent Account';
        parentAccnt.Phone = '12312323';
        parentAccnt.Company_Type__c = 'Consultant';
        parentAccnt.Description = 'test'; 
        parentAccnt.Website = 'https://www.google.com';
        parentAccnt.CRE_Exposure__c = '$0-100M';
        parentAccnt.ShippingCity = 'Test';
        parentAccnt.ShippingCountry = 'United States';
        parentAccnt.ShippingState = 'Alabama';
        parentAccnt.ShippingStreet = 'test';
        parentAccnt.ShippingPostalCode = '123';
        parentAccnt.BillingCity = 'Test';
        parentAccnt.BillingCountry = 'United States';
        parentAccnt.BillingState = 'Alabama';
        parentAccnt.BillingStreet = 'test';
        parentAccnt.BillingPostalCode = '123';
        parentAccnt.Subsidiary__c = '10 GSA LLC';
        parentAccnt.Populate_Billing_Address__c = true;
        parentAccnt.Other_Vendors__c = 'RCA';
        insert parentAccnt;
        
        Account accnt = new Account();
        accnt.Name = 'Test Account';
        accnt.Phone = '123123';
        accnt.Company_Type__c = 'Consultant';
        accnt.Description = 'test'; 
        accnt.Website = 'https://www.google.com';
        accnt.CRE_Exposure__c = '$0-100M';
        accnt.ShippingCity = 'Test';
        accnt.ShippingCountry = 'United States';
        accnt.ShippingState = 'Alabama';
        accnt.ShippingStreet = 'test';
        accnt.ShippingPostalCode = '123';
        accnt.BillingCity = 'Test';
        accnt.BillingCountry = 'United States';
        accnt.BillingState = 'Alabama';
        accnt.BillingStreet = 'test';
        accnt.BillingPostalCode = '123';
        accnt.Subsidiary__c = '10 GSA LLC';
        accnt.Populate_Billing_Address__c = true;
        accnt.Other_Vendors__c = 'RCA';
        accnt.ParentId = parentAccnt.Id;
        insert accnt;
        
        Contact ct1 = new Contact();
        ct1.FirstName = 'FName1';
        ct1.LastName = 'LName1';
        ct1.Email = 'fname1@test.com';
        ct1.AccountId = accnt.Id;
        insert ct1;
        
        Contact ct2 = new Contact();
        ct2.FirstName = 'FName12';
        ct2.LastName = 'LName121';
        ct2.Email = 'fname12@test.com';
        ct2.AccountId = accnt.Id;
        ct2.Assistant__c = ct1.Id;
        insert ct2;
       
        
        Product2 product = new Product2();
        product.Name = 'Pan-European Research + Market Data & Deals';
        product.IsActive = true;
        product.ProductCode = 'DDS10DDS11DDS2';
        insert product;
        
        PricebookEntry entry = new PricebookEntry();
        entry.IsActive = true;
        entry.Pricebook2Id = Test.getStandardPricebookId();
        entry.Product2Id = product.Id;
        entry.UnitPrice = 0;
        insert entry;
        
        Opportunity oppty = new Opportunity();
        oppty.Name = 'Test Oppty';
        oppty.CloseDate = System.today().addDays(5);
        oppty.StageName = '2 - Conducting Needs Analysis';
        oppty.AccountId = accnt.Id;
        oppty.X2nd_Year_Amount_in_USD__c = 60000;
        oppty.X3rd_Year_Amount_in_USD__c = 80000;
        oppty.Year_4_Amount__c = 90000;
        //oppty.Year_5_Amount__c = 60000;
        //oppty.Year_6_Amount__c = 60000;
        //oppty.Year_7_Amount__c = 60000;
        oppty.Automatic_Renewal__c = false;
        oppty.Close_Reason__c = 'test';
        oppty.LeadSource = 'LinkedIn';
        oppty.ADV_PPD_Sent__c = System.today();
        oppty.CRS_Sent__c = 'Yes';
        oppty.Billing_Schedule__c = 'In Advance - Annual';
        oppty.Terms__c = 'Net 30';
        oppty.Billing_Contact__c = ct1.Id;
        oppty.Contract_Start_Date__c = System.today();
        oppty.Contract_End_Date__c = System.today().addmonths(1);
        oppty.Current_Contract_Year__c = 1;
        insert oppty;
        
        OpportunityLineItem opptyLineItem = new OpportunityLineItem();
        opptyLineItem.OpportunityId = oppty.Id;
        opptyLineItem.PricebookEntryId = entry.Id;
        opptyLineItem.UnitPrice = 15000;
        opptyLineItem.Quantity = 1;
        opptyLineItem.Start_Date__c = System.today();
        opptyLineItem.End_Date__c = System.today().addMonths(1);
        opptyLineItem.Product_External_Id__c = 401;
        opptyLineItem.Delivery_Method__c = 'Snowflake';
        insert opptyLineItem; 
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = oppty.Id;
        ocr.ContactId = ct1.Id;
        ocr.Role ='Billing Contact';
        insert ocr;
        
        Id advisoryRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Advisory').getRecordTypeId();
        Opportunity oppty1 = new Opportunity();
        oppty1.Name = 'TestOppty1';
        oppty1.RecordTypeId = advisoryRT;
        oppty1.CloseDate = System.today().addDays(5);
        oppty1.StageName = '2 - Conducting Needs Analysis';
        oppty1.AccountId = accnt.Id;
        oppty1.X2nd_Year_Amount_in_USD__c = 60000;
        oppty1.X3rd_Year_Amount_in_USD__c = 60000;
        //oppty1.Year_4_Amount__c = 60000;
        //oppty1.Year_5_Amount__c = 60000;
        //oppty1.Year_6_Amount__c = 60000;
        //oppty1.Year_7_Amount__c = 60000;
        oppty1.Automatic_Renewal__c = false;
        oppty1.Close_Reason__c = 'test';
        oppty1.LeadSource = 'LinkedIn';
        oppty1.ADV_PPD_Sent__c = System.today();
        oppty1.CRS_Sent__c = 'Yes';
        oppty1.Billing_Schedule__c = 'Other';
        oppty1.Other_Invoice_Frequency__c = 'Monthly';
        oppty1.Terms__c = 'Net 30';
        oppty1.Billing_Contact__c = ct2.Id;
        oppty1.Contract_Start_Date__c = System.today();
        oppty1.Contract_End_Date__c = System.today().addmonths(1);
        insert oppty1;
        
        OpportunityLineItem opptyLineItem1 = new OpportunityLineItem();
        opptyLineItem1.OpportunityId = oppty1.Id;
        opptyLineItem1.PricebookEntryId = entry.Id;
        opptyLineItem1.UnitPrice = 15000;
        opptyLineItem1.Quantity = 1;
        opptyLineItem1.Start_Date__c = System.today();
        opptyLineItem1.End_Date__c = System.today().addMonths(1);
        opptyLineItem1.Product_External_Id__c = 401;
        insert opptyLineItem1; 
        
        OpportunityContactRole ocr1 = new OpportunityContactRole();
        ocr1.OpportunityId = oppty1.Id;
        ocr1.ContactId = ct2.Id;
        ocr1.Role ='Billing Contact';
        insert ocr1;
        
    }
    
    @isTest
    static void updateOpptyClosedWon(){        
        Opportunity opptyTemp = [Select Id,AccountId,Name  from Opportunity where RecordType.DeveloperName = 'Sales_Development' LIMIT 1];
        Opportunity oppty = new Opportunity();
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity_Closed').getRecordTypeId();
        oppty.RecordTypeId = oppRecordTypeId;
        oppty.Id = opptyTemp.Id;
        oppty.StageName = 'Closed Won'; 
        oppty.ID_Request__c = 'Not Applicable';
        oppty.Win_Validation__c = 'Opportunity Reviewed';
        //oppty.Win_Validation__c = 'Opportunity Reviewed';
        Test.startTest();
        //For creating Renewal Opportunities from Sales Opportunity
        update oppty;   
        //For creating Renewal Opportunity from the last Closed Renewal Opportunity
        Opportunity lastRenewalOpportunity = [Select Id from Opportunity where Id != :oppty.Id ORDER BY CreatedDate DESC LIMIT 1];
        //lastRenewalOpportunity.StageName = 'Closed Won';
        lastRenewalOpportunity.Close_Reason__c = 'Contracted Client';
        //lastRenewalOpportunity.Create_New_Renewal_Opportunity__c = true;
        lastRenewalOpportunity.ID_Request__c = 'Not Applicable';
        lastRenewalOpportunity.Win_Validation__c = 'Opportunity Reviewed';
        lastRenewalOpportunity.Activation_Deactivation_Needs__c = 'Full Account Activation';
        //lastRenewalOpportunity.Win_Validation__c = 'Opportunity Reviewed';
        Plative_OpportunityTriggerHandler.afterUpdateRun = false;
        update lastRenewalOpportunity;
        Plative_OpportunityTriggerHelper.getOppLineIteamsIds(new set<Id>{oppty.Id});
        Test.stopTest();
    }
   @isTest
    static void opptyValidationsTest(){   
       
        Opportunity opptyTemp = [Select Id,AccountId,Name  from Opportunity  LIMIT 1];
        Opportunity oppty = new Opportunity();
        oppty.Id = opptyTemp.Id;
        //oppty.StageName = 'Verbal Win (6)'; 
        oppty.ID_Request__c = 'Not Applicable';
        opptyTemp.Create_New_Renewal_Opportunity__c = false;
        oppty.Win_Validation__c = 'Opportunity Reviewed';
        oppty.Designated_ARR__c = 600000;
        //oppty.Win_Validation__c = 'Opportunity Reviewed';
        Test.startTest();
        update oppty;   
        
        Test.stopTest();
    } 


    @isTest
    static void opptyProjectTest(){ 

       Id advisoryRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Advisory').getRecordTypeId(); 
        
       Opportunity opptyTemp = [Select Id,AccountId,Name,Synced__c  from Opportunity LIMIT 1];
        system.debug('-------------------------'+opptyTemp);
        Project__c prj = new Project__c();
        prj.Name = 'TestProject';
        prj.Opportunity__c = opptyTemp.Id;
        insert prj;
        
        Opportunity oppty = new Opportunity();
        oppty.Id = opptyTemp.Id;
        oppty.StageName = 'Active'; 
        oppty.ID_Request__c = 'Not Applicable';
        oppty.Win_Validation__c = 'Opportunity Reviewed';
        oppty.RecordTypeId = advisoryRT;
        oppty.Synced__c = 'Yes';
       
        Test.startTest();
        update oppty; 
        
       
        
        Test.stopTest();
       
  }
    @isTest Static void testUpdateProductsOnOpportunityBatch() {
        Test.startTest();
        Opportunity opptyTemp = [Select Id,Products__c  from Opportunity LIMIT 1];
        opptyTemp.Products__c = 'EURO Research';
        update opptyTemp;
        Database.executeBatch(new UpdateProductsOnOpportunityBatch(), 200);
        Test.stopTest();
    }
    @isTest Static void insertOpptyClosedWon() {
        Test.startTest();
		Account accnt = [Select Id from Account Limit 1];

        Contact ct1 = new Contact();
        ct1.FirstName = 'FName3';
        ct1.LastName = 'LName3';
        ct1.Email = 'fname3@test.com';
        ct1.AccountId = accnt.Id;
        insert ct1;

        Product2 product = new Product2();
        product.Name = 'Pan-European Research + Market Data & Deals';
        product.IsActive = true;
        insert product;
        
        PricebookEntry entry = new PricebookEntry();
        entry.IsActive = true;
        entry.Pricebook2Id = Test.getStandardPricebookId();
        entry.Product2Id = product.Id;
        entry.UnitPrice = 0;
        insert entry;
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity_Closed').getRecordTypeId();

        Opportunity oppty = new Opportunity();
        oppty.Name = 'Test Oppty';
        oppty.CloseDate = System.today().addDays(5);
        oppty.StageName = 'Closed Won';
        oppty.AccountId = accnt.Id;
        oppty.Automatic_Renewal__c = false;
        oppty.Close_Reason__c = 'test';
        oppty.LeadSource = 'LinkedIn';
        oppty.ADV_PPD_Sent__c = System.today();
        oppty.CRS_Sent__c = 'Yes';
        oppty.Billing_Schedule__c = 'In Advance - Annual';
        oppty.Terms__c = 'Net 30';
        oppty.Billing_Contact__c = ct1.Id;
        oppty.Contract_Start_Date__c = System.today();
        oppty.Contract_End_Date__c = System.today().addmonths(1);
        oppty.RecordTypeId = oppRecordTypeId;
        insert oppty;
        
        OpportunityLineItem opptyLineItem = new OpportunityLineItem();
        opptyLineItem.OpportunityId = oppty.Id;
        opptyLineItem.PricebookEntryId = entry.Id;
        opptyLineItem.UnitPrice = 15000;
        opptyLineItem.Quantity = 1;
        opptyLineItem.Start_Date__c = System.today();
        opptyLineItem.End_Date__c = System.today().addMonths(1);
        opptyLineItem.Product_External_Id__c = 401;
        insert opptyLineItem; 
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = oppty.Id;
        ocr.ContactId = ct1.Id;
        ocr.Role ='Billing Contact';
        insert ocr;
        Test.stopTest();
    }
}
