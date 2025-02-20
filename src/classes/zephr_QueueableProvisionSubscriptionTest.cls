/**
* @author Zoran Zunko
* @date 6/25/21
*
*/
@IsTest
global class zephr_QueueableProvisionSubscriptionTest {
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
    public static void test_queueable_base() {
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
        zephrUserUserGrant.Subscription__c= subscription.Id;
        zephrUserUserGrant.Subscription_User__c = subscriptionUser.Id;
        zephrUserUserGrant.Zephr_Integration_Status__c = 'Pending';
        zephrUserUserGrant.Product__c = [SELECT Id FROM Product2 LIMIT 1].Id;

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
                '(^https://(.+).zephr.com)(/v4/users/reset)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/users\\?identifiers.email_address=)(.+)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'NOT FOUND', 401, false, 'GET')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        Test.startTest();
        zephr_QueueableProvisionSubscription queueableProvisionSubscription = new zephr_QueueableProvisionSubscription();
        queueableProvisionSubscription.subscriptionIds = new List<String>{
                [SELECT Id FROM Subscription__c LIMIT 1].Id
        };
        queueableProvisionSubscription.execute(null);
//        System.enqueueJob(queueableProvisionSubscription);
        Test.stopTest();
    }

    @IsTest
    public static void test_queueable_base_null_seats() {
        List<zephr_InvocableCreateSubscription.CreateSubscriptionResponse> userResponses = zephr_InvocableCreateSubscription.createSubscriptionRecords(
                new List<String>{
                        [SELECT Id FROM Order LIMIT 1].Id
                }
        );
        List<String> subResponses = zephr_InvocableCreateZephrSubModel.createZephrSubscriptionModel(new List<Id>{
                [SELECT Id FROM Subscription__c LIMIT 1].Id
        });
        List<Zephr_Account__c> zephrAccounts = [SELECT Id, Number_of_Seats__c FROM Zephr_Account__c];
        System.assert(!zephrAccounts.isEmpty());
        for (Zephr_Account__c zephrAccount : zephrAccounts) {
            zephrAccount.Number_of_Seats__c = null;
            zephrAccount.Zephr_Integration_Status__c = 'Pending';
        }
        update zephrAccounts;

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
        zephrUserUserGrant.Subscription__c= subscription.Id;
        zephrUserUserGrant.Subscription_User__c = subscriptionUser.Id;
        zephrUserUserGrant.Zephr_Integration_Status__c = 'Pending';
        zephrUserUserGrant.Product__c = [SELECT Id FROM Product2 LIMIT 1].Id;

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
                '(^https://(.+).zephr.com)(/v4/users/reset)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/users\\?identifiers.email_address=)(.+)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'NOT FOUND', 401, false, 'GET')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        Test.startTest();
        zephr_QueueableProvisionSubscription queueableProvisionSubscription = new zephr_QueueableProvisionSubscription();
        queueableProvisionSubscription.subscriptionIds = new List<String>{
                [SELECT Id FROM Subscription__c LIMIT 1].Id
        };
        queueableProvisionSubscription.execute(null);
//        System.enqueueJob(queueableProvisionSubscription);
        Test.stopTest();
        zephrAccount = [SELECT Id, Zephr_Integration_Status__c FROM Zephr_Account__c LIMIT 1];
        System.debug(LoggingLevel.ERROR, 'test_queueable_zephr_QProvisionSubscriptionUsersDuplicate - : ' +zephrAccount.Zephr_Integration_Status__c);
    }

    @IsTest
    public static void test_queueable_zephr_QProvisionSubscriptionUserGrants() {
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
        zephrAccount.Zephr_Id__c = 'zephrAccount.';
        update zephrAccount;
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
        zephrUserUserGrant.Subscription__c= subscription.Id;
        zephrUserUserGrant.Subscription_User__c = subscriptionUser.Id;
        zephrUserUserGrant.Zephr_Integration_Status__c = 'Pending';
        zephrUserUserGrant.Product__c = [SELECT Id FROM Product2 LIMIT 1].Id;

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
                '(^https://(.+).zephr.com)(/v4/users/reset)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/users\\?identifiers.email_address=)(.+)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'NOT FOUND', 401, false, 'GET')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        Test.startTest();
        zephr_QProvisionSubscriptionUserGrants zephrQProvisionSubscriptionUserGrants = new zephr_QProvisionSubscriptionUserGrants();
        zephrQProvisionSubscriptionUserGrants.subscriptionIds = new List<String>{
                [SELECT Id FROM Subscription__c LIMIT 1].Id
        };
        zephrQProvisionSubscriptionUserGrants.execute(null);
//        System.enqueueJob(queueableProvisionSubscription);
        Test.stopTest();
    }

    @IsTest
    public static void test_queueable_zephr_QProvisionSubscriptionUsers() {
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
        zephrUserUserGrant.Subscription__c= subscription.Id;
        zephrUserUserGrant.Subscription_User__c = subscriptionUser.Id;
        zephrUserUserGrant.Zephr_Integration_Status__c = 'Pending';
        zephrUserUserGrant.Product__c = [SELECT Id FROM Product2 LIMIT 1].Id;

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
                '(^https://(.+).zephr.com)(/v4/users/reset)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/users\\?identifiers.email_address=)(.+)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'NOT FOUND', 401, false, 'GET')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        Test.startTest();
        zephr_QProvisionSubscriptionUsers zephrQProvisionSubscriptionUsers = new zephr_QProvisionSubscriptionUsers();
        zephrQProvisionSubscriptionUsers.subscriptionIds = new List<String>{
                [SELECT Id FROM Subscription__c LIMIT 1].Id
        };
        zephrQProvisionSubscriptionUsers.execute(null);
//        System.enqueueJob(queueableProvisionSubscription);
        Test.stopTest();
    }

    @IsTest
    public static void test_queueable_zephr_QProvisionSubscriptionUsersDuplicate() {
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
        //one for duplicates
        Zephr_User__c zephrUserDup = new Zephr_User__c();
        zephrUserDup.Zephr_Company__c = zephrCompany.Id;
        zephrUserDup.Zephr_Integration_Status__c = 'Pending';
        zephrUserDup.Zephr_Id__c = '0d2afed5-3576-4db5-91e1-b6cdacbce6d1';
        insert zephrUserDup;
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
        zephrUserUserGrant.Subscription__c= subscription.Id;
        zephrUserUserGrant.Subscription_User__c = subscriptionUser.Id;
        zephrUserUserGrant.Zephr_Integration_Status__c = 'Pending';
        zephrUserUserGrant.Product__c = [SELECT Id FROM Product2 LIMIT 1].Id;

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
                '(^https://(.+).zephr.com)(/v4/users/reset)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/users\\?identifiers.email_address=)(.+)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'NOT FOUND', 401, false, 'GET')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        Test.startTest();
        zephr_QProvisionSubscriptionUsers zephrQProvisionSubscriptionUsers = new zephr_QProvisionSubscriptionUsers();
        zephrQProvisionSubscriptionUsers.subscriptionIds = new List<String>{
                [SELECT Id FROM Subscription__c LIMIT 1].Id
        };
        zephrQProvisionSubscriptionUsers.execute(null);
//        System.enqueueJob(queueableProvisionSubscription);
        Test.stopTest();
        List<Zephr_User__c> zephrUsers = [SELECT Id FROM Zephr_User__c WHERE Zephr_Integration_Status__c = 'Error'];
        System.assertEquals(1, zephrUsers.size());
    }

    @IsTest
    public static void test_queueable_zephr_QProvisionSubscriptionGrants() {
        List<zephr_InvocableCreateSubscription.CreateSubscriptionResponse> userResponses = zephr_InvocableCreateSubscription.createSubscriptionRecords(
                new List<String>{
                        [SELECT Id FROM Order LIMIT 1].Id
                }
        );
        List<String> subResponses = zephr_InvocableCreateZephrSubModel.createZephrSubscriptionModel(new List<Id>{
                [SELECT Id FROM Subscription__c LIMIT 1].Id
        });
        Zephr_Company__c zephrCompany = [SELECT Id FROM Zephr_Company__c LIMIT 1];
        Zephr_Account__c zephrAccount = [SELECT Id FROM Zephr_Account__c LIMIT 1];
        zephrAccount.Zephr_Id__c = 'zephrAccount.';
        update zephrAccount;
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
                '(^https://(.+).zephr.com)(/v4/users/reset)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/users\\?identifiers.email_address=)(.+)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'NOT FOUND', 401, false, 'GET')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        Test.startTest();
        zephr_QProvisionSubscriptionGrants zephrQProvisionSubscriptionGrants = new zephr_QProvisionSubscriptionGrants();
        zephrQProvisionSubscriptionGrants.subscriptionIds = new List<String>{
                [SELECT Id FROM Subscription__c LIMIT 1].Id
        };
        zephrQProvisionSubscriptionGrants.execute(null);
//        System.enqueueJob(queueableProvisionSubscription);
        Test.stopTest();
    }

    @IsTest
    public static void test_queueable_errors_account_grant() {
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
        zephrUser.Contact__c = con.Id;
        zephrUser.Zephr_Integration_Status__c = 'Error';
        insert zephrUser;
        Zephr_User_Account_Grant__c zephrUserAccountGrant = new Zephr_User_Account_Grant__c();
        zephrUserAccountGrant.Zephr_Account__c = zephrAccount.Id;
        zephrUserAccountGrant.Zephr_User__c = zephrUser.Id;
        zephrUserAccountGrant.Subscription_User__c = subscriptionUser.Id;
        zephrUserAccountGrant.Zephr_Integration_Status__c = 'Error';

        insert zephrUserAccountGrant;

        Map<String, zephr_TestMock.MockConfig> mockConfigs = new Map<String, zephr_TestMock.MockConfig>{
                '(^https://(.+).zephr.com)(/v3/accounts)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createAccount(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/companies)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createCompanyBody(), 'OK', 201, false, 'POST'),
//                '/v3/accounts/' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createGrant(), 'OK', 201, false, 'PUT'),//grant
//                '/v3/accounts' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.accountUser(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/accounts)(/(.+)/users/(.+))' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.accountUser(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/accounts)(/(.+)/users/(.+))' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.accountUser(), 'OK', 201, false, 'PUT'),
                '(^https://(.+).zephr.com)(/v3/accounts)(/(.+)/grants)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createGrant(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/users)(/(.+)/grants)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserGrant(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/users)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v4/users/reset)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/users\\?identifiers.email_address=)(.+)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'NOT FOUND', 401, false, 'GET')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        Test.startTest();
        zephr_QProvisionSubscriptionUsers zephrQProvisionSubscriptionUsers = new zephr_QProvisionSubscriptionUsers();
        zephrQProvisionSubscriptionUsers.subscriptionIds = new List<String>{
                [SELECT Id FROM Subscription__c LIMIT 1].Id
        };
        zephrQProvisionSubscriptionUsers.execute(null);
//        System.enqueueJob(queueableProvisionSubscription);
        Test.stopTest();

        List<Zephr_User__c> zephrUsers = [SELECT Id, Zephr_Integration_Status__c, Zephr_Integration_Message__c FROM Zephr_User__c];
        System.debug(LoggingLevel.ERROR, 'test_queueable_errors - zephrUsers: ' + JSON.serializePretty(zephrUsers));
        System.assert(!zephrUsers.isEmpty());
        for(Zephr_User__c zephrUserAssert : zephrUsers) {
            System.assertEquals('Synced', zephrUserAssert.Zephr_Integration_Status__c);
        }
    }

    @IsTest
    public static void test_queueable_errors_user_grant() {
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

        //create user grant data

        Subscription_User__c subscriptionUserUser = new Subscription_User__c();
        subscriptionUserUser.Subscription_NG__c = subscription.Id;
        subscriptionUserUser.Contact__c = con.Id;
        insert subscriptionUserUser;
        Zephr_User__c zephrUserUser = new Zephr_User__c();
        zephrUserUser.Zephr_Company__c = zephrCompany.Id;
        zephrUserUser.Zephr_Integration_Status__c = 'Error';
        insert zephrUserUser;
        Zephr_User_Grant__c zephrUserUserGrant = new Zephr_User_Grant__c();
        zephrUserUserGrant.Zephr_User__c = zephrUserUser.Id;
        zephrUserUserGrant.Subscription__c= subscription.Id;
        zephrUserUserGrant.Subscription_User__c = subscriptionUser.Id;
        zephrUserUserGrant.Zephr_Integration_Status__c = 'Error';
        zephrUserUserGrant.Product__c = [SELECT Id FROM Product2 LIMIT 1].Id;
        zephrUserUserGrant.Start_Date__c = Date.today();
        zephrUserUserGrant.End_Date__c = Date.today().addDays(15);

        insert zephrUserUserGrant;


        Map<String, zephr_TestMock.MockConfig> mockConfigs = new Map<String, zephr_TestMock.MockConfig>{
                '(^https://(.+).zephr.com)(/v3/accounts)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createAccount(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/companies)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createCompanyBody(), 'OK', 201, false, 'POST'),
//                '/v3/accounts/' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createGrant(), 'OK', 201, false, 'PUT'),//grant
//                '/v3/accounts' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.accountUser(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/accounts)(/(.+)/users/(.+))' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.accountUser(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/accounts)(/(.+)/users/(.+))' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.accountUser(), 'OK', 201, false, 'PUT'),
                '(^https://(.+).zephr.com)(/v3/accounts)(/(.+)/grants)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createGrant(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/users)(/(.+)/grants)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserGrant(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/users)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v4/users/reset)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/users\\?identifiers.email_address=)(.+)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'NOT FOUND', 401, false, 'GET')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        Test.startTest();
        zephr_QProvisionSubscriptionUsers queueableProvisionSubscription = new zephr_QProvisionSubscriptionUsers();
        queueableProvisionSubscription.subscriptionIds = new List<String>{
                [SELECT Id FROM Subscription__c LIMIT 1].Id
        };
        queueableProvisionSubscription.execute(null);
//        System.enqueueJob(queueableProvisionSubscription);
        Test.stopTest();

        List<Zephr_User__c> zephrUsers = [SELECT Id, Zephr_Integration_Status__c, Zephr_Integration_Message__c FROM Zephr_User__c];
        System.debug(LoggingLevel.ERROR, 'test_queueable_errors - zephrUsers: ' + JSON.serializePretty(zephrUsers));
        System.assert(!zephrUsers.isEmpty());
        for(Zephr_User__c zephrUserAssert : zephrUsers) {
            System.assertEquals('Synced', zephrUserAssert.Zephr_Integration_Status__c);
        }
    }


    @IsTest static void provisionZephrUserGrantsTest() {
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
        zephrUser.Zephr_Id__c = 'testzephrId24';
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
        zephrUserUser.Zephr_Id__c = 'testzephrId1';
        insert zephrUserUser;

        Zephr_User_Grant__c zephrUserUserGrant = new Zephr_User_Grant__c();
        zephrUserUserGrant.Zephr_User__c = zephrUserUser.Id;
        zephrUserUserGrant.Subscription__c= subscription.Id;
        zephrUserUserGrant.Subscription_User__c = subscriptionUser.Id;
        zephrUserUserGrant.Zephr_Integration_Status__c = 'Pending';
        zephrUserUserGrant.Zephr_Id__c = 'test';
        zephrUserUserGrant.Product__c = [SELECT Id FROM Product2 LIMIT 1].Id;

        insert zephrUserUserGrant;

        Test.startTest();
        zephr_QProvisionSubscriptionUserGrants pqf = new zephr_QProvisionSubscriptionUserGrants();
        pqf.provisionZephrUserGrants(new Map<Id, Zephr_User_Grant__c>(
        [
                SELECT Id, Zephr_User__c, Zephr_User__r.Zephr_Id__c, Zephr_Tenant__c, Product__r.ZephrEntitlementId__c,
                        Product__r.Zephr_Product_Slug__c, Start_Date__c, End_Date__c, Product__c
                FROM Zephr_User_Grant__c
                WHERE Id =: zephrUserUserGrant.Id
        ]
        ));
        Test.stopTest();
    }

    @IsTest static void provisionZephrUserAccountGrantsTest() {

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
        Zephr_Account__c zephrAccount = [SELECT Id, Zephr_Id__c FROM Zephr_Account__c LIMIT 1];
        zephrAccount.Zephr_Id__c = 'sdfsdf';
        update zephrAccount;

        Zephr_User__c zephrUser = new Zephr_User__c();
        zephrUser.Zephr_Company__c = zephrCompany.Id;
        zephrUser.Zephr_Integration_Status__c = 'Pending';
        zephrUser.Zephr_Id__c = 'testzephrId24';
        insert zephrUser;

        Zephr_User_Account_Grant__c zephrUserAccountGrant = new Zephr_User_Account_Grant__c();
        zephrUserAccountGrant.Zephr_Account__c = zephrAccount.Id;
        zephrUserAccountGrant.Zephr_User__c = zephrUser.Id;
        zephrUserAccountGrant.Subscription_User__c = subscriptionUser.Id;
        zephrUserAccountGrant.Zephr_Integration_Status__c = 'Pending';

        insert zephrUserAccountGrant;

        Test.startTest();
        zephr_QProvisionSubscriptionUserGrants pqf = new zephr_QProvisionSubscriptionUserGrants();
        pqf.provisionZephrUserAccountGrants(new Map<Id, Zephr_User_Account_Grant__c>(
        [
                SELECT Id, Zephr_User__c, Zephr_User__r.Zephr_Id__c, Zephr_Account__r.Zephr_Id__c, Zephr_User__r.Zephr_Tenant__c,
                        Zephr_User_Id__c, Zephr_Integration_Status__c, Zephr_Integration_Message__c
                FROM Zephr_User_Account_Grant__c
                WHERE Id =: zephrUserAccountGrant.Id
        ]
        ));
        Test.stopTest();
    }
}