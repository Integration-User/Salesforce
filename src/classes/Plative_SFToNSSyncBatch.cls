/**
* Company     : Plative
* Description : Generic Batch class to sync data from Salesforce to Netsuite.
*				Batch size to be set is 10.
* [17.Feb.2019] Kunal Jain - Code Creation 
*/
global class Plative_SFToNSSyncBatch implements Database.Batchable<sObject>, Database.Stateful,
												Database.AllowsCallouts{
    
    String sObjectApiName = '';
    String fieldToSync = '';
    
    
    global Plative_SFToNSSyncBatch(String sObjectApiName){
        this.sObjectApiName = sObjectApiName;
        //Fetch the field that needs to be checked against the object 
        if(String.isNotBlank(sObjectApiName)){
            List<Sync_Settings__mdt> syncSetting = [Select Id,Field_For_Sync__c from Sync_Settings__mdt 
													where SObject_Name__c = :sObjectApiName LIMIT 1];
            if(!syncSetting.isEmpty()){
                fieldToSync = syncSetting[0].Field_For_Sync__c;
            }
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //if Field for Sync on the object is found fetch the field mappings.
        if(String.isNotBlank(fieldToSync)){
			//Fetch the fields that need to be checked for any change 
			List<JSON_Mapping__mdt> lstFieldMappingMetaData = [SELECT Default_Value__c,Field_API_Name__c,
																	   Group__c,JSON_Node__c,Object_API_Name__c,
																	   Order__c,Parent_Node__c,Type_of_Node__c,
																	   Data_type__c,Child_Object_API_Name__c,
																	   Null_Check_field__c 
															   FROM JSON_Mapping__mdt 
															   WHERE Object_API_Name__c = :sObjectApiName];
            String query;
			if(!lstFieldMappingMetaData.isEmpty()){
                query = Plative_SFToNSSyncUtility.createQueryFromMapping(sObjectApiName,
																		 lstFieldMappingMetaData);
				query += ' WHERE '+fieldToSync+' = TRUE AND Synced__c=\'Yes\'';
			}
			if(!String.isBlank(query)){
				return Database.getQueryLocator(query);
			}
        }
        return null;     
       
    }
    global void execute(Database.BatchableContext bc, List<SObject> scope){
        // process each batch of records
        system.debug('scope: ' + scope);
		Set<Id> setIds = new Set<Id>();

		for(SObject sobj : scope){
			setIds.add((Id)sobj.get('Id'));
		}

        //Get API settings from custom metadata types
        List<API_Settings__mdt> apiSettings = [
                SELECT Consumer_Key__c, Consumer_Secret__c,
                        Endpoint__c,Token_Id__c, Token_Secret__c,
                        Account__c
                FROM API_Settings__mdt
                WHERE DeveloperName = 'Netsuite'
        ];

		//Check if sync settings exist
		Sync_Settings__mdt syncSetting = Plative_SFToNSSyncUtility.checkSyncSettings(this.sObjectApiName);
		
		List<SObject> lstChildSobjects;
		// Check if child records are to be sent in payload
		if(syncSetting.Sync_Child_Records__c){
			lstChildSobjects = Plative_SFToNSSyncUtility.getChildRecordsToSync(syncSetting,
																		    setIds,
																			this.sObjectApiName); 
		}
		

 		List<SObject> lstUnprocessedSobjects = Plative_SFToNSSyncUtility.upsertRecord(
											   scope, lstChildSobjects,apiSettings, 
											   'Sync_To_Netsuite__c');
	}    
    global void finish(Database.BatchableContext bc){
        
    }    
}