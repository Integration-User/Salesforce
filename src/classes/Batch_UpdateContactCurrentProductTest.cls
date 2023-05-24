@isTest
public class Batch_UpdateContactCurrentProductTest {
    
    @testSetup
    static void testSetup(){
        Account accnt = new Account();
        accnt.Name = 'Test Accnt';
        accnt.Secondary_Name__c = 'Test Accnt Secondary';
        accnt.Phone = '123123123';
        accnt.Website = 'www.google.com';
        accnt.DataLink_Access__c = true;
        accnt.Is_Contact_Update__c = true;
        accnt.Current_Products__c = 'US Portfolio Tools';
        insert accnt;
        
        Contact cont = new Contact();
        cont.AccountId = accnt.Id;
        cont.FirstName = 'FName';
        cont.LastName = 'LName';
        cont.Email = 'test@email.com';
        cont.Phone = '123123123';
        cont.Contact_Status__c = 'Active';
        cont.Products_Include__c = ' News Only';
        insert cont;     
    }
    
    @isTest
    static void getLastLoginDate(){
        Test.StartTest();
        Batch_UpdateContactCurrentProduct sh1 = new Batch_UpdateContactCurrentProduct();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Update Contacts', sch, sh1); 
        Test.stopTest(); 
        
    }
    @isTest
    static void UpdateAccountProductCategoryBatchtest(){
        Test.StartTest();
        Database.executeBatch(new UpdateAccountProductCategoryBatch(),200); 
        Test.stopTest(); 
        
    }
}