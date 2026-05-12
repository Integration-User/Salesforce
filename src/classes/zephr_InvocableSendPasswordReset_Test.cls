@isTest
private class zephr_InvocableSendPasswordReset_Test {

    private class SuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('Password reset link sent.');
            return res;
        }
    }

    private class FailureMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setBody('{"data":[{"id":"dummyToken123","email":"test@example.com","gstProdTosSignOff":"2024-01-01"}]}');
            return res;
        }
    }
    private class TokenHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"data":[{"id":"dummyToken123","email":"test@example.com","gstProdTosSignOff":"2024-01-01"}]}');
            return res;
        }
    }

    // Exception mock to simulate a thrown error
    private class ExceptionMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Force an exception
            throw new CalloutException('Simulated callout exception');
        }
    }

    @isTest
    static void testResetPasswordSuccess() {
        // Insert platform record BEFORE starting test
        GSA_Platform__c platform = new GSA_Platform__c(
            User_Change_Password_Reset_Token_Info__c = 'https://dummy.endpoint/token',
            Website_Password_Reset_Info__c = 'https://dummy.endpoint/reset/{!token}',
            Reset_Password_API_Key__c = 'dummyApiKey'
        );
        insert platform;
        Test.setMock(HttpCalloutMock.class, new TokenHttpMock());
        ZephrApiRequestsResponses.ResetUserPasswordRequest request = new ZephrApiRequestsResponses.ResetUserPasswordRequest();
        request.email = 'testuser@example.com';
        request.tenantId = 'Tenant123';
        request.websiteSlug = 'siteSlug';
        Test.startTest();
        List<ZephrApiRequestsResponses.User> results = zephr_InvocableSendPasswordReset.resetPassword(new List<ZephrApiRequestsResponses.ResetUserPasswordRequest>{ request });

        Test.stopTest();

    }

    @isTest
    static void testResetPasswordFailure() {
        // Insert platform record BEFORE starting test
        GSA_Platform__c platform = new GSA_Platform__c(
            User_Change_Password_Reset_Token_Info__c = 'https://dummy.endpoint/token',
            Website_Password_Reset_Info__c = 'https://dummy.endpoint/reset',
            Reset_Password_API_Key__c = 'dummyApiKey'
        );
        insert platform;
        Test.setMock(HttpCalloutMock.class, new FailureMock());
        ZephrApiRequestsResponses.ResetUserPasswordRequest request = new ZephrApiRequestsResponses.ResetUserPasswordRequest();
        request.email = 'failuser@example.com';
        Test.startTest();
        List<ZephrApiRequestsResponses.User> results = zephr_InvocableSendPasswordReset.resetPassword(new List<ZephrApiRequestsResponses.ResetUserPasswordRequest>{ request });
        Test.stopTest();
    }

    @isTest
    static void testResetPasswordException() {

        Test.setMock(HttpCalloutMock.class, new ExceptionMock());
        ZephrApiRequestsResponses.ResetUserPasswordRequest request = new ZephrApiRequestsResponses.ResetUserPasswordRequest();
        request.email = 'exceptionuser@example.com';
        request.tenantId = 'Tenant999';
        request.websiteSlug = 'siteSlug';

        List<ZephrApiRequestsResponses.User> results = zephr_InvocableSendPasswordReset.resetPassword(new List<ZephrApiRequestsResponses.ResetUserPasswordRequest>{ request });

        System.assertEquals(false, results[0].success, 'Success should be false when exception occurs');

    }
}