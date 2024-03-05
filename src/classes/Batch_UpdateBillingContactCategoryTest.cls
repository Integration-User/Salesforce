@isTest
public class Batch_UpdateBillingContactCategoryTest {
    @testSetup
    static void testSetup(){
        Trigger_Control_Setting__c setting = new Trigger_Control_Setting__c();
        setting.Opportunity__c = true;
        insert setting;
        
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
        product.Billing_Contact_Category__c = 'Research';
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
    static void testBatch_UpdateBillingContactCategory(){
        Test.startTest();
        Database.executeBatch(new Batch_UpdateBillingContactCategory(), 10);
        Test.stopTest();
    }
}