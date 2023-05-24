/**
* Company     : Plative
* Description : Trigger on Project record
* History     :
* [05.Mar.2020] Anisa Shaikh - Code Creation
*/
trigger Plative_Project on Project__c (after update, before update)  { 

	Trigger_Control_Setting__c setting = Trigger_Control_Setting__c.getOrgDefaults();
    if (setting.Project__c && trigger.isBefore && Trigger.isUpdate) {
        Plative_SFToNSSyncUtility.updateSyncToNSField(trigger.oldMap, 
									trigger.newMap, 'Project__c','Update');
    }
    if (setting.Project__c && trigger.isAfter && Trigger.isUpdate) {
		Plative_ProjectTriggerHandler.afterUpdate(trigger.newMap, trigger.oldMap);
    }
}