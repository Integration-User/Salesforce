/**
* Company     : Plative
* Description : Trigger for Opportunity product object
* History     :
* [14.May.2020] Anisa - Code Creation
*/
trigger Plative_OLITrigger on OpportunityLineItem (before insert, after insert, before delete, before update)  { 

	if(trigger.isInsert){
		if(trigger.isbefore)
			Plative_OLITriggerHandler.beforeInsert(Trigger.new);
		else if(trigger.isafter)
			Plative_OLITriggerHandler.afterInsert(Trigger.newMap);
	}
	if(trigger.isUpdate){
		if(trigger.isbefore)
			Plative_OLITriggerHandler.beforeUpdate(Trigger.new);
	}
	if(trigger.isdelete)
		Plative_OLITriggerHandler.beforeDelete(Trigger.oldMap);

}