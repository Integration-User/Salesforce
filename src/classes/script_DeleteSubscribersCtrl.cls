/**
* @author Zoran Zunko
* @date 7/22/21
*
*/
public with sharing class script_DeleteSubscribersCtrl {

    public class DeleteSubscriberResponse {
        public Contact con;
        public Boolean deleted = false;
        public Boolean duplicate = false;
        public Boolean error = false;
        public String message;

    }

    public class DeleteSubscriberRequest {
        public List<Contact> contacts;
        public String subscriptionId;

        public DeleteSubscriberRequest() {
            this.contacts = new List<Contact>();
        }

    }

    @AuraEnabled
    public static String deleteContacts(String request) {
        System.debug(LoggingLevel.FINE, 'deleteContacts - request: ' + request);
        DeleteSubscriberRequest contactRequest = (DeleteSubscriberRequest) JSON.deserialize(request, DeleteSubscriberRequest.class);
        List<DeleteSubscriberResponse> response = new List<DeleteSubscriberResponse>();
        Map<String, DeleteSubscriberResponse> responseMap = new Map<String, DeleteSubscriberResponse>();
        List<Contact> contacts = contactRequest.contacts;
        Map<String, Contact> contactsByEmails = new Map<String, Contact>();
        for (Contact con : contacts) {
            if (String.isBlank(con.Email) || contactsByEmails.containsKey(con.Email)) continue;
            con.Email = con.Email.replace(' ', '').toLowerCase();
            contactsByEmails.put(con.Email, con);
        }

        List<Subscription_User__c> existingSubscriptionUsers = [SELECT Id, Zephr_User_Account_Grant__r.Zephr_User__r.Email_Address__c FROM Subscription_User__c WHERE Subscription_NG__c = :contactRequest.subscriptionId AND Zephr_User_Account_Grant__r.Zephr_User__r.Email_Address__c IN :contactsByEmails.keySet()];
        Map<String, Subscription_User__c> existingSubUsersByEmails = new Map<String, Subscription_User__c>();
        Map<Id, String> existingSubUserEmailsById = new Map<Id,String>();
        for (Subscription_User__c subscriptionUser : existingSubscriptionUsers) {
            existingSubUsersByEmails.put(subscriptionUser.Zephr_User_Account_Grant__r.Zephr_User__r.Email_Address__c.toLowerCase(), subscriptionUser);
            existingSubUserEmailsById.put(subscriptionUser.Id,subscriptionUser.Zephr_User_Account_Grant__r.Zephr_User__r.Email_Address__c.toLowerCase());
        }

        // List<Subscription_User__c> subscriptionUsersToDelete = new List<Subscription_User__c>();
        List<Subscription_User__c> subscriptionUsersToUpdate = new List<Subscription_User__c>();

        for (Contact con : contacts) {
            DeleteSubscriberResponse singleResponse = new DeleteSubscriberResponse();
            singleResponse.con = con;
            responseMap.put(singleResponse.con.Email, singleResponse);
            if (String.isNotBlank(con.Email) && contactsByEmails.containsKey(con.Email)) {
                if (existingSubUsersByEmails.containsKey(con.Email)) {
                    // subscriptionUsersToDelete.add(existingSubUsersByEmails.get(con.Email));
                    subscriptionUsersToUpdate.add(new Subscription_User__c(
                            Id = existingSubUsersByEmails.get(con.Email).Id,
                            Subscriber_End_Date__c = DateTime.now(),
                            Subscriber_Status__c = 'Inactive'
                    ));
                } else {
                    if (contactsByEmails.get(con.Email) == con) {
                        singleResponse.message = 'Not an active subscriber';
                    }
                }
            } else if (String.isBlank(con.Email)) {
                singleResponse.error = true;
                singleResponse.message = 'Missing email';
            }
            response.add(singleResponse);
        }
        // if (!subscriptionUsersToDelete.isEmpty()) {
        if (!subscriptionUsersToUpdate.isEmpty()) {

            // Database.DeleteResult[] subscriptionUserResults = Database.delete(subscriptionUsersToDelete, false);
            Database.SaveResult[] subscriptionUserResults = Database.update(subscriptionUsersToUpdate, false);
            for (Integer i = 0; i < subscriptionUserResults.size(); i++) {
                Database.SaveResult subscriptionUserResult = subscriptionUserResults[i];
                System.debug(LoggingLevel.FINE, 'deleteContacts - subscriptionUsersToDelete[i].Zephr_User_Account_Grant__r.Zephr_User__r.Email_Address__c: ' + existingSubUserEmailsById.get(subscriptionUsersToUpdate[i].Id));
                DeleteSubscriberResponse singleResponse = responseMap.get(existingSubUserEmailsById.get(subscriptionUsersToUpdate[i].Id));
                if (subscriptionUserResult.success) {
                    singleResponse.deleted = true;
                    singleResponse.message = 'Deactivated';
                } else {
                    singleResponse.error = true;
                    singleResponse.message = JSON.serialize(subscriptionUserResult.errors);
                }
            }
        }
        System.debug(LoggingLevel.FINE, 'deleteContacts - response: ' + JSON.serializePretty(response));

        return JSON.serialize(response);
    }
}