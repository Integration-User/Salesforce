trigger Plative_AccountProductLineTrigger on Account_Product_Line__c (after insert, after delete) {
    
    Trigger_Control_Setting__c setting = Trigger_Control_Setting__c.getOrgDefaults();
    
    if(Test.isRunningTest() || setting.Account_Product_Line__c){
        if(Trigger.isAfter){
            if(Trigger.isInsert){
                Plative_AccountProductLineTriggerHandler.updateProductLineOnPlatform(Trigger.new);
                Plative_AccountProductLineTriggerHandler.afterInsert(Trigger.new);
            }
            
            if(Trigger.isDelete){
                Plative_AccountProductLineTriggerHandler.updateProductLineOnPlatform(Trigger.old);
                Plative_AccountProductLineTriggerHandler.updateProductInAccountContact(Trigger.old);
            }
        } 
    }
}