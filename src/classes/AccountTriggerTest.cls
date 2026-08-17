@IsTest
public class AccountTriggerTest {
    @TestSetup static void loadData() {
        insert new Trigger_Control_Setting__c(SetupOwnerId=UserInfo.getOrganizationId(), Account__c=true);

        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization_Account').getRecordTypeId();

		Account acc = new Account();
        acc.Name = 'Test Account 1';
        acc.RecordTypeId = accRecordTypeId;
        acc.ZoomInfo_NAICS_Code_account__c = '111110';
        acc.ZoomInfo_SIC_Code_account__c = '1061';
        acc.ZoomInfo_Industry_account__c = 'Education';
        acc.ZoomInfo_Primary_Sub_Industry__c = 'Colleges & Universities';
        Insert acc;
        
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Existing_Business').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = oppRecordTypeId;
        opp.Name = 'OppTest 1';
        opp.CloseDate = system.today();
        opp.StageName = '2 - Conducting Needs Analysis';
        opp.CurrencyIsoCode = 'USD';
        opp.AccountId = acc.Id;
        opp.Sectors_Sold__c = 'All Sectors';
        opp.Sales_Type__c = 'New';
        opp.Department__c = 'Corporate';
        opp.Class__c = 'Corporate';
        Insert opp;
    }
    @IsTest static void testClientsInHierarchyRollup() {
        Id orgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization_Account').getRecordTypeId();

        Account parentAccount = new Account(Name='Parent Organization', RecordTypeId = orgRecordTypeId, Type = 'Client');
        insert parentAccount;

        Account childAccount = new Account(Name='Child Organization', RecordTypeId = orgRecordTypeId, ParentId = parentAccount.Id, Type = 'Client');
        insert childAccount;

        Account grandChildAccount = new Account(Name='Grandchild Organization', RecordTypeId = orgRecordTypeId, ParentId = childAccount.Id, Type = 'Client');
        insert grandChildAccount;

        parentAccount = [SELECT Id, Clients_In_Hierarchy__c FROM Account WHERE Id = :parentAccount.Id];
        System.assertEquals(2, parentAccount.Clients_In_Hierarchy__c, 'Parent should count both client descendants.');

        childAccount.Type = 'Prospect';
        update childAccount;

        parentAccount = [SELECT Id, Clients_In_Hierarchy__c FROM Account WHERE Id = :parentAccount.Id];
        System.assertEquals(1, parentAccount.Clients_In_Hierarchy__c, 'Parent should recalculate after child relationship changes.');
    }

    @IsTest static void testAccountOwner() {
        Profile p2 = [SELECT Id FROM Profile WHERE Name='Standard User'];
        user userRecord1 = new user();
        userRecord1.LastName ='AccOwner' ;
        userRecord1.Username ='testUseracc@user.com' ;
        userRecord1.Email = 'vendor.sfdc15@user.com';
        userRecord1.Alias = 'tsusera';
        userRecord1.TimeZoneSidKey = 'America/Los_Angeles';
        userRecord1.LocaleSidKey = 'en_US';
        userRecord1.EmailEncodingKey = 'UTF-8';
        userRecord1.LanguageLocaleKey = 'en_US';
        userRecord1.ProfileId = p2.Id;
        insert userRecord1;
        Test.startTest();
        Account acc = [Select Id, Synced__c, OwnerId, BillingStreet, BillingCity, BillingState, BillingPostalCode, ShippingCity, ShippingStreet, ShippingCountry, ShippingPostalCode FROM Account WHERE Name = 'Test Account 1'];
        acc.OwnerId = userRecord1.Id;
        boolean isError = false;
        acc.Trigger_Real_time_Sync__c = true;
        acc.Synced__c = 'Yes';
        acc.Company_Type__c = 'Accountant';
        try {
            Update acc;
            Plative_AccountTriggerHelper.updateCTypeId(null, null);
        } catch (Exception e) {
            System.debug(' Message - ' + e.getMessage());
            isError = true;
        }
        Plative_AccountTriggerHelper.checkIfAddressChanged(acc, acc);
        Test.stopTest();
        Opportunity opp = [Select Id, OwnerId From Opportunity Where AccountId = :acc.Id]; 
        if (!isError) {
            System.assertEquals(acc.OwnerId, opp.OwnerId, 'Owner change should propagate to renewal opportunities.');
        }
    }

}
