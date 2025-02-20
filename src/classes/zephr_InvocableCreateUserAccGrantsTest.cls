/**
* @author Zoran Zunko
* @date 6/23/21
*
*/
@IsTest
public with sharing class zephr_InvocableCreateUserAccGrantsTest {
    @TestSetup
    static void dataSetup() {
        TriggerSettings__c tsettings = TriggerSettings__c.getOrgDefaults();
        tsettings.ZephrFeatureSwitchDisabled__c = true;
        upsert tsettings;
        Account a = new Account(
                Name = 'Test Account',
                Account_Hierarchy_Ext_Id__c = '11111',
                ZephrCompanyId__c = 'c2641dcb-8609-40bd-8b0c-a5ebeef9c108'
        );
        insert a;

        Id pricebookId = Test.getStandardPricebookId();
        Order o = new Order(
                AccountId = a.Id,
                EffectiveDate = Date.today(),
                Status = 'Draft',
                Pricebook2Id = pricebookId
        );
        insert o;

        Product2 prod = new Product2(
                Name = 'Test product',
                ZephrEntitlementId__c = 'test-ent',
                Zephr_Product_Slug__c = 'test-ent'


        );
        insert prod;

        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert pbe;

        OrderItem oi = new OrderItem(
                OrderId = o.Id,
                UnitPrice = 100.0,
                Quantity = 10,
                PricebookEntryId = pbe.Id
        );
        insert oi;

        Contact c = new Contact(
                FirstName = 'Tester',
                LastName = 'One',
                Email = 'tester.one@account.com',
                AccountId = a.Id,
                MailingCountry = 'United Kingdom'
        );
        insert c;
    }

    @IsTest
    public static void test_createUserAccountGrants() {
        List<zephr_InvocableCreateSubscription.CreateSubscriptionResponse> userResponses = zephr_InvocableCreateSubscription.createSubscriptionRecords(
                new List<String>{
                        [SELECT Id FROM Order LIMIT 1].Id
                }
        );
        List<String> subResponses = zephr_InvocableCreateZephrSubModel.createZephrSubscriptionModel(new List<Id>{
                [SELECT Id FROM Subscription__c LIMIT 1].Id
        });

        Subscription__c subscription = [SELECT Id,Zephr_Account__c,  Account__c FROM Subscription__c WHERE Id IN :subResponses];
        Contact con = [SELECT Id, AccountId FROM Contact];
        Subscription_User__c subscriptionUser = new Subscription_User__c();
        subscriptionUser.Subscription_NG__c = subscription.Id;
        subscriptionUser.Contact__c = con.Id;
        insert subscriptionUser;
        List<zephr_InvocableCreateUserAccountGrants.CreateUserAccountGrantsRequest> createUserAccountGrantsRequests = new List<zephr_InvocableCreateUserAccountGrants.CreateUserAccountGrantsRequest>();
        zephr_InvocableCreateUserAccountGrants.CreateUserAccountGrantsRequest req = new zephr_InvocableCreateUserAccountGrants.CreateUserAccountGrantsRequest();
        req.subscription = subscription;
        req.users = new List<Subscription_User__c>{subscriptionUser};
        createUserAccountGrantsRequests.add(req);

        zephr_InvocableCreateUserAccountGrants.createUserAccountGrants(createUserAccountGrantsRequests);


    }

}