/**
 *
 * No try catches deliberately so we can see as many errors as possible during initial testing
* @author Zoran Zunko
* @date 7/6/21
*
*/
public with sharing class script_UploadSubscribersCtrl {

    public class CreateContactsResponse {
        public Contact con;
        public Boolean created = false;
        public Boolean duplicate = false;
        public Boolean error = false;
        public String message;

    }

    public class CreateContactsRequest {
        public List<Contact> contacts;
        public String subscriptionId;

        public CreateContactsRequest() {
            this.contacts = new List<Contact>();
        }

    }

    @AuraEnabled
    public static String createContacts(String request) {
        System.debug(LoggingLevel.FINE, 'createContacts - request: ' + request);
        CreateContactsRequest contactRequest = (CreateContactsRequest) JSON.deserialize(request, CreateContactsRequest.class);
        List<CreateContactsResponse> response = new List<CreateContactsResponse>();
        Map<String, CreateContactsResponse> responseMap = new Map<String, CreateContactsResponse>();
        List<Contact> contacts = contactRequest.contacts;
        Map<String, Contact> contactsByEmails = new Map<String, Contact>();
        for (Contact con : contacts) {
            if (String.isBlank(con.Email) || contactsByEmails.containsKey(con.Email)) continue;
            con.Email = con.Email.replace(' ', '').toLowerCase();
            contactsByEmails.put(con.Email, con);
        }

        Subscription__c subscription = [SELECT Id, Account__c FROM Subscription__c WHERE Id = :contactRequest.subscriptionId];
        System.debug(LoggingLevel.FINE, 'createContacts - contactRequest.subscriptionId: ' + contactRequest.subscriptionId);

        List<Contact> existingContacts = [SELECT Id, Email FROM Contact WHERE AccountId = :subscription.Account__c AND Email IN :contactsByEmails.keySet()];
//        List<Contact> existingContacts = [SELECT Id, Email FROM Contact WHERE AccountId = :subscription.Account__c AND Email IN :contactsByEmails.keySet()];
        Map<String, Contact> existingContactsByEmails = new Map<String, Contact>();
        for (Contact existingContact : existingContacts) {
            existingContactsByEmails.put(existingContact.Email.toLowerCase(), existingContact);
        }

        List<Contact> contactsToInsert = new List<Contact>();

        for (Contact con : contacts) {
            CreateContactsResponse singleResponse = new CreateContactsResponse();
            singleResponse.con = con;
            responseMap.put(singleResponse.con.Email, singleResponse);
            if (String.isNotBlank(con.Email) && contactsByEmails.containsKey(con.Email)) {
                if (existingContactsByEmails.containsKey(con.Email)) {
                    con.Id = existingContactsByEmails.get(con.Email).Id;
                    singleResponse.message = 'Existing contact';
                } else if (contactsByEmails.get(con.Email) == con) {
                    contactsByEmails.get(con.Email).AccountId = subscription.Account__c;
                    contactsToInsert.add(contactsByEmails.get(con.Email));
                }
            } else if (String.isBlank(con.Email)) {
                singleResponse.error = true;
                singleResponse.message = 'Missing email';
            }

            response.add(singleResponse);
        }
        System.debug(LoggingLevel.FINE, 'createContacts - response: ' + JSON.serializePretty(response));
        System.debug(LoggingLevel.FINE, 'createContacts - contactsToInsert: ' + contactsToInsert);
        if (!contactsToInsert.isEmpty()) {
            Database.SaveResult[] contactResults = Database.insert(contactsToInsert, false);
            for (Integer i = 0; i < contactResults.size(); i++) {
                Database.SaveResult contactResult = contactResults[i];
                System.debug(LoggingLevel.FINE, 'createContacts - contactsToInsert[i].Email: ' + contactsToInsert[i].Email);
                CreateContactsResponse singleResponse = responseMap.get(contactsToInsert[i].Email);
                if (contactResult.success) {
                    System.debug(LoggingLevel.FINE, 'createContacts - contactsToInsert[i].Id: ' + contactsToInsert[i].Id);
                    System.debug(LoggingLevel.FINE, 'createContacts - contactResult.id: ' + contactResult.id);
                    singleResponse.created = true;
                    singleResponse.message = 'Created';
                } else {
                    singleResponse.error = true;
                    singleResponse.message = JSON.serialize(contactResult.errors);
                    if(singleResponse.message.contains('DUPLICATES_DETECTED')) {
                        singleResponse.message = 'Contact exists on another account';
                    }
                }
            }
        }
        System.debug(LoggingLevel.FINE, 'createContacts - response: ' + JSON.serializePretty(response));

        List<script_InvocableCreateSubscriptionUsers.CreateSubscriptionUserRequest> subscriptionUserRequests = new List<script_InvocableCreateSubscriptionUsers.CreateSubscriptionUserRequest>();
        for (Contact con : contacts) {
            System.debug(LoggingLevel.FINE, 'createContacts - con.Email: ' + con.Email);
            CreateContactsResponse singleResponse = responseMap.get(con.Email);
            System.debug(LoggingLevel.FINE, 'createContacts - singleResponse.error: ' + singleResponse.error);
            if (!singleResponse.error) {
                script_InvocableCreateSubscriptionUsers.CreateSubscriptionUserRequest subscriptionUserRequest = new script_InvocableCreateSubscriptionUsers.CreateSubscriptionUserRequest();
                subscriptionUserRequest.contactId = singleResponse.con.Id;
                subscriptionUserRequest.subscriptionId = subscription.Id;
                subscriptionUserRequests.add(subscriptionUserRequest);
            }
        }

        System.debug(LoggingLevel.FINE, 'createContacts - subscriptionUserRequests: ' + subscriptionUserRequests);
        List<script_InvocableCreateSubscriptionUsers.CreateSubscriptionUserResponse> subscriptionUserResponses = script_InvocableCreateSubscriptionUsers.createSubscriptionUsers(subscriptionUserRequests);
        Map<Id, script_InvocableCreateSubscriptionUsers.CreateSubscriptionUserResponse> subscriptionUserResponsesMap = new Map<Id, script_InvocableCreateSubscriptionUsers.CreateSubscriptionUserResponse>();
        for (script_InvocableCreateSubscriptionUsers.CreateSubscriptionUserResponse subscriptionUserResponse : subscriptionUserResponses) {
            subscriptionUserResponsesMap.put(subscriptionUserResponse.contactId, subscriptionUserResponse);
        }

        for (CreateContactsResponse contactsResponse : response) {
            if (subscriptionUserResponsesMap.containsKey(contactsResponse.con.Id)) {
                script_InvocableCreateSubscriptionUsers.CreateSubscriptionUserResponse subscriptionUserResponse = subscriptionUserResponsesMap.get(contactsResponse.con.Id);
                contactsResponse.error = subscriptionUserResponse.error;
                contactsResponse.message = subscriptionUserResponse.message;
            }
        }

        return JSON.serialize(response);
    }

    @AuraEnabled
    public static void pushToZephr(String subscriptionId) {
        zephr_InvocableStartSubProvisioning.startSubscriptionProvisioningQueueable(new List<String>{
                subscriptionId
        });
    }
}