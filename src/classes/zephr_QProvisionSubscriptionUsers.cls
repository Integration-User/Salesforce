/**
* @author Zoran Zunko
* @date 10/27/21
*
*/

public with sharing class zephr_QProvisionSubscriptionUsers implements Queueable, Database.AllowsCallouts {
    public List<Id> subscriptionIds;
    public void execute(QueueableContext qc) {
        if (subscriptionIds.isEmpty()) return;
        Map<Id, Zephr_User__c> newZephrUsers;
        Map<Id, Zephr_User_Account_Grant__c> zephrUserAccountGrants;
        Map<Id, Zephr_User_Grant__c> zephrUserGrants;
        Map<Id, String> zephrWebsiteBySubscription;

        zephrUserAccountGrants = getZephrUserAccountGrants(subscriptionIds);
        zephrWebsiteBySubscription = getSubscriptionWebsites(subscriptionIds);
        System.debug(LoggingLevel.FINE, 'execute - zephrUserAccountGrants.size(): ' + zephrUserAccountGrants.size());
        newZephrUsers = provisionZephrUsers(zephrUserAccountGrants, zephrWebsiteBySubscription);
        if (!limitsReached) {
            zephrUserGrants = getZephrUserGrants(subscriptionIds);
            newZephrUsers.putAll(provisionZephrUsers(zephrUserGrants));
            System.debug(LoggingLevel.FINE, 'execute - newZephrUsers: ' + JSON.serialize(newZephrUsers));
        }
        if (newZephrUsers != null && !newZephrUsers.isEmpty()) {
            Database.SaveResult[] saveResults = Database.update(newZephrUsers.values(), false);
            List<Zephr_User__c> zephrUsersWithErrors = new List<Zephr_User__c>();
            for (Database.SaveResult saveResult : saveResults) {
                if (!saveResult.success) {
                    Zephr_User__c zephrUser = newZephrUsers.get(saveResult.getId());
                    zephrUser.Zephr_Id__c = null;
                    zephrUser.Zephr_Integration_Status__c = 'Error';
                    zephrUser.Zephr_Integration_Message__c = JSON.serializePretty(saveResult.getErrors());

                    zephrUsersWithErrors.add(zephrUser);
                }
            }
            if(!zephrUsersWithErrors.isEmpty()) update zephrUsersWithErrors;
        }
        if (limitsReached) {//todo check if there are any more to provision...
            zephr_QProvisionSubscriptionUsers zephrQProvisionSubscriptionUsers = new zephr_QProvisionSubscriptionUsers();
            zephrQProvisionSubscriptionUsers.subscriptionIds = this.subscriptionIds;
            System.enqueueJob(zephrQProvisionSubscriptionUsers);
        } else if (!Test.isRunningTest()) {
            zephr_QProvisionSubscriptionUserGrants zephrQProvisionSubscriptionUserGrants = new zephr_QProvisionSubscriptionUserGrants();
            zephrQProvisionSubscriptionUserGrants.subscriptionIds = this.subscriptionIds;
            System.enqueueJob(zephrQProvisionSubscriptionUserGrants);
        }
    }

    Boolean limitsReached = false;

    @TestVisible Integer getRemainingCallouts() {
        return (Limits.getLimitCallouts() - Limits.getCallouts() - 2);
    }

    @TestVisible Map<Id, Zephr_User_Grant__c> getZephrUserGrants(List<Id> subscriptionIds) {
        return new Map<Id, Zephr_User_Grant__c>([
                SELECT
                        End_Date__c,
                        Name,
                        Product__r.ZephrEntitlementId__c,
                        Product__r.Zephr_Website__c,
                        Start_Date__c,
                        Subscription__c,
                        Zephr_API_URL__c,
                        Zephr_Id__c,
                        Zephr_Integration_Message__c,
                        Zephr_Integration_Status__c,
                        Zephr_Tenant__c,
                        Zephr_User__c,
                        Zephr_User__r.Name,
                        Zephr_User__r.Zephr_Company__c,
                        Zephr_User__r.Zephr_Id__c,
                        Zephr_User__r.Zephr_Integration_Message__c,
                        Zephr_User__r.Zephr_Integration_Status__c,
                        Zephr_User__r.Zephr_Tenant__c,
                        Zephr_User__r.Zephr_Email__c,
                        Zephr_User__r.Zephr_Email_Verified__c,
                        Subscription_User__c,
                        Subscription_User__r.Contact__c,
                        Subscription_User__r.Contact__r.FirstName,
                        Subscription_User__r.Contact__r.LastName,
                        Subscription_User__r.Contact__r.Email,
                        Subscription_User__r.Contact__r.Account.Name,
                        Subscription_User__r.Contact__r.Title,
                        Subscription_User__r.Contact__r.MailingCity,
                        Subscription_User__r.Contact__r.MailingCountry,
                        Subscription_User__r.Contact__r.Phone,
                        Subscription_User__r.Contact__r.Account.Company_Type__c,
                        Subscription_User__r.Lead__r.FirstName,
                        Subscription_User__r.Lead__r.LastName,
                        Subscription_User__r.Lead__r.Email,
                        Subscription_User__r.Lead__r.Company,
                        Subscription_User__r.Lead__r.Title,
                        Subscription_User__r.Lead__r.City,
                        Subscription_User__r.Lead__r.Country,
                        Subscription_User__r.Lead__r.Phone,
                        Subscription_User__r.Lead__r.Company_Type__c
                FROM Zephr_User_Grant__c
                WHERE Subscription_User__r.Subscription_NG__c IN :subscriptionIds AND (Zephr_Integration_Status__c = 'Pending' OR Zephr_Integration_Status__c = 'Error')
        ]);
    }

    @TestVisible Map<Id, Zephr_User_Account_Grant__c> getZephrUserAccountGrants(List<Id> subscriptionIds) {
        return new Map<Id, Zephr_User_Account_Grant__c>([
                SELECT
                        CurrencyIsoCode,
                        Id,
                        Name,
                        Zephr_Account__c,
                        Zephr_Account__r.Zephr_Id__c,
                        Zephr_Account__r.Subscription__c,
                        Zephr_Account_Id__c,
                        Zephr_API_URL__c,
                        Zephr_Integration_Message__c,
                        Zephr_Integration_Status__c,
                        Zephr_User__c,
                        Zephr_User__r.Name,
                        Zephr_User__r.Zephr_Company__c,
                        Zephr_User__r.Zephr_Id__c,
                        Zephr_User__r.Zephr_Integration_Message__c,
                        Zephr_User__r.Zephr_Integration_Status__c,
                        Zephr_User__r.Zephr_Tenant__c,
                        Zephr_User__r.Zephr_Email__c,
                        Zephr_User__r.Zephr_Email_Verified__c,
                        Zephr_User_Id__c,
                        Subscription_User__c,
                        Subscription_User__r.Contact__c,
                        Subscription_User__r.Contact__r.FirstName,
                        Subscription_User__r.Contact__r.LastName,
                        Subscription_User__r.Contact__r.Email,
                        Subscription_User__r.Contact__r.Account.Name,
                        Subscription_User__r.Contact__r.Title,
                        Subscription_User__r.Contact__r.MailingCity,
                        Subscription_User__r.Contact__r.MailingCountry,
                        Subscription_User__r.Contact__r.Phone,
                        Subscription_User__r.Contact__r.Account.Company_Type__c,
                        Subscription_User__r.Lead__r.FirstName,
                        Subscription_User__r.Lead__r.LastName,
                        Subscription_User__r.Lead__r.Email,
                        Subscription_User__r.Lead__r.Company,
                        Subscription_User__r.Lead__r.Title,
                        Subscription_User__r.Lead__r.City,
                        Subscription_User__r.Lead__r.Country,
                        Subscription_User__r.Lead__r.Phone,
                        Subscription_User__r.Lead__r.Company_Type__c
                FROM Zephr_User_Account_Grant__c
                WHERE Zephr_Account__r.Subscription__c IN :subscriptionIds AND (Zephr_Integration_Status__c = 'Pending' OR Zephr_Integration_Status__c = 'Error')
        ]);
    }

    @TestVisible Map<Id, String> getSubscriptionWebsites(List<Id> subscriptionIds) {
        Map<Id, String> response = new Map<Id, String>();
        for (Subscription_Product__c subscriptionProduct : [SELECT Id, Subscription__c, Product__r.Zephr_Website__c FROM Subscription_Product__c WHERE Subscription__c IN :subscriptionIds ORDER BY CreatedDate DESC]) {
            if (response.containsKey(subscriptionProduct.Subscription__c)) continue;
            response.put(subscriptionProduct.Subscription__c, subscriptionProduct.Product__r.Zephr_Website__c);
        }
        return response;
    }

    @TestVisible Map<Id, Zephr_User__c> provisionZephrUsers(Map<Id, Zephr_User_Account_Grant__c> zephrUserAccountGrants, Map<Id, String> zephrSubscriptionWebsites) {
        Map<Id, Zephr_User__c> newZephrUsers = new Map<Id, Zephr_User__c>();
        Map<Id, Zephr_User_Account_Grant__c> zephrUserAccountGrantsByZephrUsers = new Map<Id, Zephr_User_Account_Grant__c>();

        for (Zephr_User_Account_Grant__c zephrUserAccountGrant : zephrUserAccountGrants.values()) {
            if (String.isBlank(zephrUserAccountGrant.Zephr_User__r.Zephr_Id__c)) {
                newZephrUsers.put(zephrUserAccountGrant.Zephr_User__c, zephrUserAccountGrant.Zephr_User__r);
                zephrUserAccountGrantsByZephrUsers.put(zephrUserAccountGrant.Zephr_User__c, zephrUserAccountGrant);
            }
        }

        List<ZephrApiRequestsResponses.CreateUserRequest> createUserRequests = new List<ZephrApiRequestsResponses.CreateUserRequest>();
        for (Zephr_User__c zephrUser : newZephrUsers.values()) {
//three callouts per user
            if (getRemainingCallouts() >= 3 * createUserRequests.size()) {
//if there is a contact associated with sub user
                if (
                        zephrUserAccountGrantsByZephrUsers.get(zephrUser.Id).Subscription_User__r.Contact__c != null ||
                                zephrUserAccountGrantsByZephrUsers.get(zephrUser.Id).Subscription_User__r.Lead__c != null) {

                    ZephrApiRequestsResponses.CreateUserRequest createUserRequest = new ZephrApiRequestsResponses.CreateUserRequest();

                    if (zephrUserAccountGrantsByZephrUsers.get(zephrUser.Id).Subscription_User__r.Contact__c != null) {
                        Contact userContact = zephrUserAccountGrantsByZephrUsers.get(zephrUser.Id).Subscription_User__r.Contact__r;

                        zephrUser.Zephr_First_Name__c = userContact.FirstName;
                        zephrUser.Zephr_Last_Name__c = userContact.LastName;
                        zephrUser.Zephr_Email__c = userContact.Email;
                        zephrUser.Zephr_Company_Name__c = userContact.Account.Name;
                        zephrUser.Zephr_Job_Title__c = userContact.Title;
                        zephrUser.Zephr_City__c = userContact.MailingCity;
                        zephrUser.Zephr_Country__c = userContact.MailingCountry;
                        zephrUser.Zephr_Company_Type__c = userContact.Account.Company_Type__c;
                        zephrUser.Zephr_Telephone_Number__c = userContact.Phone;
                        createUserRequest.salesforceIdMapped = userContact.Id;
                    } else if (zephrUserAccountGrantsByZephrUsers.get(zephrUser.Id).Subscription_User__r.Lead__c != null) {
                        Lead userLead = zephrUserAccountGrantsByZephrUsers.get(zephrUser.Id).Subscription_User__r.Lead__r;

                        zephrUser.Zephr_First_Name__c = userLead.FirstName;
                        zephrUser.Zephr_Last_Name__c = userLead.LastName;
                        zephrUser.Zephr_Email__c = userLead.Email;
                        zephrUser.Zephr_Company_Name__c = userLead.Company;
                        zephrUser.Zephr_Job_Title__c = userLead.Title;
                        zephrUser.Zephr_City__c = userLead.City;
                        zephrUser.Zephr_Country__c = userLead.Country;
                        zephrUser.Zephr_Company_Type__c = userLead.Company_Type__c;
                        zephrUser.Zephr_Telephone_Number__c = userLead.Phone;
                        createUserRequest.salesforceIdMapped = userLead.Id;
                    }

                    createUserRequest.firstName = zephrUser.Zephr_First_Name__c;
                    createUserRequest.lastName = zephrUser.Zephr_Last_Name__c;
                    createUserRequest.email = zephrUser.Zephr_Email__c;
                    createUserRequest.companyName = zephrUser.Zephr_Company_Name__c;
                    createUserRequest.jobTitle = zephrUser.Zephr_Job_Title__c;
                    createUserRequest.city = zephrUser.Zephr_City__c;
                    createUserRequest.country = zephrUser.Zephr_Country__c;
                    createUserRequest.companyType = zephrUser.Zephr_Company_Type__c;
                    createUserRequest.telephoneNumber = zephrUser.Zephr_Telephone_Number__c;
                    createUserRequest.tenantId = zephrUser.Zephr_Tenant__c;
                    createUserRequest.salesforceId = zephrUser.Id;
                    createUserRequest.startDate = Date.today();
                    createUserRequest.sendPasswordReset = true;
                    createUserRequest.emailVerified = true;

                    createUserRequest.websiteName = zephrSubscriptionWebsites.get(zephrUserAccountGrantsByZephrUsers.get(zephrUser.Id).Zephr_Account__r.Subscription__c);

                    createUserRequests.add(createUserRequest);
                } else {
                    zephrUser.Zephr_Integration_Status__c = 'Error';
                    zephrUser.Zephr_Integration_Message__c = 'Not enough information to sync to Zephr';
                }
            } else {
                limitsReached = true;
                break;
            }
        }
        System.debug(LoggingLevel.FINE, 'execute - limitsReached: ' + limitsReached);
        System.debug(LoggingLevel.FINE, 'execute - newZephrUsers: ' + newZephrUsers);

        for (ZephrApiRequestsResponses.User userResponse : zephr_InvocableCreateUser.createZephrUser(createUserRequests)) {
            System.debug(LoggingLevel.FINE, 'execute - userResponse: ' + JSON.serialize(userResponse));
            Zephr_User__c zephrUser = newZephrUsers.get(userResponse.salesforceId);
            zephrUser.Zephr_Integration_Message__c = userResponse.message;
            if (userResponse.success) {
                zephrUser.Zephr_Email__c = userResponse.identifiers?.get('email_address');
                zephrUser.Zephr_Email_Verified__c = userResponse?.email_verified == null ? false : userResponse.email_verified; //todo userResponse.email_verified;
                zephrUser.Zephr_Integration_Status__c = 'Synced';
                zephrUser.Zephr_Id__c = userResponse.user_id;
                zephrUser.Zephr_Tracking_Id__c = userResponse.tracking_id;
            } else {
                zephrUser.Zephr_Integration_Status__c = 'Error';
            }
        }

        return newZephrUsers;
    }

    @TestVisible Map<Id, Zephr_User__c> provisionZephrUsers(Map<Id, Zephr_User_Grant__c> zephrUserGrants) {
        Map<Id, Zephr_User__c> newZephrUsers = new Map<Id, Zephr_User__c>();
        Map<Id, Zephr_User_Grant__c> zephrUserGrantsByZephrUsers = new Map<Id, Zephr_User_Grant__c>();

        for (Zephr_User_Grant__c zephrUserGrant : zephrUserGrants.values()) {
            if (String.isBlank(zephrUserGrant.Zephr_User__r.Zephr_Id__c)) {
                newZephrUsers.put(zephrUserGrant.Zephr_User__c, zephrUserGrant.Zephr_User__r);
                zephrUserGrantsByZephrUsers.put(zephrUserGrant.Zephr_User__c, zephrUserGrant);
            }
        }

        List<ZephrApiRequestsResponses.CreateUserRequest> createUserRequests = new List<ZephrApiRequestsResponses.CreateUserRequest>();
        for (Zephr_User__c zephrUser : newZephrUsers.values()) {
            if (getRemainingCallouts() >= createUserRequests.size() * 3) {
//if there is a contact associated with sub user
                if (
                        zephrUserGrantsByZephrUsers.get(zephrUser.Id).Subscription_User__r.Contact__c != null ||
                                zephrUserGrantsByZephrUsers.get(zephrUser.Id).Subscription_User__r.Lead__c != null) {
                    ZephrApiRequestsResponses.CreateUserRequest createUserRequest = new ZephrApiRequestsResponses.CreateUserRequest();

                    if (zephrUserGrantsByZephrUsers.get(zephrUser.Id).Subscription_User__r.Contact__c != null) {
                        Contact userContact = zephrUserGrantsByZephrUsers.get(zephrUser.Id).Subscription_User__r.Contact__r;

                        zephrUser.Zephr_First_Name__c = userContact.FirstName;
                        zephrUser.Zephr_Last_Name__c = userContact.LastName;
                        zephrUser.Zephr_Email__c = userContact.Email;
                        zephrUser.Zephr_Company_Name__c = userContact.Account.Name;
                        zephrUser.Zephr_Job_Title__c = userContact.Title;
                        zephrUser.Zephr_City__c = userContact.MailingCity;
                        zephrUser.Zephr_Country__c = userContact.MailingCountry;
                        zephrUser.Zephr_Company_Type__c = userContact.Account.Company_Type__c;
                        zephrUser.Zephr_Telephone_Number__c = userContact.Phone;
                        createUserRequest.salesforceIdMapped = userContact.Id;
                    } else if (zephrUserGrantsByZephrUsers.get(zephrUser.Id).Subscription_User__r.Lead__c != null) {
                        Lead userLead = zephrUserGrantsByZephrUsers.get(zephrUser.Id).Subscription_User__r.Lead__r;

                        zephrUser.Zephr_First_Name__c = userLead.FirstName;
                        zephrUser.Zephr_Last_Name__c = userLead.LastName;
                        zephrUser.Zephr_Email__c = userLead.Email;
                        zephrUser.Zephr_Company_Name__c = userLead.Company;
                        zephrUser.Zephr_Job_Title__c = userLead.Title;
                        zephrUser.Zephr_City__c = userLead.City;
                        zephrUser.Zephr_Country__c = userLead.Country;
                        zephrUser.Zephr_Company_Type__c = userLead.Company_Type__c;
                        zephrUser.Zephr_Telephone_Number__c = userLead.Phone;
                        createUserRequest.salesforceIdMapped = userLead.Id;
                    }

                    createUserRequest.firstName = zephrUser.Zephr_First_Name__c;
                    createUserRequest.lastName = zephrUser.Zephr_Last_Name__c;
                    createUserRequest.email = zephrUser.Zephr_Email__c;
                    createUserRequest.companyName = zephrUser.Zephr_Company_Name__c;
                    createUserRequest.jobTitle = zephrUser.Zephr_Job_Title__c;
                    createUserRequest.city = zephrUser.Zephr_City__c;
                    createUserRequest.country = zephrUser.Zephr_Country__c;
                    createUserRequest.companyType = zephrUser.Zephr_Company_Type__c;
                    createUserRequest.telephoneNumber = zephrUser.Zephr_Telephone_Number__c;
                    createUserRequest.tenantId = zephrUser.Zephr_Tenant__c;
                    createUserRequest.salesforceId = zephrUser.Id;
                    createUserRequest.startDate = Date.today();
                    createUserRequest.sendPasswordReset = true;
                    createUserRequest.emailVerified = true;
                    createUserRequest.websiteName = zephrUserGrantsByZephrUsers.get(zephrUser.Id).Product__r.Zephr_Website__c;

                    createUserRequests.add(createUserRequest);
                } else {
                    zephrUser.Zephr_Integration_Status__c = 'Error';
                    zephrUser.Zephr_Integration_Message__c = 'Not enough information to sync to Zephr';
                }
            } else {
                limitsReached = true;
                break;
            }
        }
        System.debug(LoggingLevel.FINE, 'execute - limitsReached: ' + limitsReached);
        System.debug(LoggingLevel.FINE, 'execute - newZephrUsers: ' + newZephrUsers);

        for (ZephrApiRequestsResponses.User userResponse : zephr_InvocableCreateUser.createZephrUser(createUserRequests)) {
            System.debug(LoggingLevel.FINE, 'execute - userResponse: ' + JSON.serialize(userResponse));
            Zephr_User__c zephrUser = newZephrUsers.get(userResponse.salesforceId);
            zephrUser.Zephr_Integration_Message__c = userResponse.message;
            if (userResponse.success) {
                zephrUser.Zephr_Integration_Status__c = 'Synced';
                zephrUser.Zephr_Id__c = userResponse.user_id;
            } else {
                zephrUser.Zephr_Integration_Status__c = 'Error';
            }
        }

        return newZephrUsers;
    }
}