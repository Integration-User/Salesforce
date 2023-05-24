Public class Batch_UpdateContactCategory implements Database.Batchable<sObject> {
        
    Public Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        String query = 'Select id from Account';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, list<Account> listAccounts){
        Map<Id,Set<String>> mapAccountCategory = new Map<Id,Set<String>>();
        List<OpportunityLineItem> listOppoLine = [Select Opportunityid, Opportunity.Accountid,Product2.Billing_Contact_Category__c 
                            from OpportunityLineItem where Opportunity.stagename like '%Closed%' and Opportunity.Accountid in: listAccounts];
                            
        for(OpportunityLineItem line : listOppoLine){
            if(Product2.Billing_Contact_Category__c != null){
                         if(!mapAccountCategory.containskey(line.Opportunity.Accountid))
                                mapAccountCategory.put(line.Opportunity.Accountid,new Set<String>());
                mapAccountCategory.get(line.Opportunity.Accountid).add(line.Product2.Billing_Contact_Category__c); 
            }
        }
        List<Contact> listContacts = [Select id,Billing_Contact_Multi__c,Accountid from Contact where AccountId in: mapAccountCategory.keyset() and Billing_Contact__c = true and Billing_Contact_Multi__C = null];
        for(Contact con : listContacts){
            String collegeString = '';
            for(String s:mapAccountCategory.get(con.Accountid)) {
                   collegeString += (collegeString==''?'':';')+s;
            }
            con.Billing_Contact_Multi__c = collegeString;
        }
        system.debug('listContacts'+listContacts);
        update listContacts;        
        
     }
     
     public void finish(Database.BatchableContext BC){
     }   
 }