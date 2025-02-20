/**
* @author Zoran Zunko
* @date 9/28/21
*
*/

trigger SubscriptionUserTrigger on Subscription_User__c (before delete, after undelete, after update) {
    TriggerDispatcher.Run(new SubscriptionUserTriggerHandler());
}