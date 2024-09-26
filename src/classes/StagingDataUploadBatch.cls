public class StagingDataUploadBatch implements Database.Batchable<sObject> {
    public final String targetObjectName;
    
    public StagingDataUploadBatch(String objectName){
        this.targetObjectName = objectName;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'Select Id, Record_Id__c, Status__c, Failure_Reason__c, Object_API_Name__c FROM Staging_Data_Upload__c WHERE Object_API_Name__c=\''+ this.targetObjectName 
            + '\' AND Status__c != \'Success\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Staging_Data_Upload__c> scope){
        Map<String, Staging_Data_Upload__c> stgMap = new Map<String, Staging_Data_Upload__c>();
        for(Staging_Data_Upload__c stg : scope) {
            stgMap.put(stg.Record_Id__c, stg);
        }
        if(!stgMap.isEMpty()) {
           List<Contact_Email_Distribution__c> updatedDistributions = new List<Contact_Email_Distribution__c>(); 
            for(Contact_Email_Distribution__c distribution : [SELECT Id, Opt_Out__c, Email_Distribution__c from Contact_Email_Distribution__c Where Contact__r.GSA_ID__c IN :stgMap.keySet()]) {
 				distribution.Opt_Out__c = true;
                updatedDistributions.add(distribution);
            }
            try {
                update updatedDistributions;
                scope[0].Status__c = 'Success';
                update scope;
            } catch(Exception e) {
                System.debug('Error - ' + e.getMessage());
                scope[0].Status__c = 'Failure';
                scope[0].Failure_Reason__c = e.getMessage();
                update scope;
            }
            
            
        }
        
    }
    
    public void finish(Database.BatchableContext bc){
    }
}