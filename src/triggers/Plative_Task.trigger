/**
* Company     : Plative
* Description : Trigger on Tasks
* [30.Mar.2020] Anisa Shaikh - Code Creation 
*/
trigger Plative_Task on Task (after insert, after update, before insert)  { 

    //Get global settings to check if trigger is turned ON/OFF
    Trigger_Control_Setting__c setting = Trigger_Control_Setting__c.getOrgDefaults();

    if(setting.Task__c && Trigger.isInsert && Trigger.isAfter){
		System.enqueueJob(new Plative_ActivitySecurityUtil(trigger.newMap,'Task'));
    }
    //If update and if owner is changed
    if(setting.Task__c && Trigger.isUpdate){
        Map<Id, Task> mapAffectedTasks = new Map<Id, Task>();
        //check if owners are updated
        for(Task tsk : Trigger.new){
            if(tsk.OwnerId != Trigger.oldMap.get(tsk.Id).OwnerId){
                mapAffectedTasks.put(tsk.Id, tsk);
            }
        }
        if(!mapAffectedTasks.isEmpty()){
			System.enqueueJob(new Plative_ActivitySecurityUtil(mapAffectedTasks,'Task'));
        }
    }
    if(Trigger.isInsert && Trigger.isBefore) {
        Map<Id, User> ownerMap = new Map<Id, User>{};
        for(Task tsk: Trigger.new) {        
            ownerMap.put(tsk.OwnerId, null);        
        }
        ownerMap.putAll([SELECT Id, UserRole.Name FROM User WHERE Id IN :ownerMap.keySet()]);
        for(Task tsk : Trigger.new) {
            User user = ownerMap.get(tsk.OwnerId);
            if(tsk.Minutes_Spent__c == null && tsk.type == 'Outgoing Email' && (user.UserRole.Name == 'REA' || user.UserRole.Name == 'Research' || user.UserRole.Name == 'EU REA')){
                tsk.Minutes_Spent__c = 15;
                tsk.Analyst_Count_Data__c = 1;
            } 
        }
    }
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter) {
        TaskTriggerHandler.afterAction(Trigger.new, Trigger.oldMap);
    }
}