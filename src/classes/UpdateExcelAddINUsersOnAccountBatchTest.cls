@isTest
public class UpdateExcelAddINUsersOnAccountBatchTest {
    @testSetup
    static void testSetup(){ 
        
        Account accnt = new Account();
        accnt.Name = 'Test Account';
        accnt.Account_Status__c = 'Active';        
        insert accnt;
        
        List<Contact> conList = new List<Contact>();
        Contact cont = new Contact();
        cont.AccountId = accnt.Id;
        cont.FirstName = 'FName';
        cont.LastName = 'LName';
        cont.Email = 'test@email.com';
        cont.Phone = '9876543210';
        cont.Contact_Status__c = 'Active';  
        cont.GSA_Analyst__c = true;
        cont.Excel_Last_Use_Date__c  = Datetime.now();
        conList.add(cont);
        
        Contact cont1 = new Contact();
        cont1.AccountId = accnt.Id;
        cont1.FirstName = 'FName1';
        cont1.LastName = 'LName1';
        cont1.Email = 'test@email1.com';
        cont1.Phone = '9876543211';
        cont1.Contact_Status__c = 'Active';  
        cont1.GSA_Analyst__c = true;
        cont1.Excel_Last_Use_Date__c  = Datetime.now();
        conList.add(cont1);
        insert conList;
    }
    
    @isTest
    static void checkExcelAddInUsersTest(){
        Test.startTest();
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute()); 
        String ss = String.valueOf(Datetime.now().second());
        
        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        
        UpdateExcelAddINUsersOnAccountBatch s = new UpdateExcelAddINUsersOnAccountBatch (); 
        System.schedule('Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, s);
        Test.stopTest();
    }
}