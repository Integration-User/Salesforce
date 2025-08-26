trigger SubscriptionNSTrigger on Subscription__c (after update, after delete, after undelete) {
    SubscriptionTriggerHandler.handleTrigger(Trigger.new, Trigger.old);
}