/**
* @author Zoran Zunko
* @date 10/27/21
*
*/

public with sharing class zephr_QProvisionSubscriptionGrants implements Queueable, Database.AllowsCallouts {
    public List<Id> subscriptionIds;
    public void execute(QueueableContext qc) {
        if (subscriptionIds.isEmpty()) return;
        Map<Id, Zephr_Account_Grant__c> zephrAccountGrants;

        zephrAccountGrants = getZephrAccountGrants(subscriptionIds);
        System.debug(LoggingLevel.FINE, 'execute - zephrAccountGrants.size(): ' + zephrAccountGrants.size());
        if (!limitsReached) {//?
            provisionZephrAccountGrants(zephrAccountGrants);
        }

        if (zephrAccountGrants != null && !zephrAccountGrants.isEmpty()) update zephrAccountGrants.values();

        if (limitsReached) {
            zephr_QProvisionSubscriptionGrants zephrQProvisionSubscriptionGrants = new zephr_QProvisionSubscriptionGrants();
            zephrQProvisionSubscriptionGrants.subscriptionIds = this.subscriptionIds;
            System.enqueueJob(zephrQProvisionSubscriptionGrants);
        }
        else if(!Test.isRunningTest()){
            zephr_QProvisionSubscriptionUsers zephrQProvisionSubscriptionUsers = new zephr_QProvisionSubscriptionUsers();
            zephrQProvisionSubscriptionUsers.subscriptionIds = this.subscriptionIds;
            System.enqueueJob(zephrQProvisionSubscriptionUsers);
        }
    }

    Boolean limitsReached = false;

    @TestVisible Integer getRemainingCallouts() {
        return (Limits.getLimitCallouts() - Limits.getCallouts() - 2);
    }

    @TestVisible Map<Id, Zephr_Account_Grant__c> getZephrAccountGrants(List<Id> subscriptionIds) {
        return new Map<Id, Zephr_Account_Grant__c>([
                SELECT
                        CurrencyIsoCode,
                        Id,
                        Name,
                        OwnerId,
                        Product__r.ZephrEntitlementId__c,
                        Product__r.Zephr_Product_Slug__c,
                        Start_Date__c,
                        End_Date__c,
                        Zephr_Account__c,
                        Zephr_Account__r.Zephr_Id__c,
                        Zephr_API_URL__c,
                        Zephr_Id__c,
                        Zephr_Integration_Message__c,
                        Zephr_Integration_Status__c,
                        Zephr_Tenant__c
                FROM Zephr_Account_Grant__c
                WHERE Zephr_Account__r.Subscription__c IN :subscriptionIds AND (Zephr_Integration_Status__c = 'Pending' OR Zephr_Integration_Status__c = 'Error')
        ]);
    }

    @TestVisible void provisionZephrAccountGrants(Map<Id, Zephr_Account_Grant__c> zephrAccountGrants) {

        List<ZephrApiRequestsResponses.Grant> createAccountGrantRequests = new List<ZephrApiRequestsResponses.Grant>();
        System.debug(LoggingLevel.ERROR, 'provisionZephrAccountGrants - getRemainingCallouts(): ' + getRemainingCallouts());
        for (Zephr_Account_Grant__c zephrAccountGrant : zephrAccountGrants.values()) {
            if (getRemainingCallouts() > createAccountGrantRequests.size()) {
                String zephrAccountId = zephrAccountGrant.Zephr_Account__r.Zephr_Id__c;
                if (String.isNotBlank(zephrAccountId)) {
                    ZephrApiRequestsResponses.Grant createAccountGrantRequest = new ZephrApiRequestsResponses.Grant();
                    createAccountGrantRequest.tenantId = zephrAccountGrant.Zephr_Tenant__c;
                    createAccountGrantRequest.account_id = zephrAccountId;
                    createAccountGrantRequest.entitlement_id = zephrAccountGrant.Product__r.ZephrEntitlementId__c;
                    createAccountGrantRequest.product_id = zephrAccountGrant.Product__r.Zephr_Product_Slug__c;
                    createAccountGrantRequest.startTime = zephrAccountGrant.Start_Date__c;
                    createAccountGrantRequest.endTime = zephrAccountGrant.End_Date__c;
                    createAccountGrantRequest.salesforceId = zephrAccountGrant.Id;

                    createAccountGrantRequests.add(createAccountGrantRequest);
                } else {
                    zephrAccountGrant.Zephr_Integration_Status__c = 'Error';
                    zephrAccountGrant.Zephr_Integration_Message__c = 'Zephr Account (Subscription) not provisioned in Zephr';
                }
            } else {
                limitsReached = true;
                break;
            }
        }

        System.debug(LoggingLevel.ERROR, 'provisionZephrAccountGrants - createAccountGrantRequests: ' + JSON.serialize(createAccountGrantRequests));
        for (ZephrApiRequestsResponses.Grant grantResponse : zephr_InvocableCreateAccountGrant.createGrant(createAccountGrantRequests)) {
            System.debug(LoggingLevel.FINE, 'execute - grantResponse: ' + JSON.serialize(grantResponse));
            Zephr_Account_Grant__c zephrAccountGrant = zephrAccountGrants.get(grantResponse.salesforceId);
            zephrAccountGrant.Zephr_Integration_Message__c = grantResponse.message;
            if (grantResponse.success) {
                zephrAccountGrant.Zephr_Integration_Status__c = 'Synced';
                zephrAccountGrant.Zephr_Id__c = grantResponse.grant_id;
            } else {
                zephrAccountGrant.Zephr_Integration_Status__c = 'Error';
            }
        }
    }
}