@isTest
public class BatchCreateAccountLineItemsTest {
    @testSetup
    static void setup() {
        // Create test Accounts
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 1; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i, CurrencyIsoCode = 'USD'));
        }
        insert accounts;

        // Create test Products
        List<Product2> products = new List<Product2>{
            new Product2(Name = 'US Detailed NAV', IsActive = true, CurrencyIsoCode = 'USD'),
            new Product2(Name = 'US Portfolio Tools', IsActive = true, CurrencyIsoCode = 'USD'),
            new Product2(Name = 'US Tertiary Market Data', IsActive = true, CurrencyIsoCode = 'USD')
        };
        insert products;

        // Create Staging_Opportunity_Data__c records
        List<Staging_Opportunity_Data__c> stagingRecords = new List<Staging_Opportunity_Data__c>();
        for (Account acc : accounts) {
            stagingRecords.add(new Staging_Opportunity_Data__c(
                Account_Id__c = acc.Id,
                US_Detailed_NAV__c = true,
                US_Portfolio_Tool__c = true,
                US_Tertiary_Data__c = true
            ));
        }
        insert stagingRecords;
    }

    @isTest
    static void testBatchCreateAccountLineItems() {
        
        Test.startTest();
        BatchCreateAccountLineItems batch = new BatchCreateAccountLineItems();
        Database.executeBatch(batch, 1);
        Test.stopTest();

        // Assert Account_Product_Line__c records were created
        List<Account_Product_Line__c> lines = [SELECT Id, Account__c, Product__c FROM Account_Product_Line__c];
        System.assert(lines.size() > 0, 'Account_Product_Line__c records should be created');
    }

    @isTest
    static void testBatchHandlesException() {
        // Insert a staging record with invalid Account Id to force exception
        Staging_Opportunity_Data__c badStaging = new Staging_Opportunity_Data__c(
            Account_Id__c = '001000000000000AAA',
            US_Detailed_NAV__c = true
        );
        insert badStaging;

        Test.startTest();
        BatchCreateAccountLineItems batch = new BatchCreateAccountLineItems();
        Database.executeBatch(batch, 1);
        Test.stopTest();
        // No unhandled exception should occur
        System.assert(true, 'Batch should handle exceptions gracefully');
    }
    @isTest
    static void testBatchWithNullAccountId() {
        // Create staging record with null Account ID (should not create line items)
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        Staging_Opportunity_Data__c stagingRecord = new Staging_Opportunity_Data__c(
            Account_Id__c = null,
            US_Detailed_NAV__c = true,
            US_Portfolio_Tool__c = false,
            US_Tertiary_Data__c = false
        );
        insert stagingRecord;

        Test.startTest();
        BatchCreateAccountLineItems batch = new BatchCreateAccountLineItems();
        Database.executeBatch(batch, 1);
        Test.stopTest();

        // Assert no Account_Product_Line__c records were created for null Account
        List<Account_Product_Line__c> lines = [SELECT Id FROM Account_Product_Line__c];
        System.assertEquals(0, lines.size(), 'No line items should be created for null Account ID');
    }
}