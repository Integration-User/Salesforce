/**
* @author Zoran Zunko
* @date 7/22/21
*
*/
@IsTest public class script_UpdateSubscribersCtrlTest {
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
                PricebookEntryId = pbe.Id,
                ServiceDate = Date.today(),
                EndDate = Date.today().addDays(100)
        );
        insert oi;

        Subscription__c newSubscription = new Subscription__c();
        newSubscription.Account__c = a.Id;
        newSubscription.Order__c = o.Id;
        newSubscription.Order_Product__c = oi.Id;
        newSubscription.Type__c = 'Group';
        newSubscription.Number_of_Seats__c = oi.Quantity;

        insert newSubscription;

        Subscription_Product__c newSubscriptionProduct = new Subscription_Product__c();
        newSubscriptionProduct.Product__c = pbe.Product2Id;
        newSubscriptionProduct.Start_Date__c = oi.ServiceDate;
        newSubscriptionProduct.End_Date__c = oi.EndDate;
        newSubscriptionProduct.Subscription__c = newSubscription.Id;

        insert newSubscriptionProduct;
    }

    @IsTest static void test_createContacts() {

        Subscription__c subscription = [SELECT Id, Number_of_Seats__c FROM Subscription__c LIMIT 1];

        zephr_InvocableCreateZephrSubModel.createZephrSubscriptionModel(new List<Id>{
                subscription.Id
        });

        // Test add new Contacts

        String SubscriberStartDate = DateTime.now().format('yyyy-MM-dd');
        String SubscriberEndDate = DateTime.now().addDays(10).format('yyyy-MM-dd');

        String request = '{"contacts":[{"FirstName":"Test","LastName":"Test10","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test10@example.com"},{"FirstName":"Test","LastName":"Test11","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test11@example.com"},{"FirstName":"Test","LastName":"Test12","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test12@example.com"},{"FirstName":"Test","LastName":"Test13","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test13@example.com"},{"FirstName":"Test","LastName":"Test14","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test14@example.com"},{"FirstName":"Test","LastName":"Test15","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test15@example.com"},{"FirstName":" ","LastName":"","Title":"","MailingStreet":"","MailingCity":"","MailingPostalCode":"","MailingCountry":"","Email":""}],"subscriptionId":"'+[SELECT Id FROM Subscription__c].Id+'","subscriptionUsers":[{"Email":"test.test10@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test10@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test11@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test12@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test13@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test14@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test15@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"}]}';

        String response = script_UpdateSubscribersCtrl.createContacts(request);

        // Test update dates

        SubscriberStartDate = DateTime.now().addDays(1).format('yyyy-MM-dd');
        SubscriberEndDate = DateTime.now().addDays(14).format('yyyy-MM-dd');

        request = '{"contacts":[{"FirstName":"Test","LastName":"Test10","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test10@example.com"},{"FirstName":"Test","LastName":"Test11","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test11@example.com"},{"FirstName":"Test","LastName":"Test12","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test12@example.com"},{"FirstName":"Test","LastName":"Test13","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test13@example.com"},{"FirstName":"Test","LastName":"Test14","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test14@example.com"},{"FirstName":"Test","LastName":"Test15","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test15@example.com"},{"FirstName":" ","LastName":"","Title":"","MailingStreet":"","MailingCity":"","MailingPostalCode":"","MailingCountry":"","Email":""}],"subscriptionId":"'+[SELECT Id FROM Subscription__c].Id+'","subscriptionUsers":[{"Email":"test.test10@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test10@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test11@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test12@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test13@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test14@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test15@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"}]}';

        response = script_UpdateSubscribersCtrl.createContacts(request);

        // Test end date before start date

        SubscriberStartDate = DateTime.now().addDays(10).format('yyyy-MM-dd');
        SubscriberEndDate = DateTime.now().addDays(1).format('yyyy-MM-dd');

        request = '{"contacts":[{"FirstName":"Test","LastName":"Test10","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test10@example.com"},{"FirstName":"Test","LastName":"Test11","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test11@example.com"},{"FirstName":"Test","LastName":"Test12","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test12@example.com"},{"FirstName":"Test","LastName":"Test13","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test13@example.com"},{"FirstName":"Test","LastName":"Test14","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test14@example.com"},{"FirstName":"Test","LastName":"Test15","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test15@example.com"},{"FirstName":" ","LastName":"","Title":"","MailingStreet":"","MailingCity":"","MailingPostalCode":"","MailingCountry":"","Email":""}],"subscriptionId":"'+[SELECT Id FROM Subscription__c].Id+'","subscriptionUsers":[{"Email":"test.test10@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test10@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test11@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test12@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test13@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test14@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test15@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"}]}';

        response = script_UpdateSubscribersCtrl.createContacts(request);

        // Test oversubscription

        subscription.Number_of_Seats__c = subscription.Number_of_Seats__c - 2;
        update subscription;

        SubscriberStartDate = DateTime.now().addDays(10).format('yyyy-MM-dd');
        SubscriberEndDate = DateTime.now().addDays(20).format('yyyy-MM-dd');

        request = '{"contacts":[{"FirstName":"Test","LastName":"Test10","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test10@example.com"},{"FirstName":"Test","LastName":"Test11","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test11@example.com"},{"FirstName":"Test","LastName":"Test12","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test12@example.com"},{"FirstName":"Test","LastName":"Test13","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test13@example.com"},{"FirstName":"Test","LastName":"Test14","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test14@example.com"},{"FirstName":"Test","LastName":"Test15","Title":"Tester","MailingStreet":"some","MailingCity":"some","MailingPostalCode":"1233","MailingCountry":"United Kingdom","Email":"test.test15@example.com"},{"FirstName":" ","LastName":"","Title":"","MailingStreet":"","MailingCity":"","MailingPostalCode":"","MailingCountry":"","Email":""}],"subscriptionId":"'+[SELECT Id FROM Subscription__c].Id+'","subscriptionUsers":[{"Email":"test.test10@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test10@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test11@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test12@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test13@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test14@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"test.test15@example.com","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"},{"Email":"","SubscriberStartDate":"' + SubscriberStartDate + '","SubscriberEndDate":"' + SubscriberEndDate + '"}]}';

        response = script_UpdateSubscribersCtrl.createContacts(request);

        System.assertEquals(6, [SELECT Id FROM Contact].size());
        System.assertEquals(6, [SELECT Id FROM Subscription_User__c].size());
    }
}