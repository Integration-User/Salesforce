global class CloneOpportunityForAccountsBatch implements Database.Batchable<SObject>,Database.Stateful {
    public Map <Id, Opportunity> SucessOppForAccount = new Map <Id, Opportunity>();
    
    // ID of the template Opportunity and Product2
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Set<Id> accountList = New Set<Id>();
        for (Subscription__c subscription : [SELECT Account__c FROM Subscription__c Where Status__c = 'Active' AND End_Date__c > 2025-07-02]) {
            accountList.add(subscription.Account__c);
        }
        return Database.getQueryLocator([
            SELECT Id, name, AccountId, StageName, Company_Type_Opp__c, CloseDate, Create_New_Renewal_Opportunity__c, Current_Contract_Year__c, 
            CurrencyIsoCode, Exclude_from_Deal_Scoring_Model__c, Customer_Channel_New__c, RecordTypeId, Pricebook2Id, Sectors_Sold__c, 
            Department__c, Department_Id__c,Class__c,Currency_NS_Internal_Id__c, Contract_Start_Date__c,Contract_End_Date__c,Sales_Type__c,
            (Select Id, End_Date__c,Licenses__c From OpportunityLineItems where Product2.Name = 'IJGlobal: News')
            FROM Opportunity 
            WHERE Id IN (
                SELECT OpportunityId 
                FROM OpportunityLineItem 
                WHERE PricebookEntry.Product2.Name = 'IJGlobal: News' 
            ) AND AccountId IN :accountList /*AND AccountId = '001WI00000I6ibtYAB'*/ AND StageName = 'Closed Won' ORDER BY LastModifiedDate DESC
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        // Still load the template Opportunity and Pricebook Entry as before
        List<Opportunity> templateOpp = [Select Id FROM Opportunity WHERE Id IN (SELECT OpportunityId FROM OpportunityLineItem WHERE PricebookEntry.Product2.Name = 'IJGlobal: IJ Investor') AND AccountId = :scope[0].AccountId];
        if(templateOpp.isEmpty() && !SucessOppForAccount.containsKey(scope[0].AccountId)) {
            Plative_OpportunityTriggerHandler.skipValidationForBatch = true;
            Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Existing_Business').getRecordTypeId();
            List<Opportunity> newOpps = new List<Opportunity>();
            Map<Id, OpportunityLineItem> oli = new Map<Id, OpportunityLineItem>();
            for (Opportunity oldOpp : scope) {
                Opportunity newOpp = oldOpp.clone(false, false, false, false);
                newOpp.CloseDate = System.today();
                newOpp.Create_New_Renewal_Opportunity__c = false;
                newOpp.Current_Contract_Year__c = null;
                newopp.RecordTypeId = oppRecordTypeId;
                newopp.Contract_Start_Date__c = Date.newInstance(2025, 7, 17);
                newopp.StageName = '2 - Conducting Needs Analysis';
                newOpps.add(newOpp);
                oli.put(oldOpp.Id, oldOpp.OpportunityLineItems[0]);
            }
            insert newOpps;
            
            List<OpportunityLineItem> items = new List<OpportunityLineItem>();
            for (Opportunity opp : newOpps) {
                PricebookEntry pbe = [Select Id, UnitPrice, Product2ID FROM PricebookEntry WHERE Product2.Name = 'IJGlobal: IJ Investor' AND Pricebook2Id = :opp.Pricebook2Id AND CurrencyIsoCode = :opp.CurrencyIsoCode];
                items.add(new OpportunityLineItem(
                    OpportunityId = opp.Id,
                    Quantity = 1,
                    Product2Id = pbe.Product2Id,
                    Start_Date__c = Date.newInstance(2025, 7, 17),
                    End_Date__c = oli.get(scope[0].Id).End_Date__c,
                    Licenses__c = oli.get(scope[0].Id).Licenses__c,
                    Sales_Type__c = 'Renewal',
                    PricebookEntryId = pbe.Id,
                    TotalPrice = 0.0,
                    Starting_Price__c = 0.0
                ));
            }
            insert items;
            
            for (Opportunity opp : newOpps) {
                opp.StageName = 'Closed Won';
            }
            update newOpps;
            SucessOppForAccount.put(scope[0].AccountId, newOpps[0]);
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Batch complete!');
        String generatedCSVFile ='Account Id, OpportunityId, Stage Name\n';
        for (Id accountId : SucessOppForAccount.keySet()) {
            String fileRow = accountId + ',' + SucessOppForAccount.get(accountId).Id+ ',' + SucessOppForAccount.get(accountId).StageName;
            generatedCSVFile +=  fileRow + '\n';
        }
        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        Blob csvBlob = blob.valueOf(generatedCSVFile);
        String csvName = 'Update Opportunity For Account - Prod.csv';
        csvAttachment.setFileName(csvName);
        csvAttachment.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'mgupta@greenstreet.com'};
            String subject = 'Update Opportunity For Account - Prod.csv';
        email.setSubject(subject);
        email.setToAddresses(toAddresses);
        email.setPlainTextBody('Update Opportunity For Account - Prod.csv');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
        if(!Test.isRunningTest()) Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }
}