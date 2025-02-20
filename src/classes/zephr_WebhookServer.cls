/**
* @author Zoran Zunko
* @date 8/30/21
*
*/

@RestResource(UrlMapping='/zephr/webhook/*')
global class zephr_WebhookServer {
    @TestVisible static Map<String, Map<String, zephr_WebhookAPI.ObjectHandler>> serviceMethodURLMap;
    public static Map<String, Map<String, zephr_WebhookAPI.ObjectHandler>> getServiceMethodURLMap() {
        if (serviceMethodURLMap == null) {
            zephr_WebhookAPI.ZephrUserHandler zephrUserHandler = new zephr_WebhookAPI.ZephrUserHandler();
            zephr_WebhookAPI.UserEmailConfirmedHandler userEmailConfirmedHandler = new zephr_WebhookAPI.UserEmailConfirmedHandler();
            zephr_WebhookAPI.UserEmailChangeHandler userEmailChangeHandler = new zephr_WebhookAPI.UserEmailChangeHandler();
            zephr_WebhookAPI.GrantCreatedHandler grantCreatedHandler = new zephr_WebhookAPI.GrantCreatedHandler();
            zephr_WebhookAPI.AccountGrantCreatedHandler accountGrantCreatedHandler = new zephr_WebhookAPI.AccountGrantCreatedHandler();
            zephr_WebhookAPI.UserAccountGrantCreatedHandler userAccountGrantCreatedHandler = new zephr_WebhookAPI.UserAccountGrantCreatedHandler();
            serviceMethodURLMap = new Map<String, Map<String, zephr_WebhookAPI.ObjectHandler>>{
                    'POST' => new Map<String, zephr_WebhookAPI.ObjectHandler>{
                            '/zephr/webhook/users/' => zephrUserHandler,
                            '/zephr/webhook/account/grant/' => accountGrantCreatedHandler,
                            '/zephr/webhook/account/user/' => userAccountGrantCreatedHandler,
                            '/zephr/webhook/grant/' => grantCreatedHandler
                    },
                    'GET' => new Map<String, zephr_WebhookAPI.ObjectHandler>(),
                    'PUT' => new Map<String, zephr_WebhookAPI.ObjectHandler>{
                            '/zephr/webhook/users/' => zephrUserHandler,
                            '/zephr/webhook/users/emailconfirmed/' => userEmailConfirmedHandler,
                            '/zephr/webhook/users/email/' => userEmailChangeHandler
                    },
                    'DELETE' => new Map<String, zephr_WebhookAPI.ObjectHandler>{
                            '/zephr/webhook/account/user/' => userAccountGrantCreatedHandler
                    }
            };
        }
        return serviceMethodURLMap;
    }

    @HttpPost
    global static void handlePost() {
        handleRequest('POST');
    }
    @HttpPut
    global static void handlePut() {
        handleRequest('PUT');
    }
    @HttpDelete
    global static void handleDelete() {
        handleRequest('DELETE');
    }
    @TestVisible static void handleRequest(String method) {
        Zephr_Webhook_Data__c zephrWebhookData = new Zephr_Webhook_Data__c();
        zephrWebhookData.Webhook_URI__c = RestContext.request.requestURI;
        try {
            String webhookBody = RestContext.request.requestBody.toString();
            System.debug(LoggingLevel.DEBUG, 'handleRequest - webhookBody: ' + webhookBody);
            System.debug(LoggingLevel.ERROR, 'handleRequest - RestContext.request.requestURI: ' + RestContext.request.requestURI);

            zephrWebhookData.Webhook_Payload__c = webhookBody;
            zephr_WebhookAPI.GeneralInformation apiRequest = (zephr_WebhookAPI.GeneralInformation) JSON.deserialize(webhookBody, zephr_WebhookAPI.GeneralInformation.class);
            zephrWebhookData.Zephr_Tenant__c = apiRequest.tenantId;
            zephrWebhookData.Type__c = apiRequest.type;
            zephrWebhookData.Status__c = 'NEW';

            if (!getServiceMethodURLMap().get(method).isEmpty()) {
                for (String serviceHandlerPattern : getServiceMethodURLMap().get(method).keySet()) {
                    Pattern serviceHandlerRegexPattern = Pattern.compile(serviceHandlerPattern);
                    Matcher pm = serviceHandlerRegexPattern.matcher(RestContext.request.requestURI);
                    if (pm.matches()) {
                        try {
                            zephr_WebhookAPI.ObjectHandler objectHandler = getServiceMethodURLMap().get(method).get(serviceHandlerPattern);
                            if (objectHandler.handleMethod(webhookBody, method) != null) {
                                zephrWebhookData.Status__c = 'OK';
                            } else {
                                if (objectHandler instanceof zephr_WebhookAPI.GrantCreatedHandler || objectHandler instanceof zephr_WebhookAPI.UserAccountGrantCreatedHandler) {
                                    zephr_ProcessUserGrantQueueable processUserGrantQueueable = new zephr_ProcessUserGrantQueueable();
                                    processUserGrantQueueable.runCounter = 0;
                                    processUserGrantQueueable.grantHandler = objectHandler;
                                    processUserGrantQueueable.zephrWebhookData = zephrWebhookData;
                                    System.enqueueJob(processUserGrantQueueable);
                                    return;
//                                } else if (objectHandler instanceof zephr_WebhookAPI.UserAccountGrantCreatedHandler) {
//                                    zephr_ProcessUserAccountGrantQueueable processUserAccountGrantQueueable = new zephr_ProcessUserAccountGrantQueueable();
//                                    processUserAccountGrantQueueable.runCounter = 0;
//                                    processUserAccountGrantQueueable.zephrWebhookData = zephrWebhookData;
//                                    System.enqueueJob(processUserAccountGrantQueueable);
//                                    return;
                                    //test
//                                }
                                }

                            }
                        } catch (Exception ex) {
                            System.debug(LoggingLevel.ERROR, ex.getMessage() + ' - ' + ex.getStackTraceString());
                            zephrWebhookData.Error_Description__c = ex.getMessage() + ' - ' + ex.getStackTraceString();
                            zephrWebhookData.Status__c = 'ERROR';
                        }
                    }
                }
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG, ex);
            zephrWebhookData.Error_Description__c = ex.getMessage() + ' - ' + ex.getStackTraceString();
            zephrWebhookData.Type__c = zephrWebhookData.Type__c == null ? 'ERROR' : zephrWebhookData.Type__c;
            zephrWebhookData.Status__c = zephrWebhookData.Status__c == 'NEW' ? 'ERROR' : zephrWebhookData.Status__c;
        }
        insert zephrWebhookData;
    }
    @HttpGet
    global static void handleGet() {
        try {
            String webhookBody = RestContext.request.requestBody.toString();
            System.debug(LoggingLevel.ERROR, 'handlePost - handleGet: ' + webhookBody);
            //do some logic
        } catch (Exception e) {
            //do some error handling
        }
    }
}