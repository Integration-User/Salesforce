public class UpdateContactProductsBatchForAccount implements Database.Batchable<sObject>, Database.Stateful {
    private Set<Id> accountIds;
    private List<String> errors = new List<String>();

    public UpdateContactProductsBatchForAccount(Set<Id> accountIds) {
        this.accountIds = accountIds;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Current_Products__c, Account.Current_Products__c FROM Contact WHERE AccountId IN :accountIds AND Contact_Status__c = 'Active']);
    }

    public void execute(Database.BatchableContext bc, List<Contact> contacts) {
        for (Contact c : contacts) {
            c.Current_Products__c = c.Account.Current_Products__c;
        }
        Plative_ContactTriggerHandler.isContactTriggerSkip = true;
        List<Database.SaveResult> results = Database.update(contacts, false);
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                String errorMsg = 'Contact ID: ' + contacts[i].Id + ' - ';
                for (Database.Error err : results[i].getErrors()) {
                    errorMsg += err.getMessage() + '; ';
                }
                errors.add(errorMsg);
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        if (!errors.isEmpty() || Test.isrunningtest()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{'mgupta@greenstreet.com'});
            mail.setSubject('Batch Update Errors');
            mail.setPlainTextBody('The following errors occurred during contact update:\n' + String.join(errors, '\n'));
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }
    }
}
