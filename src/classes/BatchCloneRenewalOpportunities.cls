public class BatchCloneRenewalOpportunities implements Database.Batchable<SObject>, Database.Stateful {
    // Track results for CSV
    private List<ResultRow> results = new List<ResultRow>();

    public class ResultRow {
        public Id stagingId;
        public String status;
        public String message;
        public ResultRow(Id stagingId, String status, String message) {
            this.stagingId = stagingId;
            this.status = status;
            this.message = message;
        }
    }
    // Query all records from Staging_Opportunity_Data__c
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Account_Id__c, Opportunity_Id__c, Open_Renewal_Product_End_Date__c, Open_Renewal_Product_Start_Date__c, Contract_Start_Date__c, Contract_End_Date__c, US_Detailed_NAV__c, US_Portfolio_Tool__c, US_Tertiary_Data__c,Are_the_products_already_on_the_renewal__c  FROM Staging_Opportunity_Data__c');
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        Map<Id, Staging_Opportunity_Data__c> oppToStagingMap = new Map<Id, Staging_Opportunity_Data__c>();
        Set<Id> oppIds = new Set<Id>();
        Savepoint sp;
        try {
            sp = Database.setSavepoint();
            for (SObject s : scope) {
                Staging_Opportunity_Data__c sod = (Staging_Opportunity_Data__c) s;
                if (sod.Opportunity_Id__c != null && sod.Account_Id__c != null) {
                    oppIds.add(sod.Opportunity_Id__c);
                    oppToStagingMap.put(sod.Opportunity_Id__c, sod);
                }
            }
            system.debug('oppIds->' + oppIds);
            if (!oppIds.isEmpty()) {
                Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
                    SELECT Id, Name, StageName, Amount, RecordTypeId, AccountId, OwnerId, Description, CurrencyIsoCode, Pricebook2Id, Account_Name__c,
                    Company_Type_Opp__c, CloseDate, Create_New_Renewal_Opportunity__c, Current_Contract_Year__c, 
                    Exclude_from_Deal_Scoring_Model__c, Customer_Channel_New__c, Sectors_Sold__c, Contract_Start_Date__c,Contract_End_Date__c,Sales_Type__c,
                    Department__c, Department_Id__c,Class__c,Currency_NS_Internal_Id__c, Account.OwnerId, Account.CurrencyIsoCode
                    FROM Opportunity WHERE Id IN :oppIds
                ]);
                system.debug('oppMap->' + oppMap);

                Id renewalRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                Map<String, Id> productNameToId = new Map<String, Id>();
                Map<String, Id> productNameToIdWithCurrency = new Map<String, Id>();
                for (Product2 p : [SELECT Id, Name, CurrencyIsoCode FROM Product2 WHERE Name IN ('US Detailed NAV', 'US Portfolio Tools', 'US Tertiary Market Data') AND IsActive = true]) {
                    productNameToId.put(p.Name, p.Id);
                    productNameToIdWithCurrency.put(p.Name + '|' + p.CurrencyIsoCode , p.Id);
                }
                List<Opportunity> newOpps = new List<Opportunity>();
                Map<Id, Opportunity> stagingIdToNewOpp = new Map<Id, Opportunity>();
                List<OpportunityLineItem> oliToInsert = new List<OpportunityLineItem>();
                Plative_OpportunityTriggerHandler.skipValidationForBatch = true;

                // 1. Add line items to existing Opportunities (do not close)
                for (Staging_Opportunity_Data__c sod : (List<Staging_Opportunity_Data__c>)scope) {
                    Opportunity existingOpp = oppMap.get(sod.Opportunity_Id__c);
                    if (existingOpp != null && !sod.Are_the_products_already_on_the_renewal__c) {
                        if (sod.US_Detailed_NAV__c == true && productNameToId.containsKey('US Detailed NAV')) {
                            Id prodId = productNameToIdWithCurrency.containsKey('US Detailed NAV|'+ existingOpp.CurrencyIsoCode) ? productNameToIdWithCurrency.get('US Detailed NAV|'+ existingOpp.CurrencyIsoCode) : productNameToId.get('US Detailed NAV');
                            Id pbeId = getPricebookEntryId(prodId, existingOpp.Pricebook2Id, existingOpp.CurrencyIsoCode);
                            if (pbeId != null) {
                                OpportunityLineItem oli = new OpportunityLineItem();
                                oli.OpportunityId = existingOpp.Id;
                                oli.PricebookEntryId = pbeId;
                                oli.Quantity = 1;
                                oli.Product2Id = prodId;
                                oli.TotalPrice = 0;
                                oli.Starting_Price__c = 0.0;
                                oli.Start_Date__c = sod.Open_Renewal_Product_Start_Date__c;
                                oli.End_Date__c = sod.Open_Renewal_Product_End_Date__c;
                                oli.Sales_Type__c = 'Upsell';
                                oli.Upsell_Cross_sell__c = true;
                                oliToInsert.add(oli);
                            }
                        }
                        if (sod.US_Portfolio_Tool__c == true && productNameToId.containsKey('US Portfolio Tools')) {
                            Id prodId = productNameToIdWithCurrency.containsKey('US Portfolio Tools|'+ existingOpp.CurrencyIsoCode) ? productNameToIdWithCurrency.get('US Portfolio Tools|'+ existingOpp.CurrencyIsoCode) : productNameToId.get('US Portfolio Tools');
                            Id pbeId = getPricebookEntryId(prodId, existingOpp.Pricebook2Id, existingOpp.CurrencyIsoCode);
                            if (pbeId != null) {
                                OpportunityLineItem oli = new OpportunityLineItem();
                                oli.OpportunityId = existingOpp.Id;
                                oli.PricebookEntryId = pbeId;
                                oli.Quantity = 1;
                                oli.Product2Id = prodId;
                                oli.TotalPrice = 0;
                                oli.Starting_Price__c = 0.0;
                                oli.Start_Date__c = sod.Open_Renewal_Product_Start_Date__c;
                                oli.End_Date__c = sod.Open_Renewal_Product_End_Date__c;
                                oli.Sales_Type__c = 'Upsell';
                                oli.Upsell_Cross_sell__c = true;
                                oliToInsert.add(oli);
                            }
                        }
                        if (sod.US_Tertiary_Data__c == true && productNameToId.containsKey('US Tertiary Market Data')) {
                            Id prodId = productNameToIdWithCurrency.containsKey('US Tertiary Market Data|'+ existingOpp.CurrencyIsoCode) ? productNameToIdWithCurrency.get('US Tertiary Market Data|'+ existingOpp.CurrencyIsoCode) : productNameToId.get('US Tertiary Market Data');
                            Id pbeId = getPricebookEntryId(prodId, existingOpp.Pricebook2Id, existingOpp.CurrencyIsoCode);
                            if (pbeId != null) {
                                OpportunityLineItem oli = new OpportunityLineItem();
                                oli.OpportunityId = existingOpp.Id;
                                oli.PricebookEntryId = pbeId;
                                oli.Quantity = 1;
                                oli.Product2Id = prodId;
                                oli.TotalPrice = 0;
                                oli.Starting_Price__c = 0.0;
                                oli.Start_Date__c = sod.Open_Renewal_Product_Start_Date__c;
                                oli.End_Date__c = sod.Open_Renewal_Product_End_Date__c;
                                oli.Sales_Type__c = 'Upsell';
                                oli.Upsell_Cross_sell__c = true;
                                oliToInsert.add(oli);
                            }
                        }
                    }
                }
                System.debug('oliToInsert-?' + oliToInsert.size());

                // 2. Continue with renewal logic (clone, add line items, close)
                for (Id oppId : oppIds) {
                    Opportunity origOpp = oppMap.get(oppId);
                    Staging_Opportunity_Data__c sod = oppToStagingMap.get(oppId);
                    if (origOpp != null && sod != null) {
                        Opportunity newOpp = origOpp.clone(false, false, false, false);
                        newOpp.RecordTypeId = renewalRTId;
                        newOpp.Contract_Start_Date__c = sod.Contract_Start_Date__c;
                        newOpp.Contract_End_Date__c = sod.Contract_End_Date__c;
                        newOpp.StageName = '2 - Conducting Needs Analysis';
                        newOpp.CloseDate = System.today();
                        newOpp.Create_New_Renewal_Opportunity__c = false;
                        newOpp.Current_Contract_Year__c = null;
                        newOpp.OwnerId = origOpp.Account.OwnerId;
                        newopp.CurrencyIsoCode = origOpp.Account.CurrencyIsoCode;
                        newopp.Activation_Deactivation_Needs__c = 'Full Account Activation';
                        newOpps.add(newOpp);
                        stagingIdToNewOpp.put(sod.Id, newOpp);  
                    }
                }
                if (!newOpps.isEmpty()) {
                    insert newOpps;
                }
                System.debug('newOpps->' + newOpps);
                for (Staging_Opportunity_Data__c sod : (List<Staging_Opportunity_Data__c>)scope) {
                    Opportunity newOpp = stagingIdToNewOpp.get(sod.Id);
                    if (newOpp == null) continue;
                    if (sod.US_Detailed_NAV__c == true && productNameToId.containsKey('US Detailed NAV')) {
                        Id prodId = productNameToIdWithCurrency.containsKey('US Detailed NAV|'+ newOpp.CurrencyIsoCode) ? productNameToIdWithCurrency.get('US Detailed NAV|'+ newOpp.CurrencyIsoCode) : productNameToId.get('US Detailed NAV');
                        Id pbeId = getPricebookEntryId(prodId, newOpp.Pricebook2Id, newOpp.CurrencyIsoCode);
                        if (pbeId != null) {
                            OpportunityLineItem oli = new OpportunityLineItem();
                            oli.OpportunityId = newOpp.Id;
                            oli.PricebookEntryId = pbeId;
                            oli.Quantity = 1;
                            oli.Product2Id = prodId;
                            oli.TotalPrice = 0;
                            oli.Starting_Price__c = 0.0;
                            oli.Start_Date__c = sod.Contract_Start_Date__c;
                            oli.End_Date__c = sod.Contract_End_Date__c;
                            oli.Sales_Type__c = 'Upsell';
                            oli.Upsell_Cross_sell__c = true;
                            oliToInsert.add(oli);
                        }
                    }
                    if (sod.US_Portfolio_Tool__c == true && productNameToId.containsKey('US Portfolio Tools')) {
                        Id prodId = productNameToIdWithCurrency.containsKey('US Portfolio Tools|'+ newOpp.CurrencyIsoCode) ? productNameToIdWithCurrency.get('US Portfolio Tools|'+ newOpp.CurrencyIsoCode) : productNameToId.get('US Portfolio Tools');
                        Id pbeId = getPricebookEntryId(prodId, newOpp.Pricebook2Id, newOpp.CurrencyIsoCode);
                        if (pbeId != null) {
                            OpportunityLineItem oli = new OpportunityLineItem();
                            oli.OpportunityId = newOpp.Id;
                            oli.PricebookEntryId = pbeId;
                            oli.Quantity = 1;
                            oli.Product2Id = prodId;
                            oli.TotalPrice = 0;
                            oli.Starting_Price__c = 0.0;
                            oli.Start_Date__c = sod.Contract_Start_Date__c;
                            oli.End_Date__c = sod.Contract_End_Date__c;
                            oli.Sales_Type__c = 'Upsell';
                            oli.Upsell_Cross_sell__c = true;
                            oliToInsert.add(oli);
                        }
                    }
                    if (sod.US_Tertiary_Data__c == true && productNameToId.containsKey('US Tertiary Market Data')) {
                        Id prodId = productNameToIdWithCurrency.containsKey('US Tertiary Market Data|'+ newOpp.CurrencyIsoCode) ? productNameToIdWithCurrency.get('US Tertiary Market Data|'+ newOpp.CurrencyIsoCode) : productNameToId.get('US Tertiary Market Data');
                        Id pbeId = getPricebookEntryId(prodId, newOpp.Pricebook2Id, newOpp.CurrencyIsoCode);
                        if (pbeId != null) {
                            OpportunityLineItem oli = new OpportunityLineItem();
                            oli.OpportunityId = newOpp.Id;
                            oli.PricebookEntryId = pbeId;
                            oli.Quantity = 1;
                            oli.Product2Id = prodId;
                            oli.TotalPrice = 0;
                            oli.Starting_Price__c = 0.0;
                            oli.Start_Date__c = sod.Contract_Start_Date__c;
                            oli.End_Date__c = sod.Contract_End_Date__c;
                            oli.Sales_Type__c = 'Upsell';
                            oli.Upsell_Cross_sell__c = true;
                            oliToInsert.add(oli);
                        }
                    }
                }
                System.debug('oliToInsert-?' + oliToInsert);
                if (!oliToInsert.isEmpty()) {
                    insert oliToInsert;
                }
                List<Opportunity> toClose = new List<Opportunity>();
                List<Case> caseList = new List<Case>();
                Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Client_Access').getRecordTypeId();
                Group groupInfo = [Select Id, name from Group where DeveloperName = 'Client_Deactivation' AND Type = 'Queue' LIMIT 1];
                for (Opportunity opp : newOpps) {
                    opp.StageName = 'Closed Won';
                    toClose.add(opp);
                    Case activationCase = new Case(BusinessHoursId = System.Label.Default_Business_Hours_Id, recordTypeId = recordTypeId,
                                                   AccountId = opp.AccountId, ActivationDeactivation_Needs__c = opp.Activation_Deactivation_Needs__c,
                                                   CurrencyIsoCode = 'USD', Due_Date__c = opp.Contract_Start_Date__c, Minutes_Spent_Cases__c = 3,
                                                   Opportunity__c = opp.Id, Origin = 'Automation', ownerId = groupInfo.Id, Priority = 'High', 
                                                   Status = 'New', Subject = Opp.Account_Name__c +' - '+ opp.Activation_Deactivation_Needs__c, Platform__c = 'Green Street');
                    caseList.add(activationCase);
                }
                if (!toClose.isEmpty()) {
                    update toClose;
                    system.debug('caseList->' + caseList);
                    if(!caseList.isEmpty() && caseList.size() > 0) insert caseList;
                }
                
                // Success for all in scope
                for (Staging_Opportunity_Data__c sod : (List<Staging_Opportunity_Data__c>)scope) {
                    results.add(new ResultRow(sod.Id, 'Success', 'Line items added to existing and renewal opportunities'));
                }
            }
        } catch (Exception e) {
            Database.rollback(sp);
            // Mark all as failed in this scope
            for (SObject s : scope) {
                Staging_Opportunity_Data__c sod = (Staging_Opportunity_Data__c)s;
                results.add(new ResultRow(sod.Id, 'Failed', e.getMessage()));
            }
        }
    }
    // Helper to get PricebookEntryId for a product, pricebook, and currency
    public Id getPricebookEntryId(Id productId, Id pricebookId, String currencyIsoCode) {
        List<PricebookEntry> pbes = [SELECT Id FROM PricebookEntry WHERE Product2Id = :productId AND Pricebook2Id = :pricebookId AND IsActive = true AND CurrencyIsoCode = :currencyIsoCode LIMIT 1];
        return pbes.isEmpty() ? null : pbes[0].Id;
    }

    public void finish(Database.BatchableContext bc) {
        // Prepare CSV
        String header = 'StagingId, Status, Message\n';
        String body = '';
        for (ResultRow row : results) {
            body += row.stagingId + ',' + row.status + ',' + row.message + '\n';
        }
        String csv = header + body;

        // Send email
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('SF-1737_BatchResults.csv');
        attachment.setBody(Blob.valueOf(csv));
        attachment.setContentType('text/csv');

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'mgupta@greenstreet.com'}); // TODO: Set to actual recipient
        mail.setSubject('SF-1737 : Batch Clone Renewal Opportunities Results');
        mail.setPlainTextBody('Please find attached the batch results.');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachment});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
}
