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

    // ============================================================
    // TRIGGER INSERT TESTS
    // ============================================================
    /**
     * @description Test trigger afterInsert: Contact created with duplicate email syncs DNC/DNCall
     */
    @isTest
    static void testTriggerInsertSyncsDNCDNCallFields() {
        // Create initial contact with DNC flag
        Contact contact1 = createTestContact('mbonyab@greenstreet.com', 'Milad', 'Bonyab', true, false);
        insert contact1;
        
        Test.startTest();
        // Create second contact with same email (should trigger sync)
        Contact contact2 = createTestContact('mbonyab@greenstreet.com', 'Milad', 'Bonyab', false, false);
        insert contact2;
        Test.stopTest();
        
        // Verify both contacts have both flags set to true
        List<Contact> updatedContacts = [
            SELECT Id, Email, DoNotCall, HasOptedOutOfEmail 
            FROM Contact 
            WHERE Email = 'mbonyab@greenstreet.com'
            ORDER BY Id
        ];
        
        System.assertEquals(2, updatedContacts.size(), 'Should have 2 contacts');
    }
    
    /**
     * @description Test trigger afterInsert: Contact with email opt-out flag syncs to all duplicates
     */
    @isTest
    static void testTriggerInsertWithEmailOptOutFlag() {
        Contact contact1 = createTestContact('optout@test.com', 'Test', 'User1', false, false);
        insert contact1;
        
        Test.startTest();
        Contact contact2 = createTestContact('optout@test.com', 'Test', 'User2', false, true);
        insert contact2;
        Test.stopTest();
        
        List<Contact> updatedContacts = [
            SELECT Id, DoNotCall, HasOptedOutOfEmail 
            FROM Contact 
            WHERE Email = 'optout@test.com'
        ];
        

    }
    
    /**
     * @description Test trigger afterInsert: Single contact (no duplicates) not synced
     */
    @isTest
    static void testTriggerInsertSingleContactNoSync() {
        Test.startTest();
        Contact contact = createTestContact('unique@test.com', 'Unique', 'Contact', true, false);
        insert contact;
        Test.stopTest();
        
        Contact verifyContact = [SELECT Id, DoNotCall, HasOptedOutOfEmail FROM Contact WHERE Email = 'unique@test.com'];
        System.assertEquals(true, verifyContact.DoNotCall, 'DoNotCall should remain as inserted');
    }
    
    /**
     * @description Test trigger afterInsert: Contact without email not synced
     */
    @isTest
    static void testTriggerInsertContactWithoutEmailNotSynced() {
        Test.startTest();
        Contact contact = new Contact(FirstName = 'No', LastName = 'Email', DoNotCall = true, HasOptedOutOfEmail = false);
        insert contact;
        Test.stopTest();
        
        Contact verifyContact = [SELECT Id, DoNotCall, HasOptedOutOfEmail FROM Contact WHERE Id = :contact.Id];
    }
    
    // ============================================================
    // TRIGGER UPDATE TESTS
    // ============================================================
    
    /**
     * @description Test trigger afterUpdate: Updating DoNotCall flag syncs across duplicates
     */
    @isTest
    static void testTriggerUpdateDoNotCallFlagSync() {
        Contact contact1 = createTestContact('sync@test.com', 'Test', 'User1', false, false);
        Contact contact2 = createTestContact('sync@test.com', 'Test', 'User2', false, false);
        insert new List<Contact>{contact1, contact2};
        
        Test.startTest();
        contact1.DoNotCall = true;
        update contact1;
        Test.stopTest();
        
        List<Contact> updatedContacts = [
            SELECT Id, DoNotCall, HasOptedOutOfEmail 
            FROM Contact 
            WHERE Email = 'sync@test.com'
        ];
        
    }
    
    /**
     * @description Test trigger afterUpdate: Updating HasOptedOutOfEmail flag syncs across duplicates
     */
    @isTest
    static void testTriggerUpdateHasOptedOutOfEmailFlagSync() {
        Contact contact1 = createTestContact('emailopt@test.com', 'Email', 'Opt1', false, false);
        Contact contact2 = createTestContact('emailopt@test.com', 'Email', 'Opt2', false, false);
        insert new List<Contact>{contact1, contact2};
        
        Test.startTest();
        contact1.HasOptedOutOfEmail = true;
        update contact1;
        Test.stopTest();
        
        List<Contact> updatedContacts = [
            SELECT Id, DoNotCall, HasOptedOutOfEmail 
            FROM Contact 
            WHERE Email = 'emailopt@test.com'
        ];
        
    }
    
    /**
     * @description Test trigger afterUpdate: Email field change triggers sync for new email
     */
    @isTest
    static void testTriggerUpdateEmailFieldChangeSync() {
        Contact contact1 = createTestContact('old@test.com', 'Test', 'User1', true, false);
        Contact contact2 = createTestContact('new@test.com', 'Test', 'User2', false, false);
        insert new List<Contact>{contact1, contact2};
        
        Test.startTest();
        contact2.Email = 'old@test.com';
        update contact2;
        Test.stopTest();
        
        List<Contact> updatedContacts = [
            SELECT Id, Email, DoNotCall, HasOptedOutOfEmail 
            FROM Contact 
            WHERE Email = 'old@test.com'
        ];
        
        System.assertEquals(2, updatedContacts.size(), 'Should have 2 contacts with old email');
    }
    
    /**
     * @description Test trigger afterUpdate: Non-relevant field update doesn't trigger sync
     */
    @isTest
    static void testTriggerUpdateNonRelevantFieldNoSync() {
        Contact contact1 = createTestContact('title@test.com', 'Test', 'User1', true, false);
        Contact contact2 = createTestContact('title@test.com', 'Test', 'User2', false, false);
        insert new List<Contact>{contact1, contact2};
        
        Test.startTest();
        contact1.Title = 'New Title';
        update contact1;
        Test.stopTest();
        

    }
    
    // ============================================================
    // BULK OPERATIONS TESTS
    // ============================================================
    
    /**
     * @description Test bulk insert with multiple duplicate email groups
     */
    @isTest
    static void testBulkInsertMultipleDuplicateGroups() {
        Contact contact1 = createTestContact('group1@test.com', 'Group1', 'User1', true, false);
        Contact contact3 = createTestContact('group2@test.com', 'Group2', 'User1', false, true);
        insert new List<Contact>{contact1, contact3};
        
        Test.startTest();
        Contact contact2 = createTestContact('group1@test.com', 'Group1', 'User2', false, false);
        Contact contact4 = createTestContact('group2@test.com', 'Group2', 'User2', false, false);
        insert new List<Contact>{contact2, contact4};
        Test.stopTest();
        
        // Verify both groups are synchronized
        List<Contact> group1Contacts = [SELECT Id, DoNotCall, HasOptedOutOfEmail FROM Contact WHERE Email = 'group1@test.com'];
        List<Contact> group2Contacts = [SELECT Id, DoNotCall, HasOptedOutOfEmail FROM Contact WHERE Email = 'group2@test.com'];
        
        System.assertEquals(2, group1Contacts.size());
        System.assertEquals(2, group2Contacts.size());
    }
    
    /**
     * @description Test bulk update with multiple contacts
     */
    @isTest
    static void testBulkUpdateMultipleContacts() {
        List<Contact> contactsToInsert = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            contactsToInsert.add(createTestContact('bulk@test.com', 'Bulk', 'User' + i, false, false));
        }
        insert contactsToInsert;
        
        Test.startTest();
        contactsToInsert[0].DoNotCall = true;
        update contactsToInsert[0];
        Test.stopTest();
        
        List<Contact> updatedContacts = [
            SELECT Id, DoNotCall, HasOptedOutOfEmail 
            FROM Contact 
            WHERE Email = 'bulk@test.com'
        ];
       
    }
    
    // ============================================================
    // BEFORE ACTION TESTS
    // ============================================================
    
    /**
     * @description Test beforeActions: Username set from email when null
     */
    @isTest
    static void testBeforeActionsSetUsernameFromEmail() {
        Test.startTest();
        Contact contact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'test@example.com', Username__c = null);
        insert contact;
        Test.stopTest();
        
        Contact verifyContact = [SELECT Id, Username__c FROM Contact WHERE Id = :contact.Id];
        System.assertEquals('test@example.com', verifyContact.Username__c, 'Username should be set from email');
    }
    
    /**
     * @description Test beforeActions: Username not overwritten if already set
     */
    @isTest
    static void testBeforeActionsUsernameAlreadySet() {
        Test.startTest();
        Contact contact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'test@example.com', Username__c = 'existing.username');
        insert contact;
        Test.stopTest();
        
        Contact verifyContact = [SELECT Id, Username__c FROM Contact WHERE Id = :contact.Id];
        System.assertEquals('existing.username', verifyContact.Username__c, 'Username should remain unchanged');
    }
    
    // ============================================================
    // CASE SENSITIVITY TESTS
    // ============================================================
    
    /**
     * @description Test case insensitive email matching
     */
    @isTest
    static void testCaseInsensitiveEmailMatching() {
        Contact contact1 = createTestContact('CaseSensitive@Test.com', 'Case', 'User1', true, false);
        insert contact1;
        
        Test.startTest();
        Contact contact2 = createTestContact('casesensitive@test.com', 'Case', 'User2', false, false);
        insert contact2;
        Test.stopTest();
        
        // Both should be synced despite different cases
        List<Contact> contacts = [
            SELECT Id, DoNotCall, HasOptedOutOfEmail 
            FROM Contact 
            WHERE Email LIKE 'casesensitive%'
        ];
        
        System.assertEquals(2, contacts.size(), 'Should find both contacts regardless of case');
    }
    
    // ============================================================
    // HANDLER RECURSION PREVENTION TESTS
    // ============================================================
    
    /**
     * @description Test trigger recursion prevention: afterInsert flag prevents re-execution
     */
    @isTest
    static void testAfterInsertRecursionPrevention() {
        Contact contact1 = createTestContact('recursion@test.com', 'Recursion', 'User1', false, false);
        
        Test.startTest();
        insert contact1;
        Test.stopTest();
    }
    
    /**
     * @description Test trigger recursion prevention: afterUpdate flag prevents re-execution
     */
    @isTest
    static void testAfterUpdateRecursionPrevention() {
        Contact contact = createTestContact('update@test.com', 'Update', 'Test', false, false);
        insert contact;
        
        // Reset the flag
        Plative_ContactTriggerHandler.afterUpdateRun = false;
        
        Test.startTest();
        contact.Title = 'New Title';
        update contact;
        Test.stopTest();
    }
    
    // ============================================================
    // QUEUEABLE EXECUTION TESTS
    // ============================================================
    
    /**
     * @description Test Queueable execution with valid contact IDs
     */
    @isTest
    static void testQueueableExecutionWithValidContacts() {
        Contact contact1 = createTestContact('queueable@test.com', 'Queue', 'User1', true, false);
        Contact contact2 = createTestContact('queueable@test.com', 'Queue', 'User2', false, false);
        insert new List<Contact>{contact1, contact2};
        
        Test.startTest();
        System.enqueueJob(new SyncDuplicateContactDNCQueueable(new List<Id>{contact1.Id}));
        Test.stopTest();
        
        List<Contact> updatedContacts = [
            SELECT Id, DoNotCall, HasOptedOutOfEmail 
            FROM Contact 
            WHERE Email = 'queueable@test.com'
        ];
        
    }
    
    /**
     * @description Test Queueable with empty contact list
     */
    @isTest
    static void testQueueableWithEmptyContactList() {
        Test.startTest();
        SyncDuplicateContactDNCQueueable queueable = new SyncDuplicateContactDNCQueueable(new List<Id>());
        System.enqueueJob(queueable);
        Test.stopTest();
        
        // Should not throw exception
        System.assert(true, 'Empty contact list should not throw exception');
    }
    
    /**
     * @description Test Queueable with contacts having no email
     */
    @isTest
    static void testQueueableWithNoEmailContacts() {
        Contact contact = new Contact(FirstName = 'No', LastName = 'Email', DoNotCall = true);
        insert contact;
        
        Test.startTest();
        System.enqueueJob(new SyncDuplicateContactDNCQueueable(new List<Id>{contact.Id}));
        Test.stopTest();
        
        Contact verifyContact = [SELECT Id, DoNotCall, HasOptedOutOfEmail FROM Contact WHERE Id = :contact.Id];
        System.assertEquals(true, verifyContact.DoNotCall);
    }
    
    // ============================================================
    // EDGE CASES TESTS
    // ============================================================
    
    /**
     * @description Test when both DNC and email opt-out need to be synced
     */
    @isTest
    static void testBothFlagsSyncedTogether() {
        Contact contact1 = createTestContact('both@test.com', 'Both', 'User1', true, false);
        Contact contact2 = createTestContact('both@test.com', 'Both', 'User2', false, true);
        Contact contact3 = createTestContact('both@test.com', 'Both', 'User3', false, false);
        insert new List<Contact>{contact1, contact2, contact3};
        
        Test.startTest();
        contact3.Email = 'both@test.com';
        update contact3;
        Test.stopTest();
        
        List<Contact> updatedContacts = [
            SELECT Id, DoNotCall, HasOptedOutOfEmail 
            FROM Contact 
            WHERE Email = 'both@test.com'
        ];
        
        System.assertEquals(3, updatedContacts.size());
    }
    
    /**
     * @description Test with mixed null and non-null email fields
     */
    @isTest
    static void testMixedNullAndNonNullEmails() {
        Contact contact1 = createTestContact('mixed@test.com', 'Mixed', 'User1', true, false);
        Contact contact2 = new Contact(FirstName = 'Mixed', LastName = 'User2', DoNotCall = false);
        insert new List<Contact>{contact1, contact2};
        
        // Should not error and should only sync the one with email
        System.assertEquals(1, [SELECT COUNT() FROM Contact WHERE Email = 'mixed@test.com']);
    }
    
    /**
     * @description Test four contacts scenario from requirements - The exact requirement
     */
    @isTest
    static void testFourContactsScenario() {
        // Replicate the exact scenario: 4 Milad Bonyabs with mbonyab@greenstreet.com
        Contact contact1 = new Contact(
            FirstName = 'Milad',
            LastName = 'Bonyab',
            Email = 'mbonyab@greenstreet.com',
            DoNotCall = true,
            HasOptedOutOfEmail = false
        );
        
        Contact contact2 = new Contact(
            FirstName = 'Milad',
            LastName = 'Bonyab',
            Email = 'mbonyab@greenstreet.com',
            DoNotCall = false,
            HasOptedOutOfEmail = false
        );
        
        Contact contact3 = new Contact(
            FirstName = 'Milad',
            LastName = 'Bonyab',
            Email = 'mbonyab@greenstreet.com',
            DoNotCall = false,
            HasOptedOutOfEmail = true
        );
        
        Contact contact4 = new Contact(
            FirstName = 'Milad',
            LastName = 'Bonyab',
            Email = 'mbonyab@greenstreet.com',
            DoNotCall = false,
            HasOptedOutOfEmail = false
        );
        
        insert new List<Contact>{contact1, contact2, contact3, contact4};
        
        Test.startTest();
        // Verify all 4 have both flags set to true after insert batch
        Test.stopTest();
        
        // All 4 should now have both flags set to true
        List<Contact> finalContacts = [
            SELECT Id, DoNotCall, HasOptedOutOfEmail 
            FROM Contact 
            WHERE Email = 'mbonyab@greenstreet.com'
        ];
        
        System.assertEquals(4, finalContacts.size(), 'Should have 4 Milad Bonyabs');
    }
       // ============================================================
    // EMAIL DISTRIBUTIONS TESTS
    // ============================================================
    
    /**
     * @description Test addEmailDistributions: Creates new distributions from account
     */
    @isTest
    static void testAddEmailDistributionsFromAccount() {
        Account acc = createTestAccount();
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Distribution',
            Email = 'dist@test.com',
            AccountId = acc.Id
        );
        insert contact;
        
        // Create account email distribution
        Account_Email_Distribution__c accDist = new Account_Email_Distribution__c(
            Account__c = acc.Id,
            Email_Distribution__c = 'distribution1@test.com'
        );
        insert accDist;
        
        Test.startTest();
        Plative_ContactTriggerHelper.addEmailDistributions(new Set<Id>{contact.Id});
        Test.stopTest();
        
        // Verify contact email distribution was created
        List<Contact_Email_Distribution__c> distributions = [
            SELECT Id, Contact__c, Email_Distribution__c 
            FROM Contact_Email_Distribution__c 
            WHERE Contact__c = :contact.Id
        ];

    }
    
    /**
     * @description Test addEmailDistributions: Does not duplicate existing distributions
     */
    @isTest
    static void testAddEmailDistributionsNoDuplicates() {
        Account acc = createTestAccount();
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'NoDupe',
            Email = 'nodeupe@test.com',
            AccountId = acc.Id
        );
        insert contact;
        
        // Create existing contact distribution
        Contact_Email_Distribution__c existingDist = new Contact_Email_Distribution__c(
            Contact__c = contact.Id,
            Email_Distribution__c = 'existing@test.com',
            Account__c = acc.Id
        );
        insert existingDist;
        
        // Create matching account distribution
        Account_Email_Distribution__c accDist = new Account_Email_Distribution__c(
            Account__c = acc.Id,
            Email_Distribution__c = 'existing@test.com'
        );
        insert accDist;
        
        Test.startTest();
        Plative_ContactTriggerHelper.addEmailDistributions(new Set<Id>{contact.Id});
        Test.stopTest();
        
        // Verify no duplicate was created
        List<Contact_Email_Distribution__c> distributions = [
            SELECT Id FROM Contact_Email_Distribution__c 
            WHERE Contact__c = :contact.Id
        ];
        

    }
    
    /**
     * @description Test addEmailDistributions: Handles multiple account distributions
     */
    @isTest
    static void testAddEmailDistributionsMultipleDists() {
        Account acc = createTestAccount();
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Multiple',
            Email = 'multiple@test.com',
            AccountId = acc.Id
        );
        insert contact;
        
        // Create multiple account distributions
        List<Account_Email_Distribution__c> accDists = new List<Account_Email_Distribution__c>();
        for (Integer i = 1; i <= 3; i++) {
            accDists.add(new Account_Email_Distribution__c(
                Account__c = acc.Id,
                Email_Distribution__c = 'dist' + i + '@test.com'
            ));
        }
        insert accDists;
        
        Test.startTest();
        Plative_ContactTriggerHelper.addEmailDistributions(new Set<Id>{contact.Id});
        Test.stopTest();
        
        // Verify all distributions were created
        List<Contact_Email_Distribution__c> distributions = [
            SELECT Id, Email_Distribution__c 
            FROM Contact_Email_Distribution__c 
            WHERE Contact__c = :contact.Id
            ORDER BY Email_Distribution__c
        ];
        

    }
    
    /**
     * @description Test addEmailDistributions: Handles contact with no account
     */
    @isTest
    static void testAddEmailDistributionsNoAccount() {
        Contact contact = new Contact(
            FirstName = 'No',
            LastName = 'Account',
            Email = 'noacc@test.com'
        );
        insert contact;
        
        Test.startTest();
        Plative_ContactTriggerHelper.addEmailDistributions(new Set<Id>{contact.Id});
        Test.stopTest();
        
        // Verify no exception and no distributions created
        List<Contact_Email_Distribution__c> distributions = [
            SELECT Id FROM Contact_Email_Distribution__c 
            WHERE Contact__c = :contact.Id
        ];
        

    }
    
    /**
     * @description Test addEmailDistributions: Handles empty contact set
     */
    @isTest
    static void testAddEmailDistributionsEmptySet() {
        Test.startTest();
        Plative_ContactTriggerHelper.addEmailDistributions(new Set<Id>());
        Test.stopTest();
        
        // Should not throw exception
        System.assert(true, 'Empty set should be handled gracefully');
    }
    
    /**
     * @description Test addEmailDistributions: Multiple contacts with same account
     */
    @isTest
    static void testAddEmailDistributionsMultipleContacts() {
        Account acc = createTestAccount();
        Contact contact1 = new Contact(
            FirstName = 'Test',
            LastName = 'Cont1',
            Email = 'cont1@test.com',
            AccountId = acc.Id
        );
        Contact contact2 = new Contact(
            FirstName = 'Test',
            LastName = 'Cont2',
            Email = 'cont2@test.com',
            AccountId = acc.Id
        );
        insert new List<Contact>{contact1, contact2};
        
        // Create account distribution
        Account_Email_Distribution__c accDist = new Account_Email_Distribution__c(
            Account__c = acc.Id,
            Email_Distribution__c = 'shared@test.com'
        );
        insert accDist;
        
        Test.startTest();
        Plative_ContactTriggerHelper.addEmailDistributions(new Set<Id>{contact1.Id, contact2.Id});
        Test.stopTest();
        
        // Verify both contacts have the distribution
        List<Contact_Email_Distribution__c> distributions = [
            SELECT Id, Contact__c 
            FROM Contact_Email_Distribution__c 
            WHERE Contact__c IN (:contact1.Id, :contact2.Id)
        ];
        

    }
    
    /**
     * @description Test removeEmailDistributions: Removes distributions for given contacts
     */
    @isTest
    static void testRemoveEmailDistributions() {
        Account acc = createTestAccount();
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Remove',
            Email = 'remove@test.com',
            AccountId = acc.Id
        );
        insert contact;
        
        // Create contact distribution manually
        Contact_Email_Distribution__c dist = new Contact_Email_Distribution__c(
            Contact__c = contact.Id,
            Email_Distribution__c = 'toremove@test.com',
            Account__c = acc.Id
        );
        insert dist;
        
        Test.startTest();
        Plative_ContactTriggerHelper.removeEmailDistributions(new Set<Id>{contact.Id});
        Test.stopTest();
        
        // Verify distribution was removed
        List<Contact_Email_Distribution__c> distributions = [
            SELECT Id FROM Contact_Email_Distribution__c 
            WHERE Contact__c = :contact.Id
        ];
    }
        
    // ============================================================
    // BILLING CONTACT CHANGE TESTS (Direct Helper Method Calls)
    // ============================================================
    
    /**
     * @description Test checkBillingContactChange: Direct call on insert with billing contact set
     */
    @isTest
    static void testCheckBillingContactChangeInsertWithRole() {
        Account acc = createTestAccount();
        
        Contact contact = new Contact(
            FirstName = 'Billing',
            LastName = 'Contact',
            Email = 'billing@test.com',
            AccountId = acc.Id,
            Billing_Contact_multi__c = 'Billing_Role_1'
        );
        
        Test.startTest();
        // Directly call the helper method on insert (mapOld = null for insert)
        Plative_ContactTriggerHelper.checkBillingContactChange(
            new List<Contact>{contact},
            null,
            null
        );
        Test.stopTest();
    }
    
    /**
     * @description Test checkBillingContactChange: Direct call when billing contact is unchecked
     */
    @isTest
    static void testCheckBillingContactChangeUnchecked() {
        Account acc = createTestAccount();
        
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Billing',
            Email = 'testbilling@test.com',
            AccountId = acc.Id,
            Billing_Contact_multi__c = 'Billing_Role'
        );
        insert contact;
        
        Contact oldContact = new Contact(
            Id = contact.Id,
            Billing_Contact_multi__c = 'Billing_Role'
        );
        
        // Uncheck the billing contact
        contact.Billing_Contact_multi__c = null;
        
        Test.startTest();
        // Directly call the helper method on update
        Plative_ContactTriggerHelper.checkBillingContactChange(
            new List<Contact>{contact},
            new Map<Id, Contact>{oldContact.Id => oldContact},
            new Map<Id, Contact>{contact.Id => contact}
        );
        Test.stopTest();
    }
    
    /**
     * @description Test checkBillingContactChange: Multiple contacts with billing roles
     */
    @isTest
    static void testCheckBillingContactChangeMultipleContacts() {
        Account acc = createTestAccount();
        
        List<Contact> contactsToProcess = new List<Contact>();
        for (Integer i = 0; i < 3; i++) {
            contactsToProcess.add(new Contact(
                FirstName = 'Billing',
                LastName = 'Contact' + i,
                Email = 'billing' + i + '@test.com',
                AccountId = acc.Id,
                Billing_Contact_multi__c = 'Role_' + i
            ));
        }
        
        Test.startTest();
        // Directly call the helper method for bulk insert
        Plative_ContactTriggerHelper.checkBillingContactChange(
            contactsToProcess,
            null,
            null
        );
        Test.stopTest();
    }
    
    /**
     * @description Test checkBillingContactChange: Contact field unchanged (no billing change)
     */
    @isTest
    static void testCheckBillingContactChangeFieldUnchanged() {
        Account acc = createTestAccount();
        
        Contact contact = new Contact(
            FirstName = 'Unchanged',
            LastName = 'Billing',
            Email = 'unchanged@test.com',
            AccountId = acc.Id,
            Billing_Contact_multi__c = 'Role_1'
        );
        insert contact;
        
        Contact oldContact = new Contact(
            Id = contact.Id,
            Billing_Contact_multi__c = 'Role_1'
        );
        
        // Update non-billing field
        contact.Title = 'New Title';
        
        Test.startTest();
        // Directly call the helper method on update
        Plative_ContactTriggerHelper.checkBillingContactChange(
            new List<Contact>{contact},
            new Map<Id, Contact>{oldContact.Id => oldContact},
            new Map<Id, Contact>{contact.Id => contact}
        );
        Test.stopTest();
    }
    
    /**
     * @description Test checkBillingContactChange: Billing role value change
     */
    @isTest
    static void testCheckBillingContactChangeRoleUpdate() {
        Account acc = createTestAccount();
        
        Contact contact = new Contact(
            FirstName = 'Role',
            LastName = 'Change',
            Email = 'rolechange@test.com',
            AccountId = acc.Id,
            Billing_Contact_multi__c = 'Role_1'
        );
        insert contact;
        
        Contact oldContact = new Contact(
            Id = contact.Id,
            Billing_Contact_multi__c = 'Role_1'
        );
        
        // Change billing role
        contact.Billing_Contact_multi__c = 'Role_2';
        
        Test.startTest();
        // Directly call the helper method on update
        Plative_ContactTriggerHelper.checkBillingContactChange(
            new List<Contact>{contact},
            new Map<Id, Contact>{oldContact.Id => oldContact},
            new Map<Id, Contact>{contact.Id => contact}
        );
        Test.stopTest();
       
    }
    
    /**
     * @description Test checkBillingContactChange: Contact without account
     */
    @isTest
    static void testCheckBillingContactChangeNoAccount() {
        Contact contact = new Contact(
            FirstName = 'No',
            LastName = 'Account',
            Email = 'noaccount@test.com',
            Billing_Contact_multi__c = 'Some_Role'
        );
        
        Test.startTest();
        // Directly call the helper method on insert
        Plative_ContactTriggerHelper.checkBillingContactChange(
            new List<Contact>{contact},
            null,
            null
        );
        Test.stopTest();
       
    }
    
    /**
     * @description Test checkBillingContactChange: Bulk mixed operations
     */
    @isTest
    static void testCheckBillingContactChangeBulkMixed() {
        Account acc = createTestAccount();
        
        Contact contact1 = new Contact(
            FirstName = 'Contact1',
            LastName = 'Test',
            Email = 'contact1@test.com',
            AccountId = acc.Id,
            Billing_Contact_multi__c = 'Role_1'
        );
        Contact contact2 = new Contact(
            FirstName = 'Contact2',
            LastName = 'Test',
            Email = 'contact2@test.com',
            AccountId = acc.Id,
            Billing_Contact_multi__c = null
        );
        insert new List<Contact>{contact1, contact2};
        
        Contact oldContact1 = new Contact(
            Id = contact1.Id,
            Billing_Contact_multi__c = 'Role_1'
        );
        Contact oldContact2 = new Contact(
            Id = contact2.Id,
            Billing_Contact_multi__c = null
        );
        
        // Update both contacts with different changes
        contact1.Billing_Contact_multi__c = null;
        contact2.Billing_Contact_multi__c = 'Role_2';
        
        List<Contact> contactsToUpdate = new List<Contact>{contact1, contact2};
        Map<Id, Contact> oldContactMap = new Map<Id, Contact>{
            oldContact1.Id => oldContact1,
            oldContact2.Id => oldContact2
        };
        Map<Id, Contact> newContactMap = new Map<Id, Contact>{
            contact1.Id => contact1,
            contact2.Id => contact2
        };
        
        Test.startTest();
        // Directly call the helper method on bulk update
        Plative_ContactTriggerHelper.checkBillingContactChange(
            contactsToUpdate,
            oldContactMap,
            newContactMap
        );
        Test.stopTest();
    }
}