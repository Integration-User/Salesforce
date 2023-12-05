public class UpdateProductsOnOpportunityBatch implements Database.Batchable<Opportunity>, Database.Stateful{
    public String generatedCSVFile ='Id, Name, Old products__c, New products__c, Old Product Type, New Product Type\n';
    public Iterable<Opportunity> start(Database.BatchableContext BC) {
        Set<Opportunity> diffOpp = new Set<Opportunity>(); 
        for (Opportunity opp : [SELECT id, name, products__c, Product_Types__c, (SELECT product2.Name FROM OpportunityLineItems WHERE Lost_Product__c = false) 
                                FROM Opportunity Where RecordType.DeveloperName IN ('Existing_Business', 'Renewal_Closed', 'Sales_Opportunity', 'Sales_Opportunity_Closed')]) {
            /*List<String> oppProducts = new List<String>();
            if (String.isNotBlank(opp.products__c)) {
                oppProducts = opp.products__c.split(';');
            }
            List<OpportunityLineItem> oliList = opp.OpportunityLineItems;
            for (OpportunityLineItem oli : oliList) {
                if (!oppProducts.contains(oli.product2.Name) || oppProducts.size() != oliList.size()) {
                    diffOpp.add(opp);
                }
            }*/
            List<OpportunityLineItem> oliList = opp.OpportunityLineItems;
            if(!oliList.isEmpty() && oliList.size() > 0) diffOpp.add(opp);
        }
        System.debug('diffOpp-->'+diffOpp.size());
        return new list<Opportunity>(diffOpp);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> oppList) {
        List<Opportunity> updatedOppList = new List<Opportunity>();
        for (Opportunity opp : oppList) {
            String proName = opp.Products__C;
            String productNames = '';
            string oldProductTypes = opp.Product_Types__c;
            for (OpportunityLineItem oli : opp.OpportunityLineItems) {
                if (String.isEmpty(productNames)) {
                    productNames = oli.product2.Name;
                } else if (!productNames.contains(oli.product2.Name)) {
                    productNames += ';' + oli.product2.Name;
                }
            }
            List<String> CategoryName = Plative_SFToNSSyncUtility.getProductCategoryNameForOpp(New List<String>{productNames});
            if (CategoryName!= null && !CategoryName.isEmpty() && CategoryName.size() > 0) opp.Product_Types__c = CategoryName[0];
            String[] oldproductName = String.isNotBlank(proName) ? proName.split(';') : new List<String>(); oldproductName.sort();
            String[] newproductName = productNames.split(';');newproductName.sort();
            proName = string.join(oldproductName, ';');
            productNames = string.join(newproductName, ';');
            if (proName != productNames || oldProductTypes != opp.Product_Types__c) {
                opp.Products__c = productNames;
                updatedOppList.add(opp);
                String fileRow = opp.Id + ',' + opp.Name.replaceAll(',', ';')+ ',' +proName+ ',' + productNames+ ',' +oldProductTypes+ ',' + opp.Product_Types__c;
                generatedCSVFile +=  fileRow + '\n';
            }
            
        }
        boolean isUpdate = System_Configuration__mdt.getInstance('UpdateProductsOnOpportunityBatch').IsEnabled__c;
        system.debug('updatedOppList.isEmpty()->'+updatedOppList.isEmpty());
        system.debug('isUpdate->'+ isUpdate);
        if(!updatedOppList.isEmpty() && isUpdate) update updatedOppList;
    }
    
    
    public void finish(Database.BatchableContext BC) {
        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        Blob csvBlob = blob.valueOf(generatedCSVFile);
        String csvName = 'OpportunityProductTypeMismatchData.csv';
        csvAttachment.setFileName(csvName);
        csvAttachment.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'mgupta@greenstreet.com', 'ksantos@greenstreet.com'};
        email.setSubject('Opportunity Product AND Type Mismatch Data CSV Full');
        email.setToAddresses(toAddresses);
        email.setPlainTextBody('Opportunity Product And Type Mismatch Data CSV');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }
}
