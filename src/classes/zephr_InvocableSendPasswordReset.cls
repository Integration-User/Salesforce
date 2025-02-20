/**
* @author Zoran Zunko
* @date 9/24/21
*
*/
public with sharing class zephr_InvocableSendPasswordReset {
    @InvocableMethod public static List<ZephrApiRequestsResponses.User> resetPassword(List<ZephrApiRequestsResponses.ResetUserPasswordRequest> userRequests) {
        List<ZephrApiRequestsResponses.User> response = new List<ZephrApiRequestsResponses.User>();

        try {
            Map<String, ZephrIntegrationNG> zephrIntegrationsByTenantMap = new Map<String, ZephrIntegrationNG>();

            for (ZephrApiRequestsResponses.ResetUserPasswordRequest userRequest : userRequests) {
                ZephrApiRequestsResponses.User userResponse = new ZephrApiRequestsResponses.User();
                userResponse.message = 'ERROR';
                userResponse.success = false;

                if(!zephrIntegrationsByTenantMap.containsKey(userRequest.tenantId)) {
                    zephrIntegrationsByTenantMap.put(userRequest.tenantId, new ZephrIntegrationNG(userRequest.tenantId));
                }

                ZephrIntegrationNG zephr = zephrIntegrationsByTenantMap.get(userRequest.tenantId);

                try {
                    HttpResponse res = zephr.sendResetPassword(userRequest.email, userRequest.tenantId + '|' +userRequest.websiteSlug);
                    if (res.getStatusCode() == 201 || res.getStatusCode() == 200) {
                        userResponse.success = true;
                        userResponse.message = 'Password reset link sent.';
                    } else {
                        userResponse.success = false;
                        userResponse.message = res.getBody();
                    }
                } catch (Exception ex) {
                    System.debug(LoggingLevel.ERROR, ex.getMessage() + ' - ' + ex.getStackTraceString());
                    userResponse.message = ex.getMessage() + ' - ' + ex.getStackTraceString();
                }
                response.add(userResponse);
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + ' - ' + ex.getStackTraceString());
            ZephrIntegrationService.publishErrorEvent(UserInfo.getUserName(), ex.getStackTraceString(), ex.getMessage(), 'zephr_InvocableUpdateUserEmail - non network error');
        }
        return response;
    }
}