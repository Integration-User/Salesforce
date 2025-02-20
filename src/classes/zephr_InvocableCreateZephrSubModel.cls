/**
* @author Zoran Zunko
* @date 6/10/21
*
*/

public with sharing class zephr_InvocableCreateZephrSubModel {

    @InvocableMethod public static List<String> createZephrSubscriptionModel(List<String> subscriptionIds) {

        Map<Id, Subscription__c> subscriptions = new Map<Id, Subscription__c>([
                SELECT
                        Account__c,
                        Account__r.Name,
                        CurrencyIsoCode,
//                        End_Date__c,
                        Id,
                        Name,
                        New_End_Date__c,
                        Number_of_Seats__c,
                        Order__c,
                        Order__r.OrderNumber,
                        Order_Product__c,
//                        Original_End_Date__c,
//                        Original_Start_Date__c,
//                        Start_Date__c,
                        Type__c,
                        Zephr_Account__c, (
                        SELECT
                                CurrencyIsoCode,
                                Name,
                                Product__c,
                                Start_Date__c,
                                End_Date__c,
                                Product__r.Zephr_Tenant__c,
                                Product__r.Zephr_Product_Slug__c
                        FROM Subscription_Items__r
                )
                FROM Subscription__c
                WHERE Id IN :subscriptionIds
        ]);


        Set<Id> accountIds = new Set<Id>();
        Set<String> zephrTenants = new Set<String>();
        Map<Id, Zephr_Account__c> zephrAccountsBySubscriptionIds = new Map<Id, Zephr_Account__c>();
        Map<Id, Zephr_Account_Grant__c> zephrAccountGrantsBySubscriptionProductIds = new Map<Id, Zephr_Account_Grant__c>();

        //get all accounts and tenants
        for (Subscription__c subscription : subscriptions.values()) {
            accountIds.add(subscription.Account__c);
            for (Subscription_Product__c subscriptionProduct : subscription.Subscription_Items__r) {
                zephrTenants.add(subscriptionProduct.Product__r.Zephr_Tenant__c);
            }
        }

        //get all existing companies
        List<Zephr_Company__c> zephrCompanies = [SELECT Id, Zephr_Tenant__c, Account__c, Zephr_Id__c FROM Zephr_Company__c WHERE Account__c IN :accountIds AND Zephr_Tenant__c IN :zephrTenants];
        List<Zephr_Company__c> zephrCompaniesToInsert = new List<Zephr_Company__c>();
        Map<Id, Map<String, Zephr_Company__c>> accountIdTenantZephrCompanyMap = new Map<Id, Map<String, Zephr_Company__c>>();

        for (Zephr_Company__c zephrCompany : zephrCompanies) {
            if (!accountIdTenantZephrCompanyMap.containsKey(zephrCompany.Account__c)) {
                accountIdTenantZephrCompanyMap.put(zephrCompany.Account__c, new Map<String, Zephr_Company__c>());
            }
            accountIdTenantZephrCompanyMap.get(zephrCompany.Account__c).put(zephrCompany.Zephr_Tenant__c, zephrCompany);
        }


        //create missing records
        for (Subscription__c subscription : subscriptions.values()) {
            String tenantId;
            String productSlug;
            for (Subscription_Product__c subscriptionProduct : subscription.Subscription_Items__r) {
                zephrTenants.add(subscriptionProduct.Product__r.Zephr_Tenant__c);
                tenantId = subscriptionProduct.Product__r.Zephr_Tenant__c;
                productSlug = subscriptionProduct.Product__r.Zephr_Product_Slug__c;

                Zephr_Account_Grant__c accountGrant = new Zephr_Account_Grant__c();
                accountGrant.Subscription_Item__c = subscriptionProduct.Id;
                accountGrant.Zephr_Tenant__c = subscriptionProduct.Product__r.Zephr_Tenant__c;
                accountGrant.Zephr_Integration_Status__c = 'Pending';
                accountGrant.Start_Date__c = subscriptionProduct.Start_Date__c;
                accountGrant.End_Date__c = subscriptionProduct.End_Date__c;
                accountGrant.Product__c = subscriptionProduct.Product__c;

                zephrAccountGrantsBySubscriptionProductIds.put(subscriptionProduct.Id, accountGrant);
            }

            Zephr_Account__c zephrAccount = new Zephr_Account__c();
            zephrAccount.Name =
                    subscription.Account__r.Name.abbreviate(65) + '-' +
                            subscription.Name;
            zephrAccount.Subscription__c = subscription.Id;
            zephrAccount.Zephr_Tenant__c = tenantId;
            zephrAccount.Number_of_Seats__c = subscription.Number_of_Seats__c;
            zephrAccount.Zephr_Integration_Status__c = 'Pending';

            System.debug(LoggingLevel.ERROR, 'createZephrSubscriptionModel - accountIdTenantZephrCompanyMap: ' + JSON.serialize(accountIdTenantZephrCompanyMap));
            if (accountIdTenantZephrCompanyMap.containsKey(subscription.Account__c) && accountIdTenantZephrCompanyMap.get(subscription.Account__c).containsKey(tenantId)) {
                zephrAccount.Zephr_Company__c = accountIdTenantZephrCompanyMap.get(subscription.Account__c).get(tenantId).Id;
            } else {
                Zephr_Company__c zephrCompany = new Zephr_Company__c();
                zephrCompany.Account__c = subscription.Account__c;
                zephrCompany.Zephr_Tenant__c = tenantId;
                zephrCompany.Zephr_Integration_Status__c = 'Pending';

                zephrCompaniesToInsert.add(zephrCompany);

                System.debug(LoggingLevel.ERROR, 'createZephrSubscriptionModel - zephrCompaniesToInsert: ' + zephrCompaniesToInsert);
                if (!accountIdTenantZephrCompanyMap.containsKey(zephrCompany.Account__c)) {
                    accountIdTenantZephrCompanyMap.put(zephrCompany.Account__c, new Map<String, Zephr_Company__c>());
                }
                accountIdTenantZephrCompanyMap.get(zephrCompany.Account__c).put(zephrCompany.Zephr_Tenant__c, zephrCompany);
            }

            zephrAccountsBySubscriptionIds.put(subscription.Id, zephrAccount);
        }

        if (!zephrCompaniesToInsert.isEmpty()) {
            insert zephrCompaniesToInsert;
        }

        for (Zephr_Account__c zephrAccount : zephrAccountsBySubscriptionIds.values()) {
            if (String.isBlank(zephrAccount.Zephr_Company__c)) {
                zephrAccount.Zephr_Company__c = accountIdTenantZephrCompanyMap.get(subscriptions.get(zephrAccount.Subscription__c).Account__c).get(zephrAccount.Zephr_Tenant__c).Id;
            }
        }

        insert zephrAccountsBySubscriptionIds.values();
        for (Subscription__c subscription : subscriptions.values()) {
            subscription.Zephr_Account__c = zephrAccountsBySubscriptionIds.get(subscription.Id).Id;
            for (Subscription_Product__c subscriptionProduct : subscription.Subscription_Items__r) {
                zephrAccountGrantsBySubscriptionProductIds.get(subscriptionProduct.Id).Zephr_Account__c = zephrAccountsBySubscriptionIds.get(subscription.Id).Id;
            }
        }
        insert zephrAccountGrantsBySubscriptionProductIds.values();

        update subscriptions.values();
        return subscriptionIds;

    }
}