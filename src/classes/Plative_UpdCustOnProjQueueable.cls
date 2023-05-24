/**
* Company     : Plative
* Description : Queueable class to get customer internal id
*				in netsuite and update on project
* History     :
* [01.Apr.2020] Anisa Shaikh - Code Creation
*/
public class Plative_UpdCustOnProjQueueable implements Queueable, Database.AllowsCallouts {
	
	public List<Project__c> lstProjects;
	public Plative_UpdCustOnProjQueueable(List<Project__c> lstProjects){
		this.lstProjects = lstProjects;
	}

    public void execute(QueueableContext context) {
		
		System.debug('lstProjects '+this.lstProjects);
		List<Project__c> lstUnprocessedProjects = new List<Project__c>();
		List<Project__c> lstProcessedProjects = new List<Project__c>();
		Set<Id> setCustomerIds = new Set<Id>();
		Integer count=0;

		for(Project__c proj: this.lstProjects){			
			if(count<90){
				setCustomerIds.add(proj.Customer__c);
			}
			else{
				lstUnprocessedProjects.add(proj);
			}
			count++;
		}

		//Get API settings
		List<API_Settings__mdt> apiSettings = [SELECT Account__c, Consumer_Key__c,
													  Consumer_Secret__c, Endpoint__c,
													  Signature_Method__c, Token_Id__c,
													  Token_Secret__c, Version__c
											   FROM API_Settings__mdt
											   WHERE DeveloperName = 'Netsuite'];

		Map<Id, String> mapSFIdToNSId = new Map<Id, String>();
		if(setCustomerIds != null && !setCustomerIds.isEmpty()){
			mapSFIdToNSId =  Plative_SFToNSSyncUtility.queryInternalIds('Account',
														setCustomerIds,apiSettings);
		}

		Project__c newProj;
		for(Project__c proj: this.lstProjects){
			newProj = new Project__c();
			if(mapSFIdToNSId.containsKey(proj.Customer__c) 
			   && !String.isBlank(mapSFIdToNSId.get(proj.Customer__c))){
				newProj.Id = proj.Id;
				newProj.Customer_NS_Internal_Id__c = mapSFIdToNSId.get(proj.Customer__c);
				lstProcessedProjects.add(newProj);
			}
		}

		if(lstProcessedProjects != null && !lstProcessedProjects.isEmpty()){
			update lstProcessedProjects;
		}

		if(lstUnprocessedProjects != null && !lstUnprocessedProjects.isEmpty()){
			System.enqueueJob(new Plative_UpdCustOnProjQueueable(lstUnprocessedProjects));
		}
	}
}