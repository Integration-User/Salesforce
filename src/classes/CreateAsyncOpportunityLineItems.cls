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
            Set<Id> renewalOppIds = new Set<Id>();
            insert this.lineItems;
            List<Opportunity> updateList = new List<Opportunity>();
            if(this.isRenewalOpp) {
                Set<Id> oppIds = new Set<Id>();
                for (OpportunityLineItem oil : lineItems) {
                    oppIds.add(oil.OpportunityId); 
                }
                
                for (Opportunity renewOpp : [Select Id, Prior_Opportunity__c, Sales_Opportunity__c,Sales_Opportunity__r.Future_Renewal__c, Close_Year__c from Opportunity Where Id IN : oppIds]) {
                    if(renewOpp.Sales_Opportunity__r.Future_Renewal__c == null) {
                        updateList.add(new Opportunity(Id = renewOpp.Sales_Opportunity__c, Future_Renewal__c = renewOpp.Id));
                        updateList.add(new Opportunity(Id = renewOpp.Id, Prior_Opportunity__c = renewOpp.Sales_Opportunity__c));
                    }
                }
            } else if(!this.isRenewalOpp) {
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
                // SF-1006 - New reference field for Previous Opp
                boolean isUpdatePriorOpportunity = System_Configuration__mdt.getInstance('UpdatePriorOpportunityField').IsEnabled__c;
                if(isUpdatePriorOpportunity) {
                    Map<String, Opportunity> updateOppMap = new Map<String, Opportunity>();
                    List<String> years = new List<String>();
                    Map<Id, String> salesOppMap = new Map<Id, String>();
                    List<Opportunity> renewOppList = [Select Id, Prior_Opportunity__c, Sales_Opportunity__c,Sales_Opportunity__r.Close_Year__c, Close_Year__c from Opportunity Where Sales_Opportunity__c IN : this.soRenewalOpportunities];
                    for (Opportunity renewOpp : renewOppList) {
                        years.add(renewOpp.Sales_Opportunity__r.Close_Year__c);
                        years.add(renewOpp.Close_Year__c);
                        updateOppMap.put(renewOpp.Sales_Opportunity__c + '-' + renewOpp.Close_Year__c, renewOpp);
                        salesOppMap.put(renewOpp.Sales_Opportunity__c, renewOpp.Sales_Opportunity__r.Close_Year__c);
                    }
                    years.sort();
                    Set<String> uniqueYears = new Set<String>(years);
                    String priorOpportunity = '';
                    String futureOpportunity = '';
                    set<String> convertedyear = new Set<String>();
                    // List<Opportunity> updateList = new List<Opportunity>();
                    for (Opportunity renewOpp : renewOppList) {
                        for (String year : uniqueYears) { 
                            String key = renewOpp.Sales_Opportunity__c + '-' + year;
                            if(!convertedyear.contains(key)) {
                                if(updateOppMap.containsKey(key)) {
                                    priorOpportunity = updateOppMap.get(key).Id;
                                } else {
                                    priorOpportunity = renewOpp.Sales_Opportunity__c; 
                                }
                                Integer nextYear = Integer.valueof(renewOpp.Close_Year__c) + 1;
                                System.debug('nextYear-' + nextYear);
                                if(updateOppMap.containsKey(renewOpp.Sales_Opportunity__c + '-' + nextYear)) {
                                    futureOpportunity = updateOppMap.get(renewOpp.Sales_Opportunity__c + '-' + nextYear).Id;
                                } else {
                                    futureOpportunity = null;
                                }
                                renewOpp.Prior_Opportunity__c = priorOpportunity;
                                renewOpp.Future_Renewal__c = futureOpportunity;
                                System.debug('renewOpp-' + renewOpp);
                                updateList.add(renewOpp);
                                convertedyear.add(key);
                                break;
                            }
                        }
                    }
                    for (Id salesOppId : salesOppMap.keySet()) {
                         System.debug('nextYear salesOppId - ' + salesOppId);
                        String futureSalesOpportunity = '';
                        Integer nextYear = Integer.valueof(salesOppMap.get(salesOppId)) + 1;
                        System.debug('nextYear Sales - ' + nextYear);
                        if(updateOppMap.containsKey(salesOppId + '-' + nextYear)) {
                            futureSalesOpportunity = updateOppMap.get(salesOppId + '-' + nextYear).Id;
                        }
                        System.debug('futureSalesOpportunity Sales - ' + futureSalesOpportunity);
                        if(String.isNotBlank(futureSalesOpportunity)) {
                            updateList.add(new Opportunity(Id = salesOppId, Future_Renewal__c = futureSalesOpportunity));
                        }
                    }
                }
                // End New reference field for Previous Opp
            }
            System.debug(updateList);
            if(!updateList.isEmpty()) {
                // update updateList;
                String errorDetails ='Id, Message\n';
                boolean isupdatefailed = false;
                List<Database.SaveResult> results = Database.update(updateList, false);
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()){
                        for (Database.Error err : result.getErrors()){
                            System.debug('Error: '+ err.getStatusCode() + ' ' + err.getMessage());
                            String fileRow = result.getId() + ',' + err.getMessage();
                            errorDetails +=  fileRow + '\n';
                            isupdatefailed = true;
                        }
                    }
                }
                if(isupdatefailed) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setSubject('Future and Prior Opportunity Updates are failer');
                    email.setToAddresses(new String[]{'mgupta@greenstreet.com', 'mbonyab@greenstreet.com', 'jecusi@greenstreet.com'});
                    email.setPlainTextBody('Records are: \n' + errorDetails);
                    Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
                }
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