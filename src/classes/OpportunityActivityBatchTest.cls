@isTest
private class OpportunityActivityBatchTest {
    
    @testSetup
    static void setupTestData() {
        Trigger_Control_Setting__c setting = new Trigger_Control_Setting__c();
        setting.Event__c = true;
        setting.Task__c = true;
        insert setting;
        // Create test Opportunities
        List<Opportunity> opps = new List<Opportunity>();
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
        
        Product2 iJproduct = new Product2();
        iJproduct.Name = 'IJGlobal: News';
        iJproduct.IsActive = true;
        iJproduct.ProductCode = 'DDS10DDS11DDS3';
        insert iJproduct;
        PricebookEntry ijEntry = new PricebookEntry();
        ijEntry.IsActive = true;
        ijEntry.Pricebook2Id = Test.getStandardPricebookId();
        ijEntry.Product2Id = iJproduct.Id;
        ijEntry.UnitPrice = 0;
        insert ijEntry;
        

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
        opps.add(oppty);
        insert opps;
        
        OpportunityLineItem opptyLineItem = new OpportunityLineItem();
        opptyLineItem.OpportunityId = opps[0].Id;
        opptyLineItem.PricebookEntryId = entry.Id;
        opptyLineItem.UnitPrice = 15000;
        opptyLineItem.Quantity = 1;
        opptyLineItem.Start_Date__c = System.today();
        opptyLineItem.End_Date__c = System.today().addMonths(1);
        opptyLineItem.Product_External_Id__c = 401;
        opptyLineItem.Delivery_Method__c = 'Snowflake';
        insert opptyLineItem; 

        // Create test Tasks linked to Opportunities
        List<Task> tasks = new List<Task>();
        for (Opportunity opp : opps) {
            tasks.add(new Task(whoId = ct1.Id, WhatId = opp.Id, Subject = 'Call: Connected', CreatedDate = System.today().addDays(-10)));
            tasks.add(new Task( whoId = ct1.Id, WhatId = opp.Id, Subject = 'Reply: email', CreatedDate = System.today().addDays(-5)));
        }
        insert tasks;

        // Create test Events linked to Opportunities
        List<Event> events = new List<Event>();
        for (Opportunity opp : opps) {
            events.add(new Event(WhatId = opp.Id, Status__c  = 'Requested', DurationInMinutes=30, StartDateTime = System.today().addDays(-15), 
                                 Canceled_Date__c  = NULL, No_Show_Date__c = FALSE, whoId = ct1.Id, Type='Virtual Visit'));
        }
        insert events;
        events[0].Status__c = 'Completed';
        update events;
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        OpportunityActivityBatch batch = new OpportunityActivityBatch();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();

        // Verify that Opportunities were updated correctly
        List<Opportunity> updatedOpps = [SELECT Id, Count_of_Calls_Last_30__c, Count_of_Emails_Last_30__c, Count_of_Meetings_Last_30__c FROM Opportunity];
        System.debug('updatedOpps->' + updatedOpps);
        for (Opportunity opp : updatedOpps) {
            System.assert(opp.Count_of_Calls_Last_30__c != null);
            System.assert(opp.Count_of_Emails_Last_30__c != null);
            System.assert(opp.Count_of_Meetings_Last_30__c != null);
        }
    }
}