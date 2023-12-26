public class Plative_AccountProductLineTriggerHelper {
    
    
    //Add Email Distributions
    public static Boolean addEmailDistributions(List<Account_Product_Line__c> triggerNew){
        
        try{
            Set<Id> accountIdSet = new Set<Id>();
            //Check if Products Line Inserted are associated with News Product Lines that need to be auto-inserted
            //as email distributions
            Map<Id,Product2> newsProductMap = new Map<Id,Product2>([Select Id,Name from Product2 where News_Product_Line__c = true]);
            for(Account_Product_Line__c productLine: triggerNew){
                if(productLine.Product__c != null && newsProductMap.containsKey(productLine.Product__c)){
                    accountIdSet.add(productLine.Account__c);
                }
            }
            
            //If no accounts to process return false;
            if(accountIdSet.isEmpty()){
                return false;
            }
            
            //Using News Product Lines Names(Subscription) get Email Distributions
            Set<String> productNameSet = new Set<String>();
            for(Product2 product: newsProductMap.values()){
                productNameSet.add(product.Name);
            }
            
            //One Subscription could be associated with more than one email distribution
            Map<String,Set<String>> subscriptionVsEmailDistributions = new Map<String,Set<String>>();
            List<Email_Distribution__c> emailDistributions = [Select Id,Name,Subscription__c from Email_Distribution__c 
                                                              where Subscription__c IN :productNameSet];
            //If no email distributions found then return false
            if(emailDistributions.isEmpty()){
                return false;
            }
            
            //Map Subscription & Email Distributions
            for(Email_Distribution__c emailDistribution: emailDistributions){
                if(!subscriptionVsEmailDistributions.containsKey(emailDistribution.Subscription__c)){
                    subscriptionVsEmailDistributions.put(emailDistribution.Subscription__c, new Set<String>());
                }
                subscriptionVsEmailDistributions.get(emailDistribution.Subscription__c).add(emailDistribution.Name);
            }
            
            //Get existing email distributions associated to the Account
            Map<Id,Set<String>> accountIdVsEmailDistributions = new Map<Id,Set<String>>();
            List<Account_Email_Distribution__c> accountEmailDistributions = [Select Id,Account__c,Email_Distribution__c 
                                                                             from Account_Email_Distribution__c
                                                                             where Account__c IN :accountIdSet];
            //Map Account & its Email Distributions
            for(Account_Email_Distribution__c emailDistribution: accountEmailDistributions){
                if(!accountIdVsEmailDistributions.containsKey(emailDistribution.Account__c)){
                    accountIdVsEmailDistributions.put(emailDistribution.Account__c, new Set<String>());
                }
                accountIdVsEmailDistributions.get(emailDistribution.Account__c).add(emailDistribution.Email_Distribution__c);
            }
            
            List<Account_Email_Distribution__c> accountEmailDistributionInsertList = new List<Account_Email_Distribution__c>();
            for(Account_Product_Line__c productLine: triggerNew){
                if(accountIdSet.contains(productLine.Account__c) && newsProductMap.containsKey(productLine.Product__c)){
                    String subscriptionName = newsProductMap.get(productLine.Product__c).Name;
                    if(subscriptionVsEmailDistributions.containsKey(subscriptionName)){
                        Set<String> accountEmailDistributionSet = accountIdVsEmailDistributions.containsKey(productLine.Account__c) ? accountIdVsEmailDistributions.get(productLine.Account__c) : new Set<String>();
                        for(String emailDistribution: subscriptionVsEmailDistributions.get(subscriptionName)){
                            if(!accountEmailDistributionSet.contains(emailDistribution)){
                                Account_Email_Distribution__c emailDistributn = new Account_Email_Distribution__c();
                                emailDistributn.Account__c = productLine.Account__c;
                                emailDistributn.Email_Distribution__c = emailDistribution;
                                emailDistributn.Name = emailDistribution;
                                accountEmailDistributionInsertList.add(emailDistributn);
                            }
                        }
                    }
                }
            }
            
            if(accountEmailDistributionInsertList.isEmpty()){
                return false;
            }
            
            //insert Account Email Distributions for News Products added as Product Lines
            //SF-798 - Bulkify Email Distro assignment upon Product Addition
            //Database.insert(accountEmailDistributionInsertList, false);
            if(accountEmailDistributionInsertList.size() > 0){
                database.executeBatch(new AccountEmailDistributionInsertBatch(accountEmailDistributionInsertList), 10); // Calling batch class.
            }
            return true;
        } catch(Exception ex){
            System.debug('In Apex class clsName. At line number: ' + ex.getLineNumber() + '. Cause: ' + ex.getCause() + '. Message: ' + ex.getMessage());
            return false;
        }
    }
}