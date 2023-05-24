/**
* Company     : Plative
* Description : Handler for project trigger's dml events
* [20.Mar.2020] Anisa - Code Creation 
**/
public class Plative_ProjectTriggerHandler  {

    //Variable to handler recursion
    public static Boolean afterUpdateRun = false;
	public static Boolean beforeUpdateRun = false;

	/**
	* Description : after update DML
	**/	
	public static void afterUpdate(Map<Id, Project__c> mapNewProj,Map<Id, Project__c> mapOldProj){
		if (!Plative_ProjectTriggerHandler.afterUpdateRun) {
			Boolean isSuccess = Plative_ProjectTriggerHelper.checkIfToBeSyncedToNS(mapNewProj,mapOldProj);
			Plative_ProjectTriggerHandler.afterUpdateRun = true;
		}
	}
}