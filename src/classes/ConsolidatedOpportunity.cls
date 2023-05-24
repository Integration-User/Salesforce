public class ConsolidatedOpportunity {
    @InvocableMethod(label='Consolidated Opportunity' description='Consolidated records')
    public static List<ConsolidatedOppResult> createEnrolments(List<ConsolidatedOppInfo> consolidatedOpp) {
        System.debug('consolidatedOpp->'+consolidatedOpp);
        Set<String> closedStageName = new Set<String>{'Quota, Prior Year', 'Closed Won', 'Closed Lost', 'Active', 'Deactivated', 'Consolidated', 'Suspended'};
        ConsolidatedOppResult oppResult = new ConsolidatedOppResult();
        try {
            // Same opportunity
            if (consolidatedOpp[0].consolidatedOppId == consolidatedOpp[0].targetOpp) {
                oppResult.result = 'Error: The opportunity selected to consolidate is the same as destination. You must choose a different opportunity.';
                oppResult.isError = 'true';
            } 
            Set<Id> oppIds = new Set<Id>{consolidatedOpp[0].consolidatedOppId, consolidatedOpp[0].targetOpp};
                Map<Id, Opportunity> oppAndLineItems = New Map<Id, Opportunity>([Select Id, AccountId, Consolidated_To__c, StageName, 
                                                                                 (Select Id, Start_Date__c,End_Date__c,Allocated__c,Billing_Schedule__c,Subtotal,
                                                                                  OpportunityId,Percentage_of_Total_Amount__c,CDB_ID__c,Color__c,News_ID__c,
                                                                                  Product2Id,Quantity,PricebookEntryId,Trial_Start_Date__c, MRR__c,ProductCode,
                                                                                  Lost_Product__c, Upsell_Cross_sell__c, Sales_Type__c,Finance_Effective_Date__c,
                                                                                  ARR__c, Discount__c, Discount, ListPrice, UnitPrice, Starting_Price__c
                                                                                  From OpportunityLineItems) 
                                                                                 From Opportunity Where Id IN :oppIds]);
            

            
            if(oppAndLineItems.isEmpty() || (!oppAndLineItems.isEmpty() && oppAndLineItems.containsKey(consolidatedOpp[0].consolidatedOppId) 
                                             && closedStageName.contains(oppAndLineItems.get(consolidatedOpp[0].consolidatedOppId).StageName))
               || (!oppAndLineItems.isEmpty() && oppAndLineItems.containsKey(consolidatedOpp[0].targetOpp) 
                   && closedStageName.contains(oppAndLineItems.get(consolidatedOpp[0].targetOpp).StageName))) {
                oppResult.result = 'Error: You can only consolidate opportunities that are on an open stage. Please check the selected opportunities stages, then consolidate.';
                oppResult.isError = 'true';
            }
            else if(!oppAndLineItems.isEmpty() && oppAndLineItems.get(consolidatedOpp[0].consolidatedOppId).AccountId != oppAndLineItems.get(consolidatedOpp[0].targetOpp).AccountId) {
                oppResult.result = 'Error: You can only consolidate opportunities from the same account. Please move the opportunity to the same account, then consolidate.';
                oppResult.isError = 'true';
            } else if (oppAndLineItems.get(consolidatedOpp[0].consolidatedOppId).Consolidated_To__c != null) {
                oppResult.result = 'Error: This opportunity has already been consolidated.';
                oppResult.isError = 'true';
            } else if (!oppAndLineItems.isEmpty()) {
                List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
                for (OpportunityLineItem oli : oppAndLineItems.get(consolidatedOpp[0].consolidatedOppId).OpportunityLineItems) {
                    OpportunityLineItem newOli = oli.clone(false, false, false, false);
                    newOli.OpportunityId = oppAndLineItems.get(consolidatedOpp[0].targetOpp).Id;
                    olis.add(newOli);
                }
                if (!olis.isEmpty()) {
                    insert olis;
                    oppResult.result = 'Opportunity Successfully consolidated.';
                }
                Opportunity opp = new Opportunity(Consolidated_To__c = consolidatedOpp[0].targetOpp, 
                                                  Id = consolidatedOpp[0].consolidatedOppId,stageName = 'Consolidated');
                update opp;
            }
        } catch(Exception e) {
            oppResult.result = e.getMessage();
            oppResult.isError = 'true';
        }
        
        List<ConsolidatedOppResult> resultList = new List<ConsolidatedOppResult>{oppResult};
        return resultList;
    }
    public class ConsolidatedOppInfo {
        @InvocableVariable
        public Id consolidatedOppId;
        
        @InvocableVariable
        public Id targetOpp;
    }
    public class ConsolidatedOppResult{
        @InvocableVariable
        public String result;
         @InvocableVariable
        public String isError;
    }
}