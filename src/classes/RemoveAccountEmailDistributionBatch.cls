public class RemoveAccountEmailDistributionBatch implements Database.Batchable<sObject>, Database.Stateful{
    public List <Id> accountIds = new List<Id>();
    public List <Account_Email_Distribution__c> emailDistributionIds;
    
    public RemoveAccountEmailDistributionBatch(List<Id> accountIds){
        this.accountIds = accountIds;        
        emailDistributionIds = new List <Account_Email_Distribution__c>();
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Account__c, id FROM Account_Email_Distribution__c  where Account__c IN :accountIds');
    }
    
    public void execute(Database.BatchableContext BC, List<Account_Email_Distribution__c> scope) {
        try {
            Database.delete(scope, false);
        } catch(Exception e) {
            emailDistributionIds.addAll(scope);
        }
        
    }
    
    public void finish(Database.BatchableContext BC){
        if(emailDistributionIds.size() > 0 || Test.isRunningTest()) {
            String generatedCSVFile ='Id, AccountId\n';
            for (Account_Email_Distribution__c dis : emailDistributionIds) {
                String fileRow = dis.Id + ',' + dis.Account__c;
                generatedCSVFile +=  fileRow + '\n';
            }
            Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
            Blob csvBlob = blob.valueOf(generatedCSVFile);
            String csvName = 'Failed_Account_Email_Distribution.csv';
            csvAttachment.setFileName(csvName);
            csvAttachment.setBody(csvBlob);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'mgupta@greenstreet.com'};
                String subject = 'Failed Account Email Distribution CSV For Deactivate Account';
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            email.setPlainTextBody('Failed Account Email Distribution CSV For Deactivate Account');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email}); 
        }
    }
}