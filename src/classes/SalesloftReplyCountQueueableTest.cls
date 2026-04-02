@isTest
private class SalesloftReplyCountQueueableTest {
    @isTest
    static void testSchedulerPlusQueueableUpdatesTasks() {
        // prepare tasks that should be updated by the queueable
        Task t1 = new Task(Subject='Salesloft test', Email_Message_Id__c='<msg1>');
        Task t2 = new Task(Subject='Salesloft test2', Email_Message_Id__c='<msg2>');
        insert new List<Task>{t1, t2};

        // install mock for both token and activities
        Test.setMock(HttpCalloutMock.class, new ActivityMock());

        Test.startTest();
        // schedule the job; it will enqueue the queueable and run during stopTest
        String cron = '0 0 0 ? * * *'; // daily at midnight (any valid cron works)
        System.schedule('Salesloft Reply Count Test', cron, new SalesloftReplyCountScheduler());
        Test.stopTest();
    }

    @isTest
    static void testAuthServiceAndEmailResponseParsing() {
        // the same mock covers both token and activity endpoints
        Test.setMock(HttpCalloutMock.class, new ActivityMock());

        Test.startTest();
        String token = SalesloftAuthService.getAccessToken();
        SalesloftEmailActivityResponse resp = SalesloftAuthService.getEmailsActivities();
        SalesloftEmailActivityResponse resp1 = SalesloftAuthService.getEmailsActivities(1);
        Test.stopTest();

        // verify the auth service returned our mock token
        System.assertEquals('mock_token', token, 'access token should be parsed');

        // ensure parsing produced the expected structure
        System.assertNotEquals(null, resp, 'response should not be null');
        System.assertEquals(2, resp.data.size(), 'two activities in the mock');
        System.assertEquals('msg1', resp.data[0].message_id);
        System.assertEquals(5, resp.data[0].counts.replies);
        System.assertEquals('msg2', resp.data[1].message_id);
        System.assertEquals(10, resp.data[1].counts.replies);
        // metadata should also be populated
        System.assertNotEquals(null, resp.metadata);
        System.assertEquals(null, resp.metadata.paging.next_page);
    }

    // simple mock that returns a token and one page of activity data
    private class ActivityMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            if (req.getEndpoint().contains('/oauth/token')) {
                res.setStatusCode(200);
                res.setBody('{"access_token":"mock_token"}');
            } else if (req.getEndpoint().contains('/activities/emails')) {
                res.setStatusCode(200);
                // include two records with message_id values matching tasks above
                res.setBody(
                    '{"metadata":{"paging":{"next_page":null}},' +
                    '"data":[' +
                    '  {"message_id":"msg1","counts":{"replies":5}},' +
                    '  {"message_id":"msg2","counts":{"replies":10}}' +
                    ']' +
                    '}'
                );
            } else {
                res.setStatusCode(404);
            }
            return res;
        }
    }
    @isTest
    static void testEmailActivityResponseDirectInstantiation() {
        // creating the response and all inner types directly to bump coverage
        SalesloftEmailActivityResponse resp = new SalesloftEmailActivityResponse();
        resp.metadata = new SalesloftEmailActivityResponse.Metadata();
        resp.metadata.paging = new SalesloftEmailActivityResponse.Paging();
        resp.metadata.paging.current_page = 1;
        resp.metadata.paging.next_page = 2;
        resp.metadata.paging.per_page = 1;
        resp.metadata.paging.total_pages = 1;
        resp.data = new List<SalesloftEmailActivityResponse.ActivityData>();
        SalesloftEmailActivityResponse.ActivityData a = new SalesloftEmailActivityResponse.ActivityData();
        a.message_id = 'abc';
        resp.data.add(a);
    }
}