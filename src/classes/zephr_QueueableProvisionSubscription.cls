/**
 * Handles non-user Zephr provisioning operations for a subscription
* @author Zoran Zunko
* @date 6/9/21
*
*/
public class zephr_QueueableProvisionSubscription implements Queueable, Database.AllowsCallouts {
    public List<Id> subscriptionIds;
    public void execute(QueueableContext qc) {
        if (subscriptionIds.isEmpty()) return;

        Map<Id, Zephr_Account__c> zephrAccounts = getZephrAccounts(subscriptionIds);
        System.debug(LoggingLevel.FINE, 'execute - zephrAccounts.size(): ' + zephrAccounts.size());

        Map<Id, Zephr_Company__c> newCompanies = provisionZephrCompanies(zephrAccounts);

        provisionZephrAccounts(zephrAccounts);

        if (newCompanies != null && !newCompanies.isEmpty()) update newCompanies.values();
        if (zephrAccounts != null && !zephrAccounts.isEmpty()) update zephrAccounts.values();

        if (limitsReached) {
            zephr_QueueableProvisionSubscription queueableProvisionSubscription = new zephr_QueueableProvisionSubscription();
            queueableProvisionSubscription.subscriptionIds = this.subscriptionIds;
            System.enqueueJob(queueableProvisionSubscription);
        } else if(!Test.isRunningTest()){
            zephr_QProvisionSubscriptionGrants zephrQProvisionSubscriptionGrants = new zephr_QProvisionSubscriptionGrants();
            zephrQProvisionSubscriptionGrants.subscriptionIds = this.subscriptionIds;
            System.enqueueJob(zephrQProvisionSubscriptionGrants);
        }
    }

    Boolean limitsReached = false;

    @TestVisible Integer getRemainingCallouts() {
        return (Limits.getLimitCallouts() - Limits.getCallouts() - 2);
    }

    @TestVisible Map<Id, Zephr_Account__c> getZephrAccounts(List<Id> subscriptionIds) {
        return new Map<Id, Zephr_Account__c>([
                SELECT
                        CurrencyIsoCode,
                        Id,
                        Name,
                        Number_of_Seats__c,
                        Subscription__c,
                        Zephr_API_URL__c,
                        Zephr_Company__c,
                        Zephr_Company__r.Zephr_Id__c,
                        Zephr_Company__r.Id,
                        Zephr_Company__r.Zephr_Integration_Status__c,
                        Zephr_Company__r.Zephr_Tenant__c,
                        Zephr_Company__r.Account__r.Website,
                        Zephr_Company__r.Account__r.Name,
                        Zephr_Company__r.Account__r.Company_Type__c,
                        Zephr_Id__c,
                        Zephr_Integration_Message__c,
                        Zephr_Integration_Status__c,
                        Zephr_Tenant__c
                FROM Zephr_Account__c
                WHERE Subscription__c IN :subscriptionIds AND (Zephr_Integration_Status__c = 'Pending' OR Zephr_Integration_Status__c = 'Error') AND Zephr_Id__c = NULL
        ]);
    }

    @TestVisible Map<Id, Zephr_Company__c> provisionZephrCompanies(Map<Id, Zephr_Account__c> zephrAccounts) {
        Map<Id, Zephr_Company__c> newCompanies = new Map<Id, Zephr_Company__c>();

        for (Zephr_Account__c zephrAccount : zephrAccounts.values()) {
            if (String.isBlank(zephrAccount.Zephr_Company__r.Zephr_Id__c)) {
                //use this so reference is preserved
                newCompanies.put(zephrAccount.Zephr_Company__c, zephrAccount.Zephr_Company__r);
            }
        }

        List<ZephrApiRequestsResponses.CreateCompanyRequest> createCompanyRequests = new List<ZephrApiRequestsResponses.CreateCompanyRequest>();
        for (Zephr_Company__c zephrCompany : newCompanies.values()) {
            if (getRemainingCallouts() > createCompanyRequests.size()) {
                ZephrApiRequestsResponses.CreateCompanyRequest createCompanyRequest = new ZephrApiRequestsResponses.CreateCompanyRequest();
                createCompanyRequest.tenant = zephrCompany.Zephr_Tenant__c;
                createCompanyRequest.salesforceId = zephrCompany.Id;
                createCompanyRequest.website = zephrCompany.Account__r.Website;
                createCompanyRequest.name = zephrCompany.Account__r.Name;
                createCompanyRequests.add(createCompanyRequest);
            } else {
                limitsReached = true;
                break;
            }
        }
        System.debug(LoggingLevel.FINE, 'execute - limitsReached: ' + limitsReached);
        System.debug(LoggingLevel.FINE, 'execute - createCompanyRequests: ' + createCompanyRequests);

        for (ZephrApiRequestsResponses.Company companyResponse : zephr_InvocableCreateCompany.createZephrCompany(createCompanyRequests)) {
            System.debug(LoggingLevel.FINE, 'provisionZephrCompanies - companyResponse: ' + companyResponse);
            Zephr_Company__c zephrCompany = newCompanies.get(companyResponse.salesforceId);
            zephrCompany.Zephr_Integration_Message__c = companyResponse.message;
            if (companyResponse.success) {
                zephrCompany.Zephr_Integration_Status__c = 'Synced';
                zephrCompany.Zephr_Id__c = companyResponse.company_id;
            } else {
                zephrCompany.Zephr_Integration_Status__c = 'Error';
            }
        }

        return newCompanies;
    }

    @TestVisible void provisionZephrAccounts(Map<Id, Zephr_Account__c> zephrAccounts) {
        List<ZephrApiRequestsResponses.Account> createAccountRequests = new List<ZephrApiRequestsResponses.Account>();
        for (Zephr_Account__c zephrAccount : zephrAccounts.values()) {
            if (getRemainingCallouts() > createAccountRequests.size()) {
                if (String.isNotBlank(zephrAccount.Zephr_Company__r.Zephr_Id__c)) {
                    ZephrApiRequestsResponses.Account createAccountRequest = new ZephrApiRequestsResponses.Account();
                    createAccountRequest.tenantId = zephrAccount.Zephr_Tenant__c;
                    createAccountRequest.company_id = zephrAccount.Zephr_Company__r.Zephr_Id__c;
                    createAccountRequest.salesforceId = zephrAccount.Id;
                    createAccountRequest.name = zephrAccount.Name;
                    createAccountRequest.number_of_seats = zephrAccount.Number_of_Seats__c?.intValue();

                    createAccountRequests.add(createAccountRequest);
                } else {
                    zephrAccount.Zephr_Integration_Status__c = 'Error';
                    zephrAccount.Zephr_Integration_Message__c = 'Company not provisioned in Zephr';
                }
            } else {
                limitsReached = true;
                break;
            }
        }
        System.debug(LoggingLevel.FINE, 'execute - createAccountRequests.size(): ' + createAccountRequests.size());
        System.debug(LoggingLevel.FINE, 'execute - limitsReached: ' + limitsReached);
        System.debug(LoggingLevel.FINE, 'execute - createAccountRequests: ' + JSON.serialize(createAccountRequests));

        for (ZephrApiRequestsResponses.Account accountResponse : zephr_InvocableCreateAccount.createZephrAccount(createAccountRequests)) {
            System.debug(LoggingLevel.FINE, 'execute - accountResponse: ' + JSON.serialize(accountResponse));
            Zephr_Account__c zephrAccount = zephrAccounts.get(accountResponse.salesforceId);
            zephrAccount.Zephr_Integration_Message__c = accountResponse.message;
            if (accountResponse.success) {
                zephrAccount.Zephr_Integration_Status__c = 'Synced';
                zephrAccount.Zephr_Id__c = accountResponse.account_id;
            } else {
                zephrAccount.Zephr_Integration_Status__c = 'Error';
            }
        }
    }
}