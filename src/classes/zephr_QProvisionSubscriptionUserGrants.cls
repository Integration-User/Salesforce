/**
* @author Zoran Zunko
* @date 10/27/21
*
*/

public with sharing class zephr_QProvisionSubscriptionUserGrants implements Queueable, Database.AllowsCallouts {
    public List<Id> subscriptionIds;
    public void execute(QueueableContext qc) {
        if (subscriptionIds.isEmpty()) return;
        Map<Id, Zephr_User_Grant__c> zephrUserGrants;
        Map<Id, Zephr_User_Account_Grant__c> zephrUserAccountGrants;

        zephrUserAccountGrants = getZephrUserAccountGrants(subscriptionIds);
        System.debug(LoggingLevel.FINE, 'execute - zephrUserAccountGrants.size(): ' + zephrUserAccountGrants.size());
        zephrUserGrants = getZephrUserGrants(subscriptionIds);
        provisionZephrUserAccountGrants(zephrUserAccountGrants);
        if (!limitsReached) {
            System.debug(LoggingLevel.FINE, 'execute - zephrUserGrants: ' + JSON.serialize(zephrUserGrants));
            provisionZephrUserGrants(zephrUserGrants);
        }


        if (zephrUserAccountGrants != null && !zephrUserAccountGrants.isEmpty()) update zephrUserAccountGrants.values();
        if (zephrUserGrants != null && !zephrUserGrants.isEmpty()) update zephrUserGrants.values();

        if (limitsReached) {
            zephr_QProvisionSubscriptionUserGrants queueableProvisionSubscription = new zephr_QProvisionSubscriptionUserGrants();
            queueableProvisionSubscription.subscriptionIds = this.subscriptionIds;
            System.enqueueJob(queueableProvisionSubscription);
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
                        Product__r.Zephr_Product_Slug__c,
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
                        Zephr_Account__r.Subscription__r.Order_Product__r.Product2.Zephr_Website__c,
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

    @TestVisible void provisionZephrUserAccountGrants(Map<Id, Zephr_User_Account_Grant__c> zephrUserAccountGrants) {
        List<ZephrApiRequestsResponses.AccountUserGrant> createAccountUserGrantRequests = new List<ZephrApiRequestsResponses.AccountUserGrant>();
        for (Zephr_User_Account_Grant__c zephrUserAccountGrant : zephrUserAccountGrants.values()) {
            if (getRemainingCallouts() > createAccountUserGrantRequests.size()) {
                String zephrAccountId = zephrUserAccountGrant.Zephr_Account__r.Zephr_Id__c;
                if (String.isNotBlank(zephrAccountId) && String.isNotBlank(zephrUserAccountGrant.Zephr_User__r.Zephr_Id__c)) {
                    ZephrApiRequestsResponses.AccountUserGrant createAccountGrantRequest = new ZephrApiRequestsResponses.AccountUserGrant();
                    createAccountGrantRequest.tenantId = zephrUserAccountGrant.Zephr_User__r.Zephr_Tenant__c;
                    createAccountGrantRequest.account_id = zephrAccountId;
                    createAccountGrantRequest.user_id = zephrUserAccountGrant.Zephr_User__r.Zephr_Id__c;
                    createAccountGrantRequest.salesforceId = zephrUserAccountGrant.Id;

                    createAccountUserGrantRequests.add(createAccountGrantRequest);
                } else {
                    zephrUserAccountGrant.Zephr_Integration_Status__c = 'Error';
                    zephrUserAccountGrant.Zephr_Integration_Message__c = 'Zephr Account (Subscription) or User not provisioned in Zephr';
                }
            } else {
                limitsReached = true;
                break;
            }
        }
        for (ZephrApiRequestsResponses.AccountUserGrant accountUserGrantResponse : zephr_InvocableCreateAccountUser.createAccountUser(createAccountUserGrantRequests)) {
            System.debug(LoggingLevel.FINE, 'execute - accountUserGrantResponse: ' + JSON.serialize(accountUserGrantResponse));
            Zephr_User_Account_Grant__c zephrUserAccountGrant = zephrUserAccountGrants.get(accountUserGrantResponse.salesforceId);
            zephrUserAccountGrant.Zephr_Integration_Message__c = accountUserGrantResponse.message;
            if (accountUserGrantResponse.success) {
                zephrUserAccountGrant.Zephr_Integration_Status__c = 'Synced';
            } else {
                zephrUserAccountGrant.Zephr_Integration_Status__c = 'Error';
            }
        }
    }

    @TestVisible void provisionZephrUserGrants(Map<Id, Zephr_User_Grant__c> zephrUserGrants) {
        List<ZephrApiRequestsResponses.CreateUserGrantRequest> createUserGrantRequests = new List<ZephrApiRequestsResponses.CreateUserGrantRequest>();
        for (Zephr_User_Grant__c zephrUserGrant : zephrUserGrants.values()) {
            if (getRemainingCallouts() > createUserGrantRequests.size()) {
                if (String.isNotBlank(zephrUserGrant.Zephr_User__r.Zephr_Id__c)) {
                    ZephrApiRequestsResponses.CreateUserGrantRequest createUserGrantRequest = new ZephrApiRequestsResponses.CreateUserGrantRequest();
                    createUserGrantRequest.tenantId = zephrUserGrant.Zephr_Tenant__c;
                    createUserGrantRequest.user_id = zephrUserGrant.Zephr_User__r.Zephr_Id__c;
                    createUserGrantRequest.entitlement_id = zephrUserGrant.Product__r.ZephrEntitlementId__c;
                    createUserGrantRequest.product_id = zephrUserGrant.Product__r.Zephr_Product_Slug__c;
                    createUserGrantRequest.startTime = zephrUserGrant.Start_Date__c;
                    createUserGrantRequest.endTime = zephrUserGrant.End_Date__c;
                    createUserGrantRequest.salesforceId = zephrUserGrant.Id;

                    createUserGrantRequests.add(createUserGrantRequest);
                } else {
                    zephrUserGrant.Zephr_Integration_Status__c = 'Error';
                    zephrUserGrant.Zephr_Integration_Message__c = 'Zephr User not provisioned in Zephr';
                }
            } else {
                limitsReached = true;
                break;
            }
        }

        for (ZephrApiRequestsResponses.Grant grantResponse : zephr_InvocableCreateUserGrant.createUserGrant(createUserGrantRequests)) {
            System.debug(LoggingLevel.FINE, 'execute - grantResponse: ' + JSON.serialize(grantResponse));
            Zephr_User_Grant__c zephrUserGrant = zephrUserGrants.get(grantResponse.salesforceId);
            zephrUserGrant.Zephr_Integration_Message__c = grantResponse.message;
            if (grantResponse.success) {
                zephrUserGrant.Zephr_Integration_Status__c = 'Synced';
                zephrUserGrant.Zephr_Id__c = grantResponse.grant_id;
            } else {
                zephrUserGrant.Zephr_Integration_Status__c = 'Error';
            }
        }
    }
}