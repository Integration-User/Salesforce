/**
* Company     : Plative
* Description : Schedulable class to sync projects to NS
* History     :
* [05.Mar.2020] Anisa Shaikh - Code Creation
*/
global class Plative_ProjectSyncSchedulable implements Schedulable {
	/**
	 * @description Executes the scheduled Apex job. 
	 * @param sc contains the job ID
	 */ 
	global void execute(SchedulableContext sc) {
		
		Plative_SFToNSSyncBatch batch = new Plative_SFToNSSyncBatch('Project__c');
		Database.executeBatch(batch);

	}
}