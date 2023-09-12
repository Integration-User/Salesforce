/**
* Description : All utility methods for account trigger
* [20.Mar.2020] Plative - Code Creation 
* [22.Jan.2021] Plative - GS-307 updates to sync account to NS
**/
public class Plative_AccountTriggerHelper  {
	
	public static Boolean accUpdateSync = false;
	/**
	* Description : Check if records to be synced
	**/
	public static Boolean syncRecordsToNS(Map<Id, Account> mapOldAcc, Map<Id, Account> mapNewAcc){

		List<Account> lstAccountsToSync = new List<Account>();
        Set<Id> setAccsTochangeOppOwner = new Set<Id>();                 
		Set<Id> setAccountIds = new Set<Id>();
		//check if real time sync is to be initiated. 
		//Add parent accounts first.
        for (Account acc : mapNewAcc.values()) {
            //Checks if real time sync needs to be triggered
            if (acc.Trigger_Real_time_Sync__c && !mapOldAcc.get(acc.Id).Trigger_Real_time_Sync__c ) {
				if(!String.isBlank(acc.ParentId) && !setAccountIds.contains(acc.ParentId)){
					lstAccountsToSync.add(mapNewAcc.get(acc.ParentId));
					setAccountIds.add(acc.ParentId);
				}
				if(!setAccountIds.contains(acc.Id)){
					lstAccountsToSync.add(acc);
					setAccountIds.add(acc.Id);
				}
            }
            if (acc.ownerId != mapOldAcc.get(acc.Id).ownerId ) {
                setAccsTochangeOppOwner.add(acc.Id);
            }
        }	
        if (!setAccsTochangeOppOwner.isEmpty()) {
            Plative_AccountTriggerHandler.isOwnerChanged = true;
            updateRenewalOppOwner(setAccsTochangeOppOwner, null);
        }


		if(setAccountIds == null || setAccountIds.isEmpty()){
			return true;
		}

		//Check if sync settings exist
		Sync_Settings__mdt syncSetting = Plative_SFToNSSyncUtility.checkSyncSettings('Account');
		if(syncSetting == null){
			return true;
		}
		List<SObject> lstChildSobjects;
		// Check if child records are to be sent in payload
		if(syncSetting.Sync_Child_Records__c){
			lstChildSobjects = Plative_SFToNSSyncUtility.getChildRecordsToSync(syncSetting,
																		    setAccountIds,
																			'Account'); 
		}

		List<API_Settings__mdt> apiSettings = [SELECT Account__c, Consumer_Key__c,
													  Consumer_Secret__c, Endpoint__c,
													  Signature_Method__c, Token_Id__c,
													  Token_Secret__c, Version__c
											   FROM API_Settings__mdt
											   WHERE DeveloperName = 'Netsuite'];
		System.debug('account apiSettings '+apiSettings);
		System.debug('account lstAccountsToSync '+lstAccountsToSync);

		if(lstAccountsToSync.isEmpty()){
			return true;
		}
		Plative_SyncQueue.getInstance().put(syncSetting.Sync_Order__c, 
											new Plative_UpsertRecordQueueable(
											lstAccountsToSync,
											lstChildSobjects, apiSettings,
											syncSetting.Sync_Order__c));
		if(accUpdateSync){
			Plative_SFToNSSyncUtility.triggerJobsInQueue();
		}

		return true;
	}

	/**
	* Description : If Company Typeis updated on Account,
	*				query their NS internal id from custom mdt and update on record
	**/
	public static Boolean checkIfCTypeUpdated(List<Account> lstAccounts,
											  Map<Id, Account> mapOldAcc){
		
		Set<String> setCompanyTypes = new Set<String>();

		//check if Company Type is changed/updated
		for(Account acc : lstAccounts){
			if(!String.isBlank(acc.Company_Type__c) && 
				( mapOldAcc == null ||
			    (acc.Company_Type__c != mapOldAcc.get(acc.Id).Company_Type__c))){
				setCompanyTypes.add(acc.Company_Type__c);			
			}
		}
		//if the field is not updated then return
		if(setCompanyTypes.isEmpty()){
			return true;	
		}
		
		if(!setCompanyTypes.isEmpty()){
			updateCTypeId(lstAccounts, setCompanyTypes);
		}
		return true;
	}

	/**
	* Description : Update Company Type NS internal Id
	**/
	public static void updateCTypeId(List<Account> lstAccounts,
									Set<String> setCompanyTypes){
		List<NS_Picklist_Internal_Id__mdt> lstCTypes;
		//query custom mdt
		try{
			lstCTypes = [SELECT SF_Picklist_Field_Value__c, NS_Internal_ID__c,
								 SF_Picklist_Field_Name__c
						  FROM NS_Picklist_Internal_Id__mdt
						  WHERE SF_Picklist_Field_Value__c IN :setCompanyTypes
						  AND SF_Picklist_Field_Name__c='Company Type'];
		}
		catch(Exception e){
			System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
		}

		for(Account acc : lstAccounts){
			for(NS_Picklist_Internal_Id__mdt metadata: lstCTypes){
				if(metadata.SF_Picklist_Field_Value__c == acc.Company_Type__c){
					acc.Company_Type_NS_Internal_Id__c = metadata.NS_Internal_Id__c;
				}
			}
		}
	}

	/**
	* Description : Check fields updated on Account.Added as part of GS-307
	**/
	public static void checkFieldsUpdated(List<Account> lstAccounts, Map<Id, Account> mapOldAcc){
		
		for(Account newAcc : lstAccounts){
			Address newBillingAddress = newAcc.BillingAddress;
			Address newShippingAddress = newAcc.ShippingAddress;
			Address oldBillingAddress =  mapOldAcc.get(newAcc.Id).BillingAddress;
			Address oldShippingAddress =  mapOldAcc.get(newAcc.Id).ShippingAddress;
			if( newAcc.Synced__c == 'Yes' && 
			   ((newAcc.Became_Client__c != mapOldAcc.get(newAcc.Id).Became_Client__c) ||
			   (newAcc.Company_Type__c != mapOldAcc.get(newAcc.Id).Company_Type__c) ||
			   (newAcc.OwnerId != mapOldAcc.get(newAcc.Id).OwnerId) ||
			   (newAcc.Priority__c != mapOldAcc.get(newAcc.Id).Priority__c) ||
			   (checkIfAddressChanged(newAcc,mapOldAcc.get(newAcc.Id))))) {
			   newAcc.Trigger_Real_time_Sync__c = true;
			   accUpdateSync = true;
			}
		}
	}

	/**
	* Description : Check if any address fields have changed
	**/
	public static Boolean checkIfAddressChanged(Account newAccount, Account oldAccount){
		if((newAccount.BillingStreet != oldAccount.BillingStreet) ||
		   (newAccount.BillingCity != oldAccount.BillingCity) ||
		   (newAccount.BillingState != oldAccount.BillingState) ||
		   (newAccount.BillingPostalCode != oldAccount.BillingPostalCode) ||
		   (newAccount.ShippingCity != oldAccount.ShippingCity) ||
		   (newAccount.ShippingStreet != oldAccount.ShippingStreet) ||
		   (newAccount.ShippingCountry != oldAccount.ShippingCountry) ||
		   (newAccount.ShippingPostalCode != oldAccount.ShippingPostalCode)){
		   return true;
		}
		return false;
	}

	public static void setOwnerChangeCheckbox(Map<Id, Account> mapNewAcc, Map<Id, Account> mapOldAcc){
		for(Account acc : mapNewAcc.values()){
			Account oldRecord = mapOldAcc.get(acc.id);
			if(acc.ownerid != oldRecord.ownerid) {
				acc.Force_Owner_Update__c = true;
                acc.Is_Customer_Rep_Changed__c = true;
			}
		}
	}
    /*SF-343 - Update Account Product Include value when Account is created/updated with current product*/
    public static void updateProductIncludeValueOnAccount(List<Account> newList, Map<Id, Account> mapOldAcc) {
        for (Account acc : newList) {
            Account oldAccount = (mapOldAcc != null && !mapOldAcc.isEmpty()) ? mapOldAcc.get(acc.Id) : null;
            system.debug('-acc.Current_Products__c->'+acc.Current_Products__c);
            system.debug('-acc.Is_Contact_Update__c->'+acc.Is_Contact_Update__c);
            if (String.isNotBlank(acc.Current_Products__c) && acc.Is_Contact_Update__c 
                	&& (oldAccount == null || oldAccount.Current_Products__c != acc.Current_Products__c)) {
                acc.Products_Include__c = null;
                List<String> CategoryName = Plative_SFToNSSyncUtility.getProductCategoryName(New List<String>{acc.Current_Products__c});
                system.debug('-acc.CategoryName->'+CategoryName);
                if (CategoryName!= null && !CategoryName.isEmpty() && CategoryName.size() > 0) acc.Products_Include__c = CategoryName[0];
            } else if (acc.Is_Contact_Update__c && String.isBlank(acc.Current_Products__c)) {
                acc.Products_Include__c = null;
            }
        }
        
        
    }
    @future
    public static void updateRenewalOppOwner(Set<Id> accIds, List<String> oldAccount){
        Map<Id, Id> oldOwners = new Map<Id, Id>();
        if(oldAccount != null && !oldAccount.isEmpty()) {
            for (String jsonStr : oldAccount) {
                Account acc = (Account) Json.deserialize(jsonStr , Account.class);
                System.debug('ownerId->'+acc); 
                oldOwners.put(acc.Id, acc.OwnerId);
            }
        }
        List<Opportunity> renewalOwnerChanges = new List<Opportunity>();
        List<String> excludedStage = new List<String> {'Quota, Prior Year', 'Closed Won', 'Closed Lost', 
            						'Active', 'Deactivated', 'Consolidated', 'Suspended'};
        for(Opportunity opp: [Select Id, Name, AccountId, Account.OwnerId, ownerId FROM Opportunity 
                              WHERE Opportunity.RecordType.DeveloperName = 'Existing_Business' 
                              AND AccountId IN :accIds AND StageName NOT IN :excludedStage /*AND Products__c != 'React News'*/]) {
            if (opp.ownerId != opp.Account.OwnerId && 
                (oldAccount == null || (!oldOwners.isEmpty() && oldOwners.get(opp.AccountId) == opp.ownerId))) {
                    opp.OwnerId = opp.Account.OwnerId;
                    renewalOwnerChanges.add(opp); 
            }
        }
        if(!renewalOwnerChanges.isEmpty()) {
            update renewalOwnerChanges;
        }
    }

}