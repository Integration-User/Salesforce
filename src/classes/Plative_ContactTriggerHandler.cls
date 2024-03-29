/**
* Description : Handler for contact trigger's dml events
* [20.Mar.2020] Plative - Code Creation 
* [21.Mar.2021] Plative - Added method checkBillingContactChange invocation
**/
public class Plative_ContactTriggerHandler {
    
    //Variable to handler recursion
    public static Boolean afterUpdateRun = false;
    public static Boolean beforeUpdateRun = false;
    public static Boolean afterInsertRun = false;
    
    /**
    * Description : after update DML
    **/ 
    public static void afterUpdate(Map<Id, Contact> mapOldCon, Map<Id, Contact> mapNewCon){
        if (!Plative_ContactTriggerHandler.afterUpdateRun) {
            Plative_ContactTriggerHelper.syncRecordsToNS(mapOldCon,mapNewCon);
            //Plative_ContactTriggerHelper.checkBillingContactChange(mapNewCon.values(), mapOldCon, mapNewCon);
            Plative_ContactTriggerHelper.updateUsername(mapNewCon.values(), mapOldCon);
            Plative_ContactTriggerHelper.activateContact(mapNewCon.values(),mapOldCon);
            Plative_ContactTriggerHelper.deactivateContact(mapNewCon.values(),mapOldCon);
            Plative_ContactTriggerHandler.afterUpdateRun = true;
            if(isUpdateBillingContact(mapOldCon,mapNewCon))
                AddOrRemoveBillingContact.AddBillingContact(mapNewCon.keyset(),null);
            Plative_ContactTriggerHelper.updateExcelAddUsersOnAccount(mapNewCon.values(), mapOldCon); // SF-918
        }
    }
    
    /**
    * Description : before update DML
    **/ 
    public static void beforeUpdate(Map<Id, Contact> mapOldCon, Map<Id, Contact> mapNewCon){
        if (!Plative_ContactTriggerHandler.beforeUpdateRun) {
            Boolean isSuccess = Plative_SFToNSSyncUtility.updateSyncToNSField(mapOldCon,mapNewCon,
                                                                              'Contact', 'Update');
            Plative_SFToNSSyncUtility.updateProductFamily(mapOldCon, mapNewCon);
            Plative_ContactTriggerHandler.beforeUpdateRun = true;
        }
    }
    public static void beforeActions(List<Contact> newList){
        for(Contact con : newList){
            // Moving logic from 'Process Builder - Contact Updates + Linkedin Updates' to trigger To update User Name 
            if(con.Username__c == null && con.Email != null){
                con.Username__c = con.Email;
            }
            /* Moving logic from 'Process Builder - Contact Updates + Linkedin Updates' to trigger To update Onboarding Status
            if(con.Contact_Status__c == 'Active' && String.isBlank(Con.Onboarding_Status__c)) {
                con.Onboarding_Status__c = 'Registrant';
                con.Registrant_Date__c = System.today();
            }*/
        }
    }
    
    
    /**
    * Description : after insert DML
    **/ 
    public static void afterInsert(List<Contact> triggerNew){
        if(!Plative_ContactTriggerHandler.afterInsertRun){
            Plative_ContactTriggerHelper.activateContact(triggerNew,null);
            AddOrRemoveBillingContact.AddBillingContact(trigger.Newmap.keyset(),null);
            //Plative_ContactTriggerHelper.checkBillingContactChange(triggerNew, null,null);
            Plative_ContactTriggerHelper.updateExcelAddUsersOnAccount(triggerNew, null); // SF-918
            Plative_ContactTriggerHandler.afterInsertRun = true;
        }
    }
    
    public static Boolean  isUpdateBillingContact(Map<Id, Contact> mapOldCon, Map<Id, Contact> mapNewCon){
        Boolean isUpdate = false;
        for(Contact con : mapNewCon.values()){
            Contact oldContact = mapOldCon.get(con.id);
            if(con.Billing_Contact_Multi__c != oldContact.Billing_Contact_Multi__c){
                isUpdate = true;
                Break;
            }
        }
        return isUpdate;
    }
    
}