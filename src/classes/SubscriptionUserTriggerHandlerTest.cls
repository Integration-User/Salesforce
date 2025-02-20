/**
* @author Zoran Zunko
* @date 9/30/21
*
*/
@IsTest
public class SubscriptionUserTriggerHandlerTest {

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
                Zephr_Product_Slug__c = 'test-ent',
                Zephr_Website__c = 'test-ent',
                Zephr_Tenant__c = 'lmg'


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

        List<zephr_InvocableCreateSubscription.CreateSubscriptionResponse> userResponses = zephr_InvocableCreateSubscription.createSubscriptionRecords(
                new List<String>{
                        [SELECT Id FROM Order LIMIT 1].Id
                }
        );
        List<String> subResponses = zephr_InvocableCreateZephrSubModel.createZephrSubscriptionModel(new List<Id>{
                [SELECT Id FROM Subscription__c LIMIT 1].Id
        });

        Subscription__c subscription = [SELECT Id FROM Subscription__c WHERE Id IN :subResponses];
        Contact con = [SELECT Id, AccountId FROM Contact];
        Subscription_User__c subscriptionUser = new Subscription_User__c();
        subscriptionUser.Subscription_NG__c = subscription.Id;
        subscriptionUser.Contact__c = con.Id;
        insert subscriptionUser;

        Zephr_Company__c zephrCompany = [SELECT Id FROM Zephr_Company__c LIMIT 1];
        zephrCompany.Zephr_Integration_Status__c = 'Synced';
        zephrCompany.Zephr_Id__c = '12353412';
        update zephrCompany;

        Zephr_Account__c zephrAccount = [SELECT Id FROM Zephr_Account__c LIMIT 1];
        zephrAccount.Zephr_Integration_Status__c = 'Synced';
        zephrAccount.Zephr_Id__c = '12353412';
        update zephrCompany;

        Zephr_User__c zephrUser = new Zephr_User__c();
        zephrUser.Zephr_Company__c = zephrCompany.Id;
        zephrUser.Zephr_Integration_Status__c = 'Synced';
        zephrUser.Zephr_Id__c = '1231244512';
        insert zephrUser;

        Zephr_User_Account_Grant__c zephrUserAccountGrant = new Zephr_User_Account_Grant__c();
        zephrUserAccountGrant.Zephr_Account__c = zephrAccount.Id;
        zephrUserAccountGrant.Zephr_User__c = zephrUser.Id;
        zephrUserAccountGrant.Subscription_User__c = subscriptionUser.Id;
        zephrUserAccountGrant.Zephr_Integration_Status__c = 'Synced';

        insert zephrUserAccountGrant;
    }

    @IsTest static void test_beforeDelete() {
        Map<String, zephr_TestMock.MockConfig> mockConfigs = new Map<String, zephr_TestMock.MockConfig>{
                '(^https://lmg.api.zephr.com)(/v3/accounts)(/(.+)/users/(.+))' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.accountUser(), 'OK', 200, false, 'DELETE')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        List<Zephr_User_Account_Grant__c> userAccountGrants = [SELECT Id, Zephr_Account__r.Zephr_Id__c, Zephr_Account__r.Zephr_Tenant__c, Zephr_User__r.Zephr_Id__c, Zephr_User__r.Zephr_Tenant__c FROM Zephr_User_Account_Grant__c];
        System.assert(!userAccountGrants.isEmpty());
        System.assert(![SELECT Id FROM Subscription_User__c].isEmpty());
        Test.startTest();
        delete [SELECT Id FROM Subscription_User__c];
        Test.stopTest();
        System.assert([SELECT Id FROM Subscription_User__c].isEmpty());
        System.assert([SELECT Id, Zephr_Account__r.Zephr_Id__c, Zephr_Account__r.Zephr_Tenant__c, Zephr_User__r.Zephr_Id__c, Zephr_User__r.Zephr_Tenant__c FROM Zephr_User_Account_Grant__c].isEmpty());

    }

    @IsTest static void test_beforeUndelete() {
        Map<String, zephr_TestMock.MockConfig> mockConfigs = new Map<String, zephr_TestMock.MockConfig>{
                '(^https://lmg.api.zephr.com)(/v3/accounts)(/(.+)/users/(.+))' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.accountUser(), 'OK', 200, false, 'DELETE')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        List<Zephr_User_Account_Grant__c> userAccountGrants = [SELECT Id, Zephr_Account__r.Zephr_Id__c, Zephr_Account__r.Zephr_Tenant__c, Zephr_User__r.Zephr_Id__c, Zephr_User__r.Zephr_Tenant__c FROM Zephr_User_Account_Grant__c];
        System.assert(!userAccountGrants.isEmpty());
        System.assert(![SELECT Id FROM Subscription_User__c ALL ROWS].isEmpty());
        Test.startTest();
        delete [SELECT Id FROM Subscription_User__c];
        Test.stopTest();
        System.assert([SELECT Id FROM Subscription_User__c].isEmpty());
        System.assert([SELECT Id, Zephr_Account__r.Zephr_Id__c, Zephr_Account__r.Zephr_Tenant__c, Zephr_User__r.Zephr_Id__c, Zephr_User__r.Zephr_Tenant__c FROM Zephr_User_Account_Grant__c].isEmpty());
        try {
            undelete [SELECT Id FROM Subscription_User__c ALL ROWS];
            System.assert(false);
        } catch (Exception ex) {

        }
    }

    @IsTest static void test_afterUpdate() {
        Map<String, zephr_TestMock.MockConfig> mockConfigs = new Map<String, zephr_TestMock.MockConfig>{
                '(^https://lmg.api.zephr.com)(/v3/accounts)(/(.+)/users/(.+))' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.accountUser(), 'OK', 200, false, 'DELETE')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        List<Zephr_User_Account_Grant__c> userAccountGrants = [SELECT Id, Zephr_Account__r.Zephr_Id__c, Zephr_Account__r.Zephr_Tenant__c, Zephr_User__r.Zephr_Id__c, Zephr_User__r.Zephr_Tenant__c FROM Zephr_User_Account_Grant__c];
        System.assert(!userAccountGrants.isEmpty());
        System.assert(![SELECT Id FROM Subscription_User__c].isEmpty());
        Test.startTest();
        List<Subscription_User__c> subscriptionUsers = [SELECT Id FROM Subscription_User__c];
        for (Subscription_User__c subscriptionUser : subscriptionUsers) {
            subscriptionUser.Subscriber_Status__c = 'Inactive';
        }
        update subscriptionUsers;
        Test.stopTest();
        System.assert(![SELECT Id FROM Subscription_User__c].isEmpty());
        System.assert([SELECT Id, Zephr_Account__r.Zephr_Id__c, Zephr_Account__r.Zephr_Tenant__c, Zephr_User__r.Zephr_Id__c, Zephr_User__r.Zephr_Tenant__c FROM Zephr_User_Account_Grant__c].isEmpty());
    }

    @IsTest static void test_other() {
        SubscriptionUserTriggerHandler subscriptionUserTH = new SubscriptionUserTriggerHandler();
        subscriptionUserTH.BeforeInsert(null);
        subscriptionUserTH.AfterInsert(null, null);
        subscriptionUserTH.AfterDelete(null);
    }
}