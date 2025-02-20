/**
 * Created by david on 12/06/2021.
 */

public with sharing class SubscriptionNGHelper {
    /**
     * Filters a provided list of contacts, and returns a new list without the contacts that are already linked to the provided subscription
     *
     * Used to easily get a list of new contacts to add.
     *
     * @param contacts contacts to check
     * @param theSubscription subscritpion for check
     *
     * @return list of contacts not subscribed
     */
    public static List<Contact> filterNotSubscribedContacts(List<Contact> contacts, Subscription__c theSubscription) {
        List<Contact> outputContacts = new List<Contact>();
        Set<Id> existingContactIds = new Set<Id>();
        try {
            List<Subscription_User__c> subscriptionUsers = [SELECT Id, Contact__c FROM Subscription_User__c WHERE Subscription_NG__c = :theSubscription.Id];
            for (Subscription_User__c subscriptionUser : subscriptionUsers) {
                existingContactIds.add(subscriptionUser.Contact__c);
            }
            for (Contact loopContact : contacts) {
                if (!existingContactIds.contains(loopContact.Id)) {
                    outputContacts.add(loopContact);
                }
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + ' - ' + ex.getStackTraceString());
            ZephrIntegrationService.publishErrorEvent(UserInfo.getUserName(), ex.getStackTraceString(), ex.getMessage(), 'SubscriptionNGHelper - non network error');
        }
        return outputContacts;
    }

    /**
     * Create a set of Zephr Users and Zephr User Account Grants for the provided Subscription and Users
     *
     * This is tricky to do in flows because Zephr User is unique by tenant / email address
     * This makes it easier...
     *
     * @param subscriptionUsers users for grants
     * @param theSubscription subscription
     * @return account grants with new ones
     */
    public static List<Zephr_User_Account_Grant__c> upsertZephrAccountGrants(List<Subscription_User__c> subscriptionUsers, Subscription__c theSubscription) {
        System.debug(LoggingLevel.DEBUG, 'SubscriptionNGHelper.upsertZephrAccountGrants');
        Map<Subscription_User__c, Zephr_User__c> zephrUsersMappedBySubscriptionUsers = new Map<Subscription_User__c, Zephr_User__c>();
        Map<Id, String> emailsMappedByObjectId = new Map<Id, String>();
        Map<String, Zephr_User__c> zephrUsersMappedByEmail = new Map<String, Zephr_User__c>();
        String sObjectEmail;

        // Email addresses for the users
        Set<String> emailAddresses = new Set<String>();
        Set<Id> userContactIds = new Set<Id>();
        Set<Id> userLeadIds = new Set<Id>();
        // We need the tenant
        Zephr_Account__c theZephrAccount = [SELECT Id, Zephr_Tenant__c FROM Zephr_Account__c WHERE Id = :theSubscription.Zephr_Account__c];

        // Build a list of Lead and Contact IDs because a Subscription User can be linked to either
        for (Subscription_User__c subscriptionUser : subscriptionUsers) {
            if (subscriptionUser.Contact__c != null) {
                userContactIds.add(subscriptionUser.Contact__c);
            }
            if (subscriptionUser.Lead__c != null) {
                userLeadIds.add(subscriptionUser.Lead__c);
            }
        }

        // Build a list of Contact email addresses and a map of email addresses by ID
        List<Contact> userContacts = [SELECT Id, Email FROM Contact WHERE Id IN :userContactIds];
        for (Contact loopContact : userContacts) {
            emailAddresses.add(loopContact.Email);
            emailsMappedByObjectId.put(loopContact.Id, loopContact.Email);
        }

        // Build a list of Lead email addresses and a map of email addresses by ID
        List<Lead> userLeads = [SELECT Id, Email FROM Lead WHERE Id IN :userLeadIds];
        for (Lead loopLead : userLeads) {
            emailAddresses.add(loopLead.Email);
            emailsMappedByObjectId.put(loopLead.Id, loopLead.Email);
        }

        // Build a list of existing Zephr Users mapped by email address, for the Lead and Contact emails that we have collected
        List<Zephr_User__c> tenantZephrUsers = [SELECT Id, Email_Address__c, Zephr_Email__c FROM Zephr_User__c WHERE Zephr_Tenant__c = :theZephrAccount.Zephr_Tenant__c AND (Email_Address__c IN :emailAddresses OR Zephr_Email__c IN :emailAddresses)];
        for (Zephr_User__c tenantZephrUser : tenantZephrUsers) {
            if (String.isNotBlank(tenantZephrUser.Email_Address__c)) {
                zephrUsersMappedByEmail.put(tenantZephrUser.Email_Address__c, tenantZephrUser);
            } else {
                zephrUsersMappedByEmail.put(tenantZephrUser.Zephr_Email__c, tenantZephrUser);
            }
        }


        // If there's a Zephr User for each Subscription User email address, add it to the map of new data,
        // Otherwise add a new Zephr User
        for (Subscription_User__c subscriptionUser : subscriptionUsers) {
            sObjectEmail = '';
            if (subscriptionUser.Contact__c != null) {
                sObjectEmail = emailsMappedByObjectId.get(subscriptionUser.Contact__c);
            } else if (subscriptionUser.Lead__c != null) {
                sObjectEmail = emailsMappedByObjectId.get(subscriptionUser.Lead__c);
            }
            if (sObjectEmail != '') {
                if (zephrUsersMappedByEmail.get(sObjectEmail) != null) {
                    zephrUsersMappedBySubscriptionUsers.put(subscriptionUser, zephrUsersMappedByEmail.get(sObjectEmail));
                } else {
                    zephrUsersMappedBySubscriptionUsers.put(subscriptionUser, new Zephr_User__c(
                            Zephr_Integration_Status__c = 'Pending',
                            Zephr_Tenant__c = theZephrAccount.Zephr_Tenant__c,
                            Contact__c = subscriptionUser.Contact__c,
                            Lead__c = subscriptionUser.Lead__c
                    ));
                }
            }
        }
        upsert zephrUsersMappedBySubscriptionUsers.values();
        System.debug(LoggingLevel.DEBUG, zephrUsersMappedBySubscriptionUsers.values());

        /**
         * Build a set of Zephr Users who already have a User Account Grant for this Zephr Account, so we don't add them again
        */

        // Retrieve a list of Zephr User Account Grants for the Subscription
        Map<Id, Zephr_User_Account_Grant__c> existingUserAccountGrants = new Map<Id, Zephr_User_Account_Grant__c>([SELECT Id, Zephr_User__c, Zephr_Account__c, Subscription_User__c FROM Zephr_User_Account_Grant__c WHERE Zephr_Account__c = :theZephrAccount.Id]);
        // Hold a list of the Zephr_User__c Ids that these grants are linked to
        List<Id> zephrUsersWithGrants = new List<Id>();
        // Hold a list of the grants mapped by the Zephr_User__c Ids that these grants are linked to
        Map<Id, Zephr_User_Account_Grant__c> existingUserAccountGrantsByZephrUserId = new Map<Id, Zephr_User_Account_Grant__c>();

        for (Zephr_User_Account_Grant__c existingUserAccountGrant : existingUserAccountGrants.values()) {
            zephrUsersWithGrants.add(existingUserAccountGrant.Zephr_User__c);
            existingUserAccountGrantsByZephrUserId.put(existingUserAccountGrant.Zephr_User__c, existingUserAccountGrant);
        }
        System.debug(LoggingLevel.DEBUG, zephrUsersWithGrants);
        System.debug(LoggingLevel.DEBUG, existingUserAccountGrantsByZephrUserId);


        /**
        * Iterate over the Subscription Users and generate new Zephr User Account Grants for any Zephr Users who do not already have one
        */

        // List of new Zephr User Account Grants to insert
        List<Zephr_User_Account_Grant__c> zephrUserAccountGrants = new List<Zephr_User_Account_Grant__c>();
        Zephr_User__c relevantZephrUser;
        // Existing Zephr User Account Grant thaht we found not linked to the Subscription User
        Zephr_User_Account_Grant__c existingGrantForUser;
        // List of Zephr User Account Grants that we need to update to link them with the Subscription User
        List<Zephr_User_Account_Grant__c> zuagWithoutSubUserLookup = new List<Zephr_User_Account_Grant__c>();

        // Loop over Subscription Users
        for (Subscription_User__c subscriptionUser : zephrUsersMappedBySubscriptionUsers.keySet()) {
            System.debug(LoggingLevel.DEBUG, subscriptionUser);
            System.debug(LoggingLevel.DEBUG, zephrUsersMappedBySubscriptionUsers.get(subscriptionUser).Id);
            // Get the Zephr User for this Subscription User
            relevantZephrUser = zephrUsersMappedBySubscriptionUsers.get(subscriptionUser);
            System.debug(LoggingLevel.DEBUG, relevantZephrUser);
            // If we don't have a Zephr User Account Grant for this Zephr User, create one
            if (!zephrUsersWithGrants.contains(relevantZephrUser.Id)) {
                System.debug(LoggingLevel.DEBUG, 'Adding new Zephr User Account Grant');
                zephrUserAccountGrants.add(new Zephr_User_Account_Grant__c(
                        Subscription_User__c = subscriptionUser.Id,
                        Zephr_User__c = relevantZephrUser.Id,
                        Zephr_Account__c = theZephrAccount.Id,
                        Zephr_Integration_Status__c = 'Pending'
                ));
            // If we do have a Zephr User Account Grant for this Zephr User, then it must not be linked to the Subscription User - link it
            } else {
                System.debug(LoggingLevel.DEBUG, 'Zephr User already has a user account grant');
                // Sometimes ZUAGs become detached from the Subscription User - this reattaches them
                existingGrantForUser = existingUserAccountGrantsByZephrUserId.get(relevantZephrUser.Id);
                if (existingGrantForUser.Subscription_User__c == null) {
                    System.debug(LoggingLevel.DEBUG, 'Zephr User already has a user account grant and we will ink it to this Subscription User');
                    existingGrantForUser.Subscription_User__c = subscriptionUser.Id;
                    zuagWithoutSubUserLookup.add(existingGrantForUser);
                }
                else {
                    System.debug(LoggingLevel.DEBUG, 'Zephr User already has a user account grant and the user account grant is linked to a subscription user ' + existingGrantForUser.Subscription_User__c);
                }
            }
        }
        System.debug(LoggingLevel.DEBUG, zephrUserAccountGrants);
        insert zephrUserAccountGrants;

        System.debug(LoggingLevel.DEBUG, zuagWithoutSubUserLookup);
        update zuagWithoutSubUserLookup;

        zephrUserAccountGrants.addAll(zuagWithoutSubUserLookup);


        return zephrUserAccountGrants;
    }


}