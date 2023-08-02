trigger ContactEmailDistributionTrigger on Contact_Email_Distribution__c (before insert, before update) {
    for(Contact_Email_Distribution__c conEmailDistribution : Trigger.New) {
        conEmailDistribution.Name = conEmailDistribution.Email_Distribution__c;
    }
}