public class UpdateAccountOwner implements Database.Batchable<sObject>, Database.Stateful {
    public List <Account> failureAccount = new List<Account>();
    public List <Account> accounts = new List<Account>();
    public Id toOwnerId ;
    public Id fromOwnerId;
    public UpdateAccountOwner(List<Account> accounts, Id newOwnerid, Id oldOwnerid){
        this.accounts = accounts;
        this.toOwnerId = newOwnerid;
        this.fromOwnerId = oldOwnerid;
    }
    public Iterable<Account> start(Database.BatchableContext context) {
        return this.accounts;
    }
    public void execute(Database.BatchableContext context, List<Account> scope) {
        try {
            Plative_AccountTriggerHandler.isAccountTriggerSkip = true;
            update scope;
            Set<Id> accountIds = new Set<Id>();
            for (Account acc : scope) {
                accountIds.add(acc.Id);
            }
            updateRelatedRecords(accountIds, fromOwnerId, toOwnerId);        
        } catch(Exception e) {
            failureAccount.addAll(scope);
        }
        
    }
    public void finish(Database.BatchableContext context) {
        if(!failureAccount.isEmpty() || Test.isRunningTest()) {
            String generatedCSVFile ='Id,Name,From Owner,To Owner\n';
            for(Account acc : failureAccount) {
                String fileRow = acc.Id + ',' + acc.Name+ ',' +fromOwnerId+ ',' +toOwnerId;
                generatedCSVFile +=  fileRow + '\n';
            }
            Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
            Blob csvBlob = blob.valueOf(generatedCSVFile);
            String csvName = 'AccountOwnerUpdatedFailed.CSV';
            csvAttachment.setFileName(csvName);
            csvAttachment.setBody(csvBlob);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'mgupta@greenstreet.com'/*, 'jecusi@greenstreet.com', 'mbonyab@greenstreet.com'*/};
                String subject = 'AM CS Account Transfer: Account Owner Update Is Failed';
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            email.setPlainTextBody('Hi, AM CS Account Transfer is failed for attached records.');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        }
        
    }
    public static void updateRelatedRecords(Set<Id> accountIds, Id fromOwnerId, id toOwnerId) {
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
        // Query related Contacts
        for (Contact con : [SELECT Id, AccountId, OwnerId FROM Contact WHERE AccountId IN :accountIds AND ownerId = :fromOwnerId]) {
            con.OwnerId = toOwnerId;
            contactsToUpdate.add(con);
        }
        
        // Query related Opportunities
        for (Opportunity opp : [SELECT Id, AccountId, OwnerId FROM Opportunity WHERE AccountId IN :accountIds AND isClosed = false AND ownerId = :fromOwnerId]) {
            opp.OwnerId = toOwnerId;
            oppsToUpdate.add(opp);
        }
        // Fetch the default account team members for the new owner
        List<UserAccountTeamMember > defaultTeamMembers = [SELECT UserId, TeamMemberRole FROM UserAccountTeamMember WHERE OwnerId = :toOwnerId];
        
        // Create AccountTeamMember records
        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();
        for (UserAccountTeamMember  defaultMember : defaultTeamMembers) {
            for (Id accId : accountIds) {
                AccountTeamMember teamMember = new AccountTeamMember();
                teamMember.AccountId = accId;
                teamMember.UserId = defaultMember.UserId;
                teamMember.TeamMemberRole = defaultMember.TeamMemberRole;
                accountTeamMembers.add(teamMember);
            }
        }
        
        // Insert AccountTeamMember records
        if (!accountTeamMembers.isEmpty()) {
            insert accountTeamMembers;
        }
        
        // Update Contacts and Opportunities
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }
    @InvocableMethod(label='Update Account Owner' description='Consolidated Account records')
    public static List<ConsolidatedAccResult> updateAccountOwnerInBulk(List<ConsolidatedAccInfo> consolidatedAcc) {
        System.debug('consolidatedAcc->'+consolidatedAcc);
        ConsolidatedAccResult AccResult = new ConsolidatedAccResult();
        try {
            // Same opportunity
            if (consolidatedAcc[0].fromOwnerId == consolidatedAcc[0].ToOwnerId) {
                AccResult.result = 'Error: The selected owner should not same. You must choose a different.';
                AccResult.isError = 'true';
            }
            if(consolidatedAcc[0].fromOwnerId != consolidatedAcc[0].ToOwnerId) {
                List<Account> updatedAccList = new List<Account>();
                for(Account acc : [Select Id, Name from Account where OwnerId = :consolidatedAcc[0].fromOwnerId]) {
                    acc.ownerid = consolidatedAcc[0].toOwnerId;
                    updatedAccList.add(acc);
                }
                if(!updatedAccList.isEmpty()) {
                    Database.executeBatch(new UpdateAccountOwner(updatedAccList, consolidatedAcc[0].toOwnerId, consolidatedAcc[0].fromOwnerId), 1);
                }
                AccResult.result = 'AM CS Account Transferred Successfully. Please validate your transferred records after a few minutes.';
                
            }
        } catch(Exception e) {
            AccResult.result = e.getMessage();
            AccResult.isError = 'true';
        }
        
        List<ConsolidatedAccResult> resultList = new List<ConsolidatedAccResult>{AccResult};
            return resultList;
    }
    
    public class ConsolidatedAccInfo {
        @InvocableVariable
        public Id fromOwnerId;
        
        @InvocableVariable
        public Id toOwnerId;
    }
    public class ConsolidatedAccResult{
        @InvocableVariable
        public String result;
        @InvocableVariable
        public String isError;
    }
    
}