/**
* Company     : Plative
* Description :  Controller class for Plative_EmailDistributionOptOutLtng aura component
* History     : 
* [25.May.2020] Kunal - Code Creation 
*/
public class Plative_EmailDistributionOptOutCtrl {
    
    //Checks whether the account is active or not
    @AuraEnabled
    public static String getContactStatus(String recordId){
        String response = '';
        response = [Select Id,Contact_Status__c from Contact where Id = :recordId].Contact_Status__c;
        return response;        
    }
    
    
    //Get all contact email distributions
    @AuraEnabled
    public static List<Object> getContactEmailDistributions(String recordId){
        List<Contact_Email_Distribution__c> insertedDistribution = new List<Contact_Email_Distribution__c>();
        Contact con = [Select Id, AccountId from Contact WHERE ID =:recordId ];

        Map<String, Contact_Email_Distribution__c> existingDistributionInfo = new Map<String, Contact_Email_Distribution__c>();
        for (Contact_Email_Distribution__c distribution : [Select Id,Email_Distribution__c,Opt_Out__c from Contact_Email_Distribution__c where Contact__c = :recordId]) {
            existingDistributionInfo.put(distribution.Email_Distribution__c, distribution);
        }
        
        //Get Account Product Lines
        List<Account_Product_Line__c> accountProductLines = [Select Id,Product__r.Name from Account_Product_Line__c where Account__c = :con.AccountId];
        Set<String> subscriptionNameSet = new Set<String>();
        for(Account_Product_Line__c productLine: accountProductLines){
            subscriptionNameSet.add(productLine.Product__r.Name);
        }
        //Get Email Distributions from Subscriptions   
        Set<String> newDistributionName = new Set<String>();
        for (Email_Distribution__c emailDistribution : [SELECT Id,Name FROM Email_Distribution__c WHERE Subscription__c IN: subscriptionNameSet ORDER BY Order_of_Email_DL_s__c DESC NULLS LAST]) {
            if (!existingDistributionInfo.containsKey(emailDistribution.Name) && !newDistributionName.contains(emailDistribution.Name)) {
                Contact_Email_Distribution__c contactEmailDistribution = new Contact_Email_Distribution__c();
                contactEmailDistribution.Contact__c = recordId;
                contactEmailDistribution.Account__c = con.AccountId;
                contactEmailDistribution.Opt_Out__c = true; 
                contactEmailDistribution.Email_Distribution__c = emailDistribution.Name;
                insertedDistribution.add(contactEmailDistribution);
                newDistributionName.add(emailDistribution.Name);
            }
        }
        insert insertedDistribution;
        // insertedDistribution.addAll(existingDistributionInfo.values());
        return [Select Id,Email_Distribution__c,Opt_Out__c from Contact_Email_Distribution__c where Contact__c = :recordId];
    }
    
    //Save email distributions opt out
    @AuraEnabled
    public static String saveEmailOptOut(String recordId,List<String> emailOptOutList){
        String response = '';
        try{
            List<Contact_Email_Distribution__c> updateList = new List<Contact_Email_Distribution__c>();
            //Fetch existing Contact Email Distributions
            List<Contact_Email_Distribution__c> contactEmailDistributionList = [Select Id,Email_Distribution__c,Opt_Out__c from Contact_Email_Distribution__c
                                                                                where Contact__c = :recordId];
            
            //If Opt out list is empty then set Opt Out to false to all 
            if(emailOptOutList.isEmpty()){
                for(Contact_Email_Distribution__c contactEmailDistribution: contactEmailDistributionList){
                    contactEmailDistribution.Opt_Out__c = false;
                }            
                //Update Contact Email Distributions
                update contactEmailDistributionList;
            } else {
                //Mark all Contact Email Distribution to false except the ones contained in emailOptOut list
                for(Contact_Email_Distribution__c contactEmailDistribution: contactEmailDistributionList){
                    contactEmailDistribution.Opt_Out__c = false;
                    if(emailOptOutList.contains(contactEmailDistribution.Email_Distribution__c)){
                        contactEmailDistribution.Opt_Out__c = true; 
                    }
                }
                //Update Contact Email Distributions
                update contactEmailDistributionList;
            }        
            response = 'Success!';
        } catch(DMLException ex){
            response = ex.getDmlMessage(0);          
        }
        
        return response;
    }
    
    
}