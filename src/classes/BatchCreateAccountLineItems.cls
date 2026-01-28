public class BatchCreateAccountLineItems implements Database.Batchable<SObject>, Database.Stateful {
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
        return Database.getQueryLocator('SELECT Id, Account_Id__c, US_Detailed_NAV__c, US_Portfolio_Tool__c, US_Tertiary_Data__c FROM Staging_Opportunity_Data__c');
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        Map<Id, Staging_Opportunity_Data__c> oppToStagingMap = new Map<Id, Staging_Opportunity_Data__c>();
        Set<Id> accIds = new Set<Id>();
        Savepoint sp;
        try {
            sp = Database.setSavepoint();
            for (SObject s : scope) {
                Staging_Opportunity_Data__c sod = (Staging_Opportunity_Data__c) s;
                if (sod.Account_Id__c != null) {
                    accIds.add(sod.Account_Id__c);
                }
            }
            system.debug('accIds->' + accIds);
            if (!accIds.isEmpty()) {
                Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, CurrencyIsoCode FROM Account WHERE Id IN :accIds]);
                system.debug('accMap->' + accMap);

                Map<String, Id> productNameToIdWithCurrency = new Map<String, Id>();
                Map<String, Id> productNameToId = new Map<String, Id>();
                for (Product2 p : [SELECT Id, Name, CurrencyIsoCode FROM Product2 WHERE Name IN ('US Detailed NAV', 'US Portfolio Tools', 'US Tertiary Market Data') AND IsActive = true]) {
                    productNameToId.put(p.Name, p.Id);
                    productNameToIdWithCurrency.put(p.Name + '|' + p.CurrencyIsoCode , p.Id);
                }
                List<Account_Product_Line__c> newLineItems = new List<Account_Product_Line__c>();
                // 1. Add line items to existing Opportunities (do not close)
                for (Staging_Opportunity_Data__c sod : (List<Staging_Opportunity_Data__c>)scope) {
                    Account acc = accMap.get(sod.Account_Id__c);
                        if (sod.US_Detailed_NAV__c == true && productNameToId.containsKey('US Detailed NAV')) {
                            Id prodId = productNameToIdWithCurrency.containsKey('US Detailed NAV|'+ acc.CurrencyIsoCode) ? productNameToIdWithCurrency.get('US Detailed NAV|'+ acc.CurrencyIsoCode) : productNameToId.get('US Detailed NAV');
                            Account_Product_Line__c newProductLine = new Account_Product_Line__c();
                            newProductLine.Product__c = prodId;
                            newProductLine.Account__c = sod.Account_Id__c;
                            newLineItems.add(newProductLine);
                        }
                        if (sod.US_Portfolio_Tool__c == true && productNameToId.containsKey('US Portfolio Tools')) {
                            Id prodId = productNameToIdWithCurrency.containsKey('US Portfolio Tools|'+ acc.CurrencyIsoCode) ? productNameToIdWithCurrency.get('US Portfolio Tools|'+ acc.CurrencyIsoCode) : productNameToId.get('US Portfolio Tools');
                            Account_Product_Line__c newProductLine = new Account_Product_Line__c();
                            newProductLine.Product__c = prodId;
                            newProductLine.Account__c = sod.Account_Id__c;
                            newLineItems.add(newProductLine);
                        }
                        if (sod.US_Tertiary_Data__c == true && productNameToId.containsKey('US Tertiary Market Data')) {
                            Id prodId = productNameToIdWithCurrency.containsKey('US Tertiary Market Data|'+ acc.CurrencyIsoCode) ? productNameToIdWithCurrency.get('US Tertiary Market Data|'+ acc.CurrencyIsoCode) : productNameToId.get('US Tertiary Market Data');
                            Account_Product_Line__c newProductLine = new Account_Product_Line__c();
                            newProductLine.Product__c = prodId;
                            newProductLine.Account__c = sod.Account_Id__c;
                            newLineItems.add(newProductLine);
                        }

                }
                System.debug('newLineItems-?' + newLineItems.size());

                if (!newLineItems.isEmpty()) {
                    insert newLineItems;
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
        attachment.setFileName('SF-1848_BatchResults.csv');
        attachment.setBody(Blob.valueOf(csv));
        attachment.setContentType('text/csv');

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'mgupta@greenstreet.com'}); // TODO: Set to actual recipient
        mail.setSubject('SF-1848 : Batch Account Line Items Results');
        mail.setPlainTextBody('Please find attached the batch results.');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachment});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
}