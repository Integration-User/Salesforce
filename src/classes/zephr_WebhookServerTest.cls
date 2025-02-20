/**
 * Created by david on 07/12/2024.
 */

@IsTest
private class zephr_WebhookServerTest {

		@IsTest
		static void testGetServiceMethodURLMap() {
			Test.startTest();
			Map<String, Map<String, zephr_WebhookAPI.ObjectHandler>> serviceMethodMap = zephr_WebhookServer.getServiceMethodURLMap();
			Test.stopTest();
			Assert.areNotEqual(
					null,
					serviceMethodMap,
					'Is not null'
			);
		}

		@IsTest
		static void testHandleRequest() {

			RestRequest req = new RestRequest();
			req.requestURI = String.valueOf('/zephr/webhook/users/');
			req.addHeader('Content-Type', 'application/json');
			req.requestBody = Blob.valueOf(ZephrIntegration_TestUtility.getUsersBody());

			RestContext.request = req;

			Test.startTest();
			zephr_WebhookServer.handleRequest('POST');
			Test.stopTest();
		}

		@IsTest static void testHandleGet() {

			RestRequest req = new RestRequest();
			req.requestURI = String.valueOf('/zephr/webhook/users/');
			req.addHeader('Content-Type', 'application/json');
			req.requestBody = Blob.valueOf(ZephrIntegration_TestUtility.getUsersBody());
			RestContext.request = req;

			Test.startTest();
			zephr_WebhookServer.handleGet();
			Test.stopTest();
		}

		@IsTest static void testHandlePost() {

			RestRequest req = new RestRequest();
			req.requestURI = String.valueOf('/zephr/webhook/users/');
			req.addHeader('Content-Type', 'application/json');
			req.requestBody = Blob.valueOf(ZephrIntegration_TestUtility.getUsersBody());
			RestContext.request = req;

			Test.startTest();
			zephr_WebhookServer.handlePost();
			Test.stopTest();
		}

		@IsTest static void testHandlePut() {

			RestRequest req = new RestRequest();
			req.requestURI = String.valueOf('/zephr/webhook/users/');
			req.addHeader('Content-Type', 'application/json');
			req.requestBody = Blob.valueOf(ZephrIntegration_TestUtility.getUsersBody());
			RestContext.request = req;

			Test.startTest();
			zephr_WebhookServer.handlePut();
			Test.stopTest();
		}

		@IsTest static void testHandleDelete() {

			RestRequest req = new RestRequest();
			req.requestURI = String.valueOf('/zephr/webhook/account/user/');
			req.addHeader('Content-Type', 'application/json');
			req.requestBody = Blob.valueOf(ZephrIntegration_TestUtility.getUsersBody());
			RestContext.request = req;

			Test.startTest();
			zephr_WebhookServer.handleDelete();
			Test.stopTest();
		}

}