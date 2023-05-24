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