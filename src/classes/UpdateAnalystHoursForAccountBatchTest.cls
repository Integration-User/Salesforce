@isTest
public class UpdateAnalystHoursForAccountBatchTest {
    @testSetup
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
        cont.GSA_Analyst__c = true;
        insert cont;
        
        Event event = new Event();
        event.subject = 'appcues appcues test event';
        event.Description = 'test description';
        event.StartDateTime = system.now();
        event.EndDateTime = system.now();
        event.WhoId = cont.id;
        event.whatId = accnt.Id;
        insert event;
        
        Task tsk = new Task();
        tsk.subject = 'appcues appcues test event';
        tsk.Description = 'test description';
        tsk.WhoId = cont.id;
        tsk.whatId = accnt.Id;
        insert tsk;
        
    }
    
    @isTest
    static void convertAppcuesEvents(){
        Test.startTest();
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute()); 
        String ss = String.valueOf(Datetime.now().second());
        
        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        
        UpdateAnalystHoursForAccountBatch s = new UpdateAnalystHoursForAccountBatch (); 
        System.schedule('Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, s);
        Test.stopTest();
    }
}