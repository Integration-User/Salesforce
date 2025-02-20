/**
* @author Zoran Zunko
* @date 6/11/21
*
*/

public with sharing class zephr_InvocableCreateUserGrant {
    @InvocableMethod
    public static List<ZephrApiRequestsResponses.Grant> createUserGrant(List<ZephrApiRequestsResponses.CreateUserGrantRequest> grantRequests) {
        List<ZephrApiRequestsResponses.Grant> response = new List<ZephrApiRequestsResponses.Grant>();

        try {
            Map<String, ZephrIntegrationNG> zephrIntegrationsByTenantMap = new Map<String, ZephrIntegrationNG>();

            for (ZephrApiRequestsResponses.CreateUserGrantRequest grantRequest : grantRequests) {
                ZephrApiRequestsResponses.Grant grantResponse = new ZephrApiRequestsResponses.Grant();
                grantResponse.message = 'ERROR';
                grantResponse.salesforceId = grantRequest.salesforceId;
                grantResponse.success = false;

                if(!zephrIntegrationsByTenantMap.containsKey(grantRequest.tenantId)) {
                    zephrIntegrationsByTenantMap.put(grantRequest.tenantId, new ZephrIntegrationNG(grantRequest.tenantId));
                }

                ZephrIntegrationNG zephr = zephrIntegrationsByTenantMap.get(grantRequest.tenantId);

                try {
                    HttpResponse res = zephr.createUserGrant(grantRequest.user_id, grantRequest.product_id, grantRequest.entitlement_id, grantRequest.startTime, grantRequest.endTime);
                    if (res.getStatusCode() == 201) {
                        grantResponse = (ZephrApiRequestsResponses.Grant) JSON.deserialize(res.getBody(), ZephrApiRequestsResponses.Grant.class);
                        grantResponse.success = true;
                        grantResponse.salesforceId = grantRequest.salesforceId;
                    } else {
                        grantResponse.message = res.getBody();
                    }
                } catch (Exception ex) {
                    System.debug(LoggingLevel.ERROR, ex.getMessage() + ' - ' + ex.getStackTraceString());
                    grantResponse.message = ex.getMessage() + ' - ' + ex.getStackTraceString();
                    //todo: ZephrIntegrationService.publishErrorEvent(UserInfo.getUserName(), ex.getStackTraceString(), ex.getMessage(), 'zephr_InvocableCreateAccount - api integration error');
                }
                response.add(grantResponse);
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + ' - ' + ex.getStackTraceString());
            ZephrIntegrationService.publishErrorEvent(UserInfo.getUserName(), ex.getStackTraceString(), ex.getMessage(), 'zephr_InvocableCreateAccountGrant - non network error');
        }
        return response;
    }
}