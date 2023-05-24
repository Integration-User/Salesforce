/**
* Description : Batch class to update the records whose external id is not available for Opportunity Line records
* [12.May.2022] Prachi Gadewar- Code Creation 
**/
Public class Batch_UpdateOLIExternalId implements Database.Batchable<sObject>, Schedulable {
    
     public void execute(SchedulableContext sc){
         Database.executebatch(new Batch_UpdateOLIExternalId());        
     }
     
     Public Database.QueryLocator start(Database.BatchableContext BC) {
         String soql = 'SELECT id, Product_External_Id__c,OpportunityId,Product2Id,Customer_Channel__c from OpportunityLineItem where Product_External_Id__c = null';
         return Database.getQueryLocator(soql );
     }
        
     public void execute(Database.BatchableContext BC, list<OpportunityLineItem> lstOLI){
        Set<Id> oppoIds = new Set<Id>();
        List<OpportunityLineItem> listOLIUpdate = new List<OpportunityLineItem>();
        //Get metadata mappings
        List<SF_to_NS_Product_Mapping__mdt> lstMdt = [SELECT  SF_Product_Name__c,
                                                             Customer_Channel__c,
                                                             Netsuite_Internal_Id__c 
                                                      FROM SF_to_NS_Product_Mapping__mdt];
        // Get all Line Items
        for(OpportunityLineItem oli : lstOLI){
            oppoIds.add(oli.OpportunityId);
        }
        // Get Opportunity Records
        Map<Id,Opportunity> mapOpportunities = new Map<Id,Opportunity>([SELECT id,This_Year_Increase__c FROM Opportunity where id in: oppoIds]);

        //Query product names
        Map<Id, Product2> mapProducts = new Map<Id, Product2>([SELECT Id, Name FROM Product2]);
        for(OpportunityLineItem oli : lstOLI){
            for(SF_to_NS_Product_Mapping__mdt mdt : lstMdt){
                System.debug('Prod Name '+mapProducts.get(oli.Product2Id).Name);
                System.debug('MDT Prod Name '+mdt.SF_Product_Name__c);
                System.debug('oli.Customer_Channel__c '+ oli.Customer_Channel__c);
                if(mapProducts.get(oli.Product2Id).Name == mdt.SF_Product_Name__c &&
                   (String.isBlank(oli.Customer_Channel__c) ||
                    String.isBlank(mdt.Customer_Channel__c) ||
                    oli.Customer_Channel__c == mdt.Customer_Channel__c)){
                         oli.Product_External_Id__c = mdt.Netsuite_Internal_Id__c;
                   listOLIUpdate.add(oli);
                   break;
                }
            }
        }
        update listOLIUpdate;
     }
        
     public void finish(Database.BatchableContext BC){
     }
}