/**
* @author Zoran Zunko
* @date 7/15/21
*
*/
@IsTest
public class script_TestDataFactory {
    public static final String webhookGrantCreateJSON_EM = '{\n' +
            '  "tenantId": "euromoney",\n' +
            '  "subTenantId": "euromoney|euromoney-prod",\n' +
            '  "type": "ENTITLEMENT_GRANT",\n' +
            '  "time": 1634206490552,\n' +
            '  "details": {\n' +
            '    "tenantId": "euromoney|euromoney-prod",\n' +
            '    "subTenantId": "euromoney|euromoney-prod",\n' +
            '    "grant_id": "GRANT_ID",\n' +
            '    "user_id": "USER_ID",\n' +
            '    "expiry_state": "active",\n' +
            '    "entitlement_type": "bundle",\n' +
            '    "entitlement_id": "ENTITLEMENT_ID",\n' +
            '    "start_time": "2021-10-14 10:14:50",\n' +
            '    "end_time": "2021-10-21 10:14:50",\n' +
            '    "product_id": "euromoney-product-access"\n' +
            '  },\n' +
            '  "webhook": "Grant Create"\n' +
            '}';
    
    public static final String webhookUserGrantCreateJSON_EM = '{\n' +
        '  "tenantId": "euromoney",\n' +
        '  "subTenantId": "subTenantId",\n' +
        '  "type": "ACCOUNT_USER_CREATED",\n' +
        '  "time": 1613532273008,\n' +
        '  "details": {\n' +
        '   "account_id": "9fe3c35f-9fb8-4942-8cd9-2aec3da02a32",\n' +
        '    "accountUser": {\n' +
        '      "user_id": "c48a790d-26d7-46b0-bbde-cdb0d46574b8",\n' +
        '      "identifiers": {\n' +
        '        "email_address": "<emailAddress>"\n' +
        '      },\n' +
        '      "attributes": {},\n' +
        '      "tenantId": "euromoney",\n' +
        '      "subTenantId": "<subTenantId>",\n' +
        '      "email_verified": false,\n' +
        '      "tracking_id": "7b8c3eb2-370b-41f9-883b-07d01de3f0aa",\n' +
        '      "registered": "2021-02-17T02:27:54Z",\n' +
        '      "registration_state": "complete",\n' +
        '      "registration_tenant": "<registrationTenant>"\n' +
        '    },\n' +
        '    "currentNumberOfUsers": 4\n' +
        '  },\n' +
        '  "webhook": "<webhookLabel>"\n' +
        '}';

    public static final String webhookUserCreateJSON_EM = '{\n' +
            '  "tenantId": "euromoney",\n' +
            '  "subTenantId": "euromoney|euromoney-prod",\n' +
            '  "type": "CREATE_USER",\n' +
            '  "time": 1634206490390,\n' +
            '  "details": {\n' +
            '    "user_id": "USER_ID",\n' +
            '    "identifiers": {\n' +
            '      "email_address": "someone@example.com"\n' +
            '    },\n' +
            '    "attributes": {\n' +
            '      "first-name": "Some",\n' +
            '      "last-name": "One",\n' +
            '      "seniority": "Manager/VP",\n' +
            '      "job-title": "Exec",\n' +
            '      "company-name": "Example",\n' +
            '      "organisation-type": "Bank - Investment",\n' +
            '      "country": "US",\n' +
            '      "interest-areas": "Treasury Management",\n' +
            '      "telephone": "123456789",\n' +
            '      "contact-preferences-email": false,\n' +
            '      "contact-preferences-mail": false,\n' +
            '      "contact-preferences-phone": false,\n' +
            '      "contact-preferences-sms": false,\n' +
            '      "top-stories": false,\n' +
            '      "transaction-services": false,\n' +
            '      "banking": false,\n' +
            '      "forex": false,\n' +
            '      "wealth---delivered-monthly": false,\n' +
            '      "esg---delivered-monthly": false,\n' +
            '      "fintech---delivered-monthly": false,\n' +
            '      "terms-and-conditions": true\n' +
            '    },\n' +
            '    "tenantId": "euromoney|euromoney-prod",\n' +
            '    "subTenantId": "euromoney|euromoney-prod",\n' +
            '    "email_verified": false,\n' +
            '    "last_login": "2021-10-14T10:14:49Z",\n' +
            '    "tracking_id": "53b24e90-4802-4b44-b833-6c105ebab07b",\n' +
            '    "registered": "2021-10-14T10:14:49Z",\n' +
            '    "registration_state": "complete"\n' +
            '  },\n' +
            '  "webhook": "User Create"\n' +
            '}';
    public static final String webhookUserCreateJSON ='{\n' +
            '  "tenantId": "euromoney-sandbox",\n' +
            '  "subTenantId": "test-subtenant",\n' +
            '  "type": "CREATE_USER",\n' +
            '  "time": 1631092129075,\n' +
            '  "details": {\n' +
            '    "user_id": "USER_ID",\n' +
            '    "identifiers": {\n' +
            '      "email_address": "test@example.com"\n' +
            '    },\n' +
            '    "attributes": {\n' +
            '      "confirm-contact-pref": "true",\n' +
            '      "country": "United Kingdom",\n' +
            '      "company-name": "Test Company",\n' +
            '      "city": "London",\n' +
            '      "telephone-number": "+1234556789",\n' +
            '      "testurl": "",\n' +
            '      "contact-preference-post": "true",\n' +
            '      "contact-preference-phone": "true",\n' +
            '      "first-name": "Testing",\n' +
            '      "salesforce_id": "",\n' +
            '      "job-title": "title",\n' +
            '      "terms-and-conditions": "true",\n' +
            '      "company-type": "",\n' +
            '      "contact-preference-email": "true",\n' +
            '      "start_date": "2021-09-07",\n' +
            '      "last-name": "Tester"\n' +
            '    },\n' +
            '    "tenantId": "euromoney-sandbox",\n' +
            '    "subTenantId": "test-subtenant",\n' +
            '    "email_verified": false,\n' +
            '    "tracking_id": "7f00b04a-a8fc-4531-97fd-92b7932dc155",\n' +
            '    "registered": "2021-09-08T09:08:48Z",\n' +
            '    "registration_state": "complete"\n' +
            '  },\n' +
            '  "webhook": "User Create"\n' +
            '}';
    public static final String webhookUserUpdateJSON ='{\n' +
            '  "tenantId": "euromoney-sandbox",\n' +
            '  "subTenantId": "test-subtenant",\n' +
            '  "type": "UPDATE_USER_PROFILE",\n' +
            '  "time": 1631086846413,\n' +
            '  "details": {\n' +
            '    "user_id": "USER_ID",\n' +
            '    "identifiers": {\n' +
            '      "email_address": "test@example.com"\n' +
            '    },\n' +
            '    "attributes": {\n' +
            '      "confirm-contact-pref": true,\n' +
            '      "country": "GB",\n' +
            '      "company-name": "Test Company",\n' +
            '      "city": "some",\n' +
            '      "telephone-number": "+1234556789",\n' +
            '      "contact-preference-phone": true,\n' +
            '      "contact-preference-post": true,\n' +
            '      "first-name": "Testing",\n' +
            '      "salesforce_id": "0031w00000wfIQfAAM",\n' +
            '      "job-title": "Title",\n' +
            '      "terms-and-conditions": true,\n' +
            '      "contact-preference-email": true,\n' +
            '      "last-name": "Tester",\n' +
            '      "start_date": "2021-08-31"\n' +
            '    },\n' +
            '    "tenantId": "euromoney-sandbox",\n' +
            '    "subTenantId": "test-subtenant",\n' +
            '    "email_verified": true,\n' +
            '    "tracking_id": "725f323f-35e2-4084-84bf-156ac4b1bedf",\n' +
            '    "registered": "2021-08-31T19:01:12Z",\n' +
            '    "registration_state": "complete"\n' +
            '  },\n' +
            '  "webhook": "User Update"\n' +
            '}';
    public static final String WebhookUserEmailConfirmed_JSON = '{\n' +
        '  "tenantId": "euromoney",\n' +
        '  "subTenantId": "subTenantId",\n' +
        '  "type": "UPDATE_USER_EMAIL",\n' +
        '  "time": 1613531371288,\n' +
        '  "details": {\n' +
        '    "user_id": "USER_ID",\n' +
        '    "previous_identifiers": {\n' +
        '      "email_address": "<oldeEmailAddress>"\n' +
        '    },\n' +
        '    "identifiers": {\n' +
        '      "email_address": "<newEmailAddress>"\n' +
        '    },\n' +
        '    "tracking_id": "7b8c3eb2-370b-41f9-883b-07d01de3f0aa"\n' +
        '  },\n' +
        '  "webhook": "<webhookLabel>"\n' +
        '}';
    
    public static final String WebhookUserEmailChangeHandler_JSON = '{\n' +
        '  "tenantId": "euromoney-sandbox",\n' +
        '  "subTenantId": "subTenantId",\n' +
        '  "type": "UPDATE_USER_EMAIL",\n' +
        '  "time": 1613531371288,\n' +
        '  "details": {\n' +
        '    "previous_identifiers": {\n' +
        '      "email_address": "email123@example.com"\n' +
        '    },\n' +
        '    "identifiers": {\n' +
        '      "email_address": "email1234@example.com"\n' +
        '    },\n' +
        '    "tracking_id": "7b8c3eb2-370b-41f9-883b-07d01de3f0aa"\n' +
        '  },\n' +
        '  "webhook": "<webhookLabel>"\n' +
        '}';
    public static List<Account> createAccounts(Integer count, Boolean save) {
        List<SObject> response = new List<SObject>();
        for (Integer i = 0; i < count; i++) {
            response.add(
                    new Account(
                            Name = 'Test Account' + i,
                            Account_Hierarchy_Ext_Id__c = '11111' + i,
                            ZephrCompanyId__c = 'c2641dcb-8609-40bd-8b0c-a5ebeef9c108' + i
                    )
            );
        }
        if(save) {
            insert response;
        }
        return response;
    }
}