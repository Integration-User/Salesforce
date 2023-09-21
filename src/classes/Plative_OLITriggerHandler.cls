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
            // SF-645 - Leap Year date issues
            if(oli.End_Date__c != null && oli.Start_Date__c != null 
               && ((Date.isLeapYear(oli.End_Date__c.year()) && oli.Start_Date__c.daysBetween(oli.End_Date__c) == 364 && oli.Start_Date__c.dayOfYear() >= 60)
              || (Date.isLeapYear(oli.Start_Date__c.year()) && oli.Start_Date__c.dayOfYear() <= 60))) {
                System.debug('oli.Start_Date__c->'+oli.Start_Date__c+', oli.End_Date__c->'+oli.End_Date__c + ', times->'+oli.Start_Date__c.daysBetween(oli.End_Date__c));
                oli.End_Date__c = oli.End_Date__c.addDays(1);
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