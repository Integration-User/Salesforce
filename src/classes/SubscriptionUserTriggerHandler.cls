/**
* @author Zoran Zunko
* @date 9/28/21
*
*/
public with sharing class SubscriptionUserTriggerHandler implements ITriggerHandler {
    // Allows unit tests (or another code) to disable this trigger.
    public static Boolean TriggerDisable = false;

    public Boolean isDisabled() {
        if (TriggerSettings__c.getOrgDefaults().SubscriptionUserTriggerDisabled__c == true) {
            System.debug(LoggingLevel.FINE,'SubscriptionUserTriggerHandler.isDisabled = ' + true);
            return true;
        } else {
            System.debug(LoggingLevel.FINE,'SubscriptionUserTriggerHandler.isDisabled = ' + TriggerDisable);
            return TriggerDisable;
        }
    }

    public void BeforeInsert(List<SObject> newItems) {
        System.debug(LoggingLevel.FINE,'SubscriptionUserTriggerHandler.BeforeInsert');
    }

    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        System.debug(LoggingLevel.FINE,'SubscriptionUserTriggerHandler.BeforeUpdate');
    }

    public void BeforeDelete(Map<Id, SObject> oldItems) {
        System.debug(LoggingLevel.FINE,'SubscriptionUserTriggerHandler.BeforeDelete');
        System.debug(LoggingLevel.FINE, 'BeforeDelete - oldItems.keySet(): ' + oldItems.keySet());
        List<Zephr_User_Account_Grant__c> userAccountGrants = [SELECT Id, Zephr_Account__r.Zephr_Id__c, Zephr_Account__r.Zephr_Tenant__c, Zephr_User__r.Zephr_Id__c, Zephr_User__r.Zephr_Tenant__c FROM Zephr_User_Account_Grant__c WHERE Subscription_User__c IN :oldItems.keySet()];
        System.debug(LoggingLevel.FINE, 'BeforeDelete - userAccountGrants.size(): ' + userAccountGrants.size());
        if(!userAccountGrants.isEmpty()) {
            zephr_QueueableDeleteUserAccountGrants deleteUserAccountGrants = new zephr_QueueableDeleteUserAccountGrants();
            deleteUserAccountGrants.userAccountGrants = userAccountGrants;
            System.enqueueJob(deleteUserAccountGrants);
        }
    }

    public void AfterInsert(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        System.debug(LoggingLevel.FINE,'SubscriptionUserTriggerHandler.AfterInsert');
    }

    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        System.debug(LoggingLevel.FINE,'SubscriptionUserTriggerHandler.AfterUpdate');
        System.debug(LoggingLevel.FINE, 'AfterUpdate - newItems.keySet(): ' + newItems.keySet());
        List<Id> subscriptionUserIdsToRemove = new List<Id>();
        for (Id subscriptionUserId : newItems.keySet()) {
            // We could check old vs new to see if the status was changed, but this means we always pick up any stray records on future updates
            // And this trigger means that to remove a Zephr User Account Grant we just need a flow to update the Subscriber Status
            if (newItems.get(subscriptionUserId).get('Subscriber_Status__c') == 'Inactive' && oldItems.get(subscriptionUserId).get('Subscriber_Status__c') != 'Inactive') {
                subscriptionUserIdsToRemove.add(subscriptionUserId);
            }
        }
        // Handle Zephr users - others won't have Zephr User Account Grant records.
        List<Zephr_User_Account_Grant__c> userAccountGrants = [SELECT Id, Zephr_Account__r.Zephr_Id__c, Zephr_Account__r.Zephr_Tenant__c, Zephr_User__r.Zephr_Id__c, Zephr_User__r.Zephr_Tenant__c FROM Zephr_User_Account_Grant__c WHERE Subscription_User__c IN :subscriptionUserIdsToRemove];
        System.debug(LoggingLevel.FINE, 'BeforeUpdate - userAccountGrants.size(): ' + userAccountGrants.size());
        if(!userAccountGrants.isEmpty()) {
            zephr_QueueableDeleteUserAccountGrants deleteUserAccountGrants = new zephr_QueueableDeleteUserAccountGrants();
            deleteUserAccountGrants.userAccountGrants = userAccountGrants;
            System.enqueueJob(deleteUserAccountGrants);
        }
        // Handle SRP users ... note that we upsert all subscription users that were updated
        // SubscriptionUserTriggerHandler.upsertSrpSubscriptionUsers(newItems.keySet());

    }

    public void AfterDelete(Map<Id, SObject> oldItems) {
        System.debug(LoggingLevel.FINE,'SubscriptionUserTriggerHandler.AfterDelete');
    }

    public void AfterUndelete(Map<Id, SObject> oldItems) {
        System.debug(LoggingLevel.FINE,'SubscriptionUserTriggerHandler.AfterUndelete');
        for (SObject sobj : oldItems.values()) {
            sobj.addError('Subscription User records can\'t be undeleted due to Zephr Integration!');
        }
    }

}