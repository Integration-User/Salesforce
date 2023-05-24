/**
* Company     : Plative
* Description :  Handler class for Plative_AccountEmailDistributionTrigger
* History     : 
* [25.May.2020] Kunal - Code Creation 
*/
public class Plative_AccountEmailDistributionHandler {    
    
    //After Insert Method
    public static void afterInsert(List<Account_Email_Distribution__c> triggerNew){
        Plative_AccountEmailDistributionHelper.insertContactEmailDistribution(triggerNew);
    }
    
    //After Delete Method
    public static void afterDelete(List<Account_Email_Distribution__c> triggerOld){
        Plative_AccountEmailDistributionHelper.removeContactEmailDistribution(triggerOld);
    }

}