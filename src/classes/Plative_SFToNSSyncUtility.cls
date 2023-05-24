/**
* Company     : Plative
* Description : Class of utility methods for Salesforce to NetSuite Integration
* [17.Feb.2020] Tejkaran - Code Creation 
* [01.Mar.2020] Anisa - Added utility methods to support integration
**/
public class Plative_SFToNSSyncUtility {

	/**
	* Description : This methods checks if any of the field value for an sobject is changed. 
	*				If yes, then a Sync field for that SObject is as true so it can be sent
	*				to Netsuite in the scheduled run
	**/

    public static Boolean updateSyncToNSField(Map<Id, Sobject> oldFieldValues, 
											  Map<Id, Sobject> newFieldValues, 
											  String objectName,String dmlEvent) {

        if (!checkRecursiveStatic.runOnce()) {
			return false;
		}

		//Check that current user is not integration user
		Netsuite_Integration_User__c userSetting = Netsuite_Integration_User__c.getInstance(UserInfo.getUserId());
		if(! userSetting.Is_Integration_User__c ){
			return false;
		}
        //Fetch field to be updated on the sobject from the Sync Setting MDT
        List<Sync_Settings__mdt> syncSetting = [SELECT Id,Field_For_Sync__c FROM Sync_Settings__mdt 
												WHERE SObject_Name__c = :objectName 
												AND DML_Event__c =: dmlEvent
												AND Sync_Type__c ='Scheduled' LIMIT 1];

        //Fetch the fields that need to be checked for any change 
        List<JSON_Mapping__mdt> lstFieldMappingMetaData = [SELECT Field_API_Name__c 
														    FROM JSON_Mapping__mdt 
															WHERE Object_API_Name__c = :objectName
															AND Child_Object_API_Name__c = null];
		//Return is metadata is empty
		if(syncSetting == null || lstFieldMappingMetaData == null ||
		   syncSetting.isEmpty() || lstFieldMappingMetaData.isEmpty()){
			return false;
		}

        //Field that needs to be updated on the SObject
        String fieldForSync = syncSetting[0].Field_For_Sync__c;

        for (Id newId : newFieldValues.keySet()) {
            for (Integer i = 0; i < lstFieldMappingMetaData.size(); i++) {
                //Check if field value for that SObject has changed
                if (lstFieldMappingMetaData[i].Field_API_Name__c != null &&
					(newFieldValues.get(newId).get(lstFieldMappingMetaData[i].Field_API_Name__c) != 
					oldFieldValues.get(newId).get(lstFieldMappingMetaData[i].Field_API_Name__c))) {

                    //Update fieldForSync field to true for that SObject
                    newFieldValues.get(newId).put(fieldForSync, true);
                    break;
                }
            }
        }
		return true;
    }

	/**
	* Description : Sort and trigger queued jobs 
	**/
	public static Boolean triggerJobsInQueue(){

		//Check if queue is empty
		if(!Plative_SyncQueue.getInstance().isEmpty()){			
			
			//Sort the queue 
			List<Decimal> lstSeqNos = new List<Decimal>(Plative_SyncQueue.getInstance().keySet());
			lstSeqNos.sort();
			Map<Decimal, Plative_UpsertRecordQueueable> sortedQueue = new  Map<Decimal, 
																		   Plative_UpsertRecordQueueable>();
			
			for(Decimal seqNo : lstSeqNos){
				sortedQueue.put(seqNo, Plative_SyncQueue.getInstance().get(seqNo));
			}

			//Add sorted queue elements
			Plative_SyncQueue.getInstance().clear();
			Plative_SyncQueue.getInstance().putAll(sortedQueue);

			//Queue first job
			for(Decimal seqNo : Plative_SyncQueue.getInstance().keySet()){		
				Plative_SyncQueue.getInstance().get(seqNo).updateQueue(Plative_SyncQueue.getInstance());
				System.enqueueJob(Plative_SyncQueue.getInstance().get(seqNo));
				break;
			}
		}
		return true;
	}



	/**
	* Description : Initiates sync to Netsuite
	**/
	public static Sync_Settings__mdt checkSyncSettings(String sObjName){
		
		//Get sync settings for opportunity
        List<Sync_Settings__mdt> syncSetting = [SELECT Id,Field_For_Sync__c,
													  Sync_Child_Records__c,
													  Sync_Order__c
												FROM Sync_Settings__mdt 
												WHERE SObject_Name__c = :sObjName LIMIT 1];
		//No sync required for object
		if(syncSetting == null || syncSetting.isEmpty()){
			return null;
		}

		return syncSetting[0];
	}
	/**
	* Description : Checks if child object records to be synced in parent payload
	*				If yes, then queries and returns child object records to be synced.
	**/
	public static List<SObject> getChildRecordsToSync(Sync_Settings__mdt  parentSettings, 
													  Set<Id> parentIds,
													  String parentObjName){
		List<SObject> lstChildSobjects = new List<SObject>();
		try{
			List<Child_Object_Sync_Settings__mdt >lstChildObjects = [SELECT Parent_Object_Settings__c, 
																			Object_API_Name__c,
																			Relationship_Field__c
																	 FROM Child_Object_Sync_Settings__mdt
													  WHERE Parent_Object_Settings__c =:parentSettings.Id];
			if(lstChildObjects == null || lstChildObjects.isEmpty()){
				return lstChildSobjects;
			}

			//Create map of child object name to relationship field for parent object
			Map<String, String> mapObjToRelField = new Map<String, String>();

			//Create map of child object name with its JSON mapping
			Map<String, List<JSON_Mapping__mdt>> mapObjToJSONMapping = new Map<String, 
																		List<JSON_Mapping__mdt>>();
			List<JSON_Mapping__mdt> lstChildJSONMApping;

			//Iterate over settings to populate the maps
			for(Child_Object_Sync_Settings__mdt childObj: lstChildObjects){
				lstChildJSONMapping = new List<JSON_Mapping__mdt>();
				mapObjToRelField.put(childObj.Object_API_Name__c,
										childObj.Relationship_Field__c);
				lstChildJSONMApping = Plative_SFToNSSyncUtility.fetchJSONMappingListForChild(
																parentObjName,
																childObj.Object_API_Name__c);
				mapObjToJSONMapping.put(childObj.Object_API_Name__c,
										lstChildJSONMapping);

			}

			String strQuery;
			for(String childObjName : mapObjToRelField.keySet()){
				strQuery = '';
				strQuery = Plative_SFToNSSyncUtility.createQueryFromMappingForChild(childObjName,
														mapObjToJSONMapping.get(childObjName));	
				strQuery += ' WHERE '+mapObjToRelField.get(childObjName)+' IN :parentIds';
				lstChildSobjects.addAll(Database.query(strQuery));	
			}
			return lstChildSobjects;
		}
		catch(Exception e){
			System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
			return lstChildSobjects;
		}
	}

	/**
	* Description : Upsert record to Netsuite
	**/
	public static List<Sobject> upsertRecord(List<Sobject> lstSobjects,
											 List<Sobject> lstChildSobjects,
											 List<API_Settings__mdt> apiSettings,
											 String fieldForSync){
		
        String requestBody, requestHeader, endpoint, response;
		//Add a counter to ensure the no. of callouts do not exceed the limit
        Integer counter = 0; 
        List<Sobject> lstUnprocessedSobjects = new List<SObject>();
		List<Sobject> lstProcessedSobjects = new List<SObject>();
        List<Integration_Log__c > integrationLogInsertList = new List<Integration_Log__c>();

		String externalIdFieldName='';
		String objName;
		HttpResponse httpResponse;
		Sobject sObjToUpdate;
        //Iterate through list and make callout for each record
        for (SObject sobj : lstSobjects) {        
			httpResponse = new HttpResponse();
            try {
                counter++;
				endpoint = '';
				objName =sobj.Id.getSObjectType().getDescribe().getName();
				if (objName == 'Account') {
					endpoint = apiSettings[0].Endpoint__c+
							   'services/rest/record/v1/customer'; //change to label
					externalIdFieldName = 'Id';
				}
				else if (objName == 'Contact') {
					endpoint = apiSettings[0].Endpoint__c+
							   'services/rest/record/v1/contact'; //change to label
					externalIdFieldName = 'Id';
				}
				else if(objName == 'Project__c'){
					endpoint = apiSettings[0].Endpoint__c+
							   'services/rest/record/v1/job'; //change to label
					externalIdFieldName = 'Id';
				}
				else if(objName == 'Opportunity'){
					endpoint = apiSettings[0].Endpoint__c+
							   'services/rest/record/v1/salesorder'; //change to label
					externalIdFieldName = 'Id';
				}
				else if(objName == 'User'){
					endpoint = apiSettings[0].Endpoint__c+
							   'services/rest/record/v1/employee'; //change to label
					externalIdFieldName = 'Id';
				}
                if (counter < 90) {
                    //Call method to create request body
                    requestBody = Plative_SFToNSSyncUtility.createJSONFromMapping(sobj, objName,
                            null, 0, null, lstChildSobjects,null);
					//Add external Id to URL
					 endpoint += '/eid:'+sobj.get(externalIdFieldName);

                    //construct header for request
                    requestHeader = Plative_SFToNSSyncUtility.constructHeader('PUT', 'Netsuite', endpoint);

                    //UpsertRecord
                    httpResponse = Plative_NSAPIHandlercls.upsertRecord(requestBody, endpoint, requestHeader);

                    //Get Response Body
                    response = httpResponse.getBody();

                    //If Status Code doesn't equal to 204, log an error.
                    if (httpResponse.getStatusCode() != 204) {
                        GSD_IntegrationLog intLog = new GSD_IntegrationLog(
													endpoint, 'UpsertRecordQueueable', 
													requestHeader, requestBody, 
													String.valueOf(httpResponse.getStatusCode()), response, 
													'Error while creating record from Salesforce to Netsuite', 
													false,(String)sobj.get(externalIdFieldName) ); 
						integrationLogInsertList.add(intLog.logObject); 
						sObjToUpdate = Schema.getGlobalDescribe().get(objName).newSObject() ;
						sObjToUpdate.put('Id',sobj.get('Id'));
						sObjToUpdate.put('Trigger_Real_time_Sync__c',false);
						lstProcessedSobjects.add(sObjToUpdate);
					}
					else{
                        GSD_IntegrationLog intLog = new GSD_IntegrationLog(
													endpoint, 'UpsertRecordQueueable', 
													requestHeader, requestBody, 
													String.valueOf(httpResponse.getStatusCode()), response, 
													'Successfully created record in Netsuite', 
													true,(String)sobj.get(externalIdFieldName)); 
						integrationLogInsertList.add(intLog.logObject); 
						sObjToUpdate = Schema.getGlobalDescribe().get(objName).newSObject() ;
						sObjToUpdate.put('Id',sobj.get('Id'));
						sObjToUpdate.put(fieldForSync,false);
						sObjToUpdate.put('Synced__c','Yes');
						if(objName == 'Opportunity'){
							sObjToUpdate.put('Sync_Child_Records__c','');
						}
						lstProcessedSobjects.add(sObjToUpdate);
					}
                } 
				else{
                    lstUnprocessedSobjects.add(sobj);
                }
            } 
			catch (Exception ex) {
				if(ex.getMessage().containsIgnoreCase('Script-thrown exception')){
                    GSD_IntegrationLog intLog = new GSD_IntegrationLog(
												endpoint, 'UpsertRecordQueueable', 
												requestHeader, requestBody, 
												String.valueOf(httpResponse.getStatusCode()), response, 
												'Successfully created record in Netsuite', 
												true,(String)sobj.get(externalIdFieldName)); 
					integrationLogInsertList.add(intLog.logObject); 
					sObjToUpdate = Schema.getGlobalDescribe().get(objName).newSObject() ;
					sObjToUpdate.put('Id',sobj.get('Id'));
					sObjToUpdate.put(fieldForSync,false);
					sObjToUpdate.put('Synced__c','Yes');
					if(objName == 'Opportunity'){
						sObjToUpdate.put('Sync_Child_Records__c','');
					}
					lstProcessedSobjects.add(sObjToUpdate);				
				}
				else{
					String errorMessage = 'In Apex class Plative_UpsertRecordQueueable. At: ' + 
										   ex.getStackTraceString() + '. Message: ' + ex.getMessage();
					GSD_IntegrationLog intLog = new GSD_IntegrationLog(
													endpoint, 'UpsertRecordQueueable', 
													requestHeader, requestBody, '', response, 
													errorMessage, false,
													(String)sobj.get(externalIdFieldName));
					integrationLogInsertList.add(intLog.logObject);
				}
            }
        }
        if (!integrationLogInsertList.isEmpty()) { 
			insert integrationLogInsertList;
		}

		//Reset the real time trigger on record
        if (!lstProcessedSobjects.isEmpty()) { 
			update lstProcessedSobjects;
		}
		return lstUnprocessedSobjects;
	}


	/**
	* Description : Gets json mappings for a child object 
	**/
    public Static List<JSON_Mapping__mdt> fetchJSONMappingListForChild(String sObjectApiName,
																	   String childObjectAPIName) {
        List<JSON_Mapping__mdt> jsonMappingList = [SELECT Default_Value__c,Field_API_Name__c,
														   Group__c,JSON_Node__c,Object_API_Name__c,
														   Order__c,Parent_Node__c,Type_of_Node__c,
														   Data_type__c,Child_Object_API_Name__c,
														   Null_Check_field__c
													 FROM JSON_Mapping__mdt
													 WHERE Object_API_Name__c = :sObjectApiName
													 AND Child_Object_API_Name__c= :childObjectAPIName];
        return jsonMappingList;
    }
	/**
	* Description : Creates query from field mapping
	**/
    public Static String createQueryFromMapping(String sObjectApiName, List<JSON_Mapping__mdt> jsonMappingList) {
        String query = 'Select Sync_To_Netsuite__c, Synced__c';
		Set<String> setFields = new Set<String>();
        for (JSON_Mapping__mdt mapping : jsonMappingList) {
			if(!String.isBlank(mapping.Field_API_Name__c) &&
			   !mapping.Field_API_Name__c.equalsIgnoreCase('Id') &&
			   !setFields.contains(mapping.Field_API_Name__c) &&
			   String.isBlank(mapping.Child_Object_API_Name__c)){
				query += ',' + mapping.Field_API_Name__c;
				setFields.add(mapping.Field_API_Name__c);
			}
        }
        query += ' from ' + sObjectApiName;
        return query;
    }

	/**
	* Description : Creates query from field mapping for child object
	**/
    public Static String createQueryFromMappingForChild(String sObjectApiName, 
													   List<JSON_Mapping__mdt> jsonMappingList) {
        String query = 'Select Sync_To_Netsuite__c';
		Set<String> setFields = new Set<String>();
        for (JSON_Mapping__mdt mapping : jsonMappingList) {
			if(!String.isBlank(mapping.Field_API_Name__c) &&
			   !mapping.Field_API_Name__c.equalsIgnoreCase('Id') &&
			   !setFields.contains(mapping.Field_API_Name__c)){
				query += ',' + mapping.Field_API_Name__c;
				setFields.add(mapping.Field_API_Name__c);
			}
        }
        query += ' from ' + sObjectApiName;
        return query;
    }
	/**
	* Description : Creates query from field mapping
	
    public Static List<String> fetchSObjectFieldList(String sObjectApiName){
        List<String> fieldList = new List<String>();
        SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectApiName);
        fieldList.addAll(sObjectType.getDescribe().fields.getMap().keySet());
        return fieldList;
    }**/

	/**
	* Description : Creates payload for a record to send to Netsuite. 
	*				This method is called recursively to build a nested structure in JSON.
	*				In the first invocation the parentNode and groupNum is set to null.
	**/
	public static String createJSONFromMapping(SObject sobj, String sObjName, String parentNode,
											   Integer currentNode, Integer groupNum,
												List<Sobject> lstChildSobjects,
												String parentObjName){

		Map<String, Object> jsonMap = new Map<String, Object>();
		Map<String, Object> innerMap = new Map<String, Object>();

		List<JSON_Mapping__mdt> jsonMappingList;
		if(String.isBlank(parentObjName)){
			 jsonMappingList = getMappingForParentByGroup(sObjName, parentNode,
														 currentNode, groupNum);
		}
		else{
			 jsonMappingList = getMappingForChildByGroup(sObjName, parentObjName,parentNode, 
														  currentNode,groupNum);
		}
		List<Object> innerList;
		for(JSON_Mapping__mdt mapping: jsonMappingList){
			//check the condition field for null check
			if(!String.isBlank(mapping.Null_Check_field__c) &&
			    String.isBlank((String)sobj.get(mapping.Null_Check_field__c))){
				continue;
			}

			//If simple type mapping			
			if(mapping.Type_of_Node__c == 'Simple' && mapping.Field_API_Name__c != null &&
				mapping.Parent_Node__c == parentNode && String.isBlank(mapping.Child_Object_API_Name__c)){
				if(sObjName == 'Account' && 
				   (mapping.JSON_Node__c == 'entityid' || mapping.JSON_Node__c == 'companyname')  && 
				   (String)sobj.get('Synced__c') == 'Yes'){
				   continue;
				}
				jsonMap.put(mapping.JSON_Node__c, convertToDataType(mapping.Data_type__c,
													sobj.get(mapping.Field_API_Name__c)));
			}
			//If simple constants
			else if(mapping.Type_of_Node__c == 'Simple' && mapping.Default_Value__c != null &&
					mapping.Parent_Node__c == parentNode){
				jsonMap.put(mapping.JSON_Node__c, convertToDataType(mapping.Data_type__c,
												  mapping.Default_Value__c));
			}
			//If map for parent object
			else if(mapping.Type_of_Node__c == 'Map' &&
					mapping.Parent_Node__c == parentNode &&
					String.isBlank(mapping.Child_Object_API_Name__c)){
				jsonMap.put(mapping.JSON_Node__c,createJSONFromMapping(sobj,sObjName,
													mapping.JSON_Node__c, currentNode+1,groupNum,
													lstChildSobjects,null));
			}
			else if(mapping.Type_of_Node__c == 'Map' &&
					mapping.Parent_Node__c == parentNode &&
					!String.isBlank(mapping.Child_Object_API_Name__c)){
				jsonMap.put(mapping.JSON_Node__c,createJSONFromMapping(sobj,sObjName,
													mapping.JSON_Node__c, currentNode+1,groupNum,
													lstChildSobjects,mapping.Object_API_Name__c));
			}
			//If List of records from parent object
			else if(mapping.Type_of_Node__c == 'List' &&
					mapping.Parent_Node__c == parentNode && !mapping.List_has_Child_Records__c){
				//jsonMap.put(mapping.JSON_Node__c,createNestedListStructure(sobj,sObjName,
					//								mapping.JSON_Node__c,currentNode+1, lstChildSobjects));						
			}	
			//If List of records of child object
			else if(mapping.Type_of_Node__c == 'List' &&
					mapping.Parent_Node__c == parentNode && mapping.List_has_Child_Records__c){
				innerList = new  List<Object>();
				innerMap = new Map<String, Object>();
				for(SObject childsobj: lstChildSobjects){
					//If current object is parent of this child record
					if(childsobj.get('OpportunityId') == sobj.get('Id')){
						innerList.add(createJSONFromMappingForChild(childsobj,
														'OpportunityLineItem',sObjName,
														 mapping.JSON_Node__c, currentNode+1,
														 1,lstChildSobjects));
					}	
				}		
				jsonMap.put(mapping.JSON_Node__c,innerList);		
			}				
		}
		String jsonStr = JSON.serialize(jsonMap);
		if(!String.isBlank(jsonStr)){
			jsonStr = jsonStr.replace('\\','').replace('"{','{').replace('}"','}');
		}
		return jsonStr;
	}

	/**
	* Description : Creates payload for a record to send to Netsuite. 
	*				This method is called recursively to build a nested structure in JSON.
	*				In the first invocation the parentNode and groupNum is set to null.
	**/
	public static Map<String,Object> createJSONFromMappingForChild(SObject sobj, String sObjName,
																   String parentObjName,String parentNode,
																   Integer currentNode, Integer groupNum,
																   List<Sobject> lstChildSobjects){

		Map<String, Object> jsonMap = new Map<String, Object>();
		List<JSON_Mapping__mdt> jsonMappingList = getMappingForChildByGroup(sObjName, 
																			parentObjName,parentNode,
																			currentNode, groupNum);
		for(JSON_Mapping__mdt mapping: jsonMappingList){
			//check the condition field for null check
			if(!String.isBlank(mapping.Null_Check_field__c) &&
			    String.isBlank((String)sobj.get(mapping.Null_Check_field__c))){
				continue;
			}
			//If simple type mapping			
			if(mapping.Type_of_Node__c == 'Simple' && mapping.Field_API_Name__c != null &&
				mapping.Parent_Node__c == parentNode){
				jsonMap.put(mapping.JSON_Node__c, convertToDataType(mapping.Data_type__c,
												  sobj.get(mapping.Field_API_Name__c)));
			}
			//If simple constants
			else if(mapping.Type_of_Node__c == 'Simple' && mapping.Default_Value__c != null &&
					mapping.Parent_Node__c == parentNode){
				jsonMap.put(mapping.JSON_Node__c, convertToDataType(mapping.Data_type__c,
												  mapping.Default_Value__c));
			}
			//If maps with parent object fields
			else if(mapping.Type_of_Node__c == 'Map' &&
					mapping.Parent_Node__c == parentNode && 
					String.isBlank(mapping.Child_Object_API_Name__c)){
				jsonMap.put(mapping.JSON_Node__c,createJSONFromMapping(sobj,sObjName,
													mapping.JSON_Node__c, currentNode+1,groupNum,
													lstChildSobjects,mapping.Object_API_Name__c));
			}
			//If maps with child object fields
			else if(mapping.Type_of_Node__c == 'Map' &&
					mapping.Parent_Node__c == parentNode && 
					!String.isBlank(mapping.Child_Object_API_Name__c)){
				jsonMap.put(mapping.JSON_Node__c,createJSONFromMappingForChild(sobj,sObjName,
													mapping.Object_API_Name__c,mapping.JSON_Node__c, 
													currentNode+1,groupNum,lstChildSobjects));
			}
			//If List of records from parent object
			else if(mapping.Type_of_Node__c == 'List' &&
					mapping.Parent_Node__c == parentNode && !mapping.List_has_Child_Records__c){
				//jsonMap.put(mapping.JSON_Node__c,createNestedListStructure(sobj,sObjName,
				//									mapping.JSON_Node__c,currentNode+1, lstChildSobjects));						
			}	
			//If List of records of child object
			else if(mapping.Type_of_Node__c == 'List' &&
					mapping.Parent_Node__c == parentNode && mapping.List_has_Child_Records__c){
				for(SObject childsobj: lstChildSobjects){
					//If current object is parent of this child record
					if(childsobj.get('OpportunityID') == sobj.get('Id')){
						jsonMap.put(mapping.JSON_Node__c,createJSONFromMappingForChild(childsobj,
														'OpportunityLineItem',parentObjName,
														 mapping.JSON_Node__c, currentNode+1,
														 groupNum,lstChildSobjects));		
					}	
				}			
			}				
		}
		return jsonMap;
	}

	/**
	* Description : Converts to respective data type before adding to JSON
	**/
	public static Object convertToDataType(String datatype, Object fieldValue){
		
		//If value is null return object
		if(fieldValue == null || String.isBlank(datatype)){
			return null;
		}
		if(datatype == 'Text'){
			return String.valueOf(fieldValue);
		}
		else if(datatype == 'Boolean'){
			return Boolean.valueOf(fieldValue);
		}
		else if(datatype == 'Number'){
			return Integer.valueOf(fieldValue);
		}
		else if(datatype == 'Decimal'){
			Decimal value = (Decimal)fieldValue;
			value = value.setScale(2);
			return value;
		}
		else{
			return null;
		}
	}

	/**
	* Description : Queries child nodes for a given parent node and group
	**/
	public static List<JSON_Mapping__mdt> getMappingForParentByGroup(String sObjName, 
																	 String parentNode, 
																	 Integer currentNode,
																	 Integer groupNum){

		try{
			List<JSON_Mapping__mdt> jsonMappingList = [SELECT Default_Value__c,Field_API_Name__c,
															  Group__c,JSON_Node__c,Object_API_Name__c,
															  Order__c,
															  Parent_Node__c,Type_of_Node__c,
															  Data_type__c,Child_Object_API_Name__c,
															  List_has_Child_Records__c,
															  Null_Check_field__c
														FROM JSON_Mapping__mdt
														WHERE Order__c = :currentNode AND 
														Object_API_Name__c =:sObjName AND
														Parent_Node__c =:parentNode AND
														Group__c =:groupNum];	
			return jsonMappingList;
		}
		catch(Exception e){
			System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
			return new List<JSON_Mapping__mdt>();
		}
	}	
	/**
	* Description : Queries child nodes for a given parent node and group
	**/
	public static List<JSON_Mapping__mdt> getMappingForChildByGroup(String sObjName, 
																	String parentObjName,
																	 String parentNode, 
																	 Integer currentNode,
																	 Integer groupNum){

		try{
			List<JSON_Mapping__mdt> jsonMappingList = [SELECT Default_Value__c,Field_API_Name__c,
															  Group__c,JSON_Node__c,Object_API_Name__c,
															  Order__c,
															  Parent_Node__c,Type_of_Node__c,
															  Data_type__c,Child_Object_API_Name__c,
															  List_has_Child_Records__c,
															  Null_Check_field__c
														FROM JSON_Mapping__mdt
														WHERE Order__c = :currentNode AND 
														Child_Object_API_Name__c =:sObjName AND 
														Object_API_Name__c =:parentObjName AND
														Parent_Node__c =:parentNode AND
														Group__c =:groupNum];	
			return jsonMappingList;
		}
		catch(Exception e){
			System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
			return new List<JSON_Mapping__mdt>();
		}
	}	

	/**
	* Description : Constructs oAuth signature using HMACSHA256 algorithm
	**/
	public static String constructSignature(String httpMethodName, String baseURI, 
											Map<String, String> mapSortedParams,
											String consumerSecret, String tokenSecret){
		String signature='';
		String nonce = mapSortedParams.get('oauth_nonce'); 
		String timestamp = mapSortedParams.get('oauth_timestamp'); 
		String encodedUrl = EncodingUtil.urlEncode(baseURI, 'UTF-8');
		String secret = EncodingUtil.urlEncode(consumerSecret,'UTF-8')+'&'+
					 EncodingUtil.urlEncode(tokenSecret,'UTF-8');
		String params =  '';

		//Map of header params and query params sorted alphabetically by keys
		Boolean isFirstElem = true;
		for(String key : mapSortedParams.keySet()){
			if(!isFirstElem){
				params += '&';
			}
			params += EncodingUtil.urlEncode(key,'UTF-8')+'='+
					  EncodingUtil.urlEncode(mapSortedParams.get(key),'UTF-8');
			isFirstElem = false;
		}
		String encodedparams = EncodingUtil.urlEncode(params,'UTF-8');
		String salt = httpMethodName+'&'+ encodedUrl+'&'+encodedparams;
		Blob sig = Crypto.generateMac('HmacSHA256', Blob.valueOf(salt),Blob.valueOf(secret));
		signature = EncodingUtil.urlEncode(EncodingUtil.base64encode(sig), 'UTF-8');

		return signature;
	}

	/**
	* Description : Creates header for Netsuite integration
	**/

	public static String constructHeader(String methodName, String apiName, String endpoint){
		//Get API settings from custom metadata types
		List<API_Settings__mdt> apiSettings = [SELECT Consumer_Key__c, Consumer_Secret__c,
													  Endpoint__c,Token_Id__c, Token_Secret__c,
													  Account__c,Signature_Method__c,Version__c
											   FROM API_Settings__mdt
											   WHERE DeveloperName = :apiName];

		//Construct map of params
		Map<String, String> mapParams = new Map<String, String>();
		mapParams.put('realm',apiSettings[0].Account__c);
		mapParams.put('oauth_consumer_key',apiSettings[0].Consumer_Key__c);
		mapParams.put('oauth_token',apiSettings[0].Token_Id__c);
		mapParams.put('oauth_signature_method',apiSettings[0].Signature_Method__c);
		mapParams.put('oauth_timestamp',String.valueOf(DateTime.now().getTime()/1000));//Unix time stamp
		mapParams.put('oauth_nonce',String.valueOf(Crypto.getRandomLong())); //Random number generator
		mapParams.put('oauth_version',String.valueOf(apiSettings[0].Version__c));

		//Sorted map
		Map<String, String> sortedMap = sortMapByKey(mapParams);

		String signature = constructSignature(methodName, endpoint,sortedMap,
											  apiSettings[0].Consumer_Secret__c, 
											  apiSettings[0].Token_Secret__c);

		String header = 'OAuth ';
		Boolean isFirstElem = true;
		for(String key : mapParams.keySet()){
			if(!isFirstElem){
				header += ',';
			}
			header += key+'="'+mapParams.get(key)+'"';
			isFirstElem = false;
		}
		header +=',oauth_signature="'+signature+'"';
		return header;
	}

	/**
	* Description : Sort keys of the map alphabetically
	**/
	public static Map<String, String> sortMapByKey(Map<String, String> mapParams){
		
		Map<String, String> sortedMap = new Map<String, String>();
		List<String> lstKeys = new List<String>();
		lstKeys.addAll(mapParams.keySet());
		lstKeys.sort();
		for(String key : lstKeys){
			if(key != 'realm'){
				sortedMap.put(key, mapParams.get(key));
			}
		}
		return sortedMap;
	}

	/**
	* Description : Gets ns internal id for customers
	**/
	public static Map<Id, String> queryInternalIds(String objName, Set<Id> setIds,
												   List<API_Settings__mdt> apiSettings){

		Map<Id, String> mapSFIdToIntId = new Map<Id, String>();

		if(setIds == null || setIds.isEmpty() || 
		   apiSettings == null || apiSettings.isEmpty()){
			return mapSFIdToIntId;
		}

		HttpResponse httpresponse;
		String endpoint,requestHeader,response;
		List<Integration_Log__c > integrationLogInsertList = new List<Integration_Log__c>();

		//Iterate through each record and invoke queueable method
		for(Id objId : setIds){
			endpoint ='';
			if (objName == 'Account') {
				endpoint = apiSettings[0].Endpoint__c+
							'rest/platform/v1/record/customer/eid:'+objId;
				requestHeader = Plative_SFToNSSyncUtility.constructHeader('GET', 'Netsuite', endpoint);

                //UpsertRecord
                httpresponse = Plative_NSAPIHandlercls.queryRecord(endpoint,requestHeader);
                //Get Response Body
				try{
					response = httpresponse.getBody();
				}
				catch (Exception ex) {
					String errorMessage = 'In Apex class Plative_UpsertRecordQueueable. At: ' + 
										   ex.getStackTraceString() + '. Message: ' + ex.getMessage();
					GSD_IntegrationLog intLog = new GSD_IntegrationLog(
													endpoint, 'UpsertRecordQueueable', 
													requestHeader, '', '', response, 
													errorMessage, false, objId);
					integrationLogInsertList.add(intLog.logObject);
				}		

                //If Status Code doesn't equal to 200, log an error.
                if (httpresponse.getStatusCode() != 200) {
                    GSD_IntegrationLog intLog = new GSD_IntegrationLog(
												endpoint, 'UpsertRecordQueueable', 
												requestHeader, '', 
												String.valueOf(httpresponse.getStatusCode()), response, 
												'Error while Upserting Record from Salesforce to Netsuite', 
												false,objId); 
					integrationLogInsertList.add(intLog.logObject); 
				}
				if(!String.isBlank(response)){
					mapSFIdToIntId.put(objId, parseResponse(response));
				}
			}	
		}
        if (!integrationLogInsertList.isEmpty()) { 
			insert integrationLogInsertList;
		}
		return mapSFIdToIntId;
	}
	/**
	* Description : get external id from response
	**/
	public static String parseResponse(String responseBody){
		
		if(String.isBlank(responseBody)){
			return '';
		}
		try{
			Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(responseBody);
			if(mapResponse.containsKey('id') && mapResponse.get('id') != null){
				return (String)mapResponse.get('id');
			}
		}
		catch(Exception e){
			System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
		}
		return '';
	}
    
    public static void updateProductFamily(Map<Id, Contact> mapOldCon, Map<Id, Contact> mapNewCon){
        List<String> allProducts = new List<String>();
        Set<Id> setProductChangedCons = new Set<Id>();
        Map<String, String> mapProductWithCategory = new Map<String, String>();
        Map<Id,Account> mapAccToUpdate = new Map<Id,Account>();
        // SF-291 - Change hard code reference in Product includes trigger To Metadata
        for (Product_Category_Family_Mapping__mdt productFamily : Product_Category_Family_Mapping__mdt.getAll().values()) {
            mapProductWithCategory.put(productFamily.MasterLabel, productFamily.Product_Category__c);
        }
        /* mapProductWithCategory.put('US Portfolio Tools','Research');
        mapProductWithCategory.put('US REIT','Research');
        mapProductWithCategory.put('EUR REIT','Research');
        mapProductWithCategory.put('US REA','Research');
        mapProductWithCategory.put('EUR REA','Research');
        mapProductWithCategory.put('NEWS - ABAlert','News');
        mapProductWithCategory.put('NEWS - CMAlert','News');
        mapProductWithCategory.put('NEWS - REAlert','News');*/
        
        for(Contact con : mapNewCon.values()){
            Contact oldCon = mapOldCon.get(con.id);
            system.debug(con.Current_Products__c);
            system.debug(oldCon.Current_Products__c);
            
            if(con.Current_Products__c != null && con.Current_Products__c != oldCon.Current_Products__c){
                allProducts.addall(con.Current_Products__c.split(';'));	
                setProductChangedCons.add(con.id);
            }
        }
        if(setProductChangedCons != null && setProductChangedCons.size() > 0){
            for(Id id : setProductChangedCons){
                Boolean newsAvail = false;
                Boolean researchAvail = false;
                Contact con = mapNewCon.get(id);
                for(String str : con.Current_Products__c.split(';')){
                    if(mapProductWithCategory.get(str) == 'News'){  newsAvail = true;}
                    else if(mapProductWithCategory.get(str) == 'Research'){ researchAvail = true;}
                }			
                if(newsAvail && researchAvail){   con.Products_Include__c = 'Research & News';}
                else if(newsAvail){  con.Products_Include__c = 'News Only';}
                else if(researchAvail){  con.Products_Include__c = 'Research Only';}
                if(!mapAccToUpdate.containskey(con.AccountId))
                    mapAccToUpdate.put(con.AccountId, new Account(Id=con.AccountId,Products_Include__c=con.Products_Include__c));
            }
        }
        update mapAccToUpdate.values();
    }
    /*SF-281 - Products Included field update*/
    @InvocableMethod(label='Get Product Category' description='Product Vs Category')
    public static List<String> getProductCategoryName(List<String> productNames) {
        List<String> categoryList = null;
        Map<String, String> mapProductWithCategory = new Map<String, String>();
        // SF-291 - Change hard code reference in Product includes trigger To Metadata
        for (Product_Category_Family_Mapping__mdt productFamily : Product_Category_Family_Mapping__mdt.getAll().values()) {
            mapProductWithCategory.put(productFamily.MasterLabel, productFamily.Product_Category__c);
        }
        for (String product : productNames) {
            Boolean newsAvail = false;
            Boolean researchAvail = false;
            for(String str : product.split(';')) {
                if(mapProductWithCategory.get(str) == 'News'){  newsAvail = true;}
                else if(mapProductWithCategory.get(str) == 'Research'){ researchAvail = true;}
            }
            String categoryName = '';
            if(newsAvail && researchAvail) categoryName = 'Research & News';
            else if(newsAvail) categoryName = 'News Only';
            else if(researchAvail) categoryName = 'Research Only';
            if (String.isNotBlank(categoryName)) {
                categoryList = new List<String>();
                categoryList.add(categoryName);
            }
            break;
        }
        return categoryList;
    }
}