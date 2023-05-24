public class UpdateAccountProductCategoryBatch implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        Set<Id> setContactIds = new Set<Id>();
        List<Account> listAccounts = [SELECT id, Current_Products__c,Products_Include__c,
                                      (Select id,Current_Products__c, Products_Include__c FROM Contacts) 
                                      FROM Account where Is_Contact_Update__c = true];
        for(Account acc : listAccounts){
            for(Contact con : acc.Contacts){
                if((acc.Current_Products__c != con.Current_Products__c) || (acc.Products_Include__c != con.Products_Include__c) )
                    setContactIds.add(con.id);
            }
        }
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
        }
        database.update(listContacts, false);
    }

    
    public void finish(Database.BatchableContext BC) {
    }
}