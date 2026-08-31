@IsTest
private class AccountHierarchyRollupBatchTest {
    @IsTest
    static void rollsUpOrganizationHierarchy() {
        Id organizationRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Organization_Account').getRecordTypeId();
        Account organization = new Account(
            Name = 'Rollup Organization',
            RecordTypeId = organizationRecordTypeId,
            Type = 'Organization'
        );
        insert organization;

        Account client = new Account(
            Name = 'Rollup Client',
            ParentId = organization.Id,
            Type = 'Client',
            Annual_Recurring_Revenue__c = 1000
        );
        Account trial = new Account(
            Name = 'Rollup Trial',
            ParentId = organization.Id,
            Type = 'Client + Trial',
            Annual_Recurring_Revenue__c = 2500
        );
        Account prospect = new Account(
            Name = 'Rollup Prospect',
            ParentId = organization.Id,
            Type = 'Prospect'
        );
        insert new List<Account>{client, trial, prospect};

        Test.startTest();
        Database.executeBatch(new AccountHierarchyRollupBatch(), 200);
        Test.stopTest();

        Account result = [
            SELECT Clients_In_Hierarchy__c, Number_of_Accounts_in_Hierarchy__c, Total_ARR_in_Client_Hierarchy__c
            FROM Account
            WHERE Id = :organization.Id
        ];
        System.assertEquals(2, result.Clients_In_Hierarchy__c, 'Organization should count Client and Client + Trial descendants.');
        System.assertEquals(3, result.Number_of_Accounts_in_Hierarchy__c, 'Organization should count every descendant account.');
        System.assertEquals(3500, result.Total_ARR_in_Client_Hierarchy__c, 'Organization should sum ARR for Client account types.');
    }

    @IsTest
    static void supportsScheduledExecution() {
        Test.startTest();
        System.schedule('Account hierarchy rollup', '0 0 0 1 1 ?', new AccountHierarchyRollupBatch());
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = 'Account hierarchy rollup'], 'The batch should be schedulable.');
    }
}