/****************************************************************************
Author : Prachi Gadewar
Date : 29-09-2021
Name : Schedule_ConvertAppecuesEvents
Test Class : Schedule_ConvertAppecuesEventsTest
Description : Class convert all the Appcues events created from Integration to Custom 
            object Appecues event records and delete the Event records
****************************************************************************/

/****************************************************************************
Author : Prachi Gadewar
Date : 29-09-2021
Name : Schedule_ConvertAppecuesEvents
Test Class : Schedule_ConvertAppecuesEventsTest
Description : Class convert all the Appcues events created from Integration to Custom 
            object Appecues event records and delete the Event records
****************************************************************************/

public with sharing class Schedule_ConvertAppecuesEvents Implements Database.Batchable<sObject>, Schedulable  {
    public void execute(SchedulableContext sc){
        //convertEventsToAppcuesRec();
        Database.executeBatch(new Schedule_ConvertAppecuesEvents(),2000); 
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Event.subject, Event.Description,Event.Id,EventId,IsWhat,AccountId, RelationId,Event.EndDateTime,Status FROM EventRelation where event.subject like \'%appcues%\'');
    }
    public void execute(Database.BatchableContext BC, List<EventRelation> listAppcuesEvents) {
        List<Appcues__c> listToInsert = new List<Appcues__c>();
        Map<Id,Event> mapEvents = new Map<Id,Event>();
        Recordtype rt = [Select id from Recordtype where name = 'Appcues Event RT' limit 1];
        for(EventRelation evr : listAppcuesEvents){
            Appcues__c record = new Appcues__c();
            record.Account__c = evr.AccountId;
            record.Contact__c = evr.RelationId;
            record.Description__c = evr.Event.Description;
            record.Event_Date__c = evr.Event.EndDateTime.date();
            record.RecordTypeId = rt.id;
            record.Subject__c = evr.Event.subject;
            listToInsert.add(record);
            if(!mapEvents.containskey(evr.EventId))
                mapEvents.put(evr.EventId,new Event(Id = evr.EventId));
        }
        insert listToInsert;
        delete mapEvents.values();
    }
    public void finish(Database.BatchableContext BC) {}
    
    /* public void convertEventsToAppcuesRec(){

        List<Appcues__c> listToInsert = new List<Appcues__c>();
        Map<Id,Event> mapEvents = new Map<Id,Event>();
        Recordtype rt = [Select id from Recordtype where name = 'Appcues Event RT' limit 1];
        List<EventRelation> listAppcuesEvents =  [SELECT Event.subject, Event.Description,Event.Id,EventId,IsWhat,AccountId,
                                                         RelationId,Event.EndDateTime,Status 
                                                  FROM   EventRelation where event.subject like '%appcues%'];

        for(EventRelation evr : listAppcuesEvents){
            Appcues__c record = new Appcues__c();
            record.Account__c = evr.AccountId;
            record.Contact__c = evr.RelationId;
            record.Description__c = evr.Event.Description;
            record.Event_Date__c = evr.Event.EndDateTime.date();
            record.RecordTypeId = rt.id;
            record.Subject__c = evr.Event.subject;
            listToInsert.add(record);
            if(!mapEvents.containskey(evr.EventId))
                mapEvents.put(evr.EventId,new Event(Id = evr.EventId));
        }

        insert listToInsert;
        delete mapEvents.values();
    }*/
}