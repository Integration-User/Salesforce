/**
* @author Zoran Zunko
* @date 6/28/21
*
*/
@IsTest
global class zephr_InvocableStartSubProvisioningTest {
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
                Zephr_Website__c = 'test-ent'


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
    public static void test_startSubscriptionProvisioningQueueable() {
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
        Zephr_Account__c zephrAccount = [SELECT Id FROM Zephr_Account__c LIMIT 1];
        Zephr_User__c zephrUser = new Zephr_User__c();
        zephrUser.Zephr_Company__c = zephrCompany.Id;
        zephrUser.Zephr_Integration_Status__c = 'Pending';
        insert zephrUser;
        Zephr_User_Account_Grant__c zephrUserAccountGrant = new Zephr_User_Account_Grant__c();
        zephrUserAccountGrant.Zephr_Account__c = zephrAccount.Id;
        zephrUserAccountGrant.Zephr_User__c = zephrUser.Id;
        zephrUserAccountGrant.Subscription_User__c = subscriptionUser.Id;
        zephrUserAccountGrant.Zephr_Integration_Status__c = 'Pending';

        insert zephrUserAccountGrant;

        //create user grany data
        Contact conUser = new Contact(
                FirstName = 'Example',
                LastName = 'One',
                Email = 'example.one@example.com.com',
                AccountId = con.AccountId,
                MailingCountry = 'United Kingdom'
        );
        insert conUser;
        Subscription_User__c subscriptionUserUser = new Subscription_User__c();
        subscriptionUserUser.Subscription_NG__c = subscription.Id;
        subscriptionUserUser.Contact__c = conUser.Id;
        insert subscriptionUserUser;
        Zephr_User__c zephrUserUser = new Zephr_User__c();
        zephrUserUser.Zephr_Company__c = zephrCompany.Id;
        zephrUserUser.Zephr_Integration_Status__c = 'Pending';
        insert zephrUserUser;
        Zephr_User_Grant__c zephrUserUserGrant = new Zephr_User_Grant__c();
        zephrUserUserGrant.Zephr_User__c = zephrUser.Id;
        zephrUserUserGrant.Subscription__c = subscription.Id;
        zephrUserUserGrant.Subscription_User__c = subscriptionUser.Id;
        zephrUserUserGrant.Zephr_Integration_Status__c = 'Pending';

        insert zephrUserUserGrant;


        //todo make the map from uri/response pairs
        Map<String, zephr_TestMock.MockConfig> mockConfigs = new Map<String, zephr_TestMock.MockConfig>{
                '(^https://(.+).zephr.com)(/v3/accounts)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createAccount(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/companies)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createCompanyBody(), 'OK', 201, false, 'POST'),
//                '/v3/accounts/' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createGrant(), 'OK', 201, false, 'PUT'),//grant
//                '/v3/accounts' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.accountUser(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/accounts)(/(.+)/users/(.+))' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.accountUser(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/accounts)(/(.+)/users/(.+))' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.accountUser(), 'OK', 201, false, 'PUT'),
                '(^https://(.+).zephr.com)(/v3/accounts)(/(.+)/grants)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createGrant(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/users)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/users/reset)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/users\\?identifiers.email_address=)(.+)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'NOT FOUND', 401, false, 'GET')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        Test.startTest();
        zephr_InvocableStartSubProvisioning.startSubscriptionProvisioningQueueable(new List<String>{
                [SELECT Id FROM Subscription__c LIMIT 1].Id
        });
        Test.stopTest();
    }
}