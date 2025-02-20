@isTest
public class ZephrIntegration_TestUtility {

    static String baseUrl = ZephrIntegration.baseUrl;

    // methods return response body to mock callouts in test classes
    public static String getUsersBody() {
        return '{ "results": [ { "user_id": "80452dd3-1d83-4f5d-9375-1286e015150f", "identifiers": { "email_address": "bartosz.jarmolinski@euromoneyplc.com" }, "attributes": { "first-name": "BTest", "last-name": "Test", "country": "GB", "company-name": "SF", "company-type": "Broker", "seniority": "CEO / Head of Organisation", "terms-and-conditions": true }, "email_verified": false, "last_login": "2021-01-11T12:20:16Z", "registered": "2021-01-11T12:20:16Z", "registration_state": "complete" } ], "links": { "next": { "page": 1, "url": "/v3/users?rpp=10&page=1" }, "last": { "page": 1, "url": "/v3/users?rpp=10&page=1" }, "first": { "page": 1, "url": "/v3/users?rpp=10" } }, "meta": { "paginated": true, "rpp": 10, "count": 666 } }';
    }
    public static String createCompanyBody() {
        return '{ "company_id": "c2641dcb-8609-40bd-8b0c-a5ebeef9c108", "message": "company created successfully", "uri": "https://console.zephr.com/v3/companies/c2641dcb-8609-40bd-8b0c-a5ebeef9c108" }';
    }
    public static String createUserBody() {
        return '{ "user_id": "0d2afed5-3576-4db5-91e1-b6cdacbce6d1", "tracking_id": "7dafd502-e526-4c31-9488-a3d74a3285e6", "message": "User created successfully", "uri": "https://console.zephr.com/v3/users/0d2afed5-3576-4db5-91e1-b6cdacbce6d1" }';
    }
    public static String createAccount() {
        return '{ "account_id": "4a4a37ca-9918-4e24-b27c-63cfd448644b", "message": "company account created successfully", "uri": "https://console.zephr.com/v3/accounts/4a4a37ca-9918-4e24-b27c-63cfd448644b" }';
    }
    public static String getUserGrants() {
        return '{ "results": [ { "tenantId": "insidergroup", "subTenantId": "insidergroup", "grant_id": "c1d89ff1-2f06-4d50-945e-1e10a7d5e6f5", "user_id": "f8dbadf5-183c-42ae-beb5-f43984736a4b", "expiry_state": "active", "entitlement_type": "bundle", "entitlement_id": "1452f948-35b3-4393-8c8d-1fe0f195e692", "start_time": "2021-01-06 00:00:00", "end_time": "2021-01-20 23:59:00", "product_id": "TR Trial" }, { "tenantId": "insidergroup", "subTenantId": "insidergroup", "grant_id": "ef8d6db9-2fa0-4616-92eb-cd74e9eec9e4", "user_id": "f8dbadf5-183c-42ae-beb5-f43984736a4b", "expiry_state": "active", "entitlement_type": "bundle", "entitlement_id": "a52e8884-51a4-4671-a400-98692a6eedd0", "start_time": "2021-01-06 00:00:00", "end_time": "2021-01-20 23:59:00", "product_id": "II Trial" } ], "links": {}, "meta": { "paginated": false } }';
    }
    public static String createUserGrant() {
        return '{ "tenantId": "insidergroup", "subTenantId": "insidergroup", "grant_id": "ead74ba7-d540-41ed-b9c9-6b9ae95f9cf5", "user_id": "3ed76e72-cb47-4504-af09-11f95cd21dfa", "expiry_state": null, "entitlement_type": "bundle", "entitlement_id": "1452f948-35b3-4393-8c8d-1fe0f195e692", "start_time": "2021-01-13 00:00:01", "end_time": "2021-01-27 23:59:00", "product_id": "TR", "message": "Bundle granted successfully", "uri": "https://console.zephr.com/v3/users/3ed76e72-cb47-4504-af09-11f95cd21dfa/grants/ead74ba7-d540-41ed-b9c9-6b9ae95f9cf5" }';
    }
    public static String getAccountGrants() {
        return '{ "results": [ { "tenantId": "insidergroup", "subTenantId": "insidergroup", "grant_id": "bf2dd5d6-ebde-4418-9b55-bf564171176d", "account_id": "f709d2d4-eb66-42ee-b841-7add030386dc", "expiry_state": "active", "entitlement_type": "bundle", "entitlement_id": "2316c3fb-0697-4294-996d-fab4b33cc7a8", "start_time": "2020-11-19 12:30:00", "end_time": "2021-12-19 12:30:00", "product_id": "II" } ], "links": {}, "meta": { "paginated": false } }'; // TO DO
    }
    public static String deleteUserGrant() {
        return '';
    }
    public static String createGrant() {
        return '{ "tenantId": "insidergroup", "subTenantId": "insidergroup", "grant_id": "66c068af-135d-47ad-b4d7-98b4f81860d1", "account_id": "f709d2d4-eb66-42ee-b841-7add030386dc", "expiry_state": null, "entitlement_type": "bundle", "entitlement_id": "2316c3fb-0697-4294-996d-fab4b33cc7a8", "start_time": "2020-11-19 12:30:00", "end_time": "2021-12-19 12:30:00", "product_id": null, "message": "Bundle granted successfully", "uri": "https://console.zephr.com/v3/accounts/f709d2d4-eb66-42ee-b841-7add030386dc/grants/66c068af-135d-47ad-b4d7-98b4f81860d1" }';
    }
    public static String accountUser() {
        return '{ "account_id": "f709d2d4-eb66-42ee-b841-7add030386dc", "user_type": null, "user_id": "d4811164-6e39-48a9-8728-a3c485afb1cb", "message": "account user created successfully", "uri": "https://console.zephr.com/v3/accounts/f709d2d4-eb66-42ee-b841-7add030386dc/users/d4811164-6e39-48a9-8728-a3c485afb1cb/f709d2d4-eb66-42ee-b841-7add030386dc/users/d4811164-6e39-48a9-8728-a3c485afb1cb" }';
    }
    public static String deleteAccountGrant() {
        return '';
    }
    public static String updateUserAttributes() {
        return '{ "message": "User profile updated" }';
    }

    public static String getAttributeValues() {
        return '{\n' +
                '  "tenantId" : "testenant",\n' +
                '  "subTenantId" : "testenant",\n' +
                '  "slug" : "company-type",\n' +
                '  "label" : "Company type",\n' +
                '  "required" : false,\n' +
                '  "internal-description" : "",\n' +
                '  "public-description" : "",\n' +
                '  "validation-expression" : null,\n' +
                '  "input-type" : "select",\n' +
                '  "select-options" : [ {\n' +
                '    "label" : "Broker",\n' +
                '    "value" : "Broker",\n' +
                '    "default" : false\n' +
                '  }, {\n' +
                '    "label" : "Carrier",\n' +
                '    "value" : "Carrier",\n' +
                '    "default" : false\n' +
                '  }, {\n' +
                '    "label" : "Other Service Provider",\n' +
                '    "value" : "Other Service Provider",\n' +
                '    "default" : false\n' +
                '  }, {\n' +
                '    "label" : "Private Equity",\n' +
                '    "value" : "Private Equity",\n' +
                '    "default" : false\n' +
                '  }, {\n' +
                '    "label" : "MGA",\n' +
                '    "value" : "MGA",\n' +
                '    "default" : false\n' +
                '  }, {\n' +
                '    "label" : "Individual",\n' +
                '    "value" : "Individual",\n' +
                '    "default" : false\n' +
                '  }, {\n' +
                '    "label" : "Asset/Investment Management",\n' +
                '    "value" : "Asset/Investment Management",\n' +
                '    "default" : false\n' +
                '  }, {\n' +
                '    "label" : "Consultancy",\n' +
                '    "value" : "Consultancy",\n' +
                '    "default" : false\n' +
                '  }, {\n' +
                '    "label" : "Corporate",\n' +
                '    "value" : "Corporate",\n' +
                '    "default" : false\n' +
                '  }, {\n' +
                '    "label" : "Executive Search",\n' +
                '    "value" : "Executive Search",\n' +
                '    "default" : false\n' +
                '  }, {\n' +
                '    "label" : "Fund",\n' +
                '    "value" : "Fund",\n' +
                '    "default" : false\n' +
                '  }, {\n' +
                '    "label" : "Investment Bank",\n' +
                '    "value" : "Investment Bank",\n' +
                '    "default" : false\n' +
                '  }, {\n' +
                '    "label" : "Law Firm",\n' +
                '    "value" : "Law Firm",\n' +
                '    "default" : false\n' +
                '  }, {\n' +
                '    "label" : "Other",\n' +
                '    "value" : "Other",\n' +
                '    "default" : false\n' +
                '  }, {\n' +
                '    "label" : "Rating Agency",\n' +
                '    "value" : "Rating Agency",\n' +
                '    "default" : false\n' +
                '  }, {\n' +
                '    "label" : "Reinsurer",\n' +
                '    "value" : "Reinsurer",\n' +
                '    "default" : false\n' +
                '  } ],\n' +
                '  "range-start" : 0,\n' +
                '  "range-end" : 100,\n' +
                '  "range-step" : 5,\n' +
                '  "decision-point" : true,\n' +
                '  "publicly-writable" : true,\n' +
                '  "form-use" : true\n' +
                '}';
    }

    public static String deleteUserFromAccount() {
        return '{ "message": "account user deleted successfully" }';
    }

    public static String getUserGrants_Trial() {
        return '{ "results": [ { "tenantId": "globalcapital", "subTenantId": "globalcapital", "grant_id": "ad965365-311e-4951-8d73-09ae8d387287", "user_id": "2b6b3c73-d2b6-49bb-b042-9e86fb6a24a9", "expiry_state": "active", "entitlement_type": "bundle", "entitlement_id": "e50187bf-2e22-44e4-a67d-ab6b3841f606", "start_time": "2021-02-16 08:25:56", "end_time": "2021-03-02 08:25:56", "product_id": "insurance-insider---trial" } ], "links": {}, "meta": { "paginated": false } }';
    }

    public static String getGrant() {
        return '{ "tenantId": "euromoney-staging", "subTenantId": "euromoney-staging", "grant_id": "1f9e2b27-615b-4849-963e-4380c6b440aa", "user_id": "18420f20-5e3b-453c-bc3a-e3ca4f95c6d8", "expiry_state": "active", "entitlement_type": "entitlement", "entitlement_id": "1452f948-35b3-4393-8c8d-1fe0f195e692", "product_id": null}';
    }

    // the method returns instance of MultipleRequestMock class which is used for generating various HTTP mock responses if multiple callouts are made within test context
    public static HttpCalloutMock getHttpCalloutMockForMultipleRequests() {

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();

        CalloutMockForHttp resCreateCompany = new CalloutMockForHttp( createCompanyBody(), 201);
        endpoint2TestResp.put(baseUrl + '/v3/companies', resCreateCompany);

        CalloutMockForHttp resCreateAccount = new CalloutMockForHttp( createAccount(), 201);
        endpoint2TestResp.put(baseUrl + '/v3/accounts', resCreateAccount);

        CalloutMockForHttp resCreateGrant = new CalloutMockForHttp( createGrant(), 201);
        endpoint2TestResp.put(baseUrl + '/v3/accounts/4a4a37ca-9918-4e24-b27c-63cfd448644b/grants', resCreateGrant);

        CalloutMockForHttp resDeleteGrant = new CalloutMockForHttp( deleteAccountGrant(), 200);
        endpoint2TestResp.put(baseUrl + '/v3/accounts/4a4a37ca-9918-4e24-b27c-63cfd448644b/grants/66c068af-135d-47ad-b4d7-98b4f81860d1', resDeleteGrant);

        CalloutMockForHttp resDeleteGrant2 = new CalloutMockForHttp( deleteAccountGrant(), 200);
        endpoint2TestResp.put(baseUrl + '/v3/accounts/4a4a37ca-9918-4e24-b27c-63cfd448644b/grants/aaa06bbb-135d-47ad-b4d7-98b4f81860d1', resDeleteGrant2);

        CalloutMockForHttp resAccountUser = new CalloutMockForHttp( accountUser(), 200);
        endpoint2TestResp.put(baseUrl + '/v3/accounts/4a4a37ca-9918-4e24-b27c-63cfd448644b/users/0d2afed5-3576-4db5-91e1-b6cdacbce6d1', resAccountUser);

        CalloutMockForHttp resCreateUser = new CalloutMockForHttp( createUserBody(), 201);
        endpoint2TestResp.put(baseUrl + '/v3/users', resCreateUser);

        CalloutMockForHttp resCreateUserGrant = new CalloutMockForHttp( createUserGrant(), 201);
        endpoint2TestResp.put(baseUrl + '/v3/users/0d2afed5-3576-4db5-91e1-b6cdacbce6d1/grants', resCreateUserGrant);

        CalloutMockForHttp resDeleteUserGrant = new CalloutMockForHttp( deleteUserGrant(), 200);
        endpoint2TestResp.put(baseUrl + '/v3/users/0d2afed5-3576-4db5-91e1-b6cdacbce6d1/grants/ead74ba7-d540-41ed-b9c9-6b9ae95f9cf5', resDeleteUserGrant);

        CalloutMockForHttp resUpdateUserAttr = new CalloutMockForHttp( updateUserAttributes(), 200);
        endpoint2TestResp.put(baseUrl + '/v3/users/ead74ba7-d540-41ed-b9c9-6b9ae95f9cf5/attributes', resUpdateUserAttr);

        CalloutMockForHttp resDeleteAccountUser = new CalloutMockForHttp( deleteUserFromAccount(), 200);
        endpoint2TestResp.put(baseUrl + '/v3/accounts/4a4a37ca-9918-4e24-b27c-63cfd448644b/users/0d2afed5-3576-4db5-91e1-b6cdacbce6d1', resDeleteAccountUser);

        CalloutMockForHttp resGetUserGrantTrial = new CalloutMockForHttp(getUserGrants_Trial(), 200);
        endpoint2TestResp.put(baseUrl + '/v3/users/2b6b3c73-d2b6-49bb-b042-9e86fb6a24a9/grants', resGetUserGrantTrial);

        CalloutMockForHttp resGetGrant = new CalloutMockForHttp(getGrant(), 200);
        endpoint2TestResp.put(baseUrl + '/v3/users/18420f20-5e3b-453c-bc3a-e3ca4f95c6d8/grants/1f9e2b27-615b-4849-963e-4380c6b440aa', resGetGrant);

        HttpCalloutMock multiCalloutMock = new MultipleRequestMock(endpoint2TestResp);
        return multiCalloutMock;
    }
}