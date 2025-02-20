/**
* @author Zoran Zunko
* @date 6/23/21
*
*/
@IsTest
global with sharing class zephr_InvocableCreateUserTest {
    @IsTest
    public static void test_createZephrUser_nouser() {
        List<ZephrApiRequestsResponses.CreateUserRequest> userRequests = new List<ZephrApiRequestsResponses.CreateUserRequest>();
        ZephrApiRequestsResponses.CreateUserRequest userRequest = new ZephrApiRequestsResponses.CreateUserRequest();
        userRequest.tenantId = 'testTenant';
        userRequest.salesforceId = 'testid';
        userRequest.email = '123@example.com';
        userRequest.firstName = 'fname';
        userRequest.lastName = 'lname';
        userRequest.companyName = 'cname';
        userRequest.jobTitle  = 'title';
        userRequest.city = 'city';
        userRequest.country = 'United Kingdom';
        userRequest.companyType = 'type' ;
        userRequest.startDate = Date.today();
        userRequest.sendPasswordReset = true;
        userRequests.add(userRequest);

        Map<String, zephr_TestMock.MockConfig> mockConfigs = new Map<String, zephr_TestMock.MockConfig>{
                '(^https://(.+).zephr.com)(/v3/users$)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/users\\?identifiers.email_address=)(.+)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'NOT FOUND', 401, false, 'GET'),
                '(^https://(.+).zephr.com)(/v4/users/reset)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 201, false, 'POST')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        List<ZephrApiRequestsResponses.User> companyResponses = zephr_InvocableCreateUser.createZephrUser(userRequests);
        System.assertEquals('User created successfully and password reset link sent.', companyResponses[0].message);
        System.assert(companyResponses[0].success);
    }

    @IsTest
    public static void test_createZephrUser_nouser_error() {
        List<ZephrApiRequestsResponses.CreateUserRequest> userRequests = new List<ZephrApiRequestsResponses.CreateUserRequest>();
        ZephrApiRequestsResponses.CreateUserRequest userRequest = new ZephrApiRequestsResponses.CreateUserRequest();
        userRequest.tenantId = 'testTenant';
        userRequest.salesforceId = 'testid';
        userRequest.email = '123@example.com';
        userRequest.firstName = 'fname';
        userRequest.lastName = 'lname';
        userRequest.companyName = 'cname';
        userRequest.jobTitle  = 'title';
        userRequest.city = 'city';
        userRequest.country = 'United Kingdom';
        userRequest.companyType = 'type' ;
        userRequest.startDate = Date.today();
        userRequest.sendPasswordReset = true;
        userRequests.add(userRequest);

        Map<String, zephr_TestMock.MockConfig> mockConfigs = new Map<String, zephr_TestMock.MockConfig>{
                '(^https://(.+).zephr.com)(/v3/users$)' => new zephr_TestMock.MockConfig('not json', 'OK', 500, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/users\\?identifiers.email_address=)(.+)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'NOT FOUND', 401, false, 'GET'),
                '(^https://(.+).zephr.com)(/v4/users/reset)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 201, false, 'POST')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        List<ZephrApiRequestsResponses.User> companyResponses = zephr_InvocableCreateUser.createZephrUser(userRequests);
        System.assertEquals('not json', companyResponses[0].message);
        System.assert(!companyResponses[0].success);
    }

    @IsTest
    public static void test_createZephrUser_nouser_exception() {
        List<ZephrApiRequestsResponses.CreateUserRequest> userRequests = new List<ZephrApiRequestsResponses.CreateUserRequest>();
        ZephrApiRequestsResponses.CreateUserRequest userRequest = new ZephrApiRequestsResponses.CreateUserRequest();
        userRequest.tenantId = 'testTenant';
        userRequest.salesforceId = 'testid';
        userRequest.email = '123@example.com';
        userRequest.firstName = 'fname';
        userRequest.lastName = 'lname';
        userRequest.companyName = 'cname';
        userRequest.jobTitle  = 'title';
        userRequest.city = 'city';
        userRequest.country = 'United Kingdom';
        userRequest.companyType = 'type' ;
        userRequest.startDate = Date.today();
        userRequest.sendPasswordReset = true;
        userRequests.add(userRequest);

        Map<String, zephr_TestMock.MockConfig> mockConfigs = new Map<String, zephr_TestMock.MockConfig>{
                '(^https://(.+).zephr.com)(/v3/users$)' => new zephr_TestMock.MockConfig('not json', 'OK', 500, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/users\\?identifiers.email_address=)(.+)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'NOT FOUND', 401, true, 'GET'),
                '(^https://(.+).zephr.com)(/v4/users/reset)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 201, false, 'POST')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        List<ZephrApiRequestsResponses.User> companyResponses = zephr_InvocableCreateUser.createZephrUser(userRequests);
        System.assert(!companyResponses[0].success);
    }

    @IsTest
    public static void test_createZephrUser_nouser_password_fail() {
        List<ZephrApiRequestsResponses.CreateUserRequest> userRequests = new List<ZephrApiRequestsResponses.CreateUserRequest>();
        ZephrApiRequestsResponses.CreateUserRequest userRequest = new ZephrApiRequestsResponses.CreateUserRequest();
        userRequest.tenantId = 'testTenant';
        userRequest.salesforceId = 'testid';
        userRequest.email = '123@example.com';
        userRequest.firstName = 'fname';
        userRequest.lastName = 'lname';
        userRequest.companyName = 'cname';
        userRequest.jobTitle  = 'title';
        userRequest.city = 'city';
        userRequest.country = 'United Kingdom';
        userRequest.companyType = 'type' ;
        userRequest.startDate = Date.today();
        userRequest.sendPasswordReset = true;
        userRequests.add(userRequest);

        Map<String, zephr_TestMock.MockConfig> mockConfigs = new Map<String, zephr_TestMock.MockConfig>{
                '(^https://(.+).zephr.com)(/v3/users$)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/users\\?identifiers.email_address=)(.+)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'NOT FOUND', 401, false, 'GET'),
                '(^https://(.+).zephr.com)(/v4/users/reset)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 401, false, 'POST')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        List<ZephrApiRequestsResponses.User> companyResponses = zephr_InvocableCreateUser.createZephrUser(userRequests);
        System.assertEquals('User created successfully but password reset link was not sent.', companyResponses[0].message);
        System.assert(companyResponses[0].success);
    }

    @IsTest
    public static void test_createZephrUser_nouser_password_not_needed() {
        List<ZephrApiRequestsResponses.CreateUserRequest> userRequests = new List<ZephrApiRequestsResponses.CreateUserRequest>();
        ZephrApiRequestsResponses.CreateUserRequest userRequest = new ZephrApiRequestsResponses.CreateUserRequest();
        userRequest.tenantId = 'testTenant';
        userRequest.salesforceId = 'testid';
        userRequest.email = '123@example.com';
        userRequest.firstName = 'fname';
        userRequest.lastName = 'lname';
        userRequest.companyName = 'cname';
        userRequest.jobTitle  = 'title';
        userRequest.city = 'city';
        userRequest.country = 'United Kingdom';
        userRequest.companyType = 'type' ;
        userRequest.startDate = Date.today();
        userRequest.sendPasswordReset = false;
        userRequests.add(userRequest);

        Map<String, zephr_TestMock.MockConfig> mockConfigs = new Map<String, zephr_TestMock.MockConfig>{
                '(^https://(.+).zephr.com)(/v3/users$)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/users\\?identifiers.email_address=)(.+)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'NOT FOUND', 401, false, 'GET'),
                '(^https://(.+).zephr.com)(/v4/users/reset)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 401, false, 'POST')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        List<ZephrApiRequestsResponses.User> companyResponses = zephr_InvocableCreateUser.createZephrUser(userRequests);
        System.assertEquals('User created successfully but password reset link was not required.', companyResponses[0].message);
        System.assert(companyResponses[0].success);
    }

    @IsTest
    public static void test_createZephrUser_user_exists() {
        List<ZephrApiRequestsResponses.CreateUserRequest> userRequests = new List<ZephrApiRequestsResponses.CreateUserRequest>();
        ZephrApiRequestsResponses.CreateUserRequest userRequest = new ZephrApiRequestsResponses.CreateUserRequest();
        userRequest.tenantId = 'testTenant';
        userRequest.salesforceId = 'testid';
        userRequest.email = '123@example.com';
        userRequest.firstName = 'fname';
        userRequest.lastName = 'lname';
        userRequest.companyName = 'cname';
        userRequest.jobTitle  = 'title';
        userRequest.city = 'city';
        userRequest.country = 'United Kingdom';
        userRequest.companyType = 'type' ;
        userRequest.startDate = Date.today();
        userRequest.sendPasswordReset = true;
        userRequests.add(userRequest);

        Map<String, zephr_TestMock.MockConfig> mockConfigs = new Map<String, zephr_TestMock.MockConfig>{
                '(^https://(.+).zephr.com)(/v3/users$)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/users\\?identifiers.email_address=)(.+)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 200, false, 'GET'),
                '(^https://(.+).zephr.com)(/v4/users/reset)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 201, false, 'POST')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        List<ZephrApiRequestsResponses.User> companyResponses = zephr_InvocableCreateUser.createZephrUser(userRequests);

        System.assertEquals('User successfully found in Zephr - using existing user id.', companyResponses[0].message);
        System.assert(companyResponses[0].success);

    }

    @IsTest
    public static void test_createZephrUser_no_email() {
        List<ZephrApiRequestsResponses.CreateUserRequest> userRequests = new List<ZephrApiRequestsResponses.CreateUserRequest>();
        ZephrApiRequestsResponses.CreateUserRequest userRequest = new ZephrApiRequestsResponses.CreateUserRequest();
        userRequest.tenantId = 'testTenant';
        userRequest.salesforceId = 'testid';
//        userRequest.email = '123@example.com';
        userRequest.firstName = 'fname';
        userRequest.lastName = 'lname';
        userRequest.companyName = 'cname';
        userRequest.jobTitle  = 'title';
        userRequest.city = 'city';
        userRequest.country = 'United Kingdom';
        userRequest.companyType = 'type' ;
        userRequest.startDate = Date.today();
        userRequest.sendPasswordReset = true;
        userRequests.add(userRequest);

        Map<String, zephr_TestMock.MockConfig> mockConfigs = new Map<String, zephr_TestMock.MockConfig>{
                '(^https://(.+).zephr.com)(/v3/users$)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 201, false, 'POST'),
                '(^https://(.+).zephr.com)(/v3/users\\?identifiers.email_address=)(.+)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 200, false, 'GET'),
                '(^https://(.+).zephr.com)(/v4/users/reset)' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.createUserBody(), 'OK', 201, false, 'POST')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        List<ZephrApiRequestsResponses.User> companyResponses = zephr_InvocableCreateUser.createZephrUser(userRequests);

    }
}