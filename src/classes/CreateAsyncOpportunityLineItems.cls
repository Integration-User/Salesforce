public class CreateAsyncOpportunityLineItems implements Queueable {
    List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
    List<Id> soRenewalOpportunities = new List<Id>();
    Boolean isRenewalOpp = false;
    public CreateAsyncOpportunityLineItems(List<OpportunityLineItem> lineItems, List<Id> soRenewalOpportunities, boolean isRenewalOpp) {
        this.lineItems = lineItems;
        this.soRenewalOpportunities = soRenewalOpportunities;
        this.isRenewalOpp = isRenewalOpp;
    }
    public void execute(QueueableContext context) { 
        if(!this.lineItems.isEmpty()) {
            insert this.lineItems;
            if(!this.isRenewalOpp) {
                List<OpportunityLineItem> opptyLineItems = [Select Id,Opportunity.Automatic_Renewal__c,ARR_Formula__c,Product2Id,OpportunityId,Opportunity.Sales_Opportunity__c,Opportunity.X2nd_Year_Amount_in_USD__c, Opportunity.X3rd_Year_Amount_in_USD__c, Opportunity.Year_4_Amount__c,   Opportunity.Year_5_Amount__c, Opportunity.Year_6_Amount__c,Opportunity.Year_7_Amount__c
                                                            from OpportunityLineItem where (Id IN :this.lineItems OR OpportunityId IN :this.soRenewalOpportunities)];
                Map<String,Decimal> keyVsArrValue = new Map<String,Decimal>();
                Map<Id,Integer> lineItemIdVsYear = new Map<Id,Integer>();
                for(OpportunityLineItem line: opptyLineItems){
                    
                    Integer year;
                    if(line.Opportunity.Automatic_Renewal__c == false){
                        year = 1;
                    } else {
                        year = getYear(line);
                    }
                    
                    if(year != null){
                        String key = (year == 1 ? line.OpportunityId : line.Opportunity.Sales_Opportunity__c) + '-' + year + '-' + line.Product2Id;
                        keyVsArrValue.put(key, line.ARR_Formula__c);
                        lineItemIdVsYear.put(line.Id, year);
                    }
                    system.debug('****lineItemIdVsYear'+lineItemIdVsYear);
                }
                
                List<OpportunityLineItem> opptyLineItemUpdateList = new List<OpportunityLineItem>();
                for(OpportunityLineItem line: opptyLineItems){
                    if(lineItemIdVsYear.containsKey(line.Id) && lineItemIdVsYear.get(line.Id) != 1){
                        Integer previousYear = lineItemIdVsYear.get(line.Id) - 1;
                        system.debug('****previousYear'+previousYear);
                        String key = line.Opportunity.Sales_Opportunity__c + '-' + previousYear + '-' + line.Product2Id;
                        system.debug('****key'+key);
                        if(keyVsArrValue.containsKey(key)){
                            line.Starting_Price__c = keyVsArrValue.get(key);
                            opptyLineItemUpdateList.add(line);
                            system.debug('****line'+line);
                        }
                    }
                }
                update opptyLineItemUpdateList;
            }
        }
    }
    private static Integer getYear(OpportunityLineItem line){
        Integer year = null;
        if(line.Opportunity.X2nd_Year_Amount_in_USD__c != null){
            return year = 2;
        } else if(line.Opportunity.X3rd_Year_Amount_in_USD__c != null){
            return year = 3;
        } else if(line.Opportunity.Year_4_Amount__c != null){
            return year = 4;
        } else if(line.Opportunity.Year_5_Amount__c != null){
            return year = 5;
        } else if(line.Opportunity.Year_6_Amount__c != null){
            return year = 6;
        } else if(line.Opportunity.Year_7_Amount__c != null){
            return year = 7;
        } 
        return year;
    }
}