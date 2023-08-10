/**
* Company     : Plative
* Description : Trigger on Contact record
* History     :
* [05.Mar.2020] Anisa Shaikh - Code Creation
*/
trigger Plative_ContactTrigger on Contact (before insert, before update, after update, after insert) {
	Trigger_Control_Setting__c setting = Trigger_Control_Setting__c.getOrgDefaults();
    if (setting.Contact__c && trigger.isBefore && Trigger.isUpdate) {
        Plative_ContactTriggerHandler.beforeUpdate(trigger.oldMap, trigger.newMap);
    }
    if (setting.Contact__c && trigger.isAfter && Trigger.isUpdate) {
        Plative_ContactTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
    }
    
    if (setting.Contact__c && trigger.isAfter && Trigger.isInsert) {
        Plative_ContactTriggerHandler.afterInsert(trigger.new);
    }
    if(trigger.isBefore) {
        Plative_ContactTriggerHandler.beforeActions(trigger.new);
    }
}