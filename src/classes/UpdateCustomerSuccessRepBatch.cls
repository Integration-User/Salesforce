global class UpdateCustomerSuccessRepBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    private List<Account> updatedAccounts = new List<Account>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, AccountId, UserId, User.name, TeamMemberRole, Account.Customer_Success_Rep_ID__c, Account.Customer_Success_Rep__c
            FROM AccountTeamMember 
            WHERE CreatedDate = TODAY
            AND TeamMemberRole = 'Customer Success'
        ]);
    }

    global void execute(Database.BatchableContext bc, List<AccountTeamMember> scope) {
        List<Account> accountsToUpdate = new List<Account>();
        for (AccountTeamMember atm : scope) {
            if (atm != null && atm.Account.Customer_Success_Rep_ID__c != atm.UserId) {
                Account acc = new Account(Id = atm.AccountId);
                acc.Customer_Success_Rep_ID__c = atm.UserId;
                acc.Customer_Success_Rep__c = atm.User.name;
                accountsToUpdate.add(acc);
            }
        }

        if (!accountsToUpdate.isEmpty()) {
            Plative_AccountTriggerHandler.isAccountTriggerSkip = true;
            update accountsToUpdate;
            updatedAccounts.addAll(accountsToUpdate);
        }
    }

    global void finish(Database.BatchableContext bc) {
        if (!updatedAccounts.isEmpty()) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{'mgupta@greenstreet.com'}); // Replace with actual recipient email
            email.setSubject('Updated Accounts - Customer Success Rep Assignment');
            String body = 'The following accounts have been updated with new Customer Success Rep IDs:\n\n';
            for (Account acc : updatedAccounts) {
                body += 'Account ID: ' + acc.Id + ', New Customer Success Rep ID: ' + acc.Customer_Success_Rep__c + '\n';
            }
            email.setPlainTextBody(body);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
        }
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new UpdateCustomerSuccessRepBatch(), 10);
    }
}