/**
* Description : Trigger for User object
* History     :
* [22.Jan.2020] Plative - Code Creation
*/
trigger Plative_User on User (after update)  { 

    Trigger_Control_Setting__c setting = Trigger_Control_Setting__c.getOrgDefaults();

    if (setting.User__c && Trigger.isAfter && Trigger.isUpdate) {
        Plative_UserTriggerHandler.afterUpdate(Trigger.newMap, Trigger.oldMap);
    }
}