/**
* Company     : Plative
* Description :  Controller class for Plative_EmailDistributionOptOutLtng aura component
* History     : 
* [26.May.2020] Kunal - Code Creation 
*/
public class Plative_EmailDistributionGenCtrl {
    
    @AuraEnabled
    public static List<Email_Distribution__c> getEmailDistributions(){
        List<Email_Distribution__c> emailDistributionList = [Select Id,Name from Email_Distribution__c];
        return emailDistributionList;
    }
    
    
    @AuraEnabled
    public static List<Contact_Email_Distribution__c> getRelatedContacts(String selectedEmailDistribution){
        system.debug('selectedEmailDistribution: ' + selectedEmailDistribution);
        List<Contact_Email_Distribution__c> contactEmailDistributions = [Select Id,Contact__r.Email,Contact__r.GSA_ID__c,Contact__r.Account.GSA_ID__c from Contact_Email_Distribution__c
                                                                         where Email_Distribution__c = :selectedEmailDistribution AND 
                                                                         Contact__r.Email != null AND
                                                                        Opt_Out__c = false AND Contact__r.Contact_Status__c = 'Active'];
        return contactEmailDistributions;
    }
        

}