/**
* @author Zoran Zunko
* @date 6/23/21
*
*/
@IsTest
public class zephr_InvocableCreateAccountTest {

    @IsTest
    public static void test_createZephrAccount() {
        List<ZephrApiRequestsResponses.Account> accountRequests = new List<ZephrApiRequestsResponses.Account>();
        ZephrApiRequestsResponses.Account accountRequest = new ZephrApiRequestsResponses.Account();
        accountRequest.name = 'test';
        accountRequest.tenantId = 'testTenant';
        accountRequest.company_id = 'cId';
        accountRequest.salesforceId = 'testid';
        accountRequest.allow_oversubscription = false;
        accountRequests.add(accountRequest);
        Test.setMock(HttpCalloutMock.class, new CalloutMockForHttp( ZephrIntegration_TestUtility.createAccount(), 201));

        List<ZephrApiRequestsResponses.Account> accountResponses = zephr_InvocableCreateAccount.createZephrAccount(accountRequests);

    }

}