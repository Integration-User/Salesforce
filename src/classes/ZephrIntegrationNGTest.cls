/**
* @author Zoran Zunko
* @date 6/23/21
*
*/
@IsTest
public class ZephrIntegrationNGTest {

    @IsTest
    public static void test_getUsers() {

        Test.setMock(HttpCalloutMock.class, new CalloutMockForHttp( ZephrIntegration_TestUtility.getUsersBody(), 200));

        ZephrIntegrationNG inst = new ZephrIntegrationNG(null);
        inst.testCallout = true;
        HttpResponse res = inst.getUsers();
    }
    @IsTest
    public static void test_createCompany() {
        Test.setMock(HttpCalloutMock.class, new CalloutMockForHttp( ZephrIntegration_TestUtility.createCompanyBody(), 201));
        ZephrIntegrationNG inst = new ZephrIntegrationNG(null);
        inst.testCallout = true;
        HttpResponse res = inst.createCompany('NewComp', 'www.newcomp.com');

        System.assertEquals(201, res.getStatusCode());
    }
    @IsTest
    public static void test_createAccount() {
        Test.setMock(HttpCalloutMock.class, new CalloutMockForHttp( ZephrIntegration_TestUtility.createAccount(), 201));
        ZephrIntegrationNG inst = new ZephrIntegrationNG(null);
        inst.testCallout = true;
        HttpResponse res = inst.createAccount( '85aac24a-8c89-41da-8eff-12bd6697dfa6', '0055774', 'II', 10, 'SomeCompany');

        System.assertEquals(201, res.getStatusCode());
    }
    @IsTest
    public static void test_createAccountNG() {
        Test.setMock(HttpCalloutMock.class, new CalloutMockForHttp( ZephrIntegration_TestUtility.createAccount(), 201));
        ZephrIntegrationNG inst = new ZephrIntegrationNG(null);
        inst.testCallout = true;
        HttpResponse res = inst.createAccount( '85aac24a-8c89-41da-8eff-12bd6697dfa6', 'Name', 10, false);

        System.assertEquals(201, res.getStatusCode());
    }
    @IsTest
    public static void test_getUserGrants() {
        Test.setMock(HttpCalloutMock.class, new CalloutMockForHttp( ZephrIntegration_TestUtility.getUserGrants(), 200));
        ZephrIntegrationNG inst = new ZephrIntegrationNG(null);
        inst.testCallout = true;
        HttpResponse res = inst.getUserGrants('80452dd3-1d83-4f5d-9375-1286e015150f');

        System.assertEquals(200, res.getStatusCode());
    }
    @IsTest
    public static void test_createUserGrant() {
        Test.setMock(HttpCalloutMock.class, new CalloutMockForHttp( ZephrIntegration_TestUtility.createUserGrant(), 201));
        ZephrIntegrationNG inst = new ZephrIntegrationNG(null);
        inst.testCallout = true;
        HttpResponse res = inst.createUserGrant('3ed76e72-cb47-4504-af09-11f95cd21dfa', 'TR', '1452f948-35b3-4393-8c8d-1fe0f195e692', Datetime.now(), Datetime.now().addDays(14) );

        System.assertEquals(201, res.getStatusCode());
    }
    @IsTest
    public static void test_getAccountGrants() {
        Test.setMock(HttpCalloutMock.class, new CalloutMockForHttp( ZephrIntegration_TestUtility.getAccountGrants(), 200));
        ZephrIntegrationNG inst = new ZephrIntegrationNG(null);
        inst.testCallout = true;
        HttpResponse res = inst.getAccountGrants( 'f709d2d4-eb66-42ee-b841-7add030386dc');

        System.assertEquals(200, res.getStatusCode());
    }
    @IsTest
    public static void test_deleteUserGrant() {
        Test.setMock(HttpCalloutMock.class, new CalloutMockForHttp( ZephrIntegration_TestUtility.deleteUserGrant(), 200));
        ZephrIntegrationNG inst = new ZephrIntegrationNG(null);
        inst.testCallout = true;
        HttpResponse res = inst.deleteUserGrant( '3ed76e72-cb47-4504-af09-11f95cd21dfa', '378ed871-042f-4482-a06a-9abf9fa1e22e');

        System.assertEquals(200, res.getStatusCode());
    }
    @IsTest
    public static void test_createGrant() {
        Test.setMock(HttpCalloutMock.class, new CalloutMockForHttp( ZephrIntegration_TestUtility.createGrant(), 201));
        ZephrIntegrationNG inst = new ZephrIntegrationNG(null);
        inst.testCallout = true;
        HttpResponse res = inst.createGrant(Date.newInstance(2020,11,19), Date.newInstance(2021, 11, 19), 'II', 'f709d2d4-eb66-42ee-b841-7add030386dc', '2316c3fb-0697-4294-996d-fab4b33cc7a8');

        System.assertEquals(201, res.getStatusCode());
    }
    @IsTest
    public static void test_accountUser() {
        Test.setMock(HttpCalloutMock.class, new CalloutMockForHttp( ZephrIntegration_TestUtility.accountUser(), 200));
        ZephrIntegrationNG inst = new ZephrIntegrationNG(null);
        inst.testCallout = true;
        HttpResponse res = inst.accountUser('f709d2d4-eb66-42ee-b841-7add030386dc', 'd4811164-6e39-48a9-8728-a3c485afb1cb', 'PUT');

        System.assertEquals(200, res.getStatusCode());
    }
    @IsTest
    public static void test_deleteAccountGrant() {
        Test.setMock(HttpCalloutMock.class, new CalloutMockForHttp( ZephrIntegration_TestUtility.deleteAccountGrant(), 200));
        ZephrIntegrationNG inst = new ZephrIntegrationNG(null);
        inst.testCallout = true;
        HttpResponse res = inst.deleteAccountGrant( 'f709d2d4-eb66-42ee-b841-7add030386dc', '66c068af-135d-47ad-b4d7-98b4f81860d1');

        System.assertEquals(200, res.getStatusCode());
    }
    @IsTest
    public static void test_updateUserAttributes() {
        Test.setMock(HttpCalloutMock.class, new CalloutMockForHttp( ZephrIntegration_TestUtility.updateUserAttributes(), 200));
        ZephrIntegrationNG inst = new ZephrIntegrationNG(null);
        inst.testCallout = true;
        HttpResponse res = inst.updateUserAttributes( 'c17c9cf4-36fd-4b54-a63f-45c7649f6090', new Map<String, String>{'salesforce_id' => '0031q00000aERpfAAG'});

        System.assertEquals(200, res.getStatusCode());
    }
    @IsTest
    public static void test_getGrant() {

        Test.setMock(HttpCalloutMock.class, new CalloutMockForHttp( ZephrIntegration_TestUtility.getGrant(), 200));
        ZephrIntegrationNG inst = new ZephrIntegrationNG(null);
        inst.testCallout = true;
        HttpResponse res = inst.getGrant('18420f20-5e3b-453c-bc3a-e3ca4f95c6d8','1f9e2b27-615b-4849-963e-4380c6b440aa');

        System.assertEquals(200, res.getStatusCode());
    }
    @IsTest
    public static void test_getUserByEmail() {

        Test.setMock(HttpCalloutMock.class, new CalloutMockForHttp( ZephrIntegration_TestUtility.createUserBody(), 200));
        ZephrIntegrationNG inst = new ZephrIntegrationNG(null);
        inst.testCallout = true;
        HttpResponse res = inst.getUserByEmail('test@example.com');

        System.assertEquals(200, res.getStatusCode());
    }
    @IsTest
    public static void test_no2XXResponse() {

        Test.setMock(HttpCalloutMock.class, new CalloutMockForHttp( 'Not authorized', 401));
        ZephrIntegrationNG zephr = new ZephrIntegrationNG(null);
        zephr.testCallout = true;
        Test.startTest();
        zephr.httpCallout('/users', 'GET', '');
        Test.stopTest();
    }
    @IsTest
    public static void test_publishHttpErrorEvent() {

        Test.startTest();
        Database.SaveResult sr = ZephrIntegrationNG.publishHttpErrorEvent(UserInfo.getUserName(), '/users', '', 'Not Authorized', 401, 'HTTP Request', 'GET');
        Test.stopTest();

        System.assertEquals(true, sr.isSuccess());
    }
    // Mock for token call
    private class TokenHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"data":[{"id":"dummyToken123","email":"test@example.com","gstProdTosSignOff":"2024-01-01"}]}');
            return res;
        }
    }

    // Mock for reset call
    private class ResetHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"message":"Password reset successful"}');
            return res;
        }
    }

    @isTest
    static void testMantisResetPasswordToken() {
        // Insert platform record BEFORE starting test
        GSA_Platform__c platform = new GSA_Platform__c(
            User_Change_Password_Reset_Token_Info__c = 'https://dummy.endpoint/token',
            Reset_Password_API_Key__c = 'dummyApiKey'
        );
        insert platform;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TokenHttpMock());
        String token = ZephrIntegrationNG.mantisResetPasswordToken('test@example.com', platform);
        Test.stopTest();

        System.assertEquals('dummyToken123', token);
    }

    @isTest
    static void testSendResetPasswordForMantis() {
        // Insert platform record BEFORE starting test
        GSA_Platform__c platform = new GSA_Platform__c(
            User_Change_Password_Reset_Token_Info__c = 'https://dummy.endpoint/token',
            Website_Password_Reset_Info__c = 'https://dummy.endpoint/reset/{!token}',
            Reset_Password_API_Key__c = 'dummyApiKey'
        );
        insert platform;

        Test.startTest();
        // First mock for token call
        Test.setMock(HttpCalloutMock.class, new TokenHttpMock());
        // Second mock for reset call
        //Test.setMock(HttpCalloutMock.class, new ResetHttpMock());

        HttpResponse response = ZephrIntegrationNG.sendResetPasswordForMantis('test@example.com');
        Test.stopTest();

        System.assertEquals(200, response.getStatusCode());
    }
    // Generic mock that can handle different endpoints
    private class GenericHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);

            if (req.getEndpoint().contains('/v3/users')) {
                res.setBody('{"message":"User created successfully"}');
            } else if (req.getEndpoint().contains('/v4/users/reset')) {
                res.setBody('{"message":"Password reset link sent"}');
            } else if (req.getEndpoint().contains('/update-email')) {
                res.setBody('{"message":"Email updated successfully"}');
            } else if (req.getEndpoint().contains('/v3/accounts/')) {
                // Return account JSON with number_of_seats so updateAccount can work
                res.setBody('{"account_id":"acc123","number_of_seats":5}');
            } else {
                res.setBody('{"message":"Generic response"}');
            }
            return res;
        }
    }

    @isTest
    static void testCreateUser() {
        Test.setMock(HttpCalloutMock.class, new GenericHttpMock());

        ZephrIntegrationNG integration = new ZephrIntegrationNG(null);


        zephr_WebhookAPI.UserDetails userDetails = new zephr_WebhookAPI.UserDetails();
        userDetails.identifiers = new zephr_WebhookAPI.Identifiers();
        userDetails.identifiers.email_address = 'test@example.com';

        Test.startTest();
        HttpResponse res = integration.createUser(userDetails);
        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
        System.assert(res.getBody().contains('User created successfully'));
    }

    @isTest
    static void testSendResetPassword() {
        Test.setMock(HttpCalloutMock.class, new GenericHttpMock());

        ZephrIntegrationNG integration = new ZephrIntegrationNG(null);


        Test.startTest();
        HttpResponse res = integration.sendResetPassword('test@example.com', 'mysite');
        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
        System.assert(res.getBody().contains('Password reset link sent'));
    }

    @isTest
    static void testUpdateUserEmail() {
        Test.setMock(HttpCalloutMock.class, new GenericHttpMock());

        ZephrIntegrationNG integration = new ZephrIntegrationNG(null);

        Test.startTest();
        HttpResponse res = integration.updateUserEmail('user123', 'new@example.com', 'mysite');
        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());

    }

    @isTest
    static void testUpdateAccount() {
        Test.setMock(HttpCalloutMock.class, new GenericHttpMock());

        ZephrIntegrationNG integration = new ZephrIntegrationNG(null);


        ZephrApiRequestsResponses.Account acc = new ZephrApiRequestsResponses.Account();
        acc.account_id = 'acc123';
        acc.number_of_seats = 10;

        Test.startTest();
        HttpResponse res = integration.updateAccount(acc);
        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());

    }
}