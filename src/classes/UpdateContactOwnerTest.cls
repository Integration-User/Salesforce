@isTest
public class UpdateContactOwnerTest {
    @testSetup static void methodName() {
        
        insertUserWithRole();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Account_Assignment').getRecordTypeId();
        
        Account accnt = new Account();
        accnt.Name = 'Test Account';
        accnt.Account_Status__c = 'Active';        
        insert accnt;
        
        Contact cont = new Contact();
        cont.AccountId = accnt.Id;
        cont.FirstName = 'FName';
        cont.LastName = 'LName';
        cont.Email = 'test@email.com';
        cont.Phone = '9876543210'; 
        cont.Contact_Status__c = 'Active';
        insert cont;
        
        Case cse = new Case();
        cse.recordTypeId = recordTypeId;
        cse.AccountId = accnt.id;
        cse.Status = 'New';
        cse.Origin = 'Email';
        insert cse;

    }
    @istest Static void updateCaseOwner() {
        
        Test.startTest();
		User u = [Select Id from User Where Username = 'testUseracc.bulkcaseowner@user.com'];
        Case cse = [Select Id, Account_manager__c from Case Limit 1];
        cse.Account_Manager__c = u.Id;
        update cse;

        Test.stopTest();
    }
    @future
    public static void insertUserWithRole() {
        UserRole r = [Select Id FROM UserRole WHERE DeveloperName = 'CAM'];
        //insert r;
        Profile p2 = [SELECT Id FROM Profile WHERE Name='Standard User'];
        user userRecord1 = new user();
        userRecord1.LastName ='CaseManagerOwner' ;
        userRecord1.Username ='testUseracc.bulkcaseowner@user.com' ;
        userRecord1.Email = 'vendor.sfdc15.bulkcaseowner@user.com';
        userRecord1.Alias = 'tsusera';
        userRecord1.TimeZoneSidKey = 'America/Los_Angeles';
        userRecord1.LocaleSidKey = 'en_US';
        userRecord1.EmailEncodingKey = 'UTF-8';
        userRecord1.LanguageLocaleKey = 'en_US';
        userRecord1.ProfileId = p2.Id;
        userRecord1.UserRoleId = r.Id;
        userRecord1.Team__c = 'Enterprise';
        insert userRecord1;
    }
}