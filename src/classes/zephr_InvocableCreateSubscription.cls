/**
* @author Zoran Zunko
* @date 6/10/21
*
*/
public with sharing class zephr_InvocableCreateSubscription {
    public class CreateSubscriptionResponse {
        @InvocableVariable(Label = 'Subscription Id' Required = true Description='Id of the created subscription')
        public String subscriptionId;
    }
    @InvocableMethod public static List<CreateSubscriptionResponse> createSubscriptionRecords(List<String> orderIds) {
        List<CreateSubscriptionResponse> response = new List<zephr_InvocableCreateSubscription.CreateSubscriptionResponse>();

        Map<Id, OrderItem> orderItems = new Map<Id, OrderItem>([
                SELECT
                        CurrencyIsoCode,
                        Description,
                        EndDate,
                        Id,
                        OrderId,
                        Order.AccountId,
                        OrderItemNumber,
                        Product2Id,
                        Product2.ZephrEntitlementId__c,
                        Product2.Zephr_Tenant__c,
                        Quantity,
                        ServiceDate
                FROM OrderItem
                WHERE OrderId IN :orderIds
        ]);


        Map<Id, Subscription__c> orderItemSubscriptionMap = new Map<Id, Subscription__c>();
        Map<Id, Subscription_Product__c> orderItemSubscriptionProductMap = new Map<Id, Subscription_Product__c>();
        Set<Id> accountIds = new Set<Id>();
        Set<String> zephrTenants = new Set<String>();
        for (OrderItem ordli : orderItems.values()) {
            accountIds.add(ordli.Order.AccountId);
            zephrTenants.add(ordli.Product2.Zephr_Tenant__c);

            Subscription__c newSubscription = new Subscription__c();
            newSubscription.Account__c = ordli.Order.AccountId;
            newSubscription.CurrencyIsoCode = ordli.CurrencyIsoCode;
            newSubscription.Order__c = ordli.OrderId;
            newSubscription.Order_Product__c = ordli.Id;
            newSubscription.Type__c = 'Group';
//            newSubscription.Start_Date__c = ordli.ServiceDate;
//            newSubscription.Original_Start_Date__c = ordli.ServiceDate;
//            newSubscription.End_Date__c = ordli.EndDate;
//            newSubscription.Original_End_Date__c = ordli.EndDate;
            newSubscription.Number_of_Seats__c = ordli.Quantity;

            orderItemSubscriptionMap.put(ordli.Id, newSubscription);

            Subscription_Product__c newSubscriptionProduct = new Subscription_Product__c();
            newSubscriptionProduct.Product__c = ordli.Product2Id;
            newSubscriptionProduct.Start_Date__c = ordLi.ServiceDate;
            newSubscriptionProduct.End_Date__c = ordli.EndDate;
            orderItemSubscriptionProductMap.put(ordli.Id, newSubscriptionProduct);
        }

        insert orderItemSubscriptionMap.values();

        for (Id ordliId : orderItemSubscriptionProductMap.keySet()) {
            orderItemSubscriptionProductMap.get(ordliId).Subscription__c = orderItemSubscriptionMap.get(ordliId).Id;
        }

        insert orderItemSubscriptionProductMap.values();

        for (Subscription__c subscription : orderItemSubscriptionMap.values()) {
            CreateSubscriptionResponse subscriptionResponse = new CreateSubscriptionResponse();
            subscriptionResponse.subscriptionId = subscription.Id;

            response.add(subscriptionResponse);
        }
        return response;

    }
}