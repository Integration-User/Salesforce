/**
* @author Zoran Zunko
* @date 6/5/21
*
*/

public with sharing class zephr_InvocableAccountUpdate {
    @InvocableMethod public static List<ZephrApiRequestsResponses.Account> updateZephrAccount(List<ZephrApiRequestsResponses.Account> accountRequests) {
        List<ZephrApiRequestsResponses.Account> response = new List<ZephrApiRequestsResponses.Account>();

        try {
            Map<String, ZephrIntegrationNG> zephrIntegrationsByTenantMap = new Map<String, ZephrIntegrationNG>();

            for (ZephrApiRequestsResponses.Account accountRequest : accountRequests) {
                ZephrApiRequestsResponses.Account accountResponse = new ZephrApiRequestsResponses.Account();
                accountResponse.message = 'ERROR';
                accountResponse.success = false;
                accountResponse.name = accountRequest.name;
                accountResponse.company_id = accountRequest.company_id;

                if(!zephrIntegrationsByTenantMap.containsKey(accountRequest.tenantId)) {
                    zephrIntegrationsByTenantMap.put(accountRequest.tenantId, new ZephrIntegrationNG(accountRequest.tenantId));
                }

                ZephrIntegrationNG zephr = zephrIntegrationsByTenantMap.get(accountRequest.tenantId);

                try {
                    HttpResponse res = zephr.updateAccount(accountRequest);
                    if (res.getStatusCode() == 201 || res.getStatusCode() == 200) {
                        accountResponse = (ZephrApiRequestsResponses.Account) JSON.deserialize(res.getBody(), ZephrApiRequestsResponses.Account.class);
                        accountResponse.success = true;

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
            ZephrIntegrationService.publishErrorEvent(UserInfo.getUserName(), ex.getStackTraceString(), ex.getMessage(), 'zephr_InvocableAccountUpdate - non network error');
        }
        return response;
    }
}