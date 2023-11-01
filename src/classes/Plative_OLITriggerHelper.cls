/**
* Company     : Plative
* Description : All utility methods for OLI trigger
* [14.May.2020] Anisa - Code Creation 
**/
public class Plative_OLITriggerHelper  {

    /**
    * Description : Check if product is added or update on oli record
    **/
    public static Boolean updateProdNSInternalId(List<OpportunityLineItem> lstOLI){
        Set<Id> oppoIds = new Set<Id>();
        //Get metadata mappings
        List<SF_to_NS_Product_Mapping__mdt> lstMdt = [SELECT  SF_Product_Name__c,
                                                             Customer_Channel__c,
                                                             Netsuite_Internal_Id__c 
                                                      FROM SF_to_NS_Product_Mapping__mdt];
        // Get all Line Items
        for(OpportunityLineItem oli : lstOLI){
            oppoIds.add(oli.OpportunityId);
        }
        
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
                   break;
                }
            }

            // Get Opportunity Records
            /* Map<Id,Opportunity> mapOpportunities = new Map<Id,Opportunity>([SELECT id,This_Year_Increase__c FROM Opportunity where id in: oppoIds]);
            // Update the Unit price based on % increase on the opportunity         
            Decimal incresedPerc = mapOpportunities.get(oli.OpportunityId).This_Year_Increase__c;
            if(incresedPerc != null && incresedPerc != 0 && oli.Starting_Price__c != null && oli.Starting_Price__c != 0){
                Decimal calculatedUnitPrice = oli.Starting_Price__c + (oli.Starting_Price__c * (incresedPerc/100));
                // SF-433 -Adjust This year % increase functionality 
                // We don't need to calculate Unitprice based on This Year Increase field for new Line Items
                // oli.UnitPrice = calculatedUnitPrice;
            }*/
        }
        return true;
    }

    public static void addOrRemoveBillingContact(Map<Id,OpportunityLineItem> lstOLI, Boolean isInsert){
        if(isInsert)
            AddOrRemoveBillingContact.AddBillingContact(new set<ID>(),lstOLI.keyset());
        else
            AddOrRemoveBillingContact.DeleteBillingContact(lstOLI.values());
    }
    
    public static void UpdateProductInOpportunity(Map<Id,OpportunityLineItem> lstOLI){
        Set<Id> setOppoIds = new Set<Id>();
        Boolean isUpdate = false;
        Map<Id,OpportunityLineItem> mapOppoLineItems = new Map<Id,OpportunityLineItem>([Select id, Product2.Name, Product2.Exclude_from_Deal_Scoring_Model__c, OpportunityId from OpportunityLineItem where id in: lstOLI.keyset()]);
        for(OpportunityLineItem line: lstOLI.values()){
            setOppoIds.add(line.OpportunityId);
        }

        Map<Id,Opportunity> mapOpportunities = new Map<Id,Opportunity>([Select id, Products__C, Exclude_from_Deal_Scoring_Model__c from Opportunity where id in:setOppoIds]);
        
        Map<Id, boolean> excludeDealOpps = new Map<Id, boolean>();
        for(OpportunityLineItem oil : [Select id, Product2.Name, Product2.Exclude_from_Deal_Scoring_Model__c, OpportunityId from OpportunityLineItem where id NOT IN: lstOLI.keyset() AND OpportunityId IN:setOppoIds AND Product2.Exclude_from_Deal_Scoring_Model__c = TRUE]) {
            excludeDealOpps.put(oil.OpportunityId, oil.Product2.Exclude_from_Deal_Scoring_Model__c);
        }
        System.debug('excludeDealOpps-->'+excludeDealOpps);
        for(OpportunityLineItem line: lstOLI.values()){
            String proName = mapOpportunities.get(line.OpportunityId).Products__C;
            if(proName != null && proName.contains(mapOppoLineItems.get(line.id).Product2.Name)){
                mapOpportunities.get(line.OpportunityId).Products__C = proName.replace(mapOppoLineItems.get(line.id).Product2.Name,'');
                isUpdate = true;
            }
            boolean dealScorFlag = mapOpportunities.get(line.OpportunityId).Exclude_from_Deal_Scoring_Model__c;
            if(excludeDealOpps.containsKey(line.OpportunityId) && excludeDealOpps.get(line.OpportunityId) != null && excludeDealOpps.get(line.OpportunityId) != dealScorFlag) {
                mapOpportunities.get(line.OpportunityId).Exclude_from_Deal_Scoring_Model__c = excludeDealOpps.containsKey(line.OpportunityId) ? excludeDealOpps.get(line.OpportunityId) : false;
                isUpdate = true;
            } else if (!excludeDealOpps.containsKey(line.OpportunityId) && mapOpportunities.get(line.OpportunityId).Exclude_from_Deal_Scoring_Model__c) {
                mapOpportunities.get(line.OpportunityId).Exclude_from_Deal_Scoring_Model__c = false;
                isUpdate = true;
            }
        }
        if(isUpdate)
            update mapOpportunities.values();
    }

    /* SF-442 - We have already Flow(Update Products on Opportunity) which is updating Opportunity Product
     * public static void updateProductsOnOpportunity(List<OpportunityLineItem> newList, Map<Id,OpportunityLineItem> oldMap){
        Set<Id> oppIds = new Set<Id>();
        for (OpportunityLineItem oli : newList) {
            OpportunityLineItem oldOli = oldMap != null ? oldMap.get(oli.Id) : null;
            if (oldOli == null || (oldOli != null && oldOli.Lost_Product__c != oli.Lost_Product__c)) {
                oppIds.add(oli.OpportunityId);
            } 
        }
        if (oppIds.size() > 0) {
            Map<Id, String> oppProductNameInfo = new Map<Id, String>();
            for (OpportunityLineItem oli : [Select Product2.Name, OpportunityId From OpportunityLineItem WHERE OpportunityId IN :oppIds AND Lost_Product__c = FALSE]) {
                System.debug('oli->'+oli);
                if (oppProductNameInfo.containsKey(oli.OpportunityId)) {
                    if(!oppProductNameInfo.get(oli.OpportunityId).contains(oli.Product2.Name)) {
                        String productNames = oppProductNameInfo.get(oli.OpportunityId) + ';' + oli.Product2.Name;
                        oppProductNameInfo.put(oli.OpportunityId, productNames);
                    }
                } else {
                    oppProductNameInfo.put(oli.OpportunityId, oli.Product2.Name);
                }
            }

            if (!oppProductNameInfo.isEmpty()) {
                List<Opportunity> updateOppList = new List<Opportunity>();
                for (Id oppId : oppProductNameInfo.keySet()) {
                    updateOppList.add(new Opportunity(Id= oppId, Products__c=oppProductNameInfo.get(oppId)));
                }
                update updateOppList;
            }
        }
        
    }*/

}