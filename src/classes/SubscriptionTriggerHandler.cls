public without sharing class SubscriptionTriggerHandler {
    public static void handleTrigger(List<Subscription__c> newList, List<Subscription__c> oldList ) {
        Set<Id> accountIds = new Set<Id>();
        if(Trigger.isUpdate || Trigger.isUndelete) {
            for(Subscription__c sub : newList) {
                if(sub.Account__c != null) {
                    accountIds.add(sub.Account__c);
                }
            }
        }
        if(Trigger.isDelete) {
            for(Subscription__c sub : oldList) {
                if(sub.Account__c != null) {
                    accountIds.add(sub.Account__c);
                }
            }
        }
        if(!accountIds.isEmpty()) {
            updateActiveSubscriptionCount(accountIds);
        }
    }

    public static void updateActiveSubscriptionCount(Set<Id> accountIds) {
        // Check CRUD permissions
        if (!Schema.sObjectType.Subscription__c.isAccessible() || !Schema.sObjectType.Account.isUpdateable()) {
            System.debug('Insufficient permissions to access Subscription__c or update Account.');
            return;
        }
        Map<Id, Integer> accIdToCount = new Map<Id, Integer>();
        for(AggregateResult ar : [ SELECT Account__c accId, COUNT(Id) cnt FROM Subscription__c 
                                    WHERE Account__c IN :accountIds AND Status__c = 'Active'
                                    AND End_Date__c >= :Date.today() GROUP BY Account__c]) {
            accIdToCount.put((Id)ar.get('accId'), (Integer)ar.get('cnt'));
        }
        List<Account> accsToUpdate = new List<Account>();
        for(Id accId : accountIds) {
            Integer count = accIdToCount.containsKey(accId) ? accIdToCount.get(accId) : 0;
            accsToUpdate.add(new Account(
                Id = accId,
                Active_Subscription_Count__c = count
            ));
        }
        if(!accsToUpdate.isEmpty()) {
            Plative_AccountTriggerHandler.isAccountTriggerSkip = true;
            update accsToUpdate;
        }
    }
}