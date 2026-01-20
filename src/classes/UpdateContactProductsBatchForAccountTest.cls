@isTest
public class UpdateContactProductsBatchForAccountTest {
    @isTest
    static void testBatchUpdate() {
        // Create test data
        Account acc = new Account(Name = 'Test Account', Current_Products__c = 'US Portfolio Tools');
        insert acc;

        Contact con1 = new Contact(LastName = 'Test Contact 1', AccountId = acc.Id, Current_Products__c = 'US Detailed NAV', Contact_Status__c = 'Active');
        Contact con2 = new Contact(LastName = 'Test Contact 2', AccountId = acc.Id, Current_Products__c = 'US Detailed NAV',Contact_Status__c = 'Active' );
        insert new List<Contact>{con1, con2};

        // Update account to trigger the batch
        Test.startTest();
        acc.Current_Products__c = 'US Portfolio Tools';
        update acc;
        Database.executeBatch(new UpdateContactProductsBatchForAccount(new Set<Id>{acc.id}), 20);
        Test.stopTest();

        // Assert contacts updated
        List<Contact> updatedContacts = [SELECT Current_Products__c FROM Contact WHERE AccountId = :acc.Id];
        for (Contact c : updatedContacts) {
            System.assertEquals('US Portfolio Tools', c.Current_Products__c, 'Contact product should be updated');
        }
    }
}
