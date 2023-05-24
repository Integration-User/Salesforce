/**
* Company     : Plative
* Description : Trigger on Account record
* History     :
* [05.Mar.2020] Anisa Shaikh - Code Creation
*/
trigger Plative_Account on Account (before insert, before update, after update)  { 
	
	Trigger_Control_Setting__c setting = Trigger_Control_Setting__c.getOrgDefaults();
    if (setting.Account__c && trigger.isBefore && Trigger.isUpdate) {
			Plative_AccountTriggerHandler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
    }
	else if(setting.Account__c && trigger.isAfter && Trigger.isUpdate) {
		Plative_AccountTriggerHandler.afterUpdate(Trigger.oldMap, Trigger.newMap);
	}
	else if(setting.Account__c && Trigger.isBefore && Trigger.isInsert){
		Plative_AccountTriggerHandler.beforeInsert(Trigger.new);
	}
}