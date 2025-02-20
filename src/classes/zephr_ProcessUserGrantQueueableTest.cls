/**
 * Created by david on 07/12/2024.
 */

@IsTest
private class zephr_ProcessUserGrantQueueableTest {

	@IsTest static void testUserGrantQueuable() {
//		'/zephr/webhook/account/user/' => userAccountGrantCreatedHandler,
//		'/zephr/webhook/grant/' => grantCreatedHandler

		RestRequest req = new RestRequest();
		req.requestURI = String.valueOf('/zephr/webhook/grant/');
		req.addHeader('Content-Type', 'application/json');
		req.requestBody = Blob.valueOf(ZephrIntegration_TestUtility.createUserGrant());
		RestContext.request = req;

		Zephr_Webhook_Data__c zephrWebhookData = new Zephr_Webhook_Data__c();
		zephrWebhookData.Webhook_URI__c = RestContext.request.requestURI;
		String webhookBody = RestContext.request.requestBody.toString();
		zephrWebhookData.Webhook_Payload__c = ZephrIntegration_TestUtility.createUserGrant();
		zephr_WebhookAPI.GeneralInformation apiRequest = (zephr_WebhookAPI.GeneralInformation) JSON.deserialize(webhookBody, zephr_WebhookAPI.GeneralInformation.class);
		zephrWebhookData.Zephr_Tenant__c = apiRequest.tenantId;
		zephrWebhookData.Type__c = apiRequest.type;
		zephrWebhookData.Status__c = 'NEW';

		zephr_ProcessUserGrantQueueable processUserGrantQueueable = new zephr_ProcessUserGrantQueueable();
		processUserGrantQueueable.runCounter = 4;
		processUserGrantQueueable.grantHandler = new zephr_WebhookAPI.GrantCreatedHandler();
		processUserGrantQueueable.zephrWebhookData = zephrWebhookData;


		Test.startTest();
		System.enqueueJob(processUserGrantQueueable);
		Test.stopTest();

	}
	@IsTest
	static void testBehavior() {




	}
}