/**
* Description : Enforces security and displays tasks.Controller to Plative_TaskRelatedList 
*				lightning component
* [09.Apr.2021] Plative - Code Creation 
**/
public class Plative_TaskRelatedListController  {

	@AuraEnabled
	/**
	* Description : Queries relevant tasks for the given user
	**/	
	public static List<Plative_ActivityWrapper> fetchTasks(String recordId){	

		List<Plative_ActivityWrapper> wrapperList = new List<Plative_ActivityWrapper>();

		//If list is displayed on Account, get tasks for related Contacts
		Set<Id> contactIds = fetchContactIds(recordId);

		//Query shadow object records for given contact
		List<Shadow_Contact__c> lstShadowRecords = [SELECT	Id, Name,Contact__c 
													FROM	Shadow_Contact__c
													WHERE	Contact__c IN :contactIds];

		Set<Id> setIds = (new Map<Id, Shadow_Contact__c>(lstShadowRecords)).keySet();

		//Create set of profiles,roles and groups
		Set<String> setKeys = new Set<String>();

		for(Shadow_Contact__c shadowRec : lstShadowRecords){
			setKeys.add(shadowRec.Name);
		}
		System.debug('setKeys '+setKeys);
        
		//Get profile of user
		User userObj = [SELECT	Id, Profile.Name, UserRole.Name 
						FROM	User
						WHERE	Id =:UserInfo.getUserId()];

		String profileName = userObj.Profile.Name;
		String role		   = userObj.UserRole.Name;
        system.debug('userObj query'+userObj);
		//Get roles and groups for user
		List<GroupMember> lstgroupMem = [SELECT		UserOrGroupId, Group.Name
										 FROM		GroupMember
										 WHERE		UserOrGroupId = :UserInfo.getUserId()
										 AND		Group.Name   IN :setKeys];
        system.debug('Group query'+lstgroupMem);
		
		Set<String> setGroups = new Set<String>();
		
		//Create set of group names
		for(GroupMember gm :lstgroupMem){
			setGroups.add(gm.Group.Name);
		}
		System.debug('setGroups '+setGroups);

		//Filtered records
		Set<Id> setFilteredShadowRecords = new Set<Id>();

		for(Shadow_Contact__c shadowRec : lstShadowRecords){
			System.debug('NAME '+shadowRec.Name);
			if(		shadowRec.Name == profileName  
			   ||	shadowRec.Name == role 
			   ||	setGroups.contains(shadowRec.Name)){
			   system.debug('here'+setGroups);
			   setFilteredShadowRecords.add(shadowRec.Id);		
			}
		}
        //Getting all users having role as Advisory
        Set<Id> advRoleIds = new Set<Id>();
        List<User> ur = [Select Id, Name,UserRole.Name from User Where UserRole.Name='Advisory' LIMIT 999];
        system.debug('u-------'+ur);
        for(User u :ur){
            system.debug('CountIds');
            advRoleIds.add(u.Id);
        }
		List<Task> lstTasks;
        List<Task> lstTasksUpdated;
		List<Event> lstEvents;
        List<Task> lstWhoIdTask;
		List<Event> lstWhoIdEvents;
		try{
			lstTasks = [SELECT	Id, Subject, ActivityDate, Type,
								Status, OwnerId, Owner.Name, Who.Name
						FROM	Task 
						WHERE	((WhatId IN :setFilteredShadowRecords
							 OR (WhatId IN :setIds AND CreatedById =: UserInfo.getUserId()))
                             AND OwnerId IN:advRoleIds)
						ORDER BY ActivityDate ASC];

			lstEvents = [SELECT		Id, Subject, ActivityDate, Type,
									OwnerId, Owner.Name, Who.Name
						FROM		Event 
						WHERE		((WhatId IN :setFilteredShadowRecords
								 OR (WhatId IN :setIds AND CreatedById = :UserInfo.getUserId()))
                                 AND OwnerId IN:advRoleIds)    
						ORDER BY	ActivityDate ASC];
           
			for(Task tsk : lstTasks){
				wrapperList.add(new Plative_ActivityWrapper(tsk));
			}
			for(Event evt : lstEvents){
				wrapperList.add(new Plative_ActivityWrapper(evt));
			}
        }
		catch(Exception e){
			System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
		}
		System.debug('Wrapper List '+wrapperList);
		return wrapperList;
	} 

	/**
	* Description : Get contact Ids for Advisory tasks
	**/	
	private static Set<Id> fetchContactIds(Id recordId){

		String sObjName = recordId.getSObjectType().getDescribe().getName();
		if(sObjName == 'Contact'){
			return new Set<Id>{recordId};
		}
		else{
			List<Contact> lstContacts = [SELECT ID FROM Contact WHERE AccountId = :recordId]; 
			if(lstContacts != null && !lstContacts.isEmpty()){
				return (new Map<Id, Contact>(lstContacts)).keySet();
			}
		}
		return new Set<Id>();
	}
}