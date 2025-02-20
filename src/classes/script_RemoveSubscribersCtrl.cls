/**
* @author Zoran Zunko
* @date 6/22/22
*
*/
public with sharing class script_RemoveSubscribersCtrl {
    public class GetSubscriptionUsersResponse {
        public List<Subscription_User__c> subscriptionUsers;
        public Integer newNumberOfSubscribers;
        public Integer numberOfSubscribers;
    }

    @AuraEnabled
    public static String getSubscriptionUsers(String subscriptionId) {
        List<Subscription_User__c> subscriptionUsers = [SELECT Id, Marked_For_Removal__c, Contact__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email FROM Subscription_User__c WHERE Subscription_NG__c = :subscriptionId];
        List<Subscription_Change__c> subscriptionChanges = [SELECT Id, Number_of_Seats__c, Subscription__r.Number_of_Seats__c FROM Subscription_Change__c WHERE Subscription__c = :subscriptionId AND Status__c = 'Pending' ORDER BY Start_Date__c ASC LIMIT 1];

        GetSubscriptionUsersResponse response = new GetSubscriptionUsersResponse();
        if(!subscriptionChanges.isEmpty()) {
            response.subscriptionUsers = subscriptionUsers;
            response.newNumberOfSubscribers = subscriptionChanges[0].Number_of_Seats__c.intValue();
            response.numberOfSubscribers = subscriptionChanges[0].Subscription__r.Number_of_Seats__c.intValue();
        }
        return JSON.serialize(response);
    }

    @AuraEnabled
    public static void setSubscriptionUsers(String subscriptionUsersJSON) {
        List<Subscription_User__c> subscriptionUsers = (List<Subscription_User__c>) JSON.deserialize(subscriptionUsersJSON, List<Subscription_User__c>.class);

        update subscriptionUsers;
    }
}