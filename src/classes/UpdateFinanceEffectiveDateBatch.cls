public class UpdateFinanceEffectiveDateBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Opportunity.Closedate, Start_Date__c, Finance_Effective_Date__c FROM OpportunityLineItem Where Opportunity.StageName IN (\'Closed Won\', \'Closed Lost\') AND Finance_Effective_Date__c = null';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<OpportunityLineItem> scope){
        try {
            List<OpportunityLineItem> oppLineIems = new List<OpportunityLineItem>();
            for (OpportunityLineItem oli : scope) {
                if (oli.Start_Date__c == null || (oli.Start_Date__c != null && oli.Opportunity.Closedate > oli.Start_Date__c)) oli.Finance_Effective_Date__c = oli.Opportunity.Closedate;
                else oli.Finance_Effective_Date__c = oli.Start_Date__c;
                oppLineIems.add(oli);
            }
            if(!oppLineIems.isEmpty()){
                update oppLineIems;
            }
        } catch(Exception e) {
            System.debug('Exception->'+e.getMessage());
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
}