Public class Batch_UpdateBillingContactCategory implements Database.Batchable<sObject> {

    Public Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        String query = 'Select id from Account';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, list<Account> accountList){
        
        Set<ID> accountSet = new Set<ID>();
        Map<Id,List<Contact>> mapAccountContacts = new Map<Id,List<Contact>>();
        Map<Id,List<OpportunityContactRole>> mapContactRoles = new Map<Id,List<OpportunityContactRole>>();
        
        Map<Id,Opportunity> mapOpportunities = new Map<Id,Opportunity>([Select id,AccountId from Opportunity where ((NOT Stagename like '%Closed%') AND Stagename != 'Consolidated' AND Accountid in: accountList)]);
        for(Opportunity oppo : mapOpportunities.values()){
            accountSet.add(oppo.AccountId);
        }
        
        Map<Id,List<OpportunityLineItem>> mapOppoLineItems = new Map<Id,List<OpportunityLineItem>>();
        List<OpportunityLineItem> listOppoLine = [Select id,opportunityid,Product2Id,product2.Billing_Contact_Category__c 
                                                    from OpportunityLineItem where Opportunityid in: mapOpportunities.keyset()];
                                                    
        for(OpportunityLineItem line : listOppoLine){
            if(!mapOppoLineItems.containskey(line.opportunityid))
                mapOppoLineItems.put(line.OpportunityId,new List<OpportunityLineItem>());
            mapOppoLineItems.get(line.OpportunityId).add(line);
        }
        
        for(OpportunityContactRole role : [Select ContactId, OpportunityId,Hidden_Billing_Contact_Category_Txt__c 
                                            from OpportunityContactRole where OpportunityId in: mapOpportunities.keyset()]){
            if(!mapContactRoles.containskey(role.OpportunityId))
                mapContactRoles.put(role.OpportunityId, new List<OpportunityContactRole>());
            mapContactRoles.get(role.OpportunityId).add(role);
        }
        
        List<Contact> listContact = [Select id,AccountId,Billing_Contact_Multi__c from Contact where AccountId in: accountSet and Billing_Contact__c = true];
        
        /*for(Contact con : listContact){
            if(!mapAccountContacts.containskey(con.AccountId))
                mapAccountContacts.put(con.AccountId, new List<Contact>());
            mapAccountContacts.get(con.AccountId).add(con);
        }*/
        
        for(Opportunity oppo : mapOpportunities.values()){
        
            String categories='';
            Integer count=0;
            if(mapOppoLineItems.containskey(oppo.Id)){
                for(OpportunityLineItem line : mapOppoLineItems.get(oppo.Id)){
                    if(!categories.contains(line.product2.Billing_Contact_Category__c)){
                        if(count <> 0)
                            categories += ';';
                        categories += line.product2.Billing_Contact_Category__c;
                        count++;
                    }
                }
            }
            /*system.debug('***mapAccountContacts : '+mapAccountContacts);
            if(mapAccountContacts.containskey(oppo.AccountID)){
                for(Contact con : mapAccountContacts.get(oppo.AccountID)){
                    con.Billing_Contact_Multi__c = categories;
                }
            }*/
            if(mapContactRoles.containskey(oppo.id)){
                for(OpportunityContactRole role : mapContactRoles.get(oppo.id)){
                    role.Hidden_Billing_Contact_Category_Txt__c = categories;
                }
            }
        }
        
        /*List<Contact> listcontacts = new List<Contact>();
        for(Id accid : mapAccountContacts.keyset()){
             if(mapAccountContacts.get(accid) != null)
                  listcontacts.addall(mapAccountContacts.get(accid));
        }
        update listcontacts;*/
        
        List<OpportunityContactRole> listContactRoles =  new List<OpportunityContactRole>();
        for(Id accid : mapContactRoles.keyset()){
                 if(mapAccountContacts.get(accid) != null)
                listContactRoles.addall(mapContactRoles.get(accid));
        }
        update listContactRoles;
     }
     
     public void finish(Database.BatchableContext BC){
     
     }
}