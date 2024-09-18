/**
* Company     : Plative
* Description : Renewal Handler Helper class for Plative_OpportunityTriggerHandler
* History     :
* [31.May.2020] Andrew Vays - Code Creation
*/
public class Plative_OpportunityRenewalHelper {
    
    public static Map<String,Date> keyVsOpptyProdEndDate = new Map<String,Date>();
    
    /**
* Description : Main function invoked by Handler for a closed Won Opportunity that needs to be cloned. 
**/
    public static void handleClosedWonRenewalOpp(List<Opportunity> lstOppty) {
        String renewalOpportunityRecordId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Renewal').getRecordTypeId();      
        Opportunity[] oppsToForecastAndRenew = new Opportunity[]{};
            Opportunity[] renewalOpportunities = new Opportunity[]{};
                Map<Id,OpportunityLineItem[]> soOpportunityLineItemMap = new Map<Id, OpportunityLineItem[]>{};
                    Map<Id,OpportunityContactRole[]> soOpportunityContactRoleMap = new Map<Id, OpportunityContactRole[]>{};
                        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();        
        Map<Id,Opportunity[]> soRenewalOpportunityMap = new  Map<Id,Opportunity[]>{};   
            
        //List will contain Forecasted OLI's for Closed Sales Opp as well as new OLI's for renewal opportunity.     
        OpportunityLineItem[] oliToCreate = new OpportunityLineItem[]{}; 
            //List will contain Opportunity Contact roles for closed Sales Ops
            OpportunityContactRole[] ocrToCReate = new OpportunityContactRole[]{};
                
                //This is no longer needed & needs to be refactored.      
                for (Opportunity Opp : lstOppty){
                    //Since this is a closed Sales Opportunity we can assume that the renewal will occur next year & this is the start of the contract. 
                    //if(Opp.Length_of_Contract__c > 1){
                    oppsToForecastAndRenew.add(Opp);
                    soRenewalOpportunityMap.put(Opp.Id,new Opportunity[]{});
                    opportunityMap.put(opp.Id, opp);
                    //}
                }
        
        OpportunityLineItem[] createdOLIs = [Select Id,Start_Date__c,End_Date__c,OpportunityId,Percentage_of_Total_Amount__c,Product2Id,Quantity,PricebookEntryId, Delivery_Method__c from OpportunityLineItem where OpportunityId in :soRenewalOpportunityMap.keyset() AND Lost_Product__c = false];
        
        for(OpportunityLineItem oli : createdOLIs){
            if(soOpportunityLineItemMap.containsKey(oli.OpportunityId)){
                soOpportunityLineItemMap.get(oli.OpportunityId).add(oli);
            }else{
                soOpportunityLineItemMap.put(oli.OpportunityId,new OpportunityLineItem[]{oli});
            }
            
        }
        
        OpportunityContactRole[] OCRs = [Select Id,ContactId,OpportunityId,IsPrimary,Role from OpportunityContactRole where OpportunityId in :soRenewalOpportunityMap.keyset()];
        
        
        for(OpportunityContactRole ocr : OCRs){
            if(soOpportunityContactRoleMap.containsKey(ocr.OpportunityId)){
                soOpportunityContactRoleMap.get(ocr.OpportunityId).add(ocr);
            }else{
                soOpportunityContactRoleMap.put(ocr.OpportunityId,new OpportunityContactRole[]{ocr});
            }
        }
        //Create Renewal Opportunities 
        for (Opportunity Opp : oppsToForecastAndRenew){
            
            if(Opp.X2nd_Year_Amount_in_USD__c != null){
                renewalOpportunities.add(createRenewalOpp(
                    Opp,
                    renewalOpportunityRecordId,
                    2,
                    '6 - Verbal Win and Finalizing Contract',
                    true
                ));
            }
            
            if(Opp.X3rd_Year_Amount_in_USD__c != null){ 
                renewalOpportunities.add(createRenewalOpp(
                    Opp,
                    renewalOpportunityRecordId,
                    3,
                    '6 - Verbal Win and Finalizing Contract',
                    true
                ));
            }
            if(Opp.Year_4_Amount__c != null){ 
                renewalOpportunities.add(createRenewalOpp(
                    Opp,
                    renewalOpportunityRecordId,
                    4,
                    '6 - Verbal Win and Finalizing Contract',
                    true
                ));
            }
            if(Opp.Year_5_Amount__c != null){ 
                renewalOpportunities.add(createRenewalOpp(
                    Opp,
                    renewalOpportunityRecordId,
                    5,
                    '6 - Verbal Win and Finalizing Contract',
                    true
                ));
            }
            if(Opp.Year_6_Amount__c != null){ 
                renewalOpportunities.add(createRenewalOpp(
                    Opp,
                    renewalOpportunityRecordId,
                    6,
                    '6 - Verbal Win and Finalizing Contract',
                    true
                ));
            }
            if(Opp.Year_7_Amount__c != null){ 
                renewalOpportunities.add(createRenewalOpp(
                    Opp,
                    renewalOpportunityRecordId,
                    7,
                    '6 - Verbal Win and Finalizing Contract',
                    true
                ));
            }
        }
        
        insert renewalOpportunities;
        
        //Create the Opportunity Line Items for each newly created Renewal Opp
        for(Opportunity Opp : renewalOpportunities){
            //This is for a single year Opportunity 
            if(Opp.Automatic_Renewal__c == false && Opp.X2nd_Year_Amount_in_USD__c == null && Opp.X3rd_Year_Amount_in_USD__c == null && Opp.Year_4_Amount__c == null && Opp.Year_5_Amount__c == null && Opp.Year_6_Amount__c == null && Opp.Year_7_Amount__c == null){
                oliToCreate.addAll(createRenewalOppLineItems(soOpportunityLineItemMap.get(Opp.Sales_Opportunity__c), Opp.Id, Opp.Amount, Opp, false, null, Opp.Sales_Opportunity__c));
            } 
            if(Opp.X2nd_Year_Amount_in_USD__c != null){
                oliToCreate.addAll(createRenewalOppLineItems(soOpportunityLineItemMap.get(Opp.Sales_Opportunity__c), Opp.Id, Opp.X2nd_Year_Amount_in_USD__c, Opp, false, 2, Opp.Sales_Opportunity__c));
            } 
            if(Opp.X3rd_Year_Amount_in_USD__c != null){
                oliToCreate.addAll(createRenewalOppLineItems(soOpportunityLineItemMap.get(Opp.Sales_Opportunity__c), Opp.Id, Opp.X3rd_Year_Amount_in_USD__c, Opp, false, 3, Opp.Sales_Opportunity__c));
            } 
            if(Opp.Year_4_Amount__c != null){
                oliToCreate.addAll(createRenewalOppLineItems(soOpportunityLineItemMap.get(Opp.Sales_Opportunity__c), Opp.Id, Opp.Year_4_Amount__c, Opp, false, 4, Opp.Sales_Opportunity__c));
            } 
            if(Opp.Year_5_Amount__c != null){
                oliToCreate.addAll(createRenewalOppLineItems(soOpportunityLineItemMap.get(Opp.Sales_Opportunity__c), Opp.Id, Opp.Year_5_Amount__c, Opp, false, 5, Opp.Sales_Opportunity__c));
            } 
            if(Opp.Year_6_Amount__c != null){
                oliToCreate.addAll(createRenewalOppLineItems(soOpportunityLineItemMap.get(Opp.Sales_Opportunity__c), Opp.Id, Opp.Year_6_Amount__c, Opp, false, 6, Opp.Sales_Opportunity__c));
            } 
            if(Opp.Year_7_Amount__c != null){
                oliToCreate.addAll(createRenewalOppLineItems(soOpportunityLineItemMap.get(Opp.Sales_Opportunity__c), Opp.Id, Opp.Year_7_Amount__c, Opp, false, 7, Opp.Sales_Opportunity__c));
            } 
            
            if(soOpportunityContactRoleMap.keySet().size() > 0 && soOpportunityContactRoleMap.containsKey(Opp.Sales_Opportunity__c)){
                for(OpportunityContactRole OCR : soOpportunityContactRoleMap.get(Opp.Sales_Opportunity__c)){
                    OpportunityContactRole newOCR = new OpportunityContactRole();
                    newOCR.ContactId = OCR.ContactId;
                    //newOCR.OpportunityId = OCR.OpportunityId;
                    newOCR.OpportunityId = Opp.Id;
                    newOCR.IsPrimary = OCR.IsPrimary;
                    newOCR.role = OCR.role;
                    ocrToCReate.add(newOCR);
                }
            }
        }
        
        if(oliToCreate.size() > 0){
            // insert oliToCreate;
            System.enqueueJob(new CreateAsyncOpportunityLineItems(oliToCreate, new List<Id>(soRenewalOpportunityMap.keyset()), false));
        }
        
        /* if(ocrToCReate.size() > 0){
            // insert ocrToCReate;
        }
        
        system.debug('****oliToCreate'+oliToCreate);
        if(!oliToCreate.isEmpty()){
            List<OpportunityLineItem> opptyLineItems = [Select Id,Opportunity.Automatic_Renewal__c,ARR_Formula__c,Product2Id,OpportunityId,Opportunity.Sales_Opportunity__c,Opportunity.X2nd_Year_Amount_in_USD__c, Opportunity.X3rd_Year_Amount_in_USD__c, Opportunity.Year_4_Amount__c,   Opportunity.Year_5_Amount__c, Opportunity.Year_6_Amount__c,Opportunity.Year_7_Amount__c
                                                        from OpportunityLineItem where (Id IN :oliToCreate OR OpportunityId IN :soRenewalOpportunityMap.keyset())];
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
        }*/
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
    
    /**
* Description : Clones Opportunity line items and returns an array of OpportunityLineItem
**/
    private static OpportunityLineItem[] createRenewalOppLineItems(OpportunityLineItem[] OppLineItems, Id childOppId, decimal parentOppAmount, Opportunity Opp, Boolean populateArr, Integer year, Id salesOpptyId){
        
        OpportunityLineItem[] oliToCreate = new OpportunityLineItem[]{};
            //Loops through Parent Opportunity Line Items & Clones them    
            for(OpportunityLineItem OLI : OppLineItems){
                OpportunityLineItem newOLI = new OpportunityLineItem();
                newOLI.OpportunityId = childOppId;
                newOLI.Product2Id = OLI.Product2Id;
                newOLI.PricebookEntryId = OLI.PricebookEntryId;
                newOLI.Quantity = OLI.Quantity;
                system.debug('Percentage_of_Total_Amount__c: ' + OLI.Percentage_of_Total_Amount__c);
                newOLI.UnitPrice = (OLI.Percentage_of_Total_Amount__c * parentOppAmount) / 100;
                //newOLI.Start_Date__c = starDt;
                //newOLI.End_Date__c = endDt;
                newOLI.Sales_Type__c = 'Renewal';
                // SF-560 - Delivery Method Requirements
                newOLI.Delivery_Method__c = OLI.Delivery_Method__c;
                newOLI.Starting_Price__c = populateArr ? OLI.ARR_Formula__c : newOLI.Starting_Price__c;

                newOLI.UnitPrice = populateArr ? newOLI.Starting_Price__c : newOLI.UnitPrice;

                if(!populateArr && salesOpptyId != null && year != null && year == 2){
                    newOLI.Start_Date__c = OLI.End_Date__c != null ? OLI.End_Date__c.addDays(1) : newOLI.Start_Date__c;
                    newOLI.End_Date__c = newOLI.Start_Date__c != null ? newOLI.Start_Date__c.addYears(1).addDays(-1) : newOLI.End_Date__c;
                    if(newOLI.End_Date__c != null){
                        String key = salesOpptyId + '-' + newOLI.Product2Id + '-2';
                        keyVsOpptyProdEndDate.put(key, newOLI.End_Date__c);
                    }
                    
                }
                
                else if(!populateArr && salesOpptyId != null && (year == 3 || year == 4 || year == 5 || year == 6 || year == 7)){
                    String key = salesOpptyId + '-' + newOLI.Product2Id + '-' + (year - 1);
                    if(keyVsOpptyProdEndDate.containsKey(key)){
                        newOLI.Start_Date__c = keyVsOpptyProdEndDate.get(key) != null ? keyVsOpptyProdEndDate.get(key).addDays(1) : newOLI.Start_Date__c;
                        newOLI.End_Date__c = newOLI.Start_Date__c != null ? newOLI.Start_Date__c.addYears(1).addDays(-1) : newOLI.End_Date__c;
                        if(newOLI.End_Date__c != null){
                            String key2 = salesOpptyId + '-' + newOLI.Product2Id + '-' + year;
                            keyVsOpptyProdEndDate.put(key2, newOLI.End_Date__c);
                        }
                    }
                } else if(populateArr && OLI.End_Date__c != null) {
                     newOLI.Start_Date__c = OLI.End_Date__c.addDays(1);
                    newOLI.End_Date__c = newOLI.Start_Date__c.addYears(1).addDays(-1);
                }
                
                /*SF-540 - Leap Year Dates*/
                if(newOLI.Start_Date__c != null && newOLI.End_Date__c != null 
                   && newOLI.Start_Date__c.daysBetween(newOLI.End_Date__c) == 364
                   && ((Date.isLeapYear(newOLI.Start_Date__c.year()) && Date.isLeapYear(newOLI.End_Date__c.year()))
                   ||(!Date.isLeapYear(newOLI.Start_Date__c.year()) && Date.isLeapYear(newOLI.End_Date__c.year()) && newOLI.End_Date__c.dayOfYear() > 59 )
                   ||(Date.isLeapYear(newOLI.Start_Date__c.year()) && !Date.isLeapYear(newOLI.End_Date__c.year()) && newOLI.Start_Date__c.dayOfYear() < 60))) {
                       System.debug('newOLI.Start_Date__c->'+newOLI.Start_Date__c+', newOLI.End_Date__c->'+newOLI.End_Date__c + ', times->'+newOLI.End_Date__c.daysBetween(newOLI.Start_Date__c));
                       newOLI.End_Date__c = newOLI.End_Date__c.addDays(1);
                   }
                    
                
                    
                oliToCreate.add(newOLI);
            }     
        
        return oliToCreate;
    }
    
    /**
* Description : Returns a Cloned Opportunity 
**/
    private static Opportunity createRenewalOpp(Opportunity Opp, id recordTypeId, integer ContractYear, string stageName, boolean renewal){
        
        Opportunity newOpp = new Opportunity();
        newOpp.CloseDate = ContractYear == 1 ? Opp.CloseDate.addYears(ContractYear) : Opp.CloseDate.addYears(ContractYear-1);
        // SF-410
        newOpp.Previous_Score__c = ContractYear == 1 ? Opp.DDS_ScoreAssignment__c : null;
        newOpp.Name = String.ValueOf(newOpp.CloseDate.Year()) + '-' + Opp.Account + '-' + '-Renewal-' + String.ValueOf(newOpp.CloseDate);
        newOpp.RecordTypeId = recordTypeId;
        newOpp.Pricebook2Id = Opp.Pricebook2Id;
        newOpp.CurrencyIsoCode = Opp.CurrencyIsoCode;
        newOpp.Sectors_Sold__c = Opp.Sectors_Sold__c;
        newOpp.Department__c = Opp.Department__c;
        newOpp.Class__c = Opp.Class__c;
        newOpp.Contract_Start_Date__c = Opp.Contract_Start_Date__c;
        newOpp.Contract_End_Date__c = Opp.Contract_End_Date__c;
        newOpp.Billing_Schedule__c = Opp.Billing_Schedule__c;
        newOpp.Billing_Contact__c = Opp.Billing_Contact__c;
        newOpp.Terms__c = Opp.Terms__c;
        newOpp.AccountId = Opp.AccountId;
        newOpp.CampaignId = Opp.CampaignId; 
        newOpp.Non_Standard_Paperwork__c = Opp.Non_Standard_Paperwork__c; 

        if(Opp.Evergreen_Contract__c == true){
            newOpp.stageName = '5 - Negotiation and Agreement Sent';
            newOpp.Next_Year_Increase__c = Opp.Next_Year_Increase__c;
            
        }
        else{
            newOpp.stageName = stageName;
        }
        newOpp.OwnerId = Opp.OwnerId;
        newOpp.Sales_Opportunity__c = Opp.Id;
        newOpp.Automatic_Renewal__c = renewal;
        newOpp.Evergreen_Contract__c = Opp.Evergreen_Contract__c;
        newOpp.Evergreen_Increase__c = Opp.Evergreen_Increase__c;
        newOpp.Current_Contract_Year__c = ContractYear;
        newOpp.Other_Invoice_Frequency__c = String.isNotBlank(Opp.Billing_Schedule__c) && (Opp.Billing_Schedule__c=='Other') ? Opp.Other_Invoice_Frequency__c : newOpp.Other_Invoice_Frequency__c;

        //Update Evergreen This year % increasex 
        if(opp.Next_Year_Increase__c != 0){
            newOpp.This_Year_Increase__c = Opp.Next_Year_Increase__c;
        }
        //Performs different calculations based on ContractYear. Values hard coded as per client spec. 
        switch on ContractYear{
            when 1 {
                newOpp.Amount = Opp.Amount;
            }
            when 2 {
                newOpp.X2nd_Year_Amount_in_USD__c = Opp.X2nd_Year_Amount_in_USD__c;
                newOpp.Amount = Opp.X2nd_Year_Amount_in_USD__c;
            }
            when 3 {
                newOpp.X3rd_Year_Amount_in_USD__c = Opp.X3rd_Year_Amount_in_USD__c;
                newOpp.Amount = Opp.X3rd_Year_Amount_in_USD__c;
            }
            when 4 {
                newOpp.Year_4_Amount__c = Opp.Year_4_Amount__c;
                newOpp.Amount = Opp.Year_4_Amount__c;
            }
            when 5 {
                newOpp.Year_5_Amount__c = Opp.Year_5_Amount__c;
                newOpp.Amount = Opp.Year_5_Amount__c;
            }
            when 6 {
                newOpp.Year_6_Amount__c = Opp.Year_6_Amount__c;
                newOpp.Amount = Opp.Year_6_Amount__c;
            }
            when 7 {
                newOpp.Year_7_Amount__c = Opp.Year_7_Amount__c;
                newOpp.Amount = Opp.Year_7_Amount__c;
            }
        }
        
        return newOpp;
    }
    
    //Create Opportunity Contact Roles
    private static List<OpportunityContactRole> createOpportunityContactRoles(List<OpportunityContactRole> contactRoles, Id opptyId){
        List<OpportunityContactRole> newContactRoles = new List<OpportunityContactRole>();
        for(OpportunityContactRole ocr: contactRoles){
            OpportunityContactRole newOcr = new OpportunityContactRole();
            newOcr.OpportunityId = opptyId;
            newOcr.ContactId = ocr.ContactId;
            newOcr.IsPrimary = ocr.IsPrimary;
            newOcr.Role = ocr.Role;
            newContactRoles.add(newOcr);
        }
        return newContactRoles;
    }
    
    //This method creates Renewal Opportunity
    public static void createNewRenewalOpportunity(List<Opportunity> triggerNew, Map<Id,Opportunity> triggerOldMap){
        
        //Get Renewal Record Type Id
        String renewalOpportunityRecordId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        String salesOppClosedRecordId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Sales Opportunity - Closed').getRecordTypeId();
        String salesOpp = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Sales Opportunity').getRecordTypeId();
        String renewalClosed = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Renewal - Closed').getRecordTypeId();
        
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
        
        for(Opportunity oppty: triggerNew){
            //Check if Create New Renewal Opportunity is true and Stage has been marked as Closed Won
            if((oppty.RecordTypeId == renewalOpportunityRecordId) || (oppty.RecordTypeId == salesOppClosedRecordId) || (oppty.RecordTypeId == salesOpp) || (oppty.RecordTypeId == renewalClosed)){
                if((oppty.Create_New_Renewal_Opportunity__c && !triggerOldMap.get(oppty.Id).Create_New_Renewal_Opportunity__c) && ((oppty.StageName == 'Closed Won') && (triggerOldMap.get(oppty.Id).StageName != oppty.StageName))){
                    opportunityMap.put(oppty.Id,oppty);
                } else if(oppty.Create_New_Renewal_Opportunity__c && (oppty.StageName == 'Closed Won') && (triggerOldMap.get(oppty.Id).StageName != oppty.StageName)){
                    opportunityMap.put(oppty.Id,oppty);
                } else if((oppty.Create_New_Renewal_Opportunity__c && !triggerOldMap.get(oppty.Id).Create_New_Renewal_Opportunity__c) && oppty.StageName == 'Closed Won'){
                    opportunityMap.put(oppty.Id,oppty);
                }
            }
        }
        
        //Get related Opportunity Products 
        Map<Id,List<OpportunityLineItem>> opportunityIdVsProducts = new Map<Id,List<OpportunityLineItem>>();
        List<OpportunityLineItem> opptyLineItemsList = [Select Id,Opportunity.Automatic_Renewal__c,Start_Date__c,End_Date__c,OpportunityId,Percentage_of_Total_Amount__c,Product2Id,Quantity,PricebookEntryId,ARR_Formula__c, Delivery_Method__c from OpportunityLineItem where OpportunityId IN :opportunityMap.keySet() AND Lost_Product__c = false];
        for(Integer i=0,j=opptyLineItemsList.size(); i<j; i++){
            if(!opportunityIdVsProducts.containsKey(opptyLineItemsList[i].OpportunityId)){
                opportunityIdVsProducts.put(opptyLineItemsList[i].OpportunityId, new List<OpportunityLineItem>());
            }
            opportunityIdVsProducts.get(opptyLineItemsList[i].OpportunityId).add(opptyLineItemsList[i]);
        }
        
        //Get related Contact Roles
        Map<Id,List<OpportunityContactRole>> opportunityIdVsContactRoles = new Map<Id,List<OpportunityContactRole>>();
        List<OpportunityContactRole> opportunityContactRoles = [Select Id,ContactId,OpportunityId,IsPrimary,Role from OpportunityContactRole where OpportunityId in :opportunityMap.keySet()];
        for(Integer i=0,j=opportunityContactRoles.size(); i<j; i++){
            if(!opportunityIdVsContactRoles.containsKey(opportunityContactRoles[i].OpportunityId)){
                opportunityIdVsContactRoles.put(opportunityContactRoles[i].OpportunityId, new List<OpportunityContactRole>());
            }
            opportunityIdVsContactRoles.get(opportunityContactRoles[i].OpportunityId).add(opportunityContactRoles[i]);
        }
        
        
        //Create Renewal Opportunities from Qualified Opportunities
        Map<Id,Opportunity> newOpportunityMap = new Map<Id,Opportunity>();
        for(Opportunity oppty: opportunityMap.values()){
            Opportunity newOppty = createRenewalOpp(oppty, renewalOpportunityRecordId, 1, '4 - Recommending', false);
            newOppty.Contract_Start_Date__c = oppty.Contract_End_Date__c != null ? oppty.Contract_End_Date__c.addDays(1) : null;
            newOppty.Contract_End_Date__c = newOppty.Contract_Start_Date__c != null ? newOppty.Contract_Start_Date__c.addYears(1).addDays(-1) : null;
            newOppty.StageName = '2 - Conducting Needs Analysis';
            newOpportunityMap.put(oppty.Id, newOppty);
        }
        
        //Insert Renewal Opportunities
        insert newOpportunityMap.values();
        
        //Create Opportunity Products & Contact Roles
        List<OpportunityContactRole> opportunityContactRolesToInsert = new List<OpportunityContactRole>();
        List<OpportunityLineItem> opportunityProductsToInsert = new List<OpportunityLineItem>();
        for(Id closedOpptyId: newOpportunityMap.keyset()){
            
            //Create Products
            if(opportunityIdVsProducts.containsKey(closedOpptyId)){
                Opportunity renewalOppty = newOpportunityMap.get(closedOpptyId);
                List<OpportunityLineItem> opportunityProducts = createRenewalOppLineItems(opportunityIdVsProducts.get(closedOpptyId), renewalOppty.Id, renewalOppty.Amount, renewalOppty, true, null, null);
                opportunityProductsToInsert.addAll(opportunityProducts);
            }
            
            //Create Opportunity Contact Roles
            if(opportunityIdVsContactRoles.containsKey(closedOpptyId)){
                Opportunity renewalOppty = newOpportunityMap.get(closedOpptyId);
                opportunityContactRolesToInsert.addAll(createOpportunityContactRoles(opportunityIdVsContactRoles.get(closedOpptyId), renewalOppty.Id));
            }
        }
        
        //Insert Opportunity Products for Renewed Opportunities
        // insert opportunityProductsToInsert;
        if(!opportunityProductsToInsert.isEmpty()) System.enqueueJob(new CreateAsyncOpportunityLineItems(opportunityProductsToInsert, new List<Id>(), true));

        
        //Insert Contact Roles for Renewed Opportunities;
        insert opportunityContactRolesToInsert;
        
    }

    public static void updateOpportunityProduct(List<Opportunity> triggerNew){

        // Get all the Opportunity Products for changed opportunities

        Map<Id,Opportunity> mapOpportunity = new Map<Id,Opportunity>(triggerNew);

        List<OpportunityLineItem> listLineItems = [Select id,Starting_Price__c,UnitPrice,Upsell_Cross_sell__c,OpportunityId 
                                                   FROM OpportunityLineItem 
                                                   WHERE OpportunityId in: triggerNew
                                                   AND Upsell_Cross_sell__c = false];

        for(OpportunityLineItem lineItem : listLineItems){
            Decimal incresedPerc = mapOpportunity.get(lineItem.OpportunityId).This_Year_Increase__c;
            Decimal calculatedUnitPrice = lineItem.Starting_Price__c + (lineItem.Starting_Price__c * (incresedPerc/100));
            lineItem.UnitPrice = calculatedUnitPrice;
        }

        update listLineItems;
    }
    public static void updateOpportunityAllocatedAmount(List<Opportunity> triggerNew){

        // Get all the Opportunity Products for changed opportunities
        Map<Id,Opportunity> mapOpportunity = new Map<Id,Opportunity>(triggerNew);
        List<OpportunityLineItem> listLineItems = [Select id, Allocated__c, Starting_Price__c,
                                                   UnitPrice,Upsell_Cross_sell__c,OpportunityId, ARR_Formula__c, 
                                                   End_Date__c, Start_Date__c
                                                   FROM OpportunityLineItem 
                                                   WHERE OpportunityId in: triggerNew AND UnitPrice > 0];
		 
        for(OpportunityLineItem lineItem : listLineItems) {
            Opportunity oppInfo = mapOpportunity.get(lineItem.OpportunityId);
            if (lineItem.Start_Date__c == null || lineItem.End_Date__c == null) {
                oppInfo.Designated_ARR__c.addError('Start and End Dates are required for each product to update ARR');
                continue;
            }
            Integer days = 365;
            Integer daysDiff = lineItem.Start_Date__c.daysBetween(lineItem.End_Date__c);
            if(daysDiff == 364 || daysDiff == 365 || daysDiff == 366) days = daysDiff;
            Decimal designatedARR = oppInfo.Designated_ARR__c;
            Decimal storeARR = oppInfo.Total_ARR__c;
            Decimal calculatedARRPerLine = (lineItem.ARR_Formula__c/storeARR)*100;
            Decimal newSalesPrice = lineItem.UnitPrice + (lineItem.UnitPrice * (calculatedARRPerLine/100));
            lineItem.Allocated__c = calculatedARRPerLine;
            Decimal newCalculatedARR = (calculatedARRPerLine*designatedARR)/100;
            Decimal times = ((Double)(lineItem.Start_Date__c.daysBetween(lineItem.End_Date__c))/days)*100;
            lineItem.UnitPrice = (newCalculatedARR*times)/100;
            System.debug('days->'+days+', daysDiff->'+daysDiff + ', times->'+times);
            System.debug('newCalculatedARR->'+newCalculatedARR+', UnitPrice->'+lineItem.UnitPrice);
        }

        update listLineItems;
    }
    // SF-964 : Creatating Multiple Client Access Cases for Green Street or Green Street News
    public static void CreateDeActivationCases(List<Opportunity> triggerNew, Map<Id,Opportunity> triggerOldMap){
        List<Case> caseList = new List<Case>();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Client_Access').getRecordTypeId();
        Group groupInfo = [Select Id, name from Group where DeveloperName = 'Client_Deactivation' AND Type = 'Queue' LIMIT 1];
        
        // Get Green Street News product List to create DeActivation Case
        System_Configuration__mdt productConfig = System_Configuration__mdt.getInstance('Green_Street_News_Platform');
        List<String> newsPlatformProductList = productConfig.Value__c.split(';');
        
        // Get Green Street Locatus product List to create DeActivation Case
        System_Configuration__mdt locatusProductConfig = System_Configuration__mdt.getInstance('Green_Street_Locatus_Platform');
        List<String> locatusPlatformProductList = locatusProductConfig.Value__c.split(';');
        
        // Get Green Street IJGlobal product List to create DeActivation Case
        System_Configuration__mdt ijGlobalProductConfig = System_Configuration__mdt.getInstance('Green_Street_IJGlobal_Platform');
        List<String> ijGlobalPlatformProductList = ijGlobalProductConfig.Value__c.split(';');

        for(Opportunity opp : triggerNew) {
            Opportunity oldOpp = triggerOldMap.get(opp.Id);
            // Checking Same criteria as per Opportunity Processes Builder logic 
            if(opp.IsClosed && String.isNotBlank(opp.Activation_Deactivation_Needs__c) 
               && opp.Activation_Deactivation_Needs__c != 'None' && oldOpp.IsClosed != opp.IsClosed) {
                   String products = opp.Products__c;
                   Boolean isGreenStreetNews = false;
                   Boolean isGreenStreetlocatus = false;
                   Boolean isGreenStreetIJGlobal = false;
                   Boolean isGreenStreet = false;
                   // For Green Street News product Check
                   for(String product : newsPlatformProductList) {
                       if(String.isNotBlank(products) && products.containsIgnoreCase(product)) {
                           isGreenStreetNews = true;
                           break;
                       }
                   }
                   // For Green Street locatus product Check
                   for(String locatusProduct : locatusPlatformProductList) {
                       if(String.isNotBlank(products) && products.containsIgnoreCase(locatusProduct)) {
                           isGreenStreetlocatus = true;
                           break;
                       }
                   }
                   // For Green Street ijGlobal product Check
                   for(String ijGlobalProduct : ijGlobalPlatformProductList) {
                       if(String.isNotBlank(products) && products.containsIgnoreCase(ijGlobalProduct)) {
                           isGreenStreetIJGlobal = true;
                           break;
                       }
                   }
                   // For Green Street product Check
                   if(String.isNotBlank(products)) {
                       for(String oppProduct : products.split(';')) {
                           if(!newsPlatformProductList.contains(oppProduct) && !locatusPlatformProductList.contains(oppProduct) && !ijGlobalPlatformProductList.contains(oppProduct)) {
                               isGreenStreet = true;
                               break;
                           }
                       }
                   }
                   system.debug('isGreenStreetIJGlobal->' + isGreenStreetIJGlobal);
                   system.debug('isGreenStreetlocatus->' + isGreenStreetlocatus);
                   system.debug('isGreenStreetNews->' + isGreenStreetNews);
                   system.debug('isGreenStreet->' + isGreenStreet);

                   // Green Street Platform Case
                   if(isGreenStreet) {
                       Case activationCase = new Case(BusinessHoursId = System.Label.Default_Business_Hours_Id, recordTypeId = recordTypeId,
                                                      AccountId = opp.AccountId, ActivationDeactivation_Needs__c = opp.Activation_Deactivation_Needs__c,
                                                      CurrencyIsoCode = 'USD', Due_Date__c = opp.Contract_Start_Date__c, Minutes_Spent_Cases__c = 3,
                                                      Opportunity__c = opp.Id, Origin = 'Automation', ownerId = groupInfo.Id, Priority = 'High', 
                                                      Status = 'New', Subject = Opp.Account_Name__c +' - '+ opp.Activation_Deactivation_Needs__c, Platform__c = 'Green Street');
                       caseList.add(activationCase);
                   }
                   if(isGreenStreetNews) {
                       Case activationCaseForNews = new Case(BusinessHoursId = System.Label.Default_Business_Hours_Id, recordTypeId = recordTypeId,
                                                      AccountId = opp.AccountId, ActivationDeactivation_Needs__c = opp.Activation_Deactivation_Needs__c,
                                                      CurrencyIsoCode = 'USD', Due_Date__c = opp.Contract_Start_Date__c, Minutes_Spent_Cases__c = 3,
                                                      Opportunity__c = opp.Id, Origin = 'Automation', ownerId = groupInfo.Id, Priority = 'High', 
                                                      Status = 'New', Subject = Opp.Account_Name__c +' - '+ opp.Activation_Deactivation_Needs__c, Platform__c = 'Green Street News');
                       caseList.add(activationCaseForNews); 
                   }
                   if(isGreenStreetlocatus) {
                       Case activationCaseForlocatus = new Case(BusinessHoursId = System.Label.Default_Business_Hours_Id, recordTypeId = recordTypeId,
                                                      AccountId = opp.AccountId, ActivationDeactivation_Needs__c = opp.Activation_Deactivation_Needs__c,
                                                      CurrencyIsoCode = 'USD', Due_Date__c = opp.Contract_Start_Date__c, Minutes_Spent_Cases__c = 3,
                                                      Opportunity__c = opp.Id, Origin = 'Automation', ownerId = groupInfo.Id, Priority = 'High', 
                                                      Status = 'New', Subject = Opp.Account_Name__c +' - '+ opp.Activation_Deactivation_Needs__c, Platform__c = 'Locatus');
                       caseList.add(activationCaseForlocatus);
                   }
                   if(isGreenStreetIJGlobal) {
                       Case activationCaseForIJGlobal = new Case(BusinessHoursId = System.Label.Default_Business_Hours_Id, recordTypeId = recordTypeId,
                                                      AccountId = opp.AccountId, ActivationDeactivation_Needs__c = opp.Activation_Deactivation_Needs__c,
                                                      CurrencyIsoCode = 'USD', Due_Date__c = opp.Contract_Start_Date__c, Minutes_Spent_Cases__c = 3,
                                                      Opportunity__c = opp.Id, Origin = 'Automation', ownerId = groupInfo.Id, Priority = 'High', 
                                                      Status = 'New', Subject = Opp.Account_Name__c +' - '+ opp.Activation_Deactivation_Needs__c, Platform__c = 'IJGlobal');
                       caseList.add(activationCaseForIJGlobal);
                   }
               }  
        }
        system.debug('caseList->' + caseList);
        if(!caseList.isEmpty() && caseList.size() > 0) insert caseList;
    }
}