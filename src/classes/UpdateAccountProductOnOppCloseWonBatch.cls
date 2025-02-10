// SF-1389 : Current Products adjustment(IJ, React, RAP)
// IF an opportunity is marked closed won or lost, check on the products that are won or lost, and either add new products onto the Current products field on the associated account(if product was won), or remove the products from Current Products field if product was lost
public class UpdateAccountProductOnOppCloseWonBatch implements Database.Batchable<sObject>, Database.Stateful {
    List<String> productList = new List<String>{'IJGlobal: Data Delivery + News + IJ Investor', 'IJGlobal: IJ Investor', 
        										'IJGlobal: IJ Investor - Trial', 'IJGlobal: News', 'IJGlobal: News - Trial', 
        										'IJGlobal: News + IJ Investor', 'IJGlobal: News + IJ Investor - Trial', 'IJGlobal: One-Time',
        										'Green Street News: Canada', 'Green Street News: Europe', 'UK Retail Analytics Pro'};
    List<Id> oppIds = new List<Id>();
    public UpdateAccountProductOnOppCloseWonBatch(List<Id> oppIds){
        this.oppIds = oppIds;
        System_Configuration__mdt productLists = [Select Id, List_Of_Value__c FROM System_Configuration__mdt where DeveloperName = 'Update_Account_On_Oppty_Closed_Products' LIMIT 1];
        this.productList = productLists.List_Of_Value__c.split(';');
    }
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, AccountId, account.Current_Products__c, (Select id, Product2.name from OpportunityLineItems) from Opportunity where StageName in (\'Closed Lost\', \'Closed Won\') AND Id = :oppIds';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext context, List<Opportunity> scope) {
        Map<Id, Account> accountUpdates = new Map<Id, Account>();
        for (Opportunity opp : scope) {
            for (OpportunityLineItem oli : opp.OpportunityLineItems) {
                if(productList.contains(oli.Product2.name) && accountUpdates.containskey(opp.AccountId)) {
                    Account acc = accountUpdates.get(opp.AccountId);
                    if(!acc.Current_Products__c.contains(oli.Product2.name)) acc.Current_Products__c = acc.Current_Products__c + ';' + oli.Product2.name;
                	accountUpdates.put(opp.AccountId, acc);
                } else if(productList.contains(oli.Product2.name) && !accountUpdates.containskey(opp.AccountId)) {
                    if(opp.account.Current_Products__c != null && !opp.account.Current_Products__c.contains(oli.Product2.name)) {
                        Account acc = new Account(id = opp.AccountId, Current_Products__c = opp.account.Current_Products__c + ';' + oli.Product2.name);
                        accountUpdates.put(opp.AccountId, acc);
                    } else {
                         Account acc = new Account(id = opp.AccountId, Current_Products__c = oli.Product2.name);
                        accountUpdates.put(opp.AccountId, acc);
                    }   
                }
            }
        }
        System.debug('accountUpdates-->' + accountUpdates);
        if(!accountUpdates.isEmpty()) update accountUpdates.values();
    }
    public void finish(Database.BatchableContext context) {
    }
}