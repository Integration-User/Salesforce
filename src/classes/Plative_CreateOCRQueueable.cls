/**
* Description : Invoked when Billing flag is checked on Contacts. 
*				It will create OCR for all the open opportunities 
*				associated to the Contact's account
* [21.Mar.2021] Plative - Created
**/
public class Plative_CreateOCRQueueable implements Queueable {
	 
	 public Set<Id> setContactIds = new Set<Id>();

	 //Constructor - Accepts set of contacts Ids
	 public Plative_CreateOCRQueueable(Set<Id> setContactIds){
		this.setContactIds = setContactIds;
	 }

	 //Overriding execute method from Queueable interface
	 public void execute(QueueableContext context) {	

		// Get Account Ids for Contacts
		List<Contact> lstContacts = [SELECT Id, AccountId FROM Contact WHERE Id IN :setContactIds
													      AND Billing_Contact__c = TRUE];

		Map<Id, Set<Id>> mapAccToBillingConIds =  new Map<Id, Set<Id>>();
		for(Contact contactRec : lstContacts){
			if(mapAccToBillingConIds.containsKey(contactRec.AccountId)){
				mapAccToBillingConIds.get(contactRec.AccountId).add(contactRec.Id);
			}
			else{
				mapAccToBillingConIds.put(contactRec.AccountId, new Set<Id>{contactRec.Id});
			}
		}

		//Query Open Opportunities for Accounts along with Billing contact role OCR
		List<Opportunity> lstOppty = [SELECT	 Id, AccountId
												,( SELECT ContactId 
												   FROM	  OpportunityContactRoles 
												   WHERE  Role = 'Billing Contact')
									  FROM		Opportunity 
									  WHERE		AccountId IN :mapAccToBillingConIds.keySet()];
		
		List<OpportunityContactRole> lstOCRsToInsert = new List<OpportunityContactRole>();
		//Iterate over Opportunities and create new OCR for the billing contact if it does not exist
		for(Opportunity oppty : lstOppty){

			List<OpportunityContactRole> lstOCRs = oppty.OpportunityContactRoles;
			Set<Id> setExistingBillingContactIds = new Set<Id>();

			for(OpportunityContactRole ocr : lstOCRs){
				setExistingBillingContactIds.add(ocr.ContactId);
			}

			//For each billing contact of the Opportunities account
			for(Id contactId : mapAccToBillingConIds.get(oppty.AccountId)){
				if(setExistingBillingContactIds.contains(contactId)) continue;
				lstOCRsToInsert.add(createOCR(oppty.Id, contactId));
			}
		}

		/**Call another queueable method to do the insert since it could potentially hit
	    maximum DML rows governor limit of 10000 **/
		if(!lstOCRsToInsert.isEmpty() && !Test.isRunningTest()){
			System.enqueueJob(new Plative_AddOrDeleteOCRQueueable(lstOCRsToInsert, true));
		}
	 }

 	/**
	* Description : Create OCR record  
	**/  
	public OpportunityContactRole createOCR(Id opptyId, Id contactId) {	
		OpportunityContactRole ocr = new OpportunityContactRole();
		ocr.OpportunityId = opptyId;
		ocr.ContactId = contactId;
		ocr.Role = 'Billing Contact';
		return ocr;
	}	
}