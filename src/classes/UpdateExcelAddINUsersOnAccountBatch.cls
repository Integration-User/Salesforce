public class UpdateExcelAddINUsersOnAccountBatch implements Database.Batchable<sObject>, Schedulable {
    public Iterable<Account> start(Database.BatchableContext BC) {
        List<Account> accList = new List<Account>();
        List<String> accIds = new List<String>();
        for(AggregateResult result : [Select Count(Id), AccountId from Contact where AccountId != null AND Excel_Last_Use_Date__c != null GROUP BY AccountId]) {
        	accIds.add(String.valueof(result.get('AccountId')));
        }
        if(!accIds.isEmpty()) accList = [Select Id, Excel_Add_In_Users__c, (Select Id from Contacts where Excel_Last_Use_Date__c != null) from Account where Id IN: accIds];
        return accList;
    }
    public void execute(Database.BatchableContext BC, List<Account> scope){
        try {
            List<Account> updatedAccounts = new List<Account>();
            for (Account acc : scope) {
                if(acc.Contacts != null && acc.Excel_Add_In_Users__c != acc.Contacts.size()) {
                    updatedAccounts.add(new Account(Id = acc.Id, Excel_Add_In_Users__c = acc.Contacts.size()));
                }
            }
            System.debug('updatedAccounts->'+updatedAccounts);
            if(!updatedAccounts.isEmpty() && updatedAccounts.size() > 0) update updatedAccounts;

        } catch(Exception e) {
            System.debug('Exception->'+e.getMessage());
        }
    }
    public void finish(Database.BatchableContext BC){
    }
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new UpdateExcelAddINUsersOnAccountBatch(), 5);
    }
    
    
}