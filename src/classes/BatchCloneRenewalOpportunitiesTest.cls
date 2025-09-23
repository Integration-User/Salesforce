@isTest
public class BatchCloneRenewalOpportunitiesTest {
    @isTest static void testBatchCloneAndLineItems() {
    // Create Account
    Account acc = new Account(Name = 'Test Account');
    insert acc;

    // Create Products
    List<Product2> products = new List<Product2>{
        new Product2(Name='US Detailed NAV', IsActive=true),
        new Product2(Name='US Portfolio Tools', IsActive=true),
        new Product2(Name='US Tertiary Market Data', IsActive=true)
    };
    insert products;

    // Get Standard Pricebook
    Id stdPbId = Test.getStandardPricebookId();
    List<PricebookEntry> pbes = new List<PricebookEntry>();
    for(Product2 p : products) {
        pbes.add(new PricebookEntry(Product2Id=p.Id, Pricebook2Id=stdPbId, UnitPrice=100, IsActive=true));
    }
    insert pbes;

    // Create Opportunity RecordType 'Renewal'
    RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'Renewal' LIMIT 1];

    // Create an existing Opportunity
    Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId = acc.Id, CloseDate = Date.today().addDays(30), StageName = 'Prospecting', Pricebook2Id=stdPbId);
    insert opp;

    // Test: Add line items to existing Opportunity
    Staging_Opportunity_Data__c sodExisting = new Staging_Opportunity_Data__c(
        Account_Id__c = acc.Id,
        Opportunity_Id__c = opp.Id,
        Contract_Start_Date__c = Date.today(),
        Contract_End_Date__c = Date.today().addMonths(12),
        US_Detailed_NAV__c = true,
        US_Portfolio_Tool__c = true,
        US_Tertiary_Data__c = false,
        Are_the_products_already_on_the_renewal__c = false
    );
    insert sodExisting;

    // Test: Renewal Opportunity scenario
    Opportunity opp2 = new Opportunity(Name = 'Renewal Opp', AccountId = acc.Id, CloseDate = Date.today().addDays(60), StageName = 'Prospecting', Pricebook2Id=stdPbId);
    insert opp2;
    Staging_Opportunity_Data__c sodRenewal = new Staging_Opportunity_Data__c(
        Account_Id__c = acc.Id,
        Opportunity_Id__c = opp2.Id,
        Contract_Start_Date__c = Date.today(),
        Contract_End_Date__c = Date.today().addMonths(6),
        US_Detailed_NAV__c = true,
        US_Portfolio_Tool__c = false,
        US_Tertiary_Data__c = true,
        Are_the_products_already_on_the_renewal__c = false
    );
    insert sodRenewal;

    Test.startTest();
    BatchCloneRenewalOpportunities batch = new BatchCloneRenewalOpportunities();
    Database.executeBatch(batch, 200);
    Test.stopTest();

    // Assert line items added to existing Opportunity
    List<OpportunityLineItem> olis1 = [SELECT Id, OpportunityId, PricebookEntryId FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
    System.assertEquals(2, olis1.size(), 'Should have added 2 line items to existing opp');
    }
}