public class Batch_UpdateContactCurrentProduct implements Database.Batchable<sObject>, Database.Stateful, Schedulable{
    
    public Set<Id> setContactIds = new Set<Id>();
    Map<Id,Account> mapAccounts = new Map<Id,Account>();
    
    
    public void execute(SchedulableContext sc)
    {
        Database.executeBatch(new Batch_UpdateContactCurrentProduct(),200); 
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        List<Account> listAccounts = [SELECT id, Current_Products__c,
                            (Select id,Current_Products__c FROM Contacts) 
                            FROM Account where Is_Contact_Update__c = true];
        for(Account acc : listAccounts){
            for(Contact con : acc.Contacts){
                System.debug('Current_Products__c->'+acc.Current_Products__c);
                System.debug('con Current_Products__c->'+con.Current_Products__c);
                if(acc.Current_Products__c != con.Current_Products__c)
                    setContactIds.add(con.id);
            }
        }
        System.debug('setContactIds->'+setContactIds);
        String query = 'Select id,Current_Products__c,Account.Current_Products__c,AccountId,Account.Products_Include__c from Contact where id in: setContactIds';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> listContacts) {
        for(Contact con: listContacts){
            if(con.Current_Products__c != con.Account.Current_Products__c){
                con.Current_Products__c = con.Account.Current_Products__c;
            }
            /*SF-281 - Products Included field update*/
            con.Products_Include__c = null;
            if (String.isNotBlank(con.Current_Products__c)) {
                List<String> CategoryName = Plative_SFToNSSyncUtility.getProductCategoryName(New List<String>{con.Current_Products__c});
                if (CategoryName!= null && !CategoryName.isEmpty() && CategoryName.size() > 0) con.Products_Include__c = CategoryName[0];
            }
            // End SF-281

            if(!mapAccounts.containskey(con.AccountId))
                mapAccounts.put(con.AccountId,new Account(id=con.AccountId,Is_Contact_Update__c = false, Products_Include__c = con.Products_Include__c));
        }
        database.update(listContacts, false);
    }
    
    public void finish(Database.BatchableContext BC) {
        if(mapAccounts != null && mapAccounts.values().size() > 0)
            update mapAccounts.values();
    }
}