/**
* @author Zoran Zunko
* @date 12/3/21
*
*/

public with sharing class script_InvocableCreateSubUsersBulk {
    public class CreateSubscriptionUsersRequest {
        @InvocableVariable(Label = 'Subscription Id' Required = true Description='Id of the Subscription')
        public String subscriptionId;
        @InvocableVariable(Label = 'Source Subscription Id' Required = true Description='Id of the Subscription to be copied')
        public String sourceSubscriptionId;
    }

    public class CreateSubscriptionUsersResponse {
        @InvocableVariable(Label = 'Subscription Id' Description='Id of the Subscription')
        public String subscriptionId;
        @InvocableVariable(Label = 'Status Message')
        public String message;
        @InvocableVariable(Label = 'Error')
        public Boolean error;
    }

    @InvocableMethod(Label='Create Bulk Subscription Users' Description='Copies all subscribers from the source Subscription')
    public static List<CreateSubscriptionUsersResponse> createSubscriptionUsers(List<CreateSubscriptionUsersRequest> createSubscriptionUserRequests) {
        List<CreateSubscriptionUsersResponse> response = new List<CreateSubscriptionUsersResponse>();
        if (createSubscriptionUserRequests.isEmpty()) return response;
        List<Contact> subscriptionContacts = new List<Contact>();
        Set<Id> subscriptionIds = new Set<Id>();
        Set<Id> sourceSubscriptionIds = new Set<Id>();
        for (CreateSubscriptionUsersRequest subscriptionUserRequest : createSubscriptionUserRequests) {
            subscriptionIds.add(subscriptionUserRequest.subscriptionId);
            sourceSubscriptionIds.add(subscriptionUserRequest.sourceSubscriptionId);
            if (subscriptionIds.size() > 1) break;
        }

        if (subscriptionIds.size() > 1) {
            for (CreateSubscriptionUsersRequest subscriptionUserRequest : createSubscriptionUserRequests) {
                CreateSubscriptionUsersResponse singleResponse = new CreateSubscriptionUsersResponse();
                singleResponse.subscriptionId = subscriptionUserRequest.subscriptionId;
                singleResponse.message = 'Only users for a single subscription can be created this way.';
                singleResponse.error = true;
                response.add(singleResponse);
            }
            return response;
        }
        List<Subscription_User__c> existingSubscriptionUsers = [SELECT Id, Contact__c, Contact__r.Name FROM Subscription_User__c WHERE Subscription_NG__c IN :sourceSubscriptionIds AND Contact__c != NULL];
        for (Subscription_User__c subscriptionUser : existingSubscriptionUsers) {
            subscriptionContacts.add(new Contact(Id = subscriptionUser.Contact__c));
        }
        Subscription__c subscription = [SELECT Id, Zephr_Account__c, Number_of_Seats__c, Seats_Allocated__c, Start_Date__c, End_Date__c FROM Subscription__c WHERE Id IN :subscriptionIds];
        Map<Id, Contact> notSubscribedContacts = new Map<Id, Contact>(SubscriptionNGHelper.filterNotSubscribedContacts(subscriptionContacts, subscription));

        List<Subscription_User__c> subscriptionUsers = new List<Subscription_User__c>();
        Map<Id, Subscription_User__c> subscriptionUsersContactIdMap = new Map<Id, Subscription_User__c>();
        for (Subscription_User__c existingSubscriptionUser : existingSubscriptionUsers) {
            if (notSubscribedContacts.containsKey(existingSubscriptionUser.Contact__c)) {
                Subscription_User__c subscriptionUser = new Subscription_User__c(
                        Subscription_NG__c = subscription.Id,
                        Contact__c = existingSubscriptionUser.Contact__c,
                        Subscriber_Start_Date__c = System.now(),
                        Subscriber_End_Date__c = subscription.End_Date__c,
                        Subscriber_Status__c = 'Active'
                );
                subscriptionUsers.add(subscriptionUser);
                subscriptionUsersContactIdMap.put(subscriptionUser.Contact__c, subscriptionUser);
            }

        }
        if (subscription.Number_of_Seats__c < (subscription.Seats_Allocated__c + subscriptionUsers.size())) {
            for (CreateSubscriptionUsersRequest subscriptionUserRequest : createSubscriptionUserRequests) {
                CreateSubscriptionUsersResponse singleResponse = new CreateSubscriptionUsersResponse();
                singleResponse.subscriptionId = subscriptionUserRequest.subscriptionId;
                singleResponse.message = 'The number of subscribers is greater than then number of seats';
                singleResponse.error = true;
                response.add(singleResponse);
            }
            return response;
        }
        insert subscriptionUsers;

        SubscriptionNGHelper.upsertZephrAccountGrants(subscriptionUsers, subscription);

        CreateSubscriptionUsersResponse singleResponse = new CreateSubscriptionUsersResponse();
        singleResponse.subscriptionId = subscription.Id;
        singleResponse.message = '';
        for (Subscription_User__c existingSubscriptionUser : existingSubscriptionUsers) {

            if (notSubscribedContacts.containsKey(existingSubscriptionUser.Contact__c)) {
                singleResponse.message += 'Created Subscription User: ' + existingSubscriptionUser.Contact__r.Name + '\n';
                singleResponse.error = false;
            } else {
                singleResponse.message += 'Already subscribed: ' + existingSubscriptionUser.Contact__r.Name + '\n';
                singleResponse.error = false;
            }
        }
        response.add(singleResponse);
        return response;
    }
}