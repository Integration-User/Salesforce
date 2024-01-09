/**
* Company     : Plative
* Description : Handler for account trigger's dml events
* [20.Mar.2020] Anisa - Code Creation 
* [25.Feb.2021] Anisa - GS-307 updates to sync account to NS
**/
public class Plative_AccountTriggerHandler{

    //Variable to handler recursion
    public static Boolean afterUpdateRun = false;
	public static Boolean beforeUpdateRun = false;
	public static Boolean beforeInsertRun = false;
    public static Boolean isOwnerChanged = false;

	/**
	* Description : after update DML
	**/	
	public static void afterUpdate(Map<Id, Account> mapOldAcc, Map<Id, Account> mapNewAcc){
		if (!Plative_AccountTriggerHandler.afterUpdateRun) {
			Boolean isSuccess = Plative_AccountTriggerHelper.syncRecordsToNS(mapOldAcc,mapNewAcc);
			Plative_AccountTriggerHandler.afterUpdateRun = true;
            /*SF-281 - Update Products name and Category field on Account and Contact*/
            boolean isContactUpdated = false;
            for (Account acc : mapNewAcc.values()) {
                if (acc.Is_Contact_Update__c && !mapOldAcc.get(acc.Id).Is_Contact_Update__c) {
                    isContactUpdated = true;
                    break;
                }
            }
            // SF-798 - Getting Record Lock issue due to this batch class
            // if (isContactUpdated) Database.executeBatch(new Batch_UpdateContactCurrentProduct(),50);         
        } else if (Plative_AccountTriggerHandler.afterUpdateRun && !Plative_AccountTriggerHandler.isOwnerChanged) {
            Set<Id> setAccsTochangeOppOwner = new Set<Id>();   
            List<String> oldAccountOwner = new List<String>();
            for (Account acc : mapNewAcc.values()) {
                if (acc.ownerId != mapOldAcc.get(acc.Id).ownerId ) {
                    setAccsTochangeOppOwner.add(acc.Id);
                    Account oldAcc = new Account(Id = acc.Id, ownerId = mapOldAcc.get(acc.Id).ownerId);
                    oldAccountOwner.add( JSON.serialize(oldAcc));
                }
            }
            system.debug('setAccsTochangeOppOwner->'+setAccsTochangeOppOwner);
            if (!setAccsTochangeOppOwner.isEmpty()) {
                Plative_AccountTriggerHandler.isOwnerChanged = true;
               Plative_AccountTriggerHelper.updateRenewalOppOwner(setAccsTochangeOppOwner, oldAccountOwner);
            }
        }

        
	}

	/**
	* Description : before update DML
	**/	
	public static void beforeUpdate(Map<Id, Account> mapNewAcc, Map<Id, Account> mapOldAcc){
		if (!Plative_AccountTriggerHandler.beforeUpdateRun) {
			Plative_AccountTriggerHelper.checkIfCTypeUpdated(mapNewAcc.values(), mapOldAcc);
			//Added below method invocation for GS-307
			Plative_AccountTriggerHelper.checkFieldsUpdated(mapNewAcc.values(), mapOldAcc); 
			Plative_AccountTriggerHandler.beforeUpdateRun = true;
			Plative_AccountTriggerHelper.setOwnerChangeCheckbox(mapNewAcc,mapOldAcc);
        } 
        /*SF-343*/
        Plative_AccountTriggerHelper.updateProductIncludeValueOnAccount(Trigger.New, mapOldAcc);
        
	}

    /**
    * Description : before insert dml event
    **/
    public static void beforeInsert(List<Account> lstAccounts) {
        if (!Plative_AccountTriggerHandler.beforeInsertRun) {
		    Boolean isSuccess = Plative_AccountTriggerHelper.checkIfCTypeUpdated(lstAccounts, null);
            Plative_AccountTriggerHandler.beforeInsertRun = true;
        } 
     }
}