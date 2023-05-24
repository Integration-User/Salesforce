public class UpdateProductsOnOpportunityBatch implements Database.Batchable<Opportunity>, Database.Stateful{
    public String generatedCSVFile ='Id, Name, old products__c, new products__c, old Type, new Type\n';
    public Iterable<Opportunity> start(Database.BatchableContext BC) {
        Set<Opportunity> diffOpp = new Set<Opportunity>(); 
        for (Opportunity opp : [SELECT id, name, products__c, (SELECT product2.Name FROM OpportunityLineItems) FROM Opportunity]) {
            List<String> oppProducts = new List<String>();
            if (String.isNotBlank(opp.products__c)) {
                oppProducts = opp.products__c.split(';');
            }
            List<OpportunityLineItem> oliList = opp.OpportunityLineItems;
            for (OpportunityLineItem oli : oliList) {
                if (!oppProducts.contains(oli.product2.Name) || oppProducts.size() != oliList.size()) {
                    diffOpp.add(opp);
                }
            }
        }
        System.debug('diffOpp-->'+diffOpp.size());
        return new list<Opportunity>(diffOpp);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> oppList) {
        List<Opportunity> updatedOppList = new List<Opportunity>();
        for (Opportunity opp : oppList) {
            String proName = opp.Products__C;
            String productNames = '';
            for (OpportunityLineItem oli : opp.OpportunityLineItems) {
                if (String.isEmpty(productNames)) {
                    productNames = oli.product2.Name;
                } else if (!productNames.contains(oli.product2.Name)) {
                    productNames += ';' + oli.product2.Name;
                }
            }
            if (proName != productNames) {
                opp.Products__C = productNames;
                updatedOppList.add(opp);
                String fileRow = opp.Id + ',' + opp.Name.replaceAll(',', ';')+ ',' +proName+ ',' + productNames;
                generatedCSVFile +=  fileRow + '\n';
            }
            
        }
        //if(!updatedOppList.isEmpty()) update updatedOppList;
    }
    
    
    public void finish(Database.BatchableContext BC) {
        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        Blob csvBlob = blob.valueOf(generatedCSVFile);
        String csvName = 'OpportunityProductMismatchData-GSFull.csv';
        csvAttachment.setFileName(csvName);
        csvAttachment.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'mgupta@greenstreet.com', 'ksantos@greenstreet.com'};
        email.setSubject('Opportunity Product Mismatch Data CSV GS Full');
        email.setToAddresses(toAddresses);
        email.setPlainTextBody('Opportunity Product Mismatch Data CSV GSFull');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }
}