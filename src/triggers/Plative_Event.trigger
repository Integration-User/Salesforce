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
        if(System.Label.Skip_Count_Of_Calls_Email_Meeting_For_Opportunity == 'False') updateCountOfMeetingsFromLast30Days(); // SF-1565
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
        if(System.Label.Skip_Count_Of_Calls_Email_Meeting_For_Opportunity == 'False') updateCountOfMeetingsFromLast30Days(); // SF-1565
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
                String conId = evtRel.relationid;
                if(!mapContact.containskey(evtRel.relationid) && conId.startsWith('003'))
                    mapContact.put(evtRel.relationid, new Contact(id=evtRel.relationid, Attended_Training_Date__c=evtRel.Event.StartDateTime.date()));
            }
            try{
                update mapContact.values();
            } catch(Exception e){}
            
        }
        
    }
    /* SF-1565
     * “Count of Meetings last 30” (Events with Status = Completed” + Cancelled Date = null, no show is FALSE) 
	*/
    public void updateCountOfMeetingsFromLast30Days(){
        Set<Id> oppIds = new Set<Id>();
        DateTime thirtyDaysAhead = System.now().addDays(30);
        // Collect Opportunity IDs from Event WhatId
        for (Event e : Trigger.new) {
            Event oldEvent = Trigger.oldMap != null ? Trigger.oldMap.get(e.Id) : null;
            if ((Trigger.isInsert || (oldEvent != null && oldEvent.Status__c != e.Status__c && e.StartDateTime <= thirtyDaysAhead)) 
                && e.Status__c == 'Completed' && e.Canceled_Date__c == NULL && e.No_Show_Date__c == FALSE
                && e.WhatId != null && e.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity') {
                oppIds.add(e.WhatId);
            }
        }
        
        if (!oppIds.isEmpty()) {
            // Query all Opportunities at once
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, Count_of_Meetings_Last_30__c FROM Opportunity WHERE Id IN :oppIds]);
            // Update Opportunity counts
            for (Event e : Trigger.new) {
                if (oppMap.containsKey(e.WhatId)) {
                    Opportunity opp = oppMap.get(e.WhatId);
                    opp.Count_of_Meetings_Last_30__c = (opp.Count_of_Meetings_Last_30__c != null) ? opp.Count_of_Meetings_Last_30__c + 1 : 1;
                }
            }
            update oppMap.values(); // Bulk update
        }
    }
}