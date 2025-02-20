/**
* @author Zoran Zunko
* @date 6/4/21
*
*/

public with sharing class zephr_InvocableCreateAccount {
    @InvocableMethod public static List<ZephrApiRequestsResponses.Account> createZephrAccount(List<ZephrApiRequestsResponses.Account> accountRequests) {
        List<ZephrApiRequestsResponses.Account> response = new List<ZephrApiRequestsResponses.Account>();

        try {
            Map<String, ZephrIntegrationNG> zephrIntegrationsByTenantMap = new Map<String, ZephrIntegrationNG>();

            for (ZephrApiRequestsResponses.Account accountRequest : accountRequests) {
                ZephrApiRequestsResponses.Account accountResponse = new ZephrApiRequestsResponses.Account();
                accountResponse.message = 'ERROR';
                accountResponse.name = accountRequest.name;
                accountResponse.company_id = accountRequest.company_id;
                accountResponse.success = false;
                accountResponse.salesforceId = accountRequest.salesforceId;
                accountResponse.allow_oversubscription = accountRequest.allow_oversubscription;

                if(!zephrIntegrationsByTenantMap.containsKey(accountRequest.tenantId)) {
                    zephrIntegrationsByTenantMap.put(accountRequest.tenantId, new ZephrIntegrationNG(accountRequest.tenantId));
                }

                ZephrIntegrationNG zephr = zephrIntegrationsByTenantMap.get(accountRequest.tenantId);

                try {
                    HttpResponse res = zephr.createAccount(accountRequest.company_id, accountRequest.name, accountRequest.number_of_seats, accountRequest.allow_oversubscription);
                    if (res.getStatusCode() == 201) {
                        accountResponse = (ZephrApiRequestsResponses.Account) JSON.deserialize(res.getBody(), ZephrApiRequestsResponses.Account.class);
                        accountResponse.success = true;
                        accountResponse.salesforceId = accountRequest.salesforceId;

                    } else {
                        accountResponse.message = res.getBody();
                    }
                } catch (Exception ex) {
                    System.debug(LoggingLevel.ERROR, ex.getMessage() + ' - ' + ex.getStackTraceString());
                    accountResponse.message = ex.getMessage() + ' - ' + ex.getStackTraceString();
                    //todo: ZephrIntegrationService.publishErrorEvent(UserInfo.getUserName(), ex.getStackTraceString(), ex.getMessage(), 'zephr_InvocableCreateAccount - api integration error');
                }
                response.add(accountResponse);
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + ' - ' + ex.getStackTraceString());
            ZephrIntegrationService.publishErrorEvent(UserInfo.getUserName(), ex.getStackTraceString(), ex.getMessage(), 'zephr_InvocableCreateAccount - non network error');
        }
        return response;
    }
}