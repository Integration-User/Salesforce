/**
* @author Zoran Zunko
* @date 7/7/21
*
*/
public with sharing class script_InvocableCreateSubscriptionUsers {
    public class CreateSubscriptionUserRequest {
        @InvocableVariable(Label = 'Subscription Id' Required = true Description='Id of the Subscription')
        public String subscriptionId;
        @InvocableVariable(Label = 'Contact Id' Required = true Description='Id of the Contact')
        public String contactId;
        @InvocableVariable(Label = 'Start Date/Time' Required = false Description = 'Start Date / Time for the Subscription User')
        public DateTime startDateTime;
        @InvocableVariable(Label = 'End Date/Time' Required = false Description = 'End Date / Time for the Subscription User')
        public DateTime endDateTime;

    }

    public class CreateSubscriptionUserResponse {
        @InvocableVariable(Label = 'Subscription Id' Description='Id of the Subscription')
        public String subscriptionId;
        @InvocableVariable(Label = 'Contact Id' Description='Id of the Contact')
        public String contactId;
        @InvocableVariable(Label = 'Subscription User Id' Description='Id of the created Subscription User')
        public String subscriptionUserId;
        @InvocableVariable(Label = 'Status Message')
        public String message;
        @InvocableVariable(Label = 'Error')
        public Boolean error;
    }

    @InvocableMethod public static List<CreateSubscriptionUserResponse> createSubscriptionUsers(List<CreateSubscriptionUserRequest> createSubscriptionUserRequests) {
        List<CreateSubscriptionUserResponse> response = new List<CreateSubscriptionUserResponse>();
        if(createSubscriptionUserRequests.isEmpty()) return response;
        List<Contact> subscriptionContacts = new List<Contact>();
        Set<Id> subscriptionIds = new Set<Id>();
        for (CreateSubscriptionUserRequest subscriptionUserRequest : createSubscriptionUserRequests) {
            if(String.isNotBlank(subscriptionUserRequest.contactId)) {
                subscriptionContacts.add(new Contact(Id = subscriptionUserRequest.contactId));
                subscriptionIds.add(subscriptionUserRequest.subscriptionId);
                if(subscriptionIds.size() > 1) break;
            }
        }
        if(subscriptionIds.size() > 1) {
            for (CreateSubscriptionUserRequest subscriptionUserRequest : createSubscriptionUserRequests) {
                CreateSubscriptionUserResponse singleResponse = new CreateSubscriptionUserResponse();
                singleResponse.subscriptionId = subscriptionUserRequest.subscriptionId;
                singleResponse.contactId = subscriptionUserRequest.contactId;
                singleResponse.message = 'Only users for a single subscription can be created this way.';
                singleResponse.error = true;

                response.add(singleResponse);
            }
            return response;
        }

        Subscription__c subscription = [SELECT Id, Zephr_Account__c, Number_of_Seats__c, Seats_Allocated__c, Start_Date__c, End_Date__c FROM Subscription__c WHERE Id IN :subscriptionIds];

        // Build a map of existing subscription users by email so we can get their Ids to update the dates
        List<Subscription_User__c> existingSubscriptionUsers = [SELECT Id, Contact__c, Contact__r.Email, Subscriber_Start_Date__c, Subscriber_End_Date__c FROM Subscription_User__c WHERE Contact__r.Email <> null AND Subscription_NG__c = :subscription.Id];
        Map<Id, Subscription_User__c> existingSubscribersByContactId = new Map<Id, Subscription_User__c>();
        for (Subscription_User__c existingSubscriptionUser : existingSubscriptionUsers) {
            if ( ! existingSubscribersByContactId.keyset().contains(existingSubscriptionUser.Contact__c)) {
                existingSubscribersByContactId.put(existingSubscriptionUser.Contact__c, existingSubscriptionUser);
            }
        }

        Map<Id, Contact> notSubscribedContacts = new Map<Id, Contact>(SubscriptionNGHelper.filterNotSubscribedContacts(subscriptionContacts, subscription));

        List<Subscription_User__c> subscriptionUsers = new List<Subscription_User__c>();
        List<Subscription_User__c> subscriptionUsersToUpdate = new List<Subscription_User__c>();
        List<Subscription_User__c> subscriptionUsersToProvisionInZephr = new List<Subscription_User__c>();
        Integer numberOfAdditionalActiveSubscribers = 0;

        Map<Id,Subscription_User__c> subscriptionUsersContactIdMap = new Map<Id, Subscription_User__c>();
        for (CreateSubscriptionUserRequest subscriptionUserRequest : createSubscriptionUserRequests) {
            // If the contact isn't already a subscriber, create the subscription user
            System.debug(LoggingLevel.DEBUG, 'script_InvocableCreateSubscriptionUsers.createSubscriptionUsers - subscriptionUserRequest: ' + subscriptionUserRequest);
            if(notSubscribedContacts.containsKey(subscriptionUserRequest.contactId)) {
                System.debug(LoggingLevel.DEBUG, 'script_InvocableCreateSubscriptionUsers.createSubscriptionUsers - notSubscribedContacts contains contactId');
                Subscription_User__c subscriptionUser = new Subscription_User__c(
                        Subscription_NG__c = subscriptionUserRequest.subscriptionId,
                        Contact__c = subscriptionUserRequest.contactId,
                        Subscriber_Start_Date__c = subscriptionUserRequest.startDateTime == null ? System.now() : subscriptionUserRequest.startDateTime,
                        Subscriber_End_Date__c = subscriptionUserRequest.endDateTime == null ? subscription.End_Date__c : subscriptionUserRequest.endDateTime,
                        Subscriber_Status__c = 'Inactive'
                );
                subscriptionUsers.add(subscriptionUser);
                subscriptionUsersContactIdMap.put(subscriptionUser.Contact__c, subscriptionUser);
                // Now we're setting dates, need to only include users who are currently active
                if (subscriptionUser.Subscriber_Start_Date__c <= System.now() && subscriptionUser.Subscriber_End_Date__c >= System.now()) {
                    numberOfAdditionalActiveSubscribers++;
                    subscriptionUsersToProvisionInZephr.add(subscriptionUser);
                    subscriptionUser.Subscriber_Status__c = 'Active';
                }
            }
            // Otherwise, if we have a date change, update the dates
            else  {
                System.debug(LoggingLevel.DEBUG, 'script_InvocableCreateSubscriptionUsers.createSubscriptionUsers - notSubscribedContacts DOES NOT contain contactId');
                if (subscriptionUserRequest.startDateTime != null || subscriptionUserRequest.endDateTime != null) {
                    Subscription_User__c subscriptionUserToUpdate= new Subscription_User__c(Id = existingSubscribersByContactId.get(subscriptionUserRequest.contactId).Id);
                    if (subscriptionUserRequest.startDateTime != null) {
                        subscriptionUserToUpdate.Subscriber_Start_Date__c = subscriptionUserRequest.startDateTime;
                    }
                    if (subscriptionUserRequest.endDateTime != null) {
                        subscriptionUserToUpdate.Subscriber_End_Date__c = subscriptionUserRequest.endDateTime;
                    }
                    subscriptionUsersToUpdate.add(subscriptionUserToUpdate);
                    // Now we're setting dates, need to only include users who were not active but will be now
                    Boolean wasAlreadyActive = existingSubscribersByContactId.get(subscriptionUserRequest.contactId).Subscriber_Start_Date__c <= System.now() &&
                            existingSubscribersByContactId.get(subscriptionUserRequest.contactId).Subscriber_End_Date__c >= System.now();
                    Boolean isNowActive = subscriptionUserToUpdate.Subscriber_Start_Date__c <= System.now() && subscriptionUserToUpdate.Subscriber_End_Date__c >= System.now();
                    if ( ( ! wasAlreadyActive ) && isNowActive) {
                        numberOfAdditionalActiveSubscribers++;
                        subscriptionUsersToProvisionInZephr.add(subscriptionUserToUpdate);
                    }

                }
            }

        }

        if(subscription.Number_of_Seats__c < (subscription.Seats_Allocated__c + numberOfAdditionalActiveSubscribers)) {
            for (CreateSubscriptionUserRequest subscriptionUserRequest : createSubscriptionUserRequests) {
                CreateSubscriptionUserResponse singleResponse = new CreateSubscriptionUserResponse();
                singleResponse.subscriptionId = subscriptionUserRequest.subscriptionId;
                singleResponse.contactId = subscriptionUserRequest.contactId;
                singleResponse.message = 'The number of subscribers is greater than then number of seats';
                singleResponse.error = true;

                response.add(singleResponse);
            }
            return response;
        }
        insert subscriptionUsers;
        update subscriptionUsersToUpdate;

        SubscriptionNGHelper.upsertZephrAccountGrants(subscriptionUsersToProvisionInZephr, subscription);

        for (CreateSubscriptionUserRequest subscriptionUserRequest : createSubscriptionUserRequests) {
            CreateSubscriptionUserResponse singleResponse = new CreateSubscriptionUserResponse();
            singleResponse.subscriptionId = subscriptionUserRequest.subscriptionId;
            singleResponse.contactId = subscriptionUserRequest.contactId;
            if(notSubscribedContacts.containsKey(subscriptionUserRequest.contactId)) {
                singleResponse.subscriptionUserId = subscriptionUserRequest.contactId;
                singleResponse.message = 'Created Subscription User';
                singleResponse.error = false;
            }
            else {
                singleResponse.subscriptionUserId = subscriptionUserRequest.contactId;
                singleResponse.message = 'Already subscribed';
                singleResponse.error = false;
            }

            response.add(singleResponse);
        }



        return response;

    }
}