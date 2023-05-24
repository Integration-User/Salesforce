/**
* Company     : Plative
* Description :  Helper class for Plative_AccountEmailDistributionTrigger
* History     : 
* [25.May.2020] Kunal - Code Creation 
*/
public class Plative_AccountEmailDistributionHelper {
    
    //This method inserts contact email distributions for account
    public static void insertContactEmailDistribution(List<Account_Email_Distribution__c> triggerNew){
        
        //AccountId Set from the inserted Email Distribution
        Set<Id> accountIdSet = new Set<Id>();
        for(Account_Email_Distribution__c emailDistribution: triggerNew){
            accountIdSet.add(emailDistribution.Account__c);
        }
        
        //Get active related contacts from the AccountId Set along with the email distributions
        List<Contact> contactList = [Select Id,AccountId,(Select Id,Email_Distribution__c,Opt_Out__c from Contact_Email_Distributions__r)
                                     from Contact where AccountId IN :accountIdSet];
        
        //Map of AccountId Vs Contact List
        Map<Id,List<Contact>> accountIdVsContactListMap = new Map<Id,List<Contact>>();
        //Map of ContactId Vs Email Distributions
        Map<Id,Set<String>> contactIdVsEmailDistributionMap = new Map<Id,Set<String>>();
        Map<String,Contact_Email_Distribution__c> EmailDistributionVsRecords = new Map<String,Contact_Email_Distribution__c>();
        
        for(Contact cont: contactList){
            //Map of AccountId Vs Contact List
            if(!accountIdVsContactListMap.containsKey(cont.AccountId)){
                accountIdVsContactListMap.put(cont.AccountId, new List<Contact>());
            }            
            accountIdVsContactListMap.get(cont.AccountId).add(cont);            
            
            for(Contact_Email_Distribution__c contEmailDist: cont.Contact_Email_Distributions__r){
                //Map of ContactId Vs Email Distributions
                if(!contactIdVsEmailDistributionMap.containsKey(cont.Id)){
                    contactIdVsEmailDistributionMap.put(cont.Id,new Set<String>());
                }
                contactIdVsEmailDistributionMap.get(cont.Id).add(contEmailDist.Email_Distribution__c);
                EmailDistributionVsRecords.put(contEmailDist.Email_Distribution__c, contEmailDist);
            }
        }
        
        List<Contact_Email_Distribution__c> contactEmailDistributionInsertList = new List<Contact_Email_Distribution__c>();
        //Iterate over inserted account email distributions
        for(Account_Email_Distribution__c emailDistribution: triggerNew){
            //Check if the account has any active contacts associated with it
            if(accountIdVsContactListMap.containsKey(emailDistribution.Account__c)){
                //Iterate over the active contacts
                for(Contact cont: accountIdVsContactListMap.get(emailDistribution.Account__c)){
                    //Check if Email Distribution is already added for that Contact. If not, then insert
                    if(!contactIdVsEmailDistributionMap.containsKey(cont.Id) || (contactIdVsEmailDistributionMap.containsKey(cont.Id) && !contactIdVsEmailDistributionMap.get(cont.Id).contains(emailDistribution.Email_Distribution__c))){
                        Contact_Email_Distribution__c contactEmailDistribution = new Contact_Email_Distribution__c();
                        contactEmailDistribution.Account__c = emailDistribution.Account__c;
                        contactEmailDistribution.Contact__c = cont.Id;
                        contactEmailDistribution.Email_Distribution__c = emailDistribution.Email_Distribution__c;
                        contactEmailDistributionInsertList.add(contactEmailDistribution);
                    }
                    if (contactIdVsEmailDistributionMap.containsKey(cont.Id) && contactIdVsEmailDistributionMap.get(cont.Id).contains(emailDistribution.Email_Distribution__c)) {
                        Contact_Email_Distribution__c contactEmailDist = EmailDistributionVsRecords.get(emailDistribution.Email_Distribution__c); 
                        if(contactEmailDist.Opt_Out__c) {
                            contactEmailDist.Opt_Out__c = false;
                            contactEmailDistributionInsertList.add(contactEmailDist);
                        }
                        system.debug('contactEmailDist-->'+contactEmailDist);
                    }
                }
            }
        }
        
        //insert contact email distributions
        upsert contactEmailDistributionInsertList;        
    }
    
    
    //This method removes email distributions from Contact if removed from account
    public static void removeContactEmailDistribution(List<Account_Email_Distribution__c> triggerOld){
        
        //Map of AccountId Vs Set of Email Distributions
        Map<Id,Set<String>> accountIdVsEmailDistributionSetMap = new Map<Id,Set<String>>();
        Set<String> emailDistributionSet = new Set<String>();
        
        //Iterate over deleted email distributions from account
        for(Account_Email_Distribution__c accntEmailDistribution: triggerOld){
            emailDistributionSet.add(accntEmailDistribution.Email_Distribution__c);
            if(!accountIdVsEmailDistributionSetMap.containsKey(accntEmailDistribution.Account__c)){
                accountIdVsEmailDistributionSetMap.put(accntEmailDistribution.Account__c, new Set<String>());
            }
            accountIdVsEmailDistributionSetMap.get(accntEmailDistribution.Account__c).add(accntEmailDistribution.Email_Distribution__c);
        }        
        
        //Fetch Contact Email Distributions
        List<Contact_Email_Distribution__c> contactEmailDistributionList = [Select Id,Account__c,Contact__c,Email_Distribution__c from Contact_Email_Distribution__c where
                                                                            Account__c IN :accountIdVsEmailDistributionSetMap.keySet() AND
                                                                            Email_Distribution__c IN :emailDistributionSet];
        
        List<Contact_Email_Distribution__c> deleteList = new List<Contact_Email_Distribution__c>();
        for(Contact_Email_Distribution__c contactEmailDistribution: contactEmailDistributionList){
            if(accountIdVsEmailDistributionSetMap.containsKey(contactEmailDistribution.Account__c) && accountIdVsEmailDistributionSetMap.get(contactEmailDistribution.Account__c).contains(contactEmailDistribution.Email_Distribution__c)){
                deleteList.add(contactEmailDistribution);
            }
        }
        
        delete deleteList;      
        
    }
    
}