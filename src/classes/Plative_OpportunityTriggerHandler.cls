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
	public static Id renewalRecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
   	public static Id salesRecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Sales Opportunity').getRecordTypeId();
    public static Id salesDevRecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('Sales_Development').getRecordTypeId();

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
            
            //SF-964 - Create Multiple Client Access Cases
            Plative_OpportunityRenewalHelper.CreateDeActivationCases(lstOppty, triggerOldMap);

            Plative_OpportunityTriggerHandler.afterUpdateRun = true;

            
        }
    }

    /**
    * Description : Before update DML event
    **/
    public static void beforeUpdate(Map<Id, Opportunity> triggerNewMap, Map<Id, Opportunity> triggerOldMap) {
        if (!Plative_OpportunityTriggerHandler.beforeUpdateRun) { 
            // SF-768 - 3X3 Contact Levels
            Set<Id> x3x3opportunities = new Set<Id>();
            for (OpportunityContactRole ocr : [SELECT Id, OpportunityId FROM OpportunityContactRole WHERE Contact.X3x3_Level__c != null AND OpportunityId IN :triggerNewMap.keySet()]) {
                x3x3opportunities.add(ocr.OpportunityId);
            }
            List<String> stageNames = new List<String>{'1 - Introducing', '2 - Conducting Needs Analysis', '3 - Qualifying', 'Closed Lost'};
            Set<Id> oppIds = new Set<Id>();
            // SF-770 Changes
            Map<Id, Integer> relIntelligenceOpp = new  Map<Id, Integer>();
            for(AggregateResult result : [SELECT count(Id), Related_Opportunity__c 
                                          FROM Relationship_Intelligence__c 
                                          WHERE Related_Opportunity__c IN :triggerNewMap.keySet() 
                                          AND Related_Opportunity__c != null AND Active__c = TRUE GROUP BY Related_Opportunity__c ]) {
                if(String.valueof(result.get('Related_Opportunity__c')) != null) relIntelligenceOpp.put(String.valueof(result.get('Related_Opportunity__c')), Integer.valueOf(result.get('expr0')));
            }
            // END SF-770 Changes

            for (Opportunity oppty : triggerNewMap.values()) {
                Opportunity oldOppty = triggerOldMap.get(oppty.Id);
                if ((oppty.recordTypeId == renewalRecordTypeId || oppty.recordTypeId == salesRecordTypeId)
                    && oppty.StageName != null && oldOppty.StageName != oppty.StageName 
                    && !stageNames.contains(oppty.StageName) && !x3x3opportunities.contains(oppty.Id)) {
                        oppty.addError('One contact must have a 3x3 Level designated before moving to Stage 4.');
                }
                //SF-770 Changes
                if((oldOppty.StageName != oppty.StageName || (oppty.Win_Validation__c == 'Pending Review' && oldOppty.Win_Validation__c != oppty.Win_Validation__c))
                   && (!relIntelligenceOpp.containsKey(oppty.id) || (relIntelligenceOpp.containsKey(oppty.id) && relIntelligenceOpp.get(oppty.id) < 1))
                   && ((oppty.recordTypeId == renewalRecordTypeId && (oppty.StageName == '6 - Verbal Win and Finalizing Contract' || oppty.StageName == 'Closed Won'))
                       || (oppty.recordTypeId == salesRecordTypeId && !stageNames.contains(oppty.StageName))
                       || (oppty.recordTypeId == salesDevRecordTypeId && (oppty.StageName == 'In Review' || oppty.StageName == 'Qualified')))) {
                    oppty.addError('Opportunity must have at least one active Relationship Intelligence record.');
                }
                // END SF-770 Changes
            }
            
            // END SF-768 - 3X3 Contact Levels
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
                List<String> productType = Plative_SFToNSSyncUtility.getProductCategoryNameForOpp(New List<String>{oppty.Products__c});
                if (productType != null && !productType.isEmpty()) oppty.Product_Types__c = productType[0];
                else oppty.Product_Types__c = null;
            } else if (oppty.Products__c == null) {
                oppty.Product_Types__c = null;
            }
        }
    }
}