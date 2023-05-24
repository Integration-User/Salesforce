/**
* Company     : Plative
* Description : Trigger for Opportunity Contact Role
* History     : 
* [17.Jun.2020] Kunal - Code Creation 
*/
trigger Plative_ContactRoleTrigger on OpportunityContactRole (after insert, after delete) {
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            Plative_ContactRoleTriggerHandler.afterInsert(Trigger.new);
        }
        
        if(Trigger.isDelete){
            Plative_ContactRoleTriggerHandler.afterDelete(Trigger.old);
        }        
    }
    
}