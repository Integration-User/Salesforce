/**
* Company     : Plative
* Description : Trigger for Opportunity object
* History     :
* [26.Feb.2020] Kunal - Code Creation
*/

trigger Plative_OpportunityTrigger on Opportunity (before insert, after insert, before update, after update) {
    
    Trigger_Control_Setting__c setting = Trigger_Control_Setting__c.getOrgDefaults();
    Trigger_Execution_Update__mdt triggerSkipUpdate = Trigger_Execution_Update__mdt.getInstance('User_'+UserInfo.getuserId());
    if(triggerSkipUpdate != null && triggerSkipUpdate.Skip_Trigger__c && triggerSkipUpdate.Objects_Name__c.contains('Opportunity')) return;
    
    if (setting.Opportunity__c && Trigger.isBefore && Trigger.isUpdate) {
        Plative_OpportunityTriggerHandler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
    }
    if (setting.Opportunity__c && Trigger.isBefore && Trigger.isInsert) {
        Plative_OpportunityTriggerHandler.beforeInsert(Trigger.new);
    }
    if (setting.Opportunity__c && Trigger.isAfter && Trigger.isInsert) {
        Plative_OpportunityTriggerHandler.afterInsert(Trigger.new);
    }
    if (setting.Opportunity__c && Trigger.isAfter && Trigger.isUpdate) {
        Plative_OpportunityTriggerHandler.afterUpdate(Trigger.newMap, Trigger.oldMap, Trigger.new);
    }
}