@isTest
public class ActiveSubscriptionCountBatchTest {
    @testSetup
    static void setup() {
        Plative_OpportunityTriggerHandler.skipValidationForBatch = true;
        // Create test Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Create Product
        Product2 newsProduct = new Product2(Name = 'IJGlobal: News', IsActive = true);
        Product2 investorProduct = new Product2(Name = 'IJGlobal: IJ Investor', IsActive = true);
        insert new List<Product2>{ newsProduct, investorProduct };
            
            PricebookEntry pbeNews = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(), Product2Id = newsProduct.Id, UnitPrice = 100, IsActive = true
            );
        PricebookEntry pbeInvestor = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(), Product2Id = investorProduct.Id, UnitPrice = 200, IsActive = true
        );
        insert new List<PricebookEntry>{ pbeNews, pbeInvestor };
            
            // Create Opportunity and Line Item
            Opportunity oldOpp = new Opportunity(
                Name = 'Test Opp - Closed', StageName = 'Closed Won', CloseDate = Date.today(),
                AccountId = acc.Id, Pricebook2Id = Test.getStandardPricebookId());
        insert oldOpp;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = oldOpp.Id, Quantity = 1, PricebookEntryId = pbeNews.Id,
            TotalPrice = 100, End_Date__c = Date.today().addMonths(3), Licenses__c = 10
        );
        insert oli;
        
        // Create Subscription record
        Subscription__c sub = new Subscription__c(
            Account__c = acc.Id, Status__c = 'Active'
        );
        insert sub;
        Order o = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert o;
        OrderItem oi = new OrderItem(
            OrderId = o.Id,
            UnitPrice = 100.0,
            Quantity = 10,
            PricebookEntryId = pbeNews.Id,
            ServiceDate = Date.today(),
            EndDate = Date.today().addDays(100)
        );
        insert oi;
        Subscription_Product__c newSubscriptionProduct = new Subscription_Product__c();
        newSubscriptionProduct.Product__c = pbeNews.Product2Id;
        newSubscriptionProduct.Start_Date__c = oi.ServiceDate;
        newSubscriptionProduct.End_Date__c = oi.EndDate;
        newSubscriptionProduct.Subscription__c = sub.Id;
        
        insert newSubscriptionProduct;
        acc.Active_Subscription_Count__c = 0;
        update acc;
    }

    @isTest static void testBatch() {
        Test.startTest();
        ActiveSubscriptionCountBatch batch = new ActiveSubscriptionCountBatch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }
}