/**
* Company     : Plative
* Description : Trigger for Opportunity product object
* History     :
* [14.May.2020] Anisa - Code Creation
*/
trigger Plative_OLITrigger on OpportunityLineItem (before insert, after insert, before delete, before update)  { 
    Trigger_Execution_Update__mdt triggerSkipUpdate = Trigger_Execution_Update__mdt.getInstance('User_'+UserInfo.getuserId());
    if(triggerSkipUpdate != null && triggerSkipUpdate.Skip_Trigger__c && triggerSkipUpdate.Objects_Name__c.contains('OpportunityLineItem')) return;
    
	if(trigger.isInsert){
		if(trigger.isbefore)
			Plative_OLITriggerHandler.beforeInsert(Trigger.new);
		else if(trigger.isafter)
			Plative_OLITriggerHandler.afterInsert(Trigger.newMap);
	}
	if(trigger.isUpdate){
		if(trigger.isbefore)
			Plative_OLITriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
	}
	if(trigger.isdelete)
		Plative_OLITriggerHandler.beforeDelete(Trigger.oldMap);

}