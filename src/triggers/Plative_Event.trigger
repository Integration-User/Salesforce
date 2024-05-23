/**
* Company     : Plative
* Description : Trigger on Events
* [30.Mar.2020] Anisa Shaikh - Code Creation 
*/
trigger Plative_Event on Event (after insert, after update)  { 

    //Get global settings
    Trigger_Control_Setting__c setting = Trigger_Control_Setting__c.getOrgDefaults();

    //If insert 
    if(setting.Event__c && Trigger.isInsert){
        System.enqueueJob(new Plative_ActivitySecurityUtil(trigger.newMap,'Event'));    
        updateContactTrainingDate();  
        updateAccountLastTrainingDate(); // SF-917
    }

    //If update
    if(setting.Event__c && Trigger.isUpdate){
        Map<Id, Event> mapAffectedEvents = new Map<Id, Event>();
        //check if owners are updated
        for(Event evt : Trigger.new){
            if(evt.OwnerId != Trigger.oldMap.get(evt.Id).OwnerId){
                mapAffectedEvents.put(evt.Id, evt);
            }
        }
        if(!mapAffectedEvents.isEmpty()){
            System.enqueueJob(new Plative_ActivitySecurityUtil(mapAffectedEvents,'Event'));    
        }
        updateContactTrainingDate();
        updateAccountLastTrainingDate(); // SF-917
    }
    public void updateAccountLastTrainingDate(){
        //SF-917 Last Training Date - Account
        Set<Id> accountIds = new Set<Id>();
        List<String> types = System.Label.Last_Training_Date_Event_Type.split(',');
        for(Event evt : Trigger.new){
            if(evt.WhatId != null && evt.WhatId.getSObjectType().getDescribe().getName() == 'Account' && evt.Status__c == 'Completed' 
               && (Trigger.isInsert || (Trigger.oldMap != null && evt.Status__c != Trigger.oldMap.get(evt.Id).Status__c)) 
                   && types.contains((String) evt.Type)) {
                   accountIds.add(evt.WhatId);
               }
        }
        if(!accountIds.isEmpty()) {
            List<Account> accList = new List<Account>();
            for(Id accId : accountIds) {
                accList.add(New Account(Id = accId, Last_Training_Date__c = System.today()));
            }
            system.debug('accList - >' + accList);
            update accList;
        }
        //END SF-917 Last Training Date - Account
    }
    public void updateContactTrainingDate(){
        String eventNames = System.Label.Training_Event_Values_For_Contact;
        Map<Id,Contact> mapContact = new Map<Id,Contact>(); 
        List<EventWhoRelation> listEventRelation = [select id,relationid,EventId,Event.StartDateTime 
                                        FROM EventWhoRelation 
                                        WHERE EventId in: trigger.new AND /* (Event.Type = 'Training' OR Event.Type = 'Visit')*/
                                                   Event.Type IN :eventNames.split(';')
                                                   AND event.Status__c = 'Completed']; 
        if(listEventRelation != null && listEventRelation.size() > 0){
            for(EventWhoRelation evtRel : listEventRelation){
                if(!mapContact.containskey(evtRel.relationid))
                    mapContact.put(evtRel.relationid, new Contact(id=evtRel.relationid, Attended_Training_Date__c=evtRel.Event.StartDateTime.date()));
            }
            try{
                update mapContact.values();
            } catch(Exception e){}
            
        }
        
    }
}