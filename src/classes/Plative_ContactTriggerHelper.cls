/**
* Description : All utility methods for contact trigger
* [20.Mar.2020] Plative - Code Creation 
* [21.Mar.2021] Plative - Added method checkBillingContactChange
**/
public class Plative_ContactTriggerHelper  {

	/**
	* Description : Check if records to be synced
	**/
	public static void syncRecordsToNS(Map<Id, Contact> mapOldCon, 
									   Map<Id, Contact> mapNewCon){

		List<Contact> lstContactsToSync = new List<Contact>();
		Set<Id> setContactIds = new Set<Id>();
		//check if real time sync is to be initiated
        for (Contact con : mapNewCon.values()) {
            if (con.Trigger_Real_time_Sync__c ) {
				if(!setContactIds.contains(con.Id)){
					lstContactsToSync.add(con);
					setContactIds.add(con.Id);
				}
            }
        }		

		//Check if sync settings exist
		Sync_Settings__mdt syncSetting = Plative_SFToNSSyncUtility.checkSyncSettings('Contact');
		if(syncSetting == null){
			return;
		}

		List<SObject> lstChildSobjects;
		// Check if child records are to be sent in payload
		if(syncSetting.Sync_Child_Records__c){
			lstChildSobjects = Plative_SFToNSSyncUtility.getChildRecordsToSync(syncSetting,setContactIds,'Contact'); 
		}

		List<API_Settings__mdt> apiSettings = [SELECT Account__c, Consumer_Key__c,
													  Consumer_Secret__c, Endpoint__c,
													  Signature_Method__c, Token_Id__c,
													  Token_Secret__c, Version__c
											   FROM API_Settings__mdt
											   WHERE DeveloperName = 'Netsuite'];
		
		if(lstContactsToSync.isEmpty()){
			return;
		}

		Plative_SyncQueue.getInstance().put(syncSetting.Sync_Order__c, new Plative_UpsertRecordQueueable(
											lstContactsToSync,lstChildSobjects, apiSettings,syncSetting.Sync_Order__c));
	}	
    
 	/**
	* Description : GS-306 Add Contact to Opportunity as Billing contact 
	*				when 'Billing Contact' checkbox is checked.					  
	**/   
	public static void checkBillingContactChange(List<Contact> lstNew , Map<Id, Contact> mapOld , Map<Id, Contact> mapNew){
		
		Set<Id> setBillingUnchecked = new Set<Id>();
		Set<Id> setBillingChecked = new Set<Id>();

		for(Contact newContact : lstNew){
			//If billing checked
			if(		newContact.Billing_Contact_multi__c != null && mapOld == null ){
			   setBillingChecked.add(newContact.Id);
			}
			//If billing unchecked
			if((mapOld != null)
			   &&  newContact.Billing_Contact_multi__c != mapOld.get(newContact.Id).Billing_Contact_multi__c){
			   setBillingUnchecked.add(newContact.Id);
			}
		}

		if(!setBillingUnchecked.isEmpty()){
			try{
				List<OpportunityContactRole> lstOCRToDelete = [SELECT	Id FROM OpportunityContactRole
															   WHERE	ContactId IN :setBillingUnchecked
															   AND		Role = 'Billing Contact'];

				if(lstOCRToDelete != null && !lstOCRToDelete.isEmpty()){
					System.enqueueJob(new Plative_AddOrDeleteOCRQueueable(lstOCRToDelete, false));
				}
			}
			catch(Exception e){
				System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
			}
		}

		if(!setBillingChecked.isEmpty()){
			System.enqueueJob(new Plative_CreateOCRQueueable(setBillingChecked));
		}
	}
    
    public static void updateUsername(List<Contact> triggerNew, Map<Id,Contact> triggerOldMap){        
        Set<Id> contactIdToProcess = new Set<Id>();
        for(Contact cont: triggerNew){
            if(String.isNotBlank(cont.Username__c) && triggerOldMap.get(cont.Id).Username__c != cont.Username__c && cont.Contact_Status__c == 'Active'){
                contactIdToProcess.add(cont.Id);
            } else if(( (String.isNotBlank(cont.FirstName) && triggerOldMap.get(cont.Id).FirstName != cont.FirstName) || (String.isNotBlank(cont.LastName) && triggerOldMap.get(cont.Id).LastName != cont.LastName)) && cont.Contact_Status__c == 'Active'){
                contactIdToProcess.add(cont.Id);
            }
        }        
        if(!contactIdToProcess.isEmpty()){
            System.enqueueJob(new Plative_UpdateActivatedUserQueueable(contactIdToProcess));
        }
    }
    
    public static void activateContact(List<Contact> triggerNew, Map<Id,Contact> triggerOldMap){        
        Set<Id> contactIdToProcess = new Set<Id>();
        for(Contact cont: triggerNew){
            if(triggerOldMap == null && cont.Activate_Contact__c == true && cont.Contact_Status__c != 'Active'){
                contactIdToProcess.add(cont.Id);
            } else if(triggerOldMap != null && triggerOldMap.get(cont.Id).Activate_Contact__c == false && cont.Activate_Contact__c == true && cont.Contact_Status__c != 'Active'){
                contactIdToProcess.add(cont.Id);
            }
        }
        if(!contactIdToProcess.isEmpty()){
            System.enqueueJob(new Plative_UpdateActivatedUserQueueable(contactIdToProcess));
        }
    }
    
    
    public static void deactivateContact(List<Contact> triggerNew, Map<Id,Contact> triggerOldMap){        
        Set<Id> contactIdToProcess = new Set<Id>();
        for(Contact cont: triggerNew){
            if(triggerOldMap != null && triggerOldMap.get(cont.Id).Activate_Contact__c == true && cont.Activate_Contact__c == false && cont.Contact_Status__c == 'Active'){
                contactIdToProcess.add(cont.Id);
            }
        }
        if(!contactIdToProcess.isEmpty()){
            System.enqueueJob(new Plative_DeActivateUserQueueable(contactIdToProcess));
        }
    }
    
    //Add Contact Email Distributions from when Contact Active
    public static void addEmailDistributions(Set<Id> contactIdSet){
        try{
            List<Contact_Email_Distribution__c> existingContactDistributions = [Select Id,Email_Distribution__c,Contact__c from Contact_Email_Distribution__c
                                                                                where Contact__c IN :contactIdSet];
            
            Map<Id,Set<String>> contactIdVsEmailDistMap = new Map<Id,Set<String>>();
            for(Contact_Email_Distribution__c contDist: existingContactDistributions){
                if(!contactIdVsEmailDistMap.containsKey(contDist.Contact__c)){
                    contactIdVsEmailDistMap.put(contDist.Contact__c, new Set<String>());
                }
                contactIdVsEmailDistMap.get(contDist.Contact__c).add(contDist.Email_Distribution__c);
            }
            
            List<Contact> contactList = [Select Id,AccountId from Contact where Id IN :contactIdSet];
            Set<Id> accountIdSet = new Set<Id>();
            for(Contact cont: contactList){
                if(cont.AccountId != null){
                    accountIdSet.add(cont.AccountId);
                }
            }    
            List<Account_Email_Distribution__c> accntEmailDistributions = [Select Id,Account__c,Email_Distribution__c from Account_Email_Distribution__c	 where
                                                                           Account__c IN :accountIdSet];
            Map<Id,List<Account_Email_Distribution__c>> accountIdVsEmailDistributions = new Map<Id,List<Account_Email_Distribution__c>>();
            for(Account_Email_Distribution__c accntEmailDistribution: accntEmailDistributions){
                if(!accountIdVsEmailDistributions.containsKey(accntEmailDistribution.Account__c)){
                    accountIdVsEmailDistributions.put(accntEmailDistribution.Account__c, new List<Account_Email_Distribution__c>());
                }
                accountIdVsEmailDistributions.get(accntEmailDistribution.Account__c).add(accntEmailDistribution);
            }
            
            List<Contact_Email_Distribution__c> contactEmailDistnToInsert = new List<Contact_Email_Distribution__c>();
            for(Contact cont: contactList){
                if(cont.AccountId != null && accountIdVsEmailDistributions.containsKey(cont.AccountId)){
                    for(Account_Email_Distribution__c accntEmailDistribution: accountIdVsEmailDistributions.get(cont.AccountId)){
                        if( !contactIdVsEmailDistMap.containsKey(cont.Id) || (contactIdVsEmailDistMap.containsKey(cont.Id) && !contactIdVsEmailDistMap.get(cont.Id).contains(accntEmailDistribution.Email_Distribution__c))){
                            Contact_Email_Distribution__c contEmailDist = createContactED(cont.AccountId,cont.Id,accntEmailDistribution.Email_Distribution__c);
                            contactEmailDistnToInsert.add(contEmailDist);
                        }                         
                    }
                }
            }
            Database.insert(contactEmailDistnToInsert,false);
        } catch(Exception ex){
            System.debug('In Apex class Plative_ContactTriggerHelper. ' + 'At line number: ' + ex.getLineNumber() + '. Cause: ' + ex.getCause() + '. Message: ' + ex.getMessage());
        }        
    }
    
    @TestVisible
    private static Contact_Email_Distribution__c createContactED(Id accountId, Id contactId, String emailDistribution){
        Contact_Email_Distribution__c contEmailDist = new Contact_Email_Distribution__c();
        contEmailDist.Account__c = accountId;
        contEmailDist.Contact__c = contactId;
        contEmailDist.Email_Distribution__c = emailDistribution;
        return contEmailDist;
    }
    
    //Remove Email Distributions when Contact Inactive
    public static void removeEmailDistributions(Set<Id> contactIdSet){
        try{
            List<Contact_Email_Distribution__c> contactEmailDistributions = [Select Id from Contact_Email_Distribution__c
                                                                             where Contact__c IN :contactIdSet];
            Database.delete(contactEmailDistributions, false);
        } catch(Exception ex){
            System.debug('In Apex class Plative_ContactTriggerHelper. ' + 'At line number: ' + ex.getLineNumber() + '. Cause: ' + ex.getCause() + '. Message: ' + ex.getMessage());
        }
    }
    // SF-918 - Excel Add-In - Account
    public static void updateExcelAddUsersOnAccount(List<Contact> contacts, Map<Id, Contact> mapOldCon){
        Map<String, Integer> accountCounts = new Map<String, Integer>();
        for(Contact con : contacts) {
            Contact oldCon = mapOldCon != null ? mapOldCon.get(con.Id) : null;
            if(!accountCounts.containsKey(con.AccountId) && (oldCon == null || (oldCon != null && con.Excel_Last_Use_Date__c != oldCon.Excel_Last_Use_Date__c))) {
                accountCounts.put(con.AccountId, 0);
            }
        }
        if(!accountCounts.isEmpty()) {
            for(AggregateResult result : [Select Count(Id), AccountId from Contact where AccountId in :accountCounts.keySet() AND Excel_Last_Use_Date__c != null GROUP BY AccountId]) {
                System.debug('result' + result);
                System.debug('result' + result.get('AccountId'));
                System.debug('Average amount' + result.get('expr0'));
                accountCounts.put(String.valueof(result.get('AccountId')), Integer.valueOf(result.get('expr0')));
            }
			List<Account> accUpdates = new List<Account>();
            for(String accId : accountCounts.keySet()) {
                accUpdates.add(New Account(Id = accId, Excel_Add_In_Users__c = accountCounts.get(accId)));
            }
            if(!accUpdates.isEmpty()) update accUpdates;
        }
    }
}