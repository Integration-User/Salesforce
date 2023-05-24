public class UpdateContactOwnerWithAccountOwner implements Database.Batchable<Contact>, Database.Stateful, Schedulable {
    public Iterable<Contact> start(Database.BatchableContext BC){
        String query = 'SELECT Id, OwnerId, Account.OwnerId, Account.Name FROM Contact WHERE Contact_Status__c = \'Active\' AND Contact_Account_Owners_Match__c= false AND (NOT Account.Name LIKE \'%Green Street%\') AND (NOT owner.userRole.Name LIKE \'%Advisory%\')';
        List<Contact> conList = new List<Contact>();
        Database.QueryLocator q = Database.getQueryLocator(query);
        system.debug(query);
        Database.QueryLocatorIterator it =  q.iterator();
        while (it.hasNext()) {
            Contact con = (Contact)it.next();
            if (con.OwnerId != con.Account.OwnerId) {
                con.OwnerId = con.Account.OwnerId;
                conList.add(con); 
            }
            System.debug(conList);
        }
        return conList;
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scopeList){
        if(!scopeList.isEmpty()) {
            Database.update(scopeList, false);
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
    public void execute(SchedulableContext sc) {
		Database.executeBatch(new UpdateContactOwnerWithAccountOwner(), 100);
    }
}