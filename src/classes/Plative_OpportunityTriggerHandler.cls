/**
* Company     : Plative
* Description : Handler class for Plative_OpportunityTrigger
* History     :
* [26.Feb.2020] Kunal - Code Creation
*/

public without sharing class Plative_OpportunityTriggerHandler {

    //Variable to handler recursion
    public static Boolean afterUpdateRun = false;
    public static Boolean beforeUpdateRun = false;
    public static Boolean beforeInsertRun = false;
    public static Boolean afterInsertRun = false;

    /**
    * Description : before insert dml event
    **/
    public static void beforeInsert(List<Opportunity> lstOppty) {
        if (!Plative_OpportunityTriggerHandler.beforeInsertRun) {
            Plative_OpportunityTriggerHelper.checkIfDeptOrClassUpdated(lstOppty,null);
            Plative_OpportunityTriggerHandler.beforeInsertRun = true;
        }
        //Plative_OpportunityTriggerHelper.updateOpportunityProcessesBeforeAction(lstOppty,null);
    }
    
    /**
    * Description : after insert dml event
    **/
    public static void afterInsert(List<Opportunity> lstOppty) {
        if (!Plative_OpportunityTriggerHandler.afterInsertRun) {
            Opportunity[] closedSalesOpportunities = new Opportunity[]{};
                for(Opportunity triggeredOpp : lstOppty){
                    string recordTypeName = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosById().get(triggeredOpp.RecordTypeId).getName();
                    if(triggeredOpp.stageName == 'Closed Won' 
                       && (recordTypeName == 'Sales Opportunity - Closed' || recordTypeName == 'Sales Opportunity' || (recordTypeName == 'Renewal' && triggeredOpp.Automatic_Renewal__c == false))){
                        closedSalesOpportunities.add(triggeredOpp);
                    }
                }
            if(closedSalesOpportunities.size() > 0){
                Plative_OpportunityRenewalHelper.handleClosedWonRenewalOpp(closedSalesOpportunities);
            }
            
            Plative_OpportunityTriggerHandler.afterInsertRun = true;
        }
    }

    /**
    * Description : After update dml event
    **/
    public static void afterUpdate(Map<Id, Opportunity> triggerNewMap, Map<Id, Opportunity> triggerOldMap, List<Opportunity> lstOppty) {
        Boolean perIncreaseChanged = false;
        Boolean perDesignatedARR = false;
        List<Opportunity> setOppoChangedPer = new List<Opportunity>();
        List<Opportunity> designatedOppARR = new List<Opportunity>();

        if (!Plative_OpportunityTriggerHandler.afterUpdateRun) {
            Plative_OpportunityTriggerHelper.syncRecordsToNS(triggerNewMap, triggerOldMap);
            Plative_OpportunityTriggerHelper.checkBillingContact(triggerNewMap, triggerOldMap);
            Plative_OpportunityTriggerHelper.checkOpportunityLineFieldsNull(triggerNewMap, triggerOldMap);
            Plative_OpportunityTriggerHelper.syncProjectForAdvOppty(triggerNewMap, triggerOldMap);
            Opportunity[] closedSalesOpportunities = new Opportunity[]{};
            for(Opportunity triggeredOpp : lstOppty){
                Opportunity oldOppo = triggerOldMap.get(triggeredOpp.Id);
                string recordTypeName = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosById().get(triggeredOpp.RecordTypeId).getName();
                if(triggeredOpp.stageName == 'Closed Won' 
                   && oldOppo.stageName != 'Closed Won' 
                   && (recordTypeName == 'Sales Opportunity - Closed' || recordTypeName == 'Sales Opportunity' || ((recordTypeName == 'Renewal' || recordTypeName == 'Renewal - Closed') && triggeredOpp.Automatic_Renewal__c == false))){
                    closedSalesOpportunities.add(triggeredOpp);
                }
                // Check if any opportunity has changed the % value
                if(triggeredOpp.This_Year_Increase__c != null && oldOppo.This_Year_Increase__c != triggeredOpp.This_Year_Increase__c){
                    perIncreaseChanged = true;
                    setOppoChangedPer.add(triggeredOpp);
                }
                // SF-353 - Create field to designate ARR that calculates Sales Price
                if(triggeredOpp.Designated_ARR__c != null && oldOppo.Designated_ARR__c != triggeredOpp.Designated_ARR__c){
                    perDesignatedARR = true;
                    designatedOppARR.add(triggeredOpp);
                }
            }
            if(closedSalesOpportunities.size() > 0){
                Plative_OpportunityRenewalHelper.handleClosedWonRenewalOpp(closedSalesOpportunities);
                // System.enqueueJob(new AsyncCreateNewRenewalOpportunity(closedSalesOpportunities));
            }
            Plative_OpportunityRenewalHelper.createNewRenewalOpportunity(lstOppty, triggerOldMap);

            // Call method to update prices for product based on % increased
            if(perIncreaseChanged){
                Plative_OpportunityRenewalHelper.updateOpportunityProduct(setOppoChangedPer);
            }
            // SF-353
            if(perDesignatedARR) {
                Plative_OpportunityRenewalHelper.updateOpportunityAllocatedAmount(designatedOppARR);
            }

            Plative_OpportunityTriggerHandler.afterUpdateRun = true;

            
        }
    }

    /**
    * Description : Before update DML event
    **/
    public static void beforeUpdate(Map<Id, Opportunity> triggerNewMap, Map<Id, Opportunity> triggerOldMap) {
        if (!Plative_OpportunityTriggerHandler.beforeUpdateRun) {
            Boolean isSuccess = Plative_SFToNSSyncUtility.updateSyncToNSField(triggerOldMap,triggerNewMap,
                                                         'Opportunity', 'Update');
            Plative_OpportunityTriggerHelper.checkIfDeptOrClassUpdated(Trigger.new, triggerOldMap);
            Plative_OpportunityTriggerHelper.syncToNSOnClosedWon(triggerNewMap, triggerOldMap);
            Plative_OpportunityTriggerHandler.beforeUpdateRun = true;
        }
        Plative_OpportunityTriggerHelper.updateHvtAndYoyFlag(triggerNewMap, triggerOldMap);
        //Plative_OpportunityTriggerHelper.updateOpportunityProcessesBeforeAction(Trigger.new, triggerOldMap);
        // SF-309 - Update Products Include based on Product instead of checkbox
        for (Opportunity oppty : triggerNewMap.values()) {
            Opportunity oldOppty = triggerOldMap.get(oppty.Id);
            if (oppty.Products__c != null && oldOppty.Products__c != oppty.Products__c) {
                List<String> productType = Plative_SFToNSSyncUtility.getProductCategoryName(New List<String>{oppty.Products__c});
                if (productType != null && !productType.isEmpty()) oppty.Product_Types__c = productType[0];
                else oppty.Product_Types__c = null;
            } else if (oppty.Products__c == null) {
                oppty.Product_Types__c = null;
            }
        }
    }
}