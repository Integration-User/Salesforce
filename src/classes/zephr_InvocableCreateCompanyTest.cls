/**
* @author Zoran Zunko
* @date 6/23/21
*
*/
@IsTest
public with sharing class zephr_InvocableCreateCompanyTest {
    @IsTest
    public static void test_createZephrCompany() {
        List<ZephrApiRequestsResponses.CreateCompanyRequest> companyRequests = new List<ZephrApiRequestsResponses.CreateCompanyRequest>();
        ZephrApiRequestsResponses.CreateCompanyRequest companyRequest = new ZephrApiRequestsResponses.CreateCompanyRequest();
        companyRequest.name = 'name';
        companyRequest.tenant = 'testTenant';
        companyRequest.website = null;
        companyRequest.salesforceId = 'testid';
        companyRequests.add(companyRequest);
        Test.setMock(HttpCalloutMock.class, new CalloutMockForHttp( ZephrIntegration_TestUtility.createCompanyBody(), 201));

        List<ZephrApiRequestsResponses.Company> companyResponses = zephr_InvocableCreateCompany.createZephrCompany(companyRequests);

    }

}