public class ActiveSubscriptionCountBatch implements Schedulable, Database.Batchable<AggregateResult> {
    public static final Integer SCOPE_SIZE = 20;

    // Use custom AggregateResultIterable to return aggregate results from start
    public Iterable<AggregateResult> start(Database.BatchableContext bc) {
        String soql = 'SELECT Account__c accId, COUNT(Id) cnt FROM Subscription__c '
            + 'WHERE Status__c = \'Active\' AND End_Date__c >= ' + String.valueOf(Date.today()) + ' AND Account__c != null '
            + 'GROUP BY Account__c';
        return new AggregateResultIterable(soql, SCOPE_SIZE);
    }

    public void execute(Database.BatchableContext bc, List<AggregateResult> scope) {
        Map<Id, Decimal> accIdToNewCount = new Map<Id, Decimal>();
        for (AggregateResult ar : scope) {
            Id accId = (Id)ar.get('accId');
            Decimal count = (Decimal)ar.get('cnt');
            accIdToNewCount.put(accId, count);
        }
        if (!accIdToNewCount.isEmpty()) {
            List<Account> accsToUpdate = prepareAccountsToUpdate(accIdToNewCount);
            performAccountUpdate(accsToUpdate);
        }
    }

    private List<Account> prepareAccountsToUpdate(Map<Id, Decimal> accIdToNewCount) {
        Map<Id, Account> accMap = new Map<Id, Account>([
            SELECT Id, Active_Subscription_Count__c FROM Account WHERE Id IN :accIdToNewCount.keySet()
        ]);
        List<Account> accsToUpdate = new List<Account>();
        for (Id accId : accIdToNewCount.keySet()) {
            Decimal newCount = accIdToNewCount.get(accId);
            Decimal oldCount = accMap.containsKey(accId) ? accMap.get(accId).Active_Subscription_Count__c : null;
            if (oldCount == null || oldCount != newCount) {
                accsToUpdate.add(new Account(
                    Id = accId,
                    Active_Subscription_Count__c = newCount
                ));
            }
        }
        return accsToUpdate;
    }

    private void performAccountUpdate(List<Account> accsToUpdate) {
        if (!accsToUpdate.isEmpty()) {
            try {
                if (Schema.sObjectType.Account.isUpdateable()) {
                    Plative_AccountTriggerHandler.isAccountTriggerSkip = true;
                    update accsToUpdate;
                } else {
                    System.debug('No update access to Account object. Skipping update.');
                }
            } catch(Exception e) {
                System.debug('Error updating Active_Subscription_Count__c: ' + e.getMessage());
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('ActiveSubscriptionCountBatch finished.');
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new ActiveSubscriptionCountBatch(), SCOPE_SIZE);
    }
}