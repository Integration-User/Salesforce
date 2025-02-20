/**
* @author Zoran Zunko
* @date 6/8/21
*
*/

public with sharing class zephr_InvocableCreateAccountGrant {
    
    @InvocableMethod
    public static List<ZephrApiRequestsResponses.Grant> createGrant(List<ZephrApiRequestsResponses.Grant> grantRequests) {
        List<ZephrApiRequestsResponses.Grant> response = new List<ZephrApiRequestsResponses.Grant>();

        try {
            Map<String, ZephrIntegrationNG> zephrIntegrationsByTenantMap = new Map<String, ZephrIntegrationNG>();
            for (ZephrApiRequestsResponses.Grant grantRequest : grantRequests) {
                ZephrApiRequestsResponses.Grant grantResponse = new ZephrApiRequestsResponses.Grant();
                grantResponse.message = 'ERROR';
                grantResponse.salesforceId = grantRequest.salesforceId;
                grantResponse.success = false;

                if(!zephrIntegrationsByTenantMap.containsKey(grantRequest.tenantId)) {
                    zephrIntegrationsByTenantMap.put(grantRequest.tenantId, new ZephrIntegrationNG(grantRequest.tenantId));
                }

                ZephrIntegrationNG zephr = zephrIntegrationsByTenantMap.get(grantRequest.tenantId);

                try {
                    HttpResponse res = zephr.createGrant(grantRequest.startTime, grantRequest.endTime, grantRequest.product_id, grantRequest.account_id, grantRequest.entitlement_id);
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