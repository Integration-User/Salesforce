/**
* @author Zoran Zunko
* @date 6/23/21
*
*/
@IsTest
public with sharing class zephr_InvocableCreateAccountGrantTest {

    @IsTest
    public static void test_createGrant() {
        List<ZephrApiRequestsResponses.Grant> grantRequests = new List<ZephrApiRequestsResponses.Grant>();
        ZephrApiRequestsResponses.Grant grantRequest = new ZephrApiRequestsResponses.Grant();
        grantRequest.startTime = Date.today();
        grantRequest.endTime = Date.today().addDays(24);
        grantRequest.tenantId = 'testTenant';
        grantRequest.salesforceId = 'testid';
        grantRequest.account_id = 'testid';
        grantRequest.entitlement_id = 'testid';
        grantRequests.add(grantRequest);
        Test.setMock(HttpCalloutMock.class, new CalloutMockForHttp( ZephrIntegration_TestUtility.createGrant(), 201));

        List<ZephrApiRequestsResponses.Grant> grantResponses = zephr_InvocableCreateAccountGrant.createGrant(grantRequests);

    }

}