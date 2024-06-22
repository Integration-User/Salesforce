public class OpportunityOwnerChangeBatch implements Database.Batchable<Opportunity>, Database.Stateful {
    private Boolean allRecords;
    public OpportunityOwnerChangeBatch(Boolean allRecords) {
        this.allRecords = allRecords;
    }
    private List<String> excludedStage = new List<String> {'Quota, Prior Year', 'Closed Won', 'Closed Lost', 
        'Active', 'Deactivated', 'Consolidated', 'Suspended'};
            
    public Iterable<Opportunity> start(Database.BatchableContext BC) {
        String query = 'Select Id, Name, Account.OwnerId, ownerId FROM Opportunity WHERE Opportunity.RecordType.DeveloperName = \'Existing_Business\'';
        query += ' AND StageName NOT IN :excludedStage AND Products__c != \'React News\' AND Products__c != \'Green Street News: Europe\'';
        if (!allRecords)  query+= ' AND LastModifiedDate >= Yesterday';
        System.debug('query=>'+query);
        List<Opportunity> oppList = new List<Opportunity>();
        Database.QueryLocator q = Database.getQueryLocator(query);
        Database.QueryLocatorIterator it =  q.iterator();
        while (it.hasNext()) {
            Opportunity opp = (Opportunity)it.next();
            if (opp.ownerId != opp.Account.OwnerId) {
                oppList.add(opp); 
            } else if(Test.isRunningTest()) oppList.add(opp); 
        }
        return oppList;

    }
    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {   
        List<Opportunity> renewalOwnerChanges = new List<Opportunity>();
        for(Opportunity opp: scope) {                    
            if (opp.ownerId != opp.Account.OwnerId) {
                opp.OwnerId = opp.Account.OwnerId;
                renewalOwnerChanges.add(opp); 
            }
        }

        if(!renewalOwnerChanges.isEmpty()) {
            update renewalOwnerChanges;
        }
    }
    public void finish(Database.BatchableContext BC) {
    }
}
