public class DeleteIntegrationLogsBatch implements Database.Batchable<sObject>, Schedulable {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        Integer successLogAge = (Integer) Log_Setting__mdt.getInstance('Purge_Logs').Maximum_log_age__c;
        Integer failureLogAge = (Integer) Log_Setting__mdt.getInstance('Purge_Failure_Logs').Maximum_log_age__c;

        String query = 'SELECT Id, CreatedDate FROM Integration_Log__c WHERE (Response_Code__c = \'200\' AND CreatedDate < LAST_N_DAYS:'+successLogAge+') ';
        query += 'OR (Response_Code__c != \'200\' AND CreatedDate < LAST_N_DAYS:'+failureLogAge+')';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        try {
            if(!scope.isEmpty()) delete scope;
        } catch(Exception e) {
            System.debug('Exception->'+e.getMessage());
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
    public void execute(SchedulableContext sc) {
		Database.executeBatch(new DeleteIntegrationLogsBatch(), 2000);
    }
}