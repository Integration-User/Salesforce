@isTest
private class ContactEmailDistributionTriggerTest {
    @isTest
    static void testSetup(){  
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
        
        Contact_Email_Distribution__c ced = new Contact_Email_Distribution__c();
        ced.Account__c = accnt.Id;
        ced.Contact__c = cont.Id;
        ced.Email_Distribution__c = Label.TestClass_ProductName;
        insert ced;
    }
}