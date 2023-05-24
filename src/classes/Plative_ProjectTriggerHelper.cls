/**
* Company     : Plative
* Description : All utility methods for Project trigger
* [20.Mar.2020] Anisa - Code Creation 
**/
public class Plative_ProjectTriggerHelper  {
	

	/**
	* Description : If sync to netsuite checked then make webservice 
	*				callout to update customer id from netsuite
	**/	

	public static Boolean checkIfToBeSyncedToNS(Map<Id, Project__c> mapNewProj,
											    Map<Id, Project__c> mapOldProj){
		
		List<Project__c> lstProjectsToSync = new List<Project__c>();
		for(Project__c proj: mapNewProj.values()){
			if(proj.Sync_To_Netsuite__c && 
			   proj.Sync_To_Netsuite__c != mapOldProj.get(proj.Id).Sync_To_Netsuite__c){
			  lstProjectsToSync.add(proj);
			}
		}
		System.debug('lstProjectsToSync '+lstProjectsToSync);

		if(!Test.isRunningTest() && !lstProjectsToSync.isEmpty()){
			System.enqueueJob(new Plative_UpdCustOnProjQueueable(lstProjectsToSync));
		}
		return true;
	}
}