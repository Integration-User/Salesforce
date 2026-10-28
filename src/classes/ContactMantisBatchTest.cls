@isTest
public class ContactMantisBatchTest {
    @testSetup
    static void setup() {
        // Create test Contacts
        Account accnt = new Account();
        accnt.Name = 'Test Account';
        accnt.Account_Status__c = 'Active';   
        accnt.Subsidiary__c = '10 GSA LLC';
        insert accnt;
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 3; i++) {
            contacts.add(new Contact(LastName = 'Test' + i, email = 'Test' + i +'@test.com'));
        }
        insert contacts;

        // Create System_Configuration__mdt record
        String contactIds = String.join(new List<String>{
            contacts[0].Id, contacts[1].Id, contacts[2].Id, accnt.Id
        }, ',');
        System_Configuration__mdt config = new System_Configuration__mdt(
            DeveloperName = 'Test_Config',
            MasterLabel = 'Test Config',
            List_Of_Value__c = contactIds
        );
        //insert config;
    }

    @isTest
    static void testBatch() {
        // Mock the callout utility if needed
        Test.startTest();
        ContactMantisBatch batch = new ContactMantisBatch('Activate', 'Account');
        Database.executeBatch(batch, 1);
        Test.stopTest();

        // Add asserts as needed, e.g. check debug logs, email, etc.
        // You can query Messaging.SingleEmailMessage if using SingleEmailMessage.sendEmail
    }
}