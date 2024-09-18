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
                List<Opportunity> updateOppList = new List<Opportunity>();
                Opportunity opp = new Opportunity(Consolidated_To__c = consolidatedOpp[0].targetOpp, 
                                                  Id = consolidatedOpp[0].consolidatedOppId,stageName = 'Consolidated');
                updateOppList.add(opp);
                // SF-824 - Consolidation Data Management for SDO process
                For(Opportunity sdoOpp : [Select Id, New_Sales_Opportunity__c FROM Opportunity WHERE New_Sales_Opportunity__c =: consolidatedOpp[0].consolidatedOppId]) {
                    sdoOpp.New_Sales_Opportunity__c = consolidatedOpp[0].targetOpp;
                    updateOppList.add(sdoOpp);
                }
                update updateOppList;
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
    
    @AuraEnabled(cacheable=true)
    public static List<opportunityWrapper> getAllOpportunityLineItems(Id caseId) {
        List<String> otherGreenStreetList = New List<String>();
        List<Case> cse = [Select Id, Opportunity__c, Platform__c from Case where id = :caseId];
        // Get Green Street News product List to create DeActivation Case
        System_Configuration__mdt productConfig = System_Configuration__mdt.getInstance('Green_Street_News_Platform');
        List<String> productList = productConfig.Value__c.split(';');
        otherGreenStreetList.addAll(productList);
        
        // Get Green Street Locatus product List to create DeActivation Case
        System_Configuration__mdt locatusProductConfig = System_Configuration__mdt.getInstance('Green_Street_Locatus_Platform');
        List<String> locatusPlatformProductList = locatusProductConfig.Value__c.split(';');
        otherGreenStreetList.addAll(locatusPlatformProductList);
        
         // Get Green Street IJGlobal product List to create DeActivation Case
        System_Configuration__mdt ijGlobalProductConfig = System_Configuration__mdt.getInstance('Green_Street_IJGlobal_Platform');
        List<String> ijGlobalPlatformProductList = ijGlobalProductConfig.Value__c.split(';');
        otherGreenStreetList.addAll(ijGlobalPlatformProductList);
        
        List<opportunityWrapper> oppWrapperList = new List<opportunityWrapper>();
        List<OpportunityLineItem> OppLineItemsList = new List<OpportunityLineItem> ();
        if(!cse.isEmpty()) {
            if(String.isNotBlank(cse[0].Platform__c) && cse[0].Platform__c == 'Green Street News') {
                OppLineItemsList = [SELECT Id, Name, Product2Id, Product2.Name, Lost_Product__c, Sales_Type__c, Start_Date__c, End_Date__c
                                    FROM OpportunityLineItem 
                                    WHERE OpportunityId =: cse[0].Opportunity__c AND Product2.Name IN :productList];
            } else if(String.isNotBlank(cse[0].Platform__c) && cse[0].Platform__c == 'Locatus') {
                OppLineItemsList = [SELECT Id, Name, Product2Id, Product2.Name, Lost_Product__c, Sales_Type__c, Start_Date__c, End_Date__c
                                    FROM OpportunityLineItem 
                                    WHERE OpportunityId =: cse[0].Opportunity__c AND Product2.Name IN :locatusPlatformProductList];
            } else if(String.isNotBlank(cse[0].Platform__c) && cse[0].Platform__c == 'IJGlobal') {
                OppLineItemsList = [SELECT Id, Name, Product2Id, Product2.Name, Lost_Product__c, Sales_Type__c, Start_Date__c, End_Date__c
                                    FROM OpportunityLineItem 
                                    WHERE OpportunityId =: cse[0].Opportunity__c AND Product2.Name IN :ijGlobalPlatformProductList];
            } else if(String.isNotBlank(cse[0].Platform__c) && cse[0].Platform__c == 'Green Street') {
                OppLineItemsList = [SELECT Id, Name, Product2Id, Product2.Name, Lost_Product__c, Sales_Type__c, Start_Date__c, End_Date__c
                                    FROM OpportunityLineItem 
                                    WHERE OpportunityId =: cse[0].Opportunity__c AND Product2.Name NOT IN :otherGreenStreetList];
            } else {
                OppLineItemsList = [SELECT Id, Name, Product2Id, Product2.Name, Lost_Product__c, Sales_Type__c, Start_Date__c, End_Date__c
                                    FROM OpportunityLineItem 
                                    WHERE OpportunityId =: cse[0].Opportunity__c];
            }
           
            if(!OppLineItemsList.isEmpty()) {
                for(OpportunityLineItem oil : OppLineItemsList){
                    opportunityWrapper oppWrapper = new opportunityWrapper();
                    oppWrapper.oppLineItem = oil;
                    oppWrapper.productUrl = '/' + oil.Id;
                    oppWrapper.productName = oil.Product2.Name;
                    oppWrapper.lostProduct = oil.Lost_Product__c;
                    oppWrapper.salesType = oil.Sales_Type__c;
                    oppWrapper.startDate = oil.Start_Date__c;
                    oppWrapper.endDate = oil.End_Date__c;
                    oppWrapper.name = oil.Name;
                    oppWrapperList.add(oppWrapper);
                }
            }
        }
        return oppWrapperList;
    }
    // SF-768 - 3X3 Contact Levels
    @AuraEnabled(cacheable=true)
    public static ContactWrapperList getAllContacts(Id opportunityId){
       	set<Id> contacts = new Set<Id>();
        ContactWrapperList result = new ContactWrapperList();
        List<ContactWrapper> firstList = new List<ContactWrapper>();
        List<ContactWrapper> contactList = new List<ContactWrapper>();
        for(OpportunityContactRole ocr : [SELECT Id, OpportunityId, ContactId, Role, Contact.Name, Contact.X3x3_Level__c, Contact.Title 
                                          FROM OpportunityContactRole 
                                          WHERE Contact.X3x3_Level__c != null AND OpportunityId =: opportunityId]){
            if(!contacts.contains(ocr.ContactId)){
                ContactWrapper conWrapper = new ContactWrapper();
                conWrapper.contactUrl = '/' + ocr.Contact.Id;
                conWrapper.x3x3Level = ocr.Contact.X3x3_Level__c;
                conWrapper.tittle = ocr.Contact.Title;
                conWrapper.name = ocr.Contact.Name;
                conWrapper.id = ocr.ContactId;
                contactList.add(conWrapper);
                contacts.add(ocr.ContactId);
                if(contacts.size() < 3) firstList.add(conWrapper);
            }    
       }
        result.firstList = firstList;  
        result.contactList = contactList; 
        return result;
    }
    public class opportunityWrapper{
        @AuraEnabled
        public OpportunityLineItem oppLineItem{get;set;}
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String productUrl{get;set;}
        @AuraEnabled
        public String productName {get;set;}
        @AuraEnabled
        public boolean lostProduct {get;set;}
        @AuraEnabled
        public String salesType {get;set;}
        @AuraEnabled
        public date startDate {get;set;}
        @AuraEnabled
        public date endDate {get;set;}
    }
    public class ContactWrapperList{
        @AuraEnabled
        public List<ContactWrapper> firstList{get;set;}
        @AuraEnabled
        public List<ContactWrapper> contactList{get;set;}
    }
    public class ContactWrapper{
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String id{get;set;}
        @AuraEnabled
        public String contactUrl{get;set;}
        @AuraEnabled
        public String x3x3Level {get;set;}
        @AuraEnabled
        public String tittle {get;set;}
    }
}