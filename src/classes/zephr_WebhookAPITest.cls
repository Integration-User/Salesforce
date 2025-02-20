/**
* @author Zoran Zunko
* @date 9/8/21
*
*/
@IsTest
public class zephr_WebhookAPITest {
    @TestSetup
    static void dataSetup() {
        TriggerSettings__c tsettings = TriggerSettings__c.getOrgDefaults();
        tsettings.ZephrFeatureSwitchDisabled__c = true;
        upsert tsettings;
        Account a = new Account(
            Name = 'Test Account',
            Account_Hierarchy_Ext_Id__c = '11111',
            ZephrCompanyId__c = 'c2641dcb-8609-40bd-8b0c-a5ebeef9c108'
        );
        insert a;

        Contact c = new Contact(
            FirstName = 'Tester',
            LastName = 'One',
            Email = 'tester.one@account.com',
            AccountId = a.Id,
            MailingCountry = 'United Kingdom'
        );
        insert c;

        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(
            Name = 'Test product',
            ZephrEntitlementId__c = 'ENTITLEMENT_ID',
            Zephr_Tenant__c = 'euromoney',
            Zephr_Product_Slug__c = 'test-ent',
            Zephr_Website__c = 'test-ent'
        );

        insert prod;

        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert pbe;

        Campaign camp = new Campaign();
        camp.Name = 'Test Campaign';
        camp.Event_Title__c = 'Test campaign for test classes';
        insert camp;
    }

    @IsTest static void test_ZephrUserHandler_handlePost_no_salesforce_data_em_example() {
        System.assert([SELECT Id FROM Zephr_User__c].isEmpty());
        zephr_WebhookAPI.ZephrUserHandler userHandler = new zephr_WebhookAPI.ZephrUserHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = userHandler.handlePost(script_TestDataFactory.webhookUserCreateJSON_EM);

        System.assertEquals('CREATE_USER', handlerResponse.type);
        System.assertEquals('euromoney', handlerResponse.tenantId);
        System.assertEquals('euromoney|euromoney-prod', handlerResponse.subTenantId);
        System.assertEquals('User Create', handlerResponse.webhook);

        List<Zephr_User__c> zephrUsers = [
            SELECT
                Zephr_Id__c,
                Zephr_Tenant__c,
                Zephr_Integration_Status__c,
                Zephr_Email__c,
                Zephr_Email_Verified__c,
                Zephr_First_Name__c,
                Zephr_Last_Name__c,
                Zephr_Company_Name__c,
                Zephr_Company_Type__c,
                Zephr_Country__c,
                Zephr_Job_Title__c,
                Zephr_Confirm_Contact_Pref__c,
                Zephr_Contact_Preference_Email__c,
                Zephr_Contact_Preference_Phone__c,
                Zephr_Contact_Preference_Post__c,
                Zephr_Telephone_Number__c,
                Zephr_Terms_and_Conditions__c,
                Zephr_Seniority__c,
                Lead__c
            FROM Zephr_User__c
        ];
        System.assertEquals(1, zephrUsers.size());
        Zephr_User__c zephrUser = zephrUsers[0];
        System.assertEquals(zephrUser.Zephr_Id__c, 'USER_ID');
        System.assertEquals(zephrUser.Zephr_Tenant__c, 'Euromoney');
        System.assertEquals(zephrUser.Zephr_Integration_Status__c, 'Synced');
        System.assertEquals(zephrUser.Zephr_Email__c, 'someone@example.com');
        System.assertEquals(zephrUser.Zephr_Email_Verified__c, false);
        System.assertEquals(zephrUser.Zephr_First_Name__c, 'Some');
        System.assertEquals(zephrUser.Zephr_Last_Name__c, 'One');
        System.assertEquals(zephrUser.Zephr_Seniority__c, 'Manager/VP');
        System.assertEquals('United States', zephrUser.Zephr_Country__c);
        System.assertEquals(zephrUser.Zephr_Company_Name__c, 'Example');
        System.assertEquals(zephrUser.Zephr_Company_Type__c, 'Bank - Investment');
        System.assertEquals(zephrUser.Zephr_Job_Title__c, 'Exec');
        System.assertEquals(zephrUser.Zephr_Confirm_Contact_Pref__c, false);
        System.assertEquals(zephrUser.Zephr_Contact_Preference_Email__c, false);
        System.assertEquals(zephrUser.Zephr_Contact_Preference_Phone__c, false);
        System.assertEquals(zephrUser.Zephr_Contact_Preference_Post__c, false);
        System.assertEquals(zephrUser.Zephr_Telephone_Number__c, '123456789');
        System.assertEquals(zephrUser.Zephr_Terms_and_Conditions__c, true);

        List<Lead> leads = [
            SELECT
                Id,
                FirstName,
                LastName,
                Company,
                Email,
                Company_Type__c,
                Phone
            FROM Lead
        ];
        System.assertEquals(0, leads.size());
    }
    
    @IsTest static void test_ZephrGrantHandler_handleDelete_em_example() {
        zephr_WebhookAPI.GrantCreatedHandler grantCreatedHandler = new zephr_WebhookAPI.GrantCreatedHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = grantCreatedHandler.handleDelete(script_TestDataFactory.webhookGrantCreateJSON_EM);
    }
    
    @IsTest static void test_ZephrGrantHandler_handlePut_em_example() {
        zephr_WebhookAPI.GrantCreatedHandler grantCreatedHandler = new zephr_WebhookAPI.GrantCreatedHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = grantCreatedHandler.handlePut(script_TestDataFactory.webhookGrantCreateJSON_EM);
    }
    
    @IsTest static void test_ZephrGrantHandler_handlePost_em_example() {
        System.assert([SELECT Id FROM Zephr_User__c].isEmpty());
        System.assert([SELECT Id FROM Lead].isEmpty());
        System.assert([SELECT Id FROM CampaignMember].isEmpty());

        Product2 prod = [SELECT Id FROM Product2];
        prod.Campaign__c = [SELECT Id FROM Campaign].Id;
        update prod;

        zephr_WebhookAPI.ZephrUserHandler userHandler = new zephr_WebhookAPI.ZephrUserHandler();
        zephr_WebhookAPI.BaseAPI userHandlerResponse = userHandler.handlePost(script_TestDataFactory.webhookUserCreateJSON_EM);

        zephr_WebhookAPI.GrantCreatedHandler grantCreatedHandler = new zephr_WebhookAPI.GrantCreatedHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = grantCreatedHandler.handlePost(script_TestDataFactory.webhookGrantCreateJSON_EM);
        System.assertEquals('ENTITLEMENT_GRANT', handlerResponse.type);
        System.assertEquals('euromoney', handlerResponse.tenantId);
        System.assertEquals('euromoney|euromoney-prod', handlerResponse.subTenantId);
        System.assertEquals('Grant Create', handlerResponse.webhook);
        List<Lead> leads = [
            SELECT
                Id,
                FirstName,
                LastName,
                Company,
                Email,
                Company_Type__c,
                Seniority__c,
                Country,
                Title,
                Phone
            FROM Lead
        ];
        System.assertEquals(1, leads.size());
        Lead newLead = leads[0];
        List<Zephr_User__c> zephrUsers = [
                SELECT
                        Zephr_Id__c,
                        Zephr_Tenant__c,
                        Zephr_Integration_Status__c,
                        Zephr_Email__c,
                        Zephr_Email_Verified__c,
                        Zephr_First_Name__c,
                        Zephr_Last_Name__c,
                        Zephr_Company_Name__c,
                        Zephr_Company_Type__c,
                        Zephr_Country__c,
                        Zephr_Job_Title__c,
                        Zephr_Confirm_Contact_Pref__c,
                        Zephr_Contact_Preference_Email__c,
                        Zephr_Contact_Preference_Phone__c,
                        Zephr_Contact_Preference_Post__c,
                        Zephr_Telephone_Number__c,
                        Zephr_Terms_and_Conditions__c,
                        Zephr_Seniority__c,
                        Lead__c
                FROM Zephr_User__c
        ];
        System.debug(LoggingLevel.ERROR, 'test_ZephrGrantHandler_handlePost_em_example - zephrUsers: ' + zephrUsers);
        System.assertEquals(1, zephrUsers.size());
        Zephr_User__c zephrUser = zephrUsers[0];
        System.assertEquals(zephrUser.Lead__c, newLead.Id);
        System.assertEquals(zephrUser.Zephr_First_Name__c, newLead.FirstName);
        System.assertEquals(zephrUser.Zephr_Last_Name__c, newLead.LastName);
        System.assertEquals(zephrUser.Zephr_Company_Name__c, newLead.Company);
        System.assertEquals(zephrUser.Zephr_Email__c, newLead.Email);
        System.assertEquals(zephrUser.Zephr_Company_Type__c, newLead.Company_Type__c);
        System.assertEquals(zephrUser.Zephr_Telephone_Number__c, newLead.Phone);
        System.assertEquals(newLead.Seniority__c, zephrUser.Zephr_Seniority__c);
        System.assertEquals(newLead.Title, zephrUser.Zephr_Job_Title__c);
        System.assertEquals(newLead.Country, zephrUser.Zephr_Country__c);

        CampaignMember campaignMember = [SELECT Id, LeadId FROM CampaignMember];
        System.assertEquals(campaignMember.LeadId, newLead.Id);
    }

    @IsTest static void test_ZephrUserHandler_handlePost_no_salesforce_data() {
        System.assert([SELECT Id FROM Zephr_User__c].isEmpty());
        System.assert([SELECT Id FROM Lead].isEmpty());
        zephr_WebhookAPI.ZephrUserHandler userHandler = new zephr_WebhookAPI.ZephrUserHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = userHandler.handlePost(script_TestDataFactory.webhookUserCreateJSON);

        System.assertEquals('CREATE_USER', handlerResponse.type);
        System.assertEquals('euromoney-sandbox', handlerResponse.tenantId);
        System.assertEquals('test-subtenant', handlerResponse.subTenantId);
        System.assertEquals('User Create', handlerResponse.webhook);

        List<Zephr_User__c> zephrUsers = [
                SELECT
                        Zephr_Id__c,
                        Zephr_Tenant__c,
                        Zephr_Integration_Status__c,
                        Zephr_Email__c,
                        Zephr_Email_Verified__c,
                        Zephr_First_Name__c,
                        Zephr_Last_Name__c,
                        Zephr_Company_Name__c,
                        Zephr_Company_Type__c,
                        Zephr_Job_Title__c,
                        Zephr_Confirm_Contact_Pref__c,
                        Zephr_Contact_Preference_Email__c,
                        Zephr_Contact_Preference_Phone__c,
                        Zephr_Contact_Preference_Post__c,
                        Zephr_Telephone_Number__c,
                        Zephr_Terms_and_Conditions__c,
                        Lead__c
                FROM Zephr_User__c
        ];
        System.assertEquals(1, zephrUsers.size());
        Zephr_User__c zephrUser = zephrUsers[0];
        System.assertEquals(zephrUser.Zephr_Id__c, 'USER_ID');
        System.assertEquals(zephrUser.Zephr_Tenant__c, 'euromoney-sandbox');
        System.assertEquals(zephrUser.Zephr_Integration_Status__c, 'Synced');
        System.assertEquals(zephrUser.Zephr_Email__c, 'test@example.com');
        System.assertEquals(zephrUser.Zephr_Email_Verified__c, false);
        System.assertEquals(zephrUser.Zephr_First_Name__c, 'Testing');
        System.assertEquals(zephrUser.Zephr_Last_Name__c, 'Tester');
        System.assertEquals(zephrUser.Zephr_Company_Name__c, 'Test Company');
        System.assertEquals(zephrUser.Zephr_Company_Type__c, null);
        System.assertEquals(zephrUser.Zephr_Job_Title__c, 'title');
        System.assertEquals(zephrUser.Zephr_Confirm_Contact_Pref__c, true);
        System.assertEquals(zephrUser.Zephr_Contact_Preference_Email__c, true);
        System.assertEquals(zephrUser.Zephr_Contact_Preference_Phone__c, true);
        System.assertEquals(zephrUser.Zephr_Contact_Preference_Post__c, true);
        System.assertEquals(zephrUser.Zephr_Telephone_Number__c, '+1234556789');
        System.assertEquals(zephrUser.Zephr_Terms_and_Conditions__c, true);

        List<Lead> leads = [
                SELECT
                        Id,
                        FirstName,
                        LastName,
                        Company,
                        Email,
                        Company_Type__c,
                        Phone
                FROM Lead
        ];
        System.assertEquals(0, leads.size());
    }

    @IsTest static void test_ZephrUserHandler_handlePost_salesforce_data_single_record_same_id() {
        System.assert([SELECT Id FROM Zephr_User__c].isEmpty());
        Zephr_User__c existingZephrUser = new Zephr_User__c();
        existingZephrUser.Zephr_Id__c = 'USER_ID';
        existingZephrUser.Zephr_Tenant__c = 'euromoney-sandbox';
        existingZephrUser.Zephr_Integration_Status__c = 'Pending';
        existingZephrUser.Zephr_Email__c = 'email123@example.com';
        existingZephrUser.Zephr_Email_Verified__c = true;
        existingZephrUser.Zephr_First_Name__c = 'Testy';
        existingZephrUser.Zephr_Last_Name__c = 'Testy';
        existingZephrUser.Zephr_Company_Name__c = 'Testy';
//        existingZephrUser.Zephr_Company_Type__c = 'Testy';
        existingZephrUser.Zephr_Job_Title__c = 'Testy';
        existingZephrUser.Zephr_Confirm_Contact_Pref__c = false;
        existingZephrUser.Zephr_Contact_Preference_Email__c = false;
        existingZephrUser.Zephr_Contact_Preference_Phone__c = false;
        existingZephrUser.Zephr_Contact_Preference_Post__c = false;
        existingZephrUser.Zephr_Telephone_Number__c = 'Testy';
        existingZephrUser.Zephr_Terms_and_Conditions__c = false;

        insert existingZephrUser;

        zephr_WebhookAPI.ZephrUserHandler userHandler = new zephr_WebhookAPI.ZephrUserHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = userHandler.handlePost(script_TestDataFactory.webhookUserCreateJSON);

        System.assertEquals('CREATE_USER', handlerResponse.type);
        System.assertEquals('euromoney-sandbox', handlerResponse.tenantId);
        System.assertEquals('test-subtenant', handlerResponse.subTenantId);
        System.assertEquals('User Create', handlerResponse.webhook);

        List<Zephr_User__c> zephrUsers = [
                SELECT
                        Zephr_Id__c,
                        Zephr_Tenant__c,
                        Zephr_Integration_Status__c,
                        Zephr_Email__c,
                        Zephr_Email_Verified__c,
                        Zephr_First_Name__c,
                        Zephr_Last_Name__c,
                        Zephr_Company_Name__c,
                        Zephr_Company_Type__c,
                        Zephr_Job_Title__c,
                        Zephr_Confirm_Contact_Pref__c,
                        Zephr_Contact_Preference_Email__c,
                        Zephr_Contact_Preference_Phone__c,
                        Zephr_Contact_Preference_Post__c,
                        Zephr_Telephone_Number__c,
                        Zephr_Terms_and_Conditions__c,
                        Lead__c
                FROM Zephr_User__c
        ];
        System.assertEquals(1, zephrUsers.size());
        Zephr_User__c zephrUser = zephrUsers[0];
        System.assertEquals(zephrUser.Zephr_Id__c, 'USER_ID');
        System.assertEquals(zephrUser.Zephr_Tenant__c, 'euromoney-sandbox');
        System.assertEquals(zephrUser.Zephr_Integration_Status__c, 'Synced');
        System.assertEquals(zephrUser.Zephr_Email__c, 'test@example.com');
        System.assertEquals(zephrUser.Zephr_Email_Verified__c, false);
        System.assertEquals(zephrUser.Zephr_First_Name__c, 'Testing');
        System.assertEquals(zephrUser.Zephr_Last_Name__c, 'Tester');
        System.assertEquals(zephrUser.Zephr_Company_Name__c, 'Test Company');
        System.assertEquals(zephrUser.Zephr_Company_Type__c, null);
        System.assertEquals(zephrUser.Zephr_Job_Title__c, 'title');
        System.assertEquals(zephrUser.Zephr_Confirm_Contact_Pref__c, true);
        System.assertEquals(zephrUser.Zephr_Contact_Preference_Email__c, true);
        System.assertEquals(zephrUser.Zephr_Contact_Preference_Phone__c, true);
        System.assertEquals(zephrUser.Zephr_Contact_Preference_Post__c, true);
        System.assertEquals(zephrUser.Zephr_Telephone_Number__c, '+1234556789');
        System.assertEquals(zephrUser.Zephr_Terms_and_Conditions__c, true);

        List<Lead> leads = [
                SELECT
                        Id,
                        FirstName,
                        LastName,
                        Company,
                        Email,
                        Company_Type__c,
                        Phone
                FROM Lead
        ];
        System.assertEquals(0, leads.size());
    }

    @IsTest static void test_ZephrUserHandler_handlePost_salesforce_data_single_record_same_email_tenant() {
        Contact con = [SELECT Id, Email FROM Contact];
        con.Email = 'test@example.com';
        update con;

        System.assert([SELECT Id FROM Zephr_User__c].isEmpty());
        Zephr_User__c existingZephrUser = new Zephr_User__c();
        existingZephrUser.Zephr_Id__c = 'USER_ID1';
        existingZephrUser.Zephr_Tenant__c = 'euromoney-sandbox';
        existingZephrUser.Zephr_Integration_Status__c = 'Pending';
        existingZephrUser.Zephr_Email__c = 'email123@example.com';
        existingZephrUser.Zephr_Email_Verified__c = true;
        existingZephrUser.Zephr_First_Name__c = 'Testy';
        existingZephrUser.Zephr_Last_Name__c = 'Testy';
        existingZephrUser.Zephr_Company_Name__c = 'Testy';
//        existingZephrUser.Zephr_Company_Type__c = 'Testy';
        existingZephrUser.Zephr_Job_Title__c = 'Testy';
        existingZephrUser.Zephr_Confirm_Contact_Pref__c = false;
        existingZephrUser.Zephr_Contact_Preference_Email__c = false;
        existingZephrUser.Zephr_Contact_Preference_Phone__c = false;
        existingZephrUser.Zephr_Contact_Preference_Post__c = false;
        existingZephrUser.Zephr_Telephone_Number__c = 'Testy';
        existingZephrUser.Zephr_Terms_and_Conditions__c = false;
        existingZephrUser.Contact__c = con.Id;
        insert existingZephrUser;
        zephr_WebhookAPI.ZephrUserHandler userHandler = new zephr_WebhookAPI.ZephrUserHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = userHandler.handlePost(script_TestDataFactory.webhookUserCreateJSON);

        System.assertEquals('CREATE_USER', handlerResponse.type);
        System.assertEquals('euromoney-sandbox', handlerResponse.tenantId);
        System.assertEquals('test-subtenant', handlerResponse.subTenantId);
        System.assertEquals('User Create', handlerResponse.webhook);

        List<Zephr_User__c> zephrUsers = [
                SELECT
                        Zephr_Id__c,
                        Zephr_Tenant__c,
                        Zephr_Integration_Status__c,
                        Zephr_Email__c,
                        Zephr_Email_Verified__c,
                        Zephr_First_Name__c,
                        Zephr_Last_Name__c,
                        Zephr_Company_Name__c,
                        Zephr_Company_Type__c,
                        Zephr_Job_Title__c,
                        Zephr_Confirm_Contact_Pref__c,
                        Zephr_Contact_Preference_Email__c,
                        Zephr_Contact_Preference_Phone__c,
                        Zephr_Contact_Preference_Post__c,
                        Zephr_Telephone_Number__c,
                        Zephr_Terms_and_Conditions__c,
                        Lead__c
                FROM Zephr_User__c
        ];
        System.assertEquals(1, zephrUsers.size());
        Zephr_User__c zephrUser = zephrUsers[0];
        System.assertEquals(zephrUser.Zephr_Id__c, 'USER_ID');
        System.assertEquals(zephrUser.Zephr_Tenant__c, 'euromoney-sandbox');
        System.assertEquals(zephrUser.Zephr_Integration_Status__c, 'Synced');
        System.assertEquals(zephrUser.Zephr_Email__c, 'test@example.com');
        System.assertEquals(zephrUser.Zephr_Email_Verified__c, false);
        System.assertEquals(zephrUser.Zephr_First_Name__c, 'Testing');
        System.assertEquals(zephrUser.Zephr_Last_Name__c, 'Tester');
        System.assertEquals(zephrUser.Zephr_Company_Name__c, 'Test Company');
        System.assertEquals(zephrUser.Zephr_Company_Type__c, null);
        System.assertEquals(zephrUser.Zephr_Job_Title__c, 'title');
        System.assertEquals(zephrUser.Zephr_Confirm_Contact_Pref__c, true);
        System.assertEquals(zephrUser.Zephr_Contact_Preference_Email__c, true);
        System.assertEquals(zephrUser.Zephr_Contact_Preference_Phone__c, true);
        System.assertEquals(zephrUser.Zephr_Contact_Preference_Post__c, true);
        System.assertEquals(zephrUser.Zephr_Telephone_Number__c, '+1234556789');
        System.assertEquals(zephrUser.Zephr_Terms_and_Conditions__c, true);

        List<Lead> leads = [
                SELECT
                        Id,
                        FirstName,
                        LastName,
                        Company,
                        Email,
                        Company_Type__c,
                        Phone
                FROM Lead
        ];
        System.assertEquals(0, leads.size());
    }

    @IsTest static void test_ZephrUserHandler_handlePost_salesforce_data_single_record_different() {
        Contact con = [SELECT Id, Email FROM Contact];


        System.assert([SELECT Id FROM Zephr_User__c].isEmpty());
        Zephr_User__c existingZephrUser = new Zephr_User__c();
        existingZephrUser.Zephr_Id__c = 'USER_ID1';
        existingZephrUser.Zephr_Tenant__c = 'euromoney-sandbox';
        existingZephrUser.Zephr_Integration_Status__c = 'Pending';
        existingZephrUser.Zephr_Email__c = 'email123@example.com';
        existingZephrUser.Zephr_Email_Verified__c = false;
        existingZephrUser.Zephr_First_Name__c = 'Testy';
        existingZephrUser.Zephr_Last_Name__c = 'Testy';
        existingZephrUser.Zephr_Company_Name__c = 'Testy';
//        existingZephrUser.Zephr_Company_Type__c = 'Testy';
        existingZephrUser.Zephr_Job_Title__c = 'Testy';
        existingZephrUser.Zephr_Confirm_Contact_Pref__c = false;
        existingZephrUser.Zephr_Contact_Preference_Email__c = false;
        existingZephrUser.Zephr_Contact_Preference_Phone__c = false;
        existingZephrUser.Zephr_Contact_Preference_Post__c = false;
        existingZephrUser.Zephr_Telephone_Number__c = 'Testy';
        existingZephrUser.Zephr_Terms_and_Conditions__c = false;
        existingZephrUser.Contact__c = con.Id;
        insert existingZephrUser;
        zephr_WebhookAPI.ZephrUserHandler userHandler = new zephr_WebhookAPI.ZephrUserHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = userHandler.handlePost(script_TestDataFactory.webhookUserCreateJSON);

        System.assertEquals('CREATE_USER', handlerResponse.type);
        System.assertEquals('euromoney-sandbox', handlerResponse.tenantId);
        System.assertEquals('test-subtenant', handlerResponse.subTenantId);
        System.assertEquals('User Create', handlerResponse.webhook);

        List<Zephr_User__c> zephrUsers = [
                SELECT
                        Zephr_Id__c,
                        Zephr_Tenant__c,
                        Zephr_Integration_Status__c,
                        Zephr_Email__c,
                        Zephr_Email_Verified__c,
                        Zephr_First_Name__c,
                        Zephr_Last_Name__c,
                        Zephr_Company_Name__c,
                        Zephr_Company_Type__c,
                        Zephr_Job_Title__c,
                        Zephr_Confirm_Contact_Pref__c,
                        Zephr_Contact_Preference_Email__c,
                        Zephr_Contact_Preference_Phone__c,
                        Zephr_Contact_Preference_Post__c,
                        Zephr_Telephone_Number__c,
                        Zephr_Terms_and_Conditions__c,
                        Lead__c
                FROM Zephr_User__c
        ];
        System.assertEquals(2, zephrUsers.size());

        List<Lead> leads = [
                SELECT
                        Id,
                        FirstName,
                        LastName,
                        Company,
                        Email,
                        Company_Type__c,
                        Phone
                FROM Lead
        ];
        System.assertEquals(0, leads.size());
    }

    @IsTest static void test_ZephrUserHandler_handlePut_no_salesforce_data() {
        System.assert([SELECT Id FROM Zephr_User__c].isEmpty());
        zephr_WebhookAPI.ZephrUserHandler userHandler = new zephr_WebhookAPI.ZephrUserHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = userHandler.handlePut(script_TestDataFactory.webhookUserUpdateJSON);

        System.assertEquals('UPDATE_USER_PROFILE', handlerResponse.type);
        System.assertEquals('euromoney-sandbox', handlerResponse.tenantId);
        System.assertEquals('test-subtenant', handlerResponse.subTenantId);
        System.assertEquals('User Update', handlerResponse.webhook);

        List<Zephr_User__c> zephrUsers = [
                SELECT
                        Zephr_Id__c,
                        Zephr_Tenant__c,
                        Zephr_Integration_Status__c,
                        Zephr_Email__c,
                        Zephr_Email_Verified__c,
                        Zephr_First_Name__c,
                        Zephr_Last_Name__c,
                        Zephr_Company_Name__c,
                        Zephr_Company_Type__c,
                        Zephr_Job_Title__c,
                        Zephr_Confirm_Contact_Pref__c,
                        Zephr_Contact_Preference_Email__c,
                        Zephr_Contact_Preference_Phone__c,
                        Zephr_Contact_Preference_Post__c,
                        Zephr_Telephone_Number__c,
                        Zephr_Terms_and_Conditions__c,
                        Lead__c
                FROM Zephr_User__c
        ];
        System.assertEquals(1, zephrUsers.size());
        Zephr_User__c zephrUser = zephrUsers[0];
        System.assertEquals(zephrUser.Zephr_Id__c, 'USER_ID');
        System.assertEquals(zephrUser.Zephr_Tenant__c, 'euromoney-sandbox');
        System.assertEquals(zephrUser.Zephr_Integration_Status__c, 'Synced');
        System.assertEquals(zephrUser.Zephr_Email__c, 'test@example.com');
        System.assertEquals(zephrUser.Zephr_Email_Verified__c, true);
        System.assertEquals(zephrUser.Zephr_First_Name__c, 'Testing');
        System.assertEquals(zephrUser.Zephr_Last_Name__c, 'Tester');
        System.assertEquals(zephrUser.Zephr_Company_Name__c, 'Test Company');
        System.assertEquals(zephrUser.Zephr_Company_Type__c, null);
        System.assertEquals(zephrUser.Zephr_Job_Title__c, 'Title');
        System.assertEquals(zephrUser.Zephr_Confirm_Contact_Pref__c, true);
        System.assertEquals(zephrUser.Zephr_Contact_Preference_Email__c, true);
        System.assertEquals(zephrUser.Zephr_Contact_Preference_Phone__c, true);
        System.assertEquals(zephrUser.Zephr_Contact_Preference_Post__c, true);
        System.assertEquals(zephrUser.Zephr_Telephone_Number__c, '+1234556789');
        System.assertEquals(zephrUser.Zephr_Terms_and_Conditions__c, true);

        List<Lead> leads = [
                SELECT
                        Id,
                        FirstName,
                        LastName,
                        Company,
                        Email,
                        Company_Type__c,
                        Phone
                FROM Lead
        ];
        System.assertEquals(0, leads.size());
    }

    @IsTest static void test_ZephrUserHandler_handlePut_salesforce_data_single_record_same_id() {
        System.assert([SELECT Id FROM Zephr_User__c].isEmpty());
        Zephr_User__c existingZephrUser = new Zephr_User__c();
        existingZephrUser.Zephr_Id__c = 'USER_ID';
        existingZephrUser.Zephr_Tenant__c = 'euromoney-sandbox';
        existingZephrUser.Zephr_Integration_Status__c = 'Pending';
        existingZephrUser.Zephr_Email__c = 'email123@example.com';
        existingZephrUser.Zephr_Email_Verified__c = false;
        existingZephrUser.Zephr_First_Name__c = 'Testy';
        existingZephrUser.Zephr_Last_Name__c = 'Testy';
        existingZephrUser.Zephr_Company_Name__c = 'Testy';
//        existingZephrUser.Zephr_Company_Type__c = 'Testy';
        existingZephrUser.Zephr_Job_Title__c = 'Testy';
        existingZephrUser.Zephr_Confirm_Contact_Pref__c = false;
        existingZephrUser.Zephr_Contact_Preference_Email__c = false;
        existingZephrUser.Zephr_Contact_Preference_Phone__c = false;
        existingZephrUser.Zephr_Contact_Preference_Post__c = false;
        existingZephrUser.Zephr_Telephone_Number__c = 'Testy';
        existingZephrUser.Zephr_Terms_and_Conditions__c = false;

        insert existingZephrUser;

        zephr_WebhookAPI.ZephrUserHandler userHandler = new zephr_WebhookAPI.ZephrUserHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = userHandler.handlePut(script_TestDataFactory.webhookUserUpdateJSON);

        System.assertEquals('UPDATE_USER_PROFILE', handlerResponse.type);
        System.assertEquals('euromoney-sandbox', handlerResponse.tenantId);
        System.assertEquals('test-subtenant', handlerResponse.subTenantId);
        System.assertEquals('User Update', handlerResponse.webhook);

        List<Zephr_User__c> zephrUsers = [
                SELECT
                        Zephr_Id__c,
                        Zephr_Tenant__c,
                        Zephr_Integration_Status__c,
                        Zephr_Email__c,
                        Zephr_Email_Verified__c,
                        Zephr_First_Name__c,
                        Zephr_Last_Name__c,
                        Zephr_Company_Name__c,
                        Zephr_Company_Type__c,
                        Zephr_Job_Title__c,
                        Zephr_Confirm_Contact_Pref__c,
                        Zephr_Contact_Preference_Email__c,
                        Zephr_Contact_Preference_Phone__c,
                        Zephr_Contact_Preference_Post__c,
                        Zephr_Telephone_Number__c,
                        Zephr_Terms_and_Conditions__c,
                        Lead__c
                FROM Zephr_User__c
        ];
        System.assertEquals(1, zephrUsers.size());
        Zephr_User__c zephrUser = zephrUsers[0];
        System.assertEquals(zephrUser.Zephr_Id__c, 'USER_ID');
        System.assertEquals(zephrUser.Zephr_Tenant__c, 'euromoney-sandbox');
        System.assertEquals(zephrUser.Zephr_Integration_Status__c, 'Synced');
        System.assertEquals(zephrUser.Zephr_Email__c, 'test@example.com');
        System.assertEquals(zephrUser.Zephr_Email_Verified__c, true);
        System.assertEquals(zephrUser.Zephr_First_Name__c, 'Testing');
        System.assertEquals(zephrUser.Zephr_Last_Name__c, 'Tester');
        System.assertEquals(zephrUser.Zephr_Company_Name__c, 'Test Company');
        System.assertEquals(zephrUser.Zephr_Company_Type__c, null);
        System.assertEquals(zephrUser.Zephr_Job_Title__c, 'Title');
        System.assertEquals(zephrUser.Zephr_Confirm_Contact_Pref__c, true);
        System.assertEquals(zephrUser.Zephr_Contact_Preference_Email__c, true);
        System.assertEquals(zephrUser.Zephr_Contact_Preference_Phone__c, true);
        System.assertEquals(zephrUser.Zephr_Contact_Preference_Post__c, true);
        System.assertEquals(zephrUser.Zephr_Telephone_Number__c, '+1234556789');
        System.assertEquals(zephrUser.Zephr_Terms_and_Conditions__c, true);

        List<Lead> leads = [
                SELECT
                        Id,
                        FirstName,
                        LastName,
                        Company,
                        Email,
                        Company_Type__c,
                        Phone
                FROM Lead
        ];
        System.assertEquals(0, leads.size());
    }

    @IsTest static void test_ZephrUserHandler_handlePut_salesforce_data_single_record_same_email_tenant() {
        Contact con = [SELECT Id, Email FROM Contact];
        con.Email = 'test@example.com';
        update con;

        System.assert([SELECT Id FROM Zephr_User__c].isEmpty());
        Zephr_User__c existingZephrUser = new Zephr_User__c();
        existingZephrUser.Zephr_Id__c = 'USER_ID1';
        existingZephrUser.Zephr_Tenant__c = 'euromoney-sandbox';
        existingZephrUser.Zephr_Integration_Status__c = 'Pending';
        existingZephrUser.Zephr_Email__c = 'email123@example.com';
        existingZephrUser.Zephr_Email_Verified__c = false;
        existingZephrUser.Zephr_First_Name__c = 'Testy';
        existingZephrUser.Zephr_Last_Name__c = 'Testy';
        existingZephrUser.Zephr_Company_Name__c = 'Testy';
//        existingZephrUser.Zephr_Company_Type__c = 'Testy';
        existingZephrUser.Zephr_Job_Title__c = 'Testy';
        existingZephrUser.Zephr_Confirm_Contact_Pref__c = false;
        existingZephrUser.Zephr_Contact_Preference_Email__c = false;
        existingZephrUser.Zephr_Contact_Preference_Phone__c = false;
        existingZephrUser.Zephr_Contact_Preference_Post__c = false;
        existingZephrUser.Zephr_Telephone_Number__c = 'Testy';
        existingZephrUser.Zephr_Terms_and_Conditions__c = false;
        existingZephrUser.Contact__c = con.Id;
        insert existingZephrUser;
        zephr_WebhookAPI.ZephrUserHandler userHandler = new zephr_WebhookAPI.ZephrUserHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = userHandler.handlePut(script_TestDataFactory.webhookUserUpdateJSON);

        System.assertEquals('UPDATE_USER_PROFILE', handlerResponse.type);
        System.assertEquals('euromoney-sandbox', handlerResponse.tenantId);
        System.assertEquals('test-subtenant', handlerResponse.subTenantId);
        System.assertEquals('User Update', handlerResponse.webhook);

        List<Zephr_User__c> zephrUsers = [
                SELECT
                        Zephr_Id__c,
                        Zephr_Tenant__c,
                        Zephr_Integration_Status__c,
                        Zephr_Email__c,
                        Zephr_Email_Verified__c,
                        Zephr_First_Name__c,
                        Zephr_Last_Name__c,
                        Zephr_Company_Name__c,
                        Zephr_Company_Type__c,
                        Zephr_Job_Title__c,
                        Zephr_Confirm_Contact_Pref__c,
                        Zephr_Contact_Preference_Email__c,
                        Zephr_Contact_Preference_Phone__c,
                        Zephr_Contact_Preference_Post__c,
                        Zephr_Telephone_Number__c,
                        Zephr_Terms_and_Conditions__c,
                        Lead__c
                FROM Zephr_User__c
        ];
        System.assertEquals(1, zephrUsers.size());
        Zephr_User__c zephrUser = zephrUsers[0];
        System.assertEquals(zephrUser.Zephr_Id__c, 'USER_ID');
        System.assertEquals(zephrUser.Zephr_Tenant__c, 'euromoney-sandbox');
        System.assertEquals(zephrUser.Zephr_Integration_Status__c, 'Synced');
        System.assertEquals(zephrUser.Zephr_Email__c, 'test@example.com');
        System.assertEquals(zephrUser.Zephr_Email_Verified__c, true);
        System.assertEquals(zephrUser.Zephr_First_Name__c, 'Testing');
        System.assertEquals(zephrUser.Zephr_Last_Name__c, 'Tester');
        System.assertEquals(zephrUser.Zephr_Company_Name__c, 'Test Company');
        System.assertEquals(zephrUser.Zephr_Company_Type__c, null);
        System.assertEquals(zephrUser.Zephr_Job_Title__c, 'Title');
        System.assertEquals(zephrUser.Zephr_Confirm_Contact_Pref__c, true);
        System.assertEquals(zephrUser.Zephr_Contact_Preference_Email__c, true);
        System.assertEquals(zephrUser.Zephr_Contact_Preference_Phone__c, true);
        System.assertEquals(zephrUser.Zephr_Contact_Preference_Post__c, true);
        System.assertEquals(zephrUser.Zephr_Telephone_Number__c, '+1234556789');
        System.assertEquals(zephrUser.Zephr_Terms_and_Conditions__c, true);

        List<Lead> leads = [
                SELECT
                        Id,
                        FirstName,
                        LastName,
                        Company,
                        Email,
                        Company_Type__c,
                        Phone
                FROM Lead
        ];
        System.assertEquals(0, leads.size());
    }
    
    @IsTest static void test_ZephrUserHandler_handleDelete_no_salesforce_data_em_example() {
        System.assert([SELECT Id FROM Zephr_User__c].isEmpty());
        zephr_WebhookAPI.ZephrUserHandler userHandler = new zephr_WebhookAPI.ZephrUserHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = userHandler.handleDelete(script_TestDataFactory.webhookUserCreateJSON_EM);
    }
        
        @IsTest static void test_ZephrUserHandler_handlePut_salesforce_data_single_record_different() {
        Contact con = [SELECT Id, Email FROM Contact];


        System.assert([SELECT Id FROM Zephr_User__c].isEmpty());
        Zephr_User__c existingZephrUser = new Zephr_User__c();
        existingZephrUser.Zephr_Id__c = 'USER_ID1';
        existingZephrUser.Zephr_Tenant__c = 'euromoney-sandbox';
        existingZephrUser.Zephr_Integration_Status__c = 'Pending';
        existingZephrUser.Zephr_Email__c = 'email123@example.com';
        existingZephrUser.Zephr_Email_Verified__c = true;
        existingZephrUser.Zephr_First_Name__c = 'Testy';
        existingZephrUser.Zephr_Last_Name__c = 'Testy';
        existingZephrUser.Zephr_Company_Name__c = 'Testy';
//        existingZephrUser.Zephr_Company_Type__c = 'Testy';
        existingZephrUser.Zephr_Job_Title__c = 'Testy';
        existingZephrUser.Zephr_Confirm_Contact_Pref__c = false;
        existingZephrUser.Zephr_Contact_Preference_Email__c = false;
        existingZephrUser.Zephr_Contact_Preference_Phone__c = false;
        existingZephrUser.Zephr_Contact_Preference_Post__c = false;
        existingZephrUser.Zephr_Telephone_Number__c = 'Testy';
        existingZephrUser.Zephr_Terms_and_Conditions__c = false;
        existingZephrUser.Contact__c = con.Id;
        insert existingZephrUser;
        zephr_WebhookAPI.ZephrUserHandler userHandler = new zephr_WebhookAPI.ZephrUserHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = userHandler.handlePut(script_TestDataFactory.webhookUserUpdateJSON);

        System.assertEquals('UPDATE_USER_PROFILE', handlerResponse.type);
        System.assertEquals('euromoney-sandbox', handlerResponse.tenantId);
        System.assertEquals('test-subtenant', handlerResponse.subTenantId);
        System.assertEquals('User Update', handlerResponse.webhook);

        List<Zephr_User__c> zephrUsers = [
                SELECT
                        Zephr_Id__c,
                        Zephr_Tenant__c,
                        Zephr_Integration_Status__c,
                        Zephr_Email__c,
                        Zephr_Email_Verified__c,
                        Zephr_First_Name__c,
                        Zephr_Last_Name__c,
                        Zephr_Company_Name__c,
                        Zephr_Company_Type__c,
                        Zephr_Job_Title__c,
                        Zephr_Confirm_Contact_Pref__c,
                        Zephr_Contact_Preference_Email__c,
                        Zephr_Contact_Preference_Phone__c,
                        Zephr_Contact_Preference_Post__c,
                        Zephr_Telephone_Number__c,
                        Zephr_Terms_and_Conditions__c,
                        Lead__c
                FROM Zephr_User__c
        ];
        System.assertEquals(2, zephrUsers.size());

        List<Lead> leads = [
                SELECT
                        Id,
                        FirstName,
                        LastName,
                        Company,
                        Email,
                        Company_Type__c,
                        Phone
                FROM Lead
        ];
        System.assertEquals(0, leads.size());
    }
    
    @IsTest static void test_ZephrUserHandler_handlePost_AccountGrantCreated() {
        System.assert([SELECT Id FROM Zephr_User__c].isEmpty());
        
        Account accountRecord = [SELECT Id FROM Account LIMIT 1];
        
        Subscription__c subscription = new Subscription__c();
        subscription.Subscription_Management_System__c = 'Zephr';
        subscription.Account__c = accountRecord.Id;
        subscription.Number_of_Seats__c = 1;
        insert subscription;
        
        Zephr_Account__c accountGrant = new Zephr_Account__c();
        accountGrant.Zephr_Id__c = '';
        accountGrant.Zephr_Tenant__c = 'euromoney';
        accountGrant.Subscription__c = subscription.Id;
        insert accountGrant;
        
        zephr_WebhookAPI.AccountGrantCreatedHandler userHandler = new zephr_WebhookAPI.AccountGrantCreatedHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = userHandler.handlePost(script_TestDataFactory.webhookGrantCreateJSON_EM);
    }
    
    @IsTest static void test_ZephrUserHandler_handlePut_AccountGrantCreated() {
        zephr_WebhookAPI.AccountGrantCreatedHandler userHandler = new zephr_WebhookAPI.AccountGrantCreatedHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = userHandler.handlePut(script_TestDataFactory.webhookGrantCreateJSON_EM);
    }
    
    @IsTest static void test_ZephrUserHandler_handleDelete_AccountGrantCreated() {
        zephr_WebhookAPI.AccountGrantCreatedHandler userHandler = new zephr_WebhookAPI.AccountGrantCreatedHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = userHandler.handleDelete(script_TestDataFactory.webhookGrantCreateJSON_EM);
    }
    
    @IsTest static void test_ZephrUserHandler_handlePost_UserAccountGrantCreated() {
        System.assert([SELECT Id FROM Zephr_User__c].isEmpty());
        
        Account accountRecord = [SELECT Id FROM Account LIMIT 1];
        
        Subscription__c subscription = new Subscription__c();
        subscription.Subscription_Management_System__c = 'Zephr';
        subscription.Account__c = accountRecord.Id;
        subscription.Number_of_Seats__c = 1;
        subscription.Zephr_Signup_Enabled__c = true;
        insert subscription;
        
        Zephr_Account__c accountGrant = new Zephr_Account__c();
        accountGrant.Zephr_Tenant__c = 'euromoney';
        accountGrant.Subscription__c = subscription.Id;
        insert accountGrant;
        
        Zephr_User__c zUser = new Zephr_User__c();
        zUser.Zephr_Email__c = 'tset@sdfs.com';
        zUser.Zephr_Id__c = 'c48a790d-26d7-46b0-bbde-cdb0d46574b8';
        zUser.Zephr_Tenant__c = 'euromoney';
        insert zUser;
        
        
        zephr_WebhookAPI.UserAccountGrantCreatedHandler userHandler = new zephr_WebhookAPI.UserAccountGrantCreatedHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = userHandler.handlePost(script_TestDataFactory.webhookUserGrantCreateJSON_EM);
        
    }
    @IsTest static void test_ZephrUserHandler_handleDelete_UserAccountGrantCreated() {
        System.assert([SELECT Id FROM Zephr_User__c].isEmpty());
        
        Account accountRecord = [SELECT Id FROM Account LIMIT 1];
        
        Subscription__c subscription = new Subscription__c();
        subscription.Subscription_Management_System__c = 'Zephr';
        subscription.Account__c = accountRecord.Id;
        subscription.Number_of_Seats__c = 1;
        subscription.Zephr_Signup_Enabled__c = true;
        insert subscription;
        
        Zephr_Account__c accountGrant = new Zephr_Account__c();
        accountGrant.Zephr_Tenant__c = 'euromoney';
        accountGrant.Zephr_Id__c = '9fe3c35f-9fb8-4942-8cd9-2aec3da02a32';
        accountGrant.Subscription__c = subscription.Id;
        insert accountGrant;
        
        Zephr_User__c zUser = new Zephr_User__c();
        zUser.Zephr_Email__c = 'tset@sdfs.com';
        zUser.Zephr_Id__c = 'c48a790d-26d7-46b0-bbde-cdb0d46574b8';
        zUser.Zephr_Tenant__c = 'euromoney';
        insert zUser;
        
        Zephr_User_Account_Grant__c zephrUserAccountGrant = new Zephr_User_Account_Grant__c();
        zephrUserAccountGrant.Zephr_Account__c = accountGrant.Id;
        zephrUserAccountGrant.Zephr_User__c = zUser.Id;
        zephrUserAccountGrant.Zephr_Integration_Status__c = 'Pending';
        insert zephrUserAccountGrant;
        
        Subscription_User__c zSubscriptionUser = new Subscription_User__c();
        zSubscriptionUser.Subscriber_Status__c = 'Active';
        zSubscriptionUser.Subscription_NG__c = subscription.Id;
        zSubscriptionUser.Subscriber_Start_Date__c = System.now().addDays(34);
        zSubscriptionUser.Zephr_User_Account_Grant__c = zephrUserAccountGrant.Id;
        insert zSubscriptionUser;
        
        zephrUserAccountGrant.Subscription_User__c = zSubscriptionUser.Id;
        update zephrUserAccountGrant;
        
        Subscription_User__c zSubUSer = [SELECT Id, Subscriber_Status__c, Subscriber_End_Date__c FROM Subscription_User__c WHERE Zephr_User_Account_Grant__r.Zephr_Account__r.Zephr_Id__c = '9fe3c35f-9fb8-4942-8cd9-2aec3da02a32' AND Zephr_User_Account_Grant__r.Zephr_User__r.Zephr_Id__c = 'c48a790d-26d7-46b0-bbde-cdb0d46574b8' LIMIT 1];
        Assert.isNotNull(zSubUSer);
        Assert.areEqual('Active', zSubUSer.Subscriber_Status__c);
        
        zephr_WebhookAPI.UserAccountGrantCreatedHandler userHandler = new zephr_WebhookAPI.UserAccountGrantCreatedHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = userHandler.handleDelete(script_TestDataFactory.webhookUserGrantCreateJSON_EM);
    
    }
    
    @IsTest static void test_ZephrUserHandler_handlePut_UserEmailConfirmedHandler() {
        zephr_WebhookAPI.UserEmailConfirmedHandler userHandler = new zephr_WebhookAPI.UserEmailConfirmedHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = userHandler.handlePut(script_TestDataFactory.WebhookUserEmailConfirmed_JSON);
    }
    
    @IsTest static void test_ZephrUserHandler_handlePost_UserEmailConfirmedHandler() {
        zephr_WebhookAPI.UserEmailConfirmedHandler userHandler = new zephr_WebhookAPI.UserEmailConfirmedHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = userHandler.handlePost(script_TestDataFactory.WebhookUserEmailConfirmed_JSON);
    }
    
    @IsTest static void test_ZephrUserHandler_handleDelete_UserEmailConfirmedHandler() {
        zephr_WebhookAPI.UserEmailConfirmedHandler userHandler = new zephr_WebhookAPI.UserEmailConfirmedHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = userHandler.handleDelete(script_TestDataFactory.WebhookUserEmailConfirmed_JSON);
    }
    
    @IsTest static void test_ZephrUserEmailHandler_handlePut_UserEmailChangeHandler() {
        Zephr_User__c existingZephrUser = new Zephr_User__c();
        existingZephrUser.Zephr_Id__c = 'USER_ID';
        existingZephrUser.Zephr_Tenant__c = 'euromoney-sandbox';
        existingZephrUser.Zephr_Integration_Status__c = 'Pending';
        existingZephrUser.Zephr_Email__c = 'email123@example.com';
        existingZephrUser.Zephr_Email_Verified__c = true;
        existingZephrUser.Zephr_First_Name__c = 'Testy';
        existingZephrUser.Zephr_Last_Name__c = 'Testy';
        existingZephrUser.Zephr_Company_Name__c = 'Testy';
//        existingZephrUser.Zephr_Company_Type__c = 'Testy';
        existingZephrUser.Zephr_Job_Title__c = 'Testy';
        existingZephrUser.Zephr_Confirm_Contact_Pref__c = false;
        existingZephrUser.Zephr_Contact_Preference_Email__c = false;
        existingZephrUser.Zephr_Contact_Preference_Phone__c = false;
        existingZephrUser.Zephr_Contact_Preference_Post__c = false;
        existingZephrUser.Zephr_Telephone_Number__c = 'Testy';
        existingZephrUser.Zephr_Terms_and_Conditions__c = false;
        
        insert existingZephrUser;
        
        zephr_WebhookAPI.UserEmailChangeHandler userHandler = new zephr_WebhookAPI.UserEmailChangeHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = userHandler.handlePut(script_TestDataFactory.WebhookUserEmailChangeHandler_JSON);
        
    }
    
    @IsTest static void test_ZephrUserEmailHandler_handleDelete_UserEmailChangeHandler() {
        zephr_WebhookAPI.UserEmailChangeHandler userHandler = new zephr_WebhookAPI.UserEmailChangeHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = userHandler.handleDelete(script_TestDataFactory.WebhookUserEmailChangeHandler_JSON);
    }
    
    @IsTest static void test_ZephrUserEmailHandler_handlePost_UserEmailChangeHandler() {
        zephr_WebhookAPI.UserEmailChangeHandler userHandler = new zephr_WebhookAPI.UserEmailChangeHandler();
        zephr_WebhookAPI.BaseAPI handlerResponse = userHandler.handlePost(script_TestDataFactory.WebhookUserEmailChangeHandler_JSON);
    }

}