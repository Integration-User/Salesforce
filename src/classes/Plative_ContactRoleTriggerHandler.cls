/**
* Company     : Plative
* Description : Handler for Opportunity Contact Role trigger
* History     : 
* [17.Jun.2020] Kunal - Code Creation 
*/
public class Plative_ContactRoleTriggerHandler {
    
    public static void afterInsert(List<OpportunityContactRole> triggerNew){
        Plative_ContactRoleTriggerHelper.addCustomInfluence(triggerNew);
    }
    
    public static void afterDelete(List<OpportunityContactRole> triggerOld){
        Plative_ContactRoleTriggerHelper.reCalculateCustomInfluence(triggerOld);
    }
    
}