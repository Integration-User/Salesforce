/**
* @author Zoran Zunko
* @date 9/22/21
*
*/
public without sharing class zephr_ProcessUserGrantQueueable implements Queueable, Database.AllowsCallouts {
    public Zephr_Webhook_Data__c zephrWebhookData;
    public Integer runCounter;
    public zephr_WebhookAPI.ObjectHandler grantHandler;
    public String lastErrorMessage = '';

    public void execute(QueueableContext qc) {
        if (zephrWebhookData == null) return;
        if (grantHandler == null) return;
        if (runCounter == null) runCounter = 0;
        if (runCounter > 5) {
            zephrWebhookData.Error_Description__c = String.isBlank(lastErrorMessage) ? 'Grant Queueable can\'t find a user - ' + zephrWebhookData.Zephr_Tenant__c : lastErrorMessage;
            zephrWebhookData.Status__c = 'ERROR';
            insert zephrWebhookData;
            return;
        }
        zephr_WebhookAPI.BaseAPI handlerResponse;
        try {
            handlerResponse = grantHandler.handlePost(zephrWebhookData.Webhook_Payload__c);
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + ' - ' + ex.getStackTraceString());
            lastErrorMessage = ex.getMessage() + ' - ' + ex.getStackTraceString();
        } finally {
//            zephr_WebhookAPI.GrantCreatedHandler grantHandler = new zephr_WebhookAPI.GrantCreatedHandler();
            if (handlerResponse == null) {
                runCounter++;
                zephr_ProcessUserGrantQueueable processUserGrantQueueable = new zephr_ProcessUserGrantQueueable();
                processUserGrantQueueable.runCounter = runCounter;
                processUserGrantQueueable.zephrWebhookData = zephrWebhookData;
                processUserGrantQueueable.grantHandler = this.grantHandler;
                processUserGrantQueueable.lastErrorMessage = this.lastErrorMessage;
                for (Long i = 0; i < (10000 * (runCounter + 1)); i++) {
                    String s = 'abcdefghijklmnoprst'.replace('a', '').replace('b', '').replace('c', '').replace('d', '').replace('e', '').replace('f', '').replace('g', '');
                    s = 'abcdefghijklmnoprst'.replace('t', '').replace('s', '').replace('r', '').replace('p', '').replace('o', '').replace('n', '').replace('m', '');
                    s = 'abcdefghijklmnoprst'.replace('t', '').replace('s', '').replace('r', '').replace('p', '').replace('o', '').replace('n', '').replace('m', '');
                    s = 'abcdefghijklmnoprst'.replace('t', '').replace('s', '').replace('r', '').replace('p', '').replace('o', '').replace('n', '').replace('m', '');
                    s = 'abcdefghijklmnoprst'.replace('t', '').replace('s', '').replace('r', '').replace('p', '').replace('o', '').replace('n', '').replace('m', '');
                }
                if ( ! Test.isRunningTest()) {
                    System.enqueueJob(processUserGrantQueueable);
                }

            } else {
                zephrWebhookData.Status__c = 'OK';
                insert zephrWebhookData;
            }
        }
    }
}