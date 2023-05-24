/**
* Company     : Plative
* Description : Handler class for different DML events on the trigger
* [14.May.2020] Anisa - Code Creation 
**/
public class Plative_OLITriggerHandler  {

    /**
    * Description : before insert DML event
    **/
    public static void beforeInsert(List<OpportunityLineItem> lstOLI){
        Boolean isSuccess = Plative_OLITriggerHelper.updateProdNSInternalId(lstOLI);
    }

    public static void beforeUpdate(List<OpportunityLineItem> lstOLI){
        /*SF-320- Current Products Accuracy - Update sales price = 0 if product is Lost
		 * Also Commenting updateProdNSInternalId method because it was not triggering before update. 
		*/
         Boolean isSuccess = Plative_OLITriggerHelper.updateProdNSInternalId(lstOLI);
        for(OpportunityLineItem oli : lstOLI){
            if (oli.Lost_Product__c) {
                oli.UnitPrice = 0.0;
            }
        }
    }

    public static void afterInsert(Map<Id,OpportunityLineItem> lstOLI){
        Plative_OLITriggerHelper.addOrRemoveBillingContact(lstOLI,true);
    }

    public static void afterUpdate(List<OpportunityLineItem> lstOLI, Map<Id,OpportunityLineItem> oldOLI){
        //Plative_OLITriggerHelper.updateProductsOnOpportunity(lstOLI, oldOLI);
    }
    public static void beforeDelete(Map<Id,OpportunityLineItem> lstOLI){
        Plative_OLITriggerHelper.UpdateProductInOpportunity(lstOLI);
        Plative_OLITriggerHelper.addOrRemoveBillingContact(lstOLI,false);
    }


}