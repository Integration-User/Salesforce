@isTest
public class AccountTriggerTest {
    @testSetup static void loadData() {
        insert new Trigger_Control_Setting__c(SetupOwnerId=UserInfo.getOrganizationId(), Account__c=true);

        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization_Account').getRecordTypeId();

		Account acc = new Account();
        acc.Name = 'Test Account 1';
        acc.RecordTypeId = accRecordTypeId;
        Insert acc;
        
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Existing_Business').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = oppRecordTypeId;
        opp.Name = 'OppTest 1';
        opp.CloseDate = system.today();
        opp.StageName = 'Qualified Prospect (2)';
        opp.CurrencyIsoCode = 'USD';
        opp.AccountId = acc.Id;
        opp.Sectors_Sold__c = 'All Sectors';
        opp.Sales_Type__c = 'New';
        opp.Department__c = 'Corporate';
        opp.Class__c = 'Corporate';
        Insert opp;
    }
    @isTest static void testAccountOwner() {
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
        Account acc = [Select Id, OwnerId FROM Account WHERE Name = 'Test Account 1'];
        acc.OwnerId = userRecord1.Id;
        Update acc;
        Test.stopTest();
        Opportunity opp = [Select Id, OwnerId From Opportunity Where AccountId = :acc.Id]; 
        System.assertEquals(acc.OwnerId, opp.OwnerId);
    }

}