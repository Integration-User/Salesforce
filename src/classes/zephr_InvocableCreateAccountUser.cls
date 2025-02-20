/**
* @author Zoran Zunko
* @date 6/9/21
*
*/
public with sharing class zephr_InvocableCreateAccountUser {
    @InvocableMethod public static List<ZephrApiRequestsResponses.AccountUserGrant> createAccountUser(List<ZephrApiRequestsResponses.AccountUserGrant> userAccountGrantRequests) {
        List<ZephrApiRequestsResponses.AccountUserGrant> response = new List<ZephrApiRequestsResponses.AccountUserGrant>();

        try {
            Map<String, ZephrIntegrationNG> zephrIntegrationsByTenantMap = new Map<String, ZephrIntegrationNG>();

            for (ZephrApiRequestsResponses.AccountUserGrant accountUserGrantRequest : userAccountGrantRequests) {
                ZephrApiRequestsResponses.AccountUserGrant accountUserGrantResponse = new ZephrApiRequestsResponses.AccountUserGrant();
                accountUserGrantResponse.message = 'ERROR';
                accountUserGrantResponse.success = false;
                accountUserGrantResponse.salesforceId = accountUserGrantRequest.salesforceId;

                if (!zephrIntegrationsByTenantMap.containsKey(accountUserGrantRequest.tenantId)) {
                    zephrIntegrationsByTenantMap.put(accountUserGrantRequest.tenantId, new ZephrIntegrationNG(accountUserGrantRequest.tenantId));
                }

                ZephrIntegrationNG zephr = zephrIntegrationsByTenantMap.get(accountUserGrantRequest.tenantId);
                //if the account user already exists the answer is 200, if it's create the answer is 201
                try {

                    HttpResponse res = zephr.accountUser(accountUserGrantRequest.account_id, accountUserGrantRequest.user_id, 'PUT');
                    if (res.getStatusCode() == 200) {
                        accountUserGrantResponse.success = true;
                        accountUserGrantResponse.salesforceId = accountUserGrantRequest.salesforceId;
                        accountUserGrantResponse.account_id = accountUserGrantRequest.account_id;
                        accountUserGrantResponse.user_id = accountUserGrantRequest.user_id;
                        accountUserGrantResponse.message = 'account user already existing';

                    }
                    else if (res.getStatusCode() == 201) {
                        accountUserGrantResponse = (ZephrApiRequestsResponses.AccountUserGrant) JSON.deserialize(res.getBody(), ZephrApiRequestsResponses.AccountUserGrant.class);
                        accountUserGrantResponse.success = true;
                        accountUserGrantResponse.salesforceId = accountUserGrantRequest.salesforceId;

                    } else {
                        accountUserGrantResponse.message = res.getBody();
                    }
                } catch (Exception ex) {
                    System.debug(LoggingLevel.ERROR, ex.getMessage() + ' - ' + ex.getStackTraceString());
                    accountUserGrantResponse.message = ex.getMessage() + ' - ' + ex.getStackTraceString();
                    //todo: ZephrIntegrationService.publishErrorEvent(UserInfo.getUserName(), ex.getStackTraceString(), ex.getMessage(), 'zephr_InvocableCreateAccount - api integration error');
                }
                response.add(accountUserGrantResponse);
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + ' - ' + ex.getStackTraceString());
            //ZephrIntegrationService.publishErrorEvent(UserInfo.getUserName(), ex.getStackTraceString(), ex.getMessage(), 'zephr_InvocableCreateAccountGrant - non network error');
        }
        return response;
    }
}