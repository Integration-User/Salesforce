/**
 * @description Comprehensive test class for Contact Trigger, Handler, Helper, and Queueable
 * Covers DNC/DNCall field synchronization across duplicate email addresses
 * and Contact trigger functionality
 * 
 * Test Coverage:
 * - Trigger afterInsert and afterUpdate functionality
 * - Queueable job execution
 * - Handler recursion prevention
 * - Helper method logic
 * - Email field changes
 * - DNC/DNCall field synchronization
 * - Bulk operations
 * - Edge cases and special scenarios
 */
@isTest
private class SyncDuplicateContactDNCQueueableTest {
    
    @testSetup static void loadData() {
        insert new Trigger_Control_Setting__c(SetupOwnerId=UserInfo.getOrganizationId(), Contact__c=true);
    }
    
    /**
     * @description Test data factory method to create test accounts
     */
    private static Account createTestAccount() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        return acc;
    }
    
    /**
     * @description Test data factory method to create test contacts
     */
    private static Contact createTestContact(String email, String firstName, String lastName, Boolean doNotCall, Boolean hasOptedOutOfEmail) {
        Contact contact = new Contact(
            Email = email,
            FirstName = firstName,
            LastName = lastName,
            DoNotCall = doNotCall,
            HasOptedOutOfEmail = hasOptedOutOfEmail
        );
        return contact;
    }
}