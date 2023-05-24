/**
* Company     : Plative
* Description : Activity security utility class.
* [20.Mar.2020] Anisa - Code Creation 
**/

public class Plative_ActivitySecurityUtil  implements Queueable{

	public  List<SObject> lstActivitiesToUpdate;
	public  Map<Id, Set<Id>> mapEventIdToAttendees;
	public  Map<Id, SObject> mapActivities;
	public  String sobjName;

	//Constructor 
	public Plative_ActivitySecurityUtil(Map<Id, SObject> mapActivities, String sobjName){
		this.mapActivities = mapActivities;
		this.sObjName = sobjName;
	}

	//Executable
	public void execute(QueueableContext context){
		requeryActivities();
		Boolean isSuccess = enforceActivitySecurity();
	}

    /**
    * Description : Requery activities since whoid and whatid are updated asynchronously
	*				
    **/
	public void requeryActivities(){
		if(sobjName == 'Task'){
			mapActivities = new Map<Id, Task>([SELECT Id, WhoId, WhatId, OwnerId 
											   FROM Task
											   WHERE Id IN :mapActivities.keySet()]);
		}
		else{
			mapActivities = new Map<Id, Event>([SELECT Id, WhoId, WhatId, OwnerId 
											   FROM Event
											   WHERE Id IN :mapActivities.keySet()]);
		}
	}

    /**
    * Description : Enforces security on event/task by checking configuration
	*				under custom metadata types
	*				
    **/
	public boolean enforceActivitySecurity(){
		
		Id whatId, whoId; //What Id and Who Id of an activity
		String whatIdObjName, whoIdObjName; //Name of the object related in WhatId and WhoId


		//for events get attendees 
		if(sobjName == 'Event'){
			getAttendeesForEvents(mapActivities.keySet());
		}
		System.debug('this.mapEventIdToAttendees'+this.mapEventIdToAttendees);

		/**Map of object name to list of activities. We will be treating the activities
		object wise **/
		Map<String, List<Sobject>> mapObjNameToActivity = new Map<String, List<Sobject>>();
		
		/** Iterate over map of activities, create datastructure to be used to
		query related records**/
		Set<Id> setUsers = new Set<Id>();      //Set of ids of all owners
		Set<Id> setWhoIds = new Set<Id>();	   //Set of whoIds of all activities
		Set<Id> setWhatIds = new Set<Id>();	   //Set of whatids of all activities
		for(SObject activity : mapActivities.values()){
			System.debug('activity Id '+activity.Id);
			whatId = (Id)activity.get('WhatId');
			whoId = (Id)activity.get('WhoId');
			System.debug('whatId '+whatId);
			System.debug('whoId '+whoId);
			setWhoIds.add(whoId);
			if(whatId != null) setWhatIds.add(whatId);
			//Get object name of What id, add to map 
			whatIdObjName = whatId != null?whatId.getSObjectType().getDescribe().getName():'';			
			if(!String.isBlank(whatIdObjName) && 
				mapObjNameToActivity.containsKey(whatIdObjName)){
				mapObjNameToActivity.get(whatIdObjName).add(activity);
			}
			else if(!String.isBlank(whatIdObjName) && 
				    !mapObjNameToActivity.containsKey(whatIdObjName)){
				mapObjNameToActivity.put(whatIdObjName, new List<Sobject>());
				mapObjNameToActivity.get(whatIdObjName).add(activity);
			}
			//Get object name of Who id, add to map
			whoIdObjName = whoId != null? whoId.getSObjectType().getDescribe().getName():'';
			if(mapObjNameToActivity.containsKey(whoIdObjName)){
				mapObjNameToActivity.get(whoIdObjName).add(activity);
			}
			else{
				mapObjNameToActivity.put(whoIdObjName, new List<Sobject>());
				mapObjNameToActivity.get(whoIdObjName).add(activity);
			}
			//Add owner id to set of user ids
			setUsers.add((Id)activity.get('OwnerId'));
			
			//Also add event attendees
			if(this.mapEventIdToAttendees != null && 
			   this.mapEventIdToAttendees.containsKey(activity.Id)){
			   setUsers.addAll(this.mapEventIdToAttendees.get(activity.Id));
			}
		}
		System.debug('setUsers'+setUsers);
		System.debug('setWhoIds'+setWhoIds);
		System.debug('setWhatIds'+setWhatIds);

		//Query user records and construct map of profile and role names to user Ids
		Map<Id, User> mapUsers = new Map<Id, User>([SELECT Id,Profile.Name,
															UserRole.Name
													FROM User
													WHERE Id IN :setUsers]);
		Map<Id, String> mapUserToProfileName = new Map<Id, String>();
		Map<Id, String> mapUserToRoleName = new Map<Id, String>();
		for(User userObj : mapUsers.values()){
			mapUserToProfileName.put(userObj.Id, userObj.Profile.Name);
			mapUserToRoleName.put(userObj.Id, userObj.UserRole.Name);
		}
		System.debug('mapUserToProfileName'+mapUserToProfileName);
		System.debug('mapUserToRoleName'+mapUserToRoleName);

		//Call method to create map of user id to associated group/role names
		Map<Id, Set<String>> mapUserIdToGroups = queryGroups(setUsers);
		System.debug('mapUserIdToGroups'+mapUserIdToGroups);

		/**Iterate over map of object name to activities, treat activities for 
		  each object separately**/
		boolean issuccess;
		for(String objName : mapObjNameToActivity.keySet()){
			issuccess = updateActivityForObj(objName, mapObjNameToActivity.get(objName),
											mapUsers, setWhoIds ,setWhatIds,
											mapUserToProfileName,mapUserIdToGroups,
											mapUserToRoleName,sobjName);
		}
		//After all the records are processed update records and reassign the activities
		if(lstActivitiesToUpdate != null && !lstActivitiesToUpdate.isEmpty()){
			System.debug('lstActivitiesToUpdate'+lstActivitiesToUpdate);
			update lstActivitiesToUpdate;
		}
		return true;
	}

    /**
    * Description : Get attendees that are users for the events
	*				
    **/
	public void getAttendeesForEvents(Set<Id> setEventIds){
		this.mapEventIdToAttendees = new Map<Id, Set<Id>>();
		//Get Child event attendees, excluding the event relation created for owner
		List<EventRelation> eventRelList;
		try{
			 eventRelList =[SELECT Id, EventId, isParent,IsInvitee,IsWhat,
									Status,RelationId 
							FROM EventRelation 
							WHERE EventId IN :setEventIds 
							AND isInvitee=true];
			for(EventRelation relation : eventRelList){
				System.debug('objname '+relation.RelationId.getSObjectType().getDescribe().getName());
				//If attendee is user then add to list
				if(relation.RelationId != null && 
				   relation.RelationId.getSObjectType().getDescribe().getName() != 'User'){
				   continue;
				}
				if(this.mapEventIdToAttendees.containsKey(relation.EventId)){
					this.mapEventIdToAttendees.get(relation.EventId).add(relation.RelationId);
				}
				else{
					this.mapEventIdToAttendees.put(relation.EventId, 
											  new Set<Id>{relation.RelationId});
				}
			}
		}
		catch(Exception e){
			System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());				
		}
	}

    /**
    * Description : Processes activities for a given object
	*				
    **/
	public boolean updateActivityForObj(String objName, List<Sobject> lstActivities,
											Map<Id, User> mapUsers,
											Set<Id> setWhoIds,  Set<Id> setWhatIds,
											Map<Id, String> mapUserToProfileName,
											Map<Id, Set<String>> mapUserIdToGroups,
											Map<Id, String> mapUserToRoleName,
											String sobjName){

		//Query custom metadata type for object
		List<Shadow_Mapping__mdt> lstmappings;
		try{
			lstmappings = [SELECT Owner_Group_Role__c,Owner_Profile__c,
								  Replace_With__c,Shadow_Object_Name__c,
								  Share_With_Profile__c,Share_with_Role_or_Group__c,
								  Target_Object_Name__c,Lookup_Field_API_Name__c
							FROM  Shadow_Mapping__mdt
							WHERE Target_Object_Name__c = :objName];
		}
		catch(Exception e){
			System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
			return false;
		}
		if(lstmappings == null || lstmappings.isEmpty()){
			return true;
		}

		/**Get shadow object name for current object and relationship field
		to associate shadow object with target object. Assuming for all
		scenarios there will only be one shadow object record per object
		and associated using the same relationship field**/
		String shadowObjectName = lstmappings[0].Shadow_Object_Name__c;
		String lookupFieldName = lstmappings[0].Lookup_Field_API_Name__c;
		
		//Query shadow object records for current object and its records
		System.debug('setWhatIds '+setWhatIds);
		System.debug('setWhoIds '+setWhoIds);
		String query = 'SELECT Id, Name FROM '+shadowObjectName+' WHERE '+
						lookupFieldName+' IN :setWhatIds OR '+lookupFieldName+
						' IN :setWhoIds';
		Map<Id, Sobject> mapShadowObjRecords = new Map<Id, Sobject>(Database.query(query));
		System.debug('mapShadowObjRecords'+mapShadowObjRecords);

		lstActivitiesToUpdate = new List<SObject>();
		Map<Id, SObject> mapNewShadowObjRecords;
		List<Sobject> lstNewShadowObjRecords;

		//Invoke method to reassign the activities
		lstNewShadowObjRecords = reassignActivity(lstActivities, lstmappings,mapUserToProfileName,
												  mapUserToRoleName, mapUserIdToGroups, 
												  mapShadowObjRecords,sobjName);
		System.debug('lstNewShadowObjRecords'+lstNewShadowObjRecords);

		/**If new shadow objects are to be created for association, insert the records
		and invoke method to reassign the activities to the new records.**/
		if(!lstNewShadowObjRecords.isEmpty()) {
			insert lstNewShadowObjRecords;
			mapNewShadowObjRecords = new Map<Id, SObject>(lstNewShadowObjRecords);
			lstNewShadowObjRecords = reassignActivity(lstActivities, lstmappings,mapUserToProfileName,
													  mapUserToRoleName,mapUserIdToGroups, 
													  mapNewShadowObjRecords,sobjName);
		}
		System.debug('lstNewShadowObjRecords'+lstNewShadowObjRecords);
		return true;
	}

    /**
    * Description : Reassigns activities as per the configuration in metadata types.
	*			    If a shadow object record already exists for a given configuration
	*				it reparents the activity by associating to the existing record.
	*				Else it will create a new shadow object records and return from this method.
	*				
    **/
	public List<Sobject> reassignActivity(List<SObject> lstActivities, 
												 List<Shadow_Mapping__mdt> lstmappings,
												 Map<Id, String> mapUserToProfileName,
												 Map<Id, String> mapUserToRoleName,
												 Map<Id, Set<String>> mapUserIdToGroups,
												 Map<Id, Sobject> mapShadowObjRecords,
												 String sobjName){

		//create variables to hold values for current iteration
		String name, sharewith,ownerId,replaceWith;
		Sobject shadowObjRec;
		List<Sobject> lstNewShadowObjRecords = new List<Sobject>();		
		boolean reassigned;

		//Iterate through list of all activities for given object
		for(Sobject activity : lstActivities){	
			reassigned = false;
			sharewith = '';
			ownerId = '';
			replaceWith = '';
			ownerId = (String)activity.get('OwnerId');
			System.debug('ownerId'+ownerId);
			//Iterate through metadata records for that object
			for(Shadow_Mapping__mdt metadata : lstmappings){
				replaceWith = metadata.Replace_With__c;
				/**Check if current activity has to be reparented, i.e,
					owner's profile/group or role matches that in the metadata**/
				if(mapUserToProfileName.get(ownerId) == metadata.Owner_Profile__c ||
				   mapUserToRoleName.get(ownerId) == metadata.Owner_Group_Role__c ||
					mapUserIdToGroups.containsKey(ownerId) && 
					mapUserIdToGroups.get(ownerId).contains(metadata.Owner_Group_Role__c)){
					reassigned = checkExistingShadowRecords(mapShadowObjRecords,metadata, 
														    replaceWith, ownerId,sObjName,
															(String)activity.get('Id'));
					if(reassigned){
						break; //exit from metadata for loop
					}
					/**If no shadow record exists to map to,create a new shadow object record 
					and add to list of shadow object records to create **/
					shadowObjRec = Schema.getGlobalDescribe().get(
									metadata.Shadow_Object_Name__c).newSObject() ;
					//Check if to be shared with profile or role/group
					if(metadata.Share_With_Profile__c != null){
						sharewith = metadata.Share_With_Profile__c;
					}
					else{
						sharewith = metadata.Share_with_Role_or_Group__c;
					}
					shadowObjRec.put('Name', sharewith);
					shadowObjRec.put(metadata.Lookup_Field_API_Name__c,activity.get(replaceWith));
					lstNewShadowObjRecords.add(shadowObjRec);		
					break;	//exit from metadata for loop	   
				}
				/**Check if current activity has to be reparented, i.e,
					event attendee's profile/group or role matches that in the metadata**/
				if(this.mapEventIdToAttendees == null || 
				   !this.mapEventIdToAttendees.containsKey(activity.Id)){
				   continue;
				}

				//Iterate over list of attendees
				for(Id relationId : this.mapEventIdToAttendees.get(activity.Id)){
					if(mapUserToProfileName.get(relationId) == metadata.Owner_Profile__c ||
						mapUserToRoleName.get(relationId) == metadata.Owner_Group_Role__c ||
						mapUserIdToGroups.containsKey(relationId) && 
						mapUserIdToGroups.get(relationId).contains(metadata.Owner_Group_Role__c)){
						reassigned = checkExistingShadowRecords(mapShadowObjRecords,metadata, 
																replaceWith, relationId,sObjName,
																(String)activity.get('Id'));
						if(reassigned){
							break; //exit from metadata for loop
						}
						/**If no shadow record exists to map to,create a new shadow object record 
						and add to list of shadow object records to create **/
						shadowObjRec = Schema.getGlobalDescribe().get(
										metadata.Shadow_Object_Name__c).newSObject() ;
						//Check if to be shared with profile or role/group
						if(metadata.Share_With_Profile__c != null){
							sharewith = metadata.Share_With_Profile__c;
						}
						else{
							sharewith = metadata.Share_with_Role_or_Group__c;
						}
						shadowObjRec.put('Name', sharewith);
						shadowObjRec.put(metadata.Lookup_Field_API_Name__c,activity.get(replaceWith));
						lstNewShadowObjRecords.add(shadowObjRec);		
						reassigned = true;
						break;	//exit from metadata for loop	   
					}						
				}
				if(reassigned){
					break;
				}
			}
		}
		return lstNewShadowObjRecords;
	}
    /**
    * Description : Iterates through list of existing shadow records and if
	*				config matches associated the activity to it
    **/
	public Boolean checkExistingShadowRecords(Map<Id, Sobject> mapShadowObjRecords,
													  Shadow_Mapping__mdt metadata, String replaceWith,
													  String ownerId, String sObjName, String recordId){
		Sobject newActivity;
		String name;
		//Iterate through list of existing shadow object records
		for(Sobject shadowObj : mapShadowObjRecords.values()){
			name = (String)shadowObj.get('Name');
			/** check if a shadow object record already exists
			that matches the share with profile/group for current
			activity owner's profile or group.
			**/
			System.debug('name'+name);
			System.debug('metadata.Share_With_Profile__c '+metadata.Share_With_Profile__c);
			System.debug('metadata.Share_with_Role_or_Group__c '+metadata.Share_with_Role_or_Group__c);
			if(name == metadata.Share_With_Profile__c ||
				name  == metadata.Share_with_Role_or_Group__c){
				// If match found then reparent the current activity
				/** If replace with WhoId, blank the WhoId and 
				associate the shadow object record using the WhatId field**/
				newActivity = Schema.getGlobalDescribe().get(sObjName).newSObject();
				newActivity.put('Id',recordId);
				if(replaceWith == 'WhoId'){			
					//newActivity.put('WhoId',null);						
				}
				newActivity.put('WhatId',shadowObj.get('Id'));
				lstActivitiesToUpdate.add(newActivity);		
				return true;		 
			}
		}
		return false;
	}	

    /**
    * Description : query group information for users.
	*				
    **/
	private Map<Id, Set<String>> queryGroups(Set<Id> setUserIds){	
		Map<Id, Set<String>> mapUserIdToGroups = new Map<Id, Set<String>>();
		try{
			/**Query group member object. This will return the 
			group names as well as the role of the user since roles
			are also created as groups in salesforce.**/
			List<GroupMember> lstgroupMember = [SELECT Id, Group.DeveloperName,
													   UserOrGroupId
											    FROM GroupMember
											    WHERE UserOrGroupId IN :setUserIds];
			//Iterate over result set and construct map
			for(GroupMember gmember: lstgroupMember){
				if(mapUserIdToGroups.containsKey(gmember.UserOrGroupId)){
					mapUserIdToGroups.get(gmember.UserOrGroupId).add(
										  gmember.Group.DeveloperName);
				}
				else{
					mapUserIdToGroups.put(gmember.UserOrGroupId, new Set<String>
										  {gmember.Group.DeveloperName});
				}
			}
		}
		catch(Exception e){
			System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
		}
		return mapUserIdToGroups;
	}
}