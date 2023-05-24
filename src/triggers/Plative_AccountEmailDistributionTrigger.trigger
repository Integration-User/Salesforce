/**
* Company     : Plative
* Description : Trigger for Account_Email_Distribution__c object
* History     : 
* [25.May.2020] Kunal - Code Creation 
*/
trigger Plative_AccountEmailDistributionTrigger on Account_Email_Distribution__c (after insert, after delete) {
    
    Trigger_Control_Setting__c setting = Trigger_Control_Setting__c.getOrgDefaults();    
    if(Test.isRunningTest() || setting.Account_Email_Distribution__c){
        if(Trigger.isAfter){
            if(Trigger.isInsert){
                Plative_AccountEmailDistributionHandler.afterInsert(Trigger.new);            
            }
            if(Trigger.isDelete){
                Plative_AccountEmailDistributionHandler.afterDelete(Trigger.Old);            
            }
        }
    }
    
}