@isTest
public class UpdateCustomerSuccessRepBatchTest {

    @TestSetup
    static void makeData() {
        // Create test users
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User user1 = new User(
            FirstName = 'Test1',
            LastName = 'User1',
            Email = 'test1@example.com',
            Username = 'testuser1mg1@example.com',
            Alias = 'tuser1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        User user2 = new User(
            FirstName = 'Test2',
            LastName = 'User2',
            Email = 'test2@example.com',
            Username = 'testuser1mg2@example.com',
            Alias = 'tuser2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert new List<User>{user1, user2};

        // Create test accounts
        Account acc1 = new Account(Name = 'Test Account 1', Customer_Success_Rep__c = 'Test2 User2');
        Account acc2 = new Account(Name = 'Test Account 2', Customer_Success_Rep__c = 'Test1 User1');
        insert new List<Account>{acc1, acc2};

        // Create AccountTeamMembers
        AccountTeamMember atm1 = new AccountTeamMember(AccountId = acc1.Id, UserId = user1.Id, TeamMemberRole = 'Customer Success');
        AccountTeamMember atm2 = new AccountTeamMember(AccountId = acc2.Id, UserId = user1.Id, TeamMemberRole = 'Customer Success');
        insert new List<AccountTeamMember>{atm1, atm2};
    }

    @isTest
    static void testBatchExecution() {
        Account updatedAcc1 = [SELECT Id, Customer_Success_Rep_ID__c, Customer_Success_Rep__c FROM Account WHERE Name = 'Test Account 1'];
        Test.startTest();
        updatedAcc1.Customer_Success_Rep_ID__c = null;
        update updatedAcc1;
        UpdateCustomerSuccessRepBatch batch = new UpdateCustomerSuccessRepBatch();
        Database.executeBatch(batch, 10);
        Test.stopTest();

        // Actually, since users are inserted, their Ids are set.
        User user1 = [SELECT Id FROM User WHERE Username = 'testuser1mg1@example.com'];
        User user2 = [SELECT Id FROM User WHERE Username = 'testuser1mg2@example.com'];
        System.assertEquals('Test1 User1', updatedAcc1.Customer_Success_Rep__c);

        // Assert that acc2 was not updated (already user1)
        Account updatedAcc2 = [SELECT Id, Customer_Success_Rep_ID__c, Customer_Success_Rep__c FROM Account WHERE Name = 'Test Account 2'];
        System.assertEquals(user1.Id, updatedAcc2.Customer_Success_Rep_ID__c);
        System.assertEquals('Test1 User1', updatedAcc2.Customer_Success_Rep__c);
    }

    @isTest
    static void testSchedulable() {
        Test.startTest();
        UpdateCustomerSuccessRepBatch batch = new UpdateCustomerSuccessRepBatch();
        String jobId = System.schedule('Test UpdateCustomerSuccessRepBatch', '0 0 0 1 1 ?', batch);
        Test.stopTest();

        // Assert that the job was scheduled
        System.assertNotEquals(null, jobId);
    }
}