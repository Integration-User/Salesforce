public class UpdateAnalystHoursForAccountBatch implements Database.Batchable<SObject>, Schedulable{
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select Id, Analyst_Hours__c, (Select Id, Total_Analyst_Hours__C From Tasks where createdDate = LAST_N_DAYS:365 AND Status = \'Completed\' AND Total_Analyst_Hours__C > 0), (Select Id, Total_Analyst_Hours__C  From Events where createdDate = LAST_N_DAYS:365 AND Status__c = \'Completed\' AND Total_Analyst_Hours__C > 0) From Account  WHERE LastModifiedDate = LAST_N_DAYS:365';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> listAccount) {
        List<Account> updatedAccounts = new List<Account>();
        for(Account acc : listAccount) {
            Double finalAnalystAmount = 0;
            for (Task tsk : acc.Tasks) {
                finalAnalystAmount += tsk.Total_Analyst_Hours__C;
            }
            for (Event event : acc.Events) {
                finalAnalystAmount += event.Total_Analyst_Hours__C;
            }
            if (acc.Analyst_Hours__c != finalAnalystAmount) {
                acc.Analyst_Hours__c = finalAnalystAmount;
                updatedAccounts.add(acc);
            }
        }
        System.debug('updatedAccounts->'+updatedAccounts.size());
        database.update(updatedAccounts, false);
    }
    
    
    public void finish(Database.BatchableContext BC) {
    }
    public void execute(SchedulableContext SC) {
      Database.executeBatch(new UpdateAnalystHoursForAccountBatch(), 1000);
   }
}