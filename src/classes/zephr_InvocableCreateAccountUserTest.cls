/**
* @author Zoran Zunko
* @date 6/23/21
*
*/
@IsTest
public with sharing class zephr_InvocableCreateAccountUserTest {
    @IsTest
    public static void test_createAccountUser() {
        List<ZephrApiRequestsResponses.AccountUserGrant> accountUserGrantRequests = new List<ZephrApiRequestsResponses.AccountUserGrant>();
        ZephrApiRequestsResponses.AccountUserGrant accountUserGrantRequest = new ZephrApiRequestsResponses.AccountUserGrant();
        accountUserGrantRequest.tenantId = 'testTenant';
        accountUserGrantRequest.user_id = 'testid';
        accountUserGrantRequest.account_id = 'testid';
        accountUserGrantRequest.salesforceId = 'testid';
        accountUserGrantRequests.add(accountUserGrantRequest);

        Map<String, zephr_TestMock.MockConfig> mockConfigs = new Map<String, zephr_TestMock.MockConfig>{
                '(^https://(.+).zephr.com)(/v3/accounts)(/(.+)/users/(.+))' => new zephr_TestMock.MockConfig(ZephrIntegration_TestUtility.accountUser(), 'OK', 201, false, 'PUT')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        List<ZephrApiRequestsResponses.AccountUserGrant> accountResponses = zephr_InvocableCreateAccountUser.createAccountUser(accountUserGrantRequests);

        System.assertEquals('account user created successfully', accountResponses[0].message);
        System.assert(accountResponses[0].success);
    }

    @IsTest
    public static void test_createAccountUser_existing() {
        List<ZephrApiRequestsResponses.AccountUserGrant> accountUserGrantRequests = new List<ZephrApiRequestsResponses.AccountUserGrant>();
        ZephrApiRequestsResponses.AccountUserGrant accountUserGrantRequest = new ZephrApiRequestsResponses.AccountUserGrant();
        accountUserGrantRequest.tenantId = 'testTenant';
        accountUserGrantRequest.user_id = 'testid';
        accountUserGrantRequest.account_id = 'testid';
        accountUserGrantRequest.salesforceId = 'testid';
        accountUserGrantRequests.add(accountUserGrantRequest);

        Map<String, zephr_TestMock.MockConfig> mockConfigs = new Map<String, zephr_TestMock.MockConfig>{
                '(^https://(.+).zephr.com)(/v3/accounts)(/(.+)/users/(.+))' => new zephr_TestMock.MockConfig('not a valid json', 'OK', 200, false, 'PUT')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        List<ZephrApiRequestsResponses.AccountUserGrant> accountResponses = zephr_InvocableCreateAccountUser.createAccountUser(accountUserGrantRequests);

        System.assertEquals('account user already existing', accountResponses[0].message);
        System.assert(accountResponses[0].success);
    }

    @IsTest
    public static void test_createAccountUser_exception() {
        List<ZephrApiRequestsResponses.AccountUserGrant> accountUserGrantRequests = new List<ZephrApiRequestsResponses.AccountUserGrant>();
        ZephrApiRequestsResponses.AccountUserGrant accountUserGrantRequest = new ZephrApiRequestsResponses.AccountUserGrant();
        accountUserGrantRequest.tenantId = 'testTenant';
        accountUserGrantRequest.user_id = 'testid';
        accountUserGrantRequest.account_id = 'testid';
        accountUserGrantRequest.salesforceId = 'testid';
        accountUserGrantRequests.add(accountUserGrantRequest);

        Map<String, zephr_TestMock.MockConfig> mockConfigs = new Map<String, zephr_TestMock.MockConfig>{
                '(^https://(.+).zephr.com)(/v3/accounts)(/(.+)/users/(.+))' => new zephr_TestMock.MockConfig('not a valid json', 'OK', 200, true, 'PUT')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        List<ZephrApiRequestsResponses.AccountUserGrant> accountResponses = zephr_InvocableCreateAccountUser.createAccountUser(accountUserGrantRequests);

        System.assert(!accountResponses[0].success);
    }

    @IsTest
    public static void test_createAccountUser_500() {
        List<ZephrApiRequestsResponses.AccountUserGrant> accountUserGrantRequests = new List<ZephrApiRequestsResponses.AccountUserGrant>();
        ZephrApiRequestsResponses.AccountUserGrant accountUserGrantRequest = new ZephrApiRequestsResponses.AccountUserGrant();
        accountUserGrantRequest.tenantId = 'testTenant';
        accountUserGrantRequest.user_id = 'testid';
        accountUserGrantRequest.account_id = 'testid';
        accountUserGrantRequest.salesforceId = 'testid';
        accountUserGrantRequests.add(accountUserGrantRequest);

        Map<String, zephr_TestMock.MockConfig> mockConfigs = new Map<String, zephr_TestMock.MockConfig>{
                '(^https://(.+).zephr.com)(/v3/accounts)(/(.+)/users/(.+))' => new zephr_TestMock.MockConfig('not a valid json', 'OK', 500, false, 'PUT')
        };
        Test.setMock(HttpCalloutMock.class, new zephr_TestMock(mockConfigs));
        List<ZephrApiRequestsResponses.AccountUserGrant> accountResponses = zephr_InvocableCreateAccountUser.createAccountUser(accountUserGrantRequests);

        System.assert(!accountResponses[0].success);
    }

}