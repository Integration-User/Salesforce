/**
* @author Zoran Zunko
* @date 9/28/21
*
*/
public class zephr_QueueableDeleteUserAccountGrants implements Queueable, Database.AllowsCallouts {
    public List<Zephr_User_Account_Grant__c> userAccountGrants;
    @TestVisible
    List<Zephr_User_Account_Grant__c> userAccountGrantsToDelete;
    @TestVisible
    List<Zephr_User_Account_Grant__c> userAccountGrantsToUpdate;

    public void execute(QueueableContext qc) {
        if(userAccountGrants.isEmpty()) return;
        userAccountGrantsToDelete = new List<Zephr_User_Account_Grant__c>();
        userAccountGrantsToUpdate = new List<Zephr_User_Account_Grant__c>();

        List<ZephrApiRequestsResponses.AccountUserGrant> deleteUserGrantRequests = new List<ZephrApiRequestsResponses.AccountUserGrant>();

        for (Zephr_User_Account_Grant__c zephrUserAccountGrant : userAccountGrants) {
            ZephrApiRequestsResponses.AccountUserGrant grantRequest = new ZephrApiRequestsResponses.AccountUserGrant();
            grantRequest.tenantId = zephrUserAccountGrant.Zephr_User__r.Zephr_Tenant__c != null ? zephrUserAccountGrant.Zephr_User__r.Zephr_Tenant__c : zephrUserAccountGrant.Zephr_Account__r.Zephr_Tenant__c;
            grantRequest.salesforceId = zephrUserAccountGrant.Id;
            grantRequest.account_id = zephrUserAccountGrant.Zephr_Account__r.Zephr_Id__c;
            grantRequest.user_id = zephrUserAccountGrant.Zephr_User__r.Zephr_Id__c;
            deleteUserGrantRequests.add(grantRequest);
        }

        List<ZephrApiRequestsResponses.AccountUserGrant> grantResponses = zephr_InvocableDeleteAccountUser.deleteAccountUser(deleteUserGrantRequests);
        for (ZephrApiRequestsResponses.AccountUserGrant grantResponse : grantResponses) {
            System.debug(LoggingLevel.FINE, 'execute - grantResponse: ' + JSON.serialize(grantResponse));
            if(grantResponse.success) {
                userAccountGrantsToDelete.add(new Zephr_User_Account_Grant__c(Id = grantResponse.salesforceId));
            }
            else {
                userAccountGrantsToUpdate.add(new Zephr_User_Account_Grant__c(Id = grantResponse.salesforceId, Zephr_Integration_Status__c = 'Error', Zephr_Integration_Message__c = grantResponse.message));
            }
        }

        delete userAccountGrantsToDelete;
        update userAccountGrantsToUpdate;
    }
}