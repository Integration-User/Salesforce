/**
 * Company     : GSD Company
 * Description : 
 * ****************************************************************************************
 * Schedulable class to delete old log records in the system
 * ****************************************************************************************
 * History     : 
 * [05.Aug.2019] Anisa Shaikh - Code Creation 
**/
global class GSD_PurgeLogsSchedulable implements Schedulable {
	/**
	 * @description Deleted older log records
	 * @param sc contains the job ID
	 */ 
	global void execute(SchedulableContext sc) {
		List<Log_Setting__mdt> logSettings;
		try{
			logSettings = [SELECT Maximum_log_age__c FROM  Log_Setting__mdt];
		}
		catch(Exception e){
			System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
		}

		Decimal logAge = 365;
		if(logSettings != null && !logSettings.isEmpty()){
			logAge = logSettings[0].Maximum_log_age__c;
		}
		try{
			String soql = 'SELECT Id FROM Integration_Log__c WHERE CreatedDate > LAST_N_DAYS:'+logAge;
			List<Integration_Log__c> lstLogs = Database.query(soql);
			if(lstLogs != null && !lstLogs.isEmpty()){
				delete lstLogs;
			}
		}
		catch(Exception e){
			System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
		}
	}
}