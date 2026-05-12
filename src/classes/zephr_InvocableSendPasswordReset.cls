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

               /* if(!zephrIntegrationsByTenantMap.containsKey(userRequest.tenantId)) {
                    zephrIntegrationsByTenantMap.put(userRequest.tenantId, new ZephrIntegrationNG(userRequest.tenantId));
                }

                ZephrIntegrationNG zephr = zephrIntegrationsByTenantMap.get(userRequest.tenantId);*/

                try {
                    System_Configuration__mdt zephrSendResetPassword = System_Configuration__mdt.getInstance('ResetWebsitePasswordEnable');
                    if(zephrSendResetPassword.IsEnabled__c || Test.isRunningTest()) {
                        //SF-2146 Wrong email being sent via 'reset password' on Sf and now it not working at all
                       // HttpResponse res = zephr.sendResetPassword(userRequest.email, userRequest.tenantId + '|' +userRequest.websiteSlug);
                        HttpResponse res = ZephrIntegrationNG.sendResetPasswordForMantis(userRequest.email);
                        if (res != null && res.getStatusCode() == 204 || res.getStatusCode() == 200) {
                            userResponse.success = true;
                            userResponse.message = 'Password reset link sent.';
                        } else {
                            userResponse.success = false;
                            userResponse.message = res.getBody();
                        }
                    } else {
                        userResponse.success = false;
                        userResponse.message = 'The password reset link cannot be sent. Please contact the System Administrator for assistance.';
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