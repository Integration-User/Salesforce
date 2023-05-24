public class CreateTaskRelationBatch implements Database.Batchable<SObject>, Database.stateful {
    public Map<Id, Task> withoutRelationshipTasks = new Map<Id, Task>();
    public Map<Id, Event> eventList = new Map<Id, Event>();
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        //return database.getQueryLocator('SELECT Id, Subject, owner.Name, (Select RelationId from TaskRelations where IsWhat = false), Owner_Contact__c from Task where Owner.UserRole.Name IN (\'Research\', \'REA\', \'EU REA\')');
    	if(!Test.isRunningTest()) query = 'SELECT Id, Subject, Minutes_Spent__c, Web_Demo__c, Analyst_Count_Data__c, Description, Type, ownerId, whatid, whoId, ActivityDate, status, recordtype.Name, Owner.UserRole.Name, Owner.Name, Case__c, Diagnostic_Discussion__c, Campaign__c,Model_Count__c, (Select RelationId, TaskId, IsWhat, AccountId from TaskRelations where IsWhat = false) from task where type IN (\'Virtual Customer Success Visit\', \'Virtual Visit\', \'Virtual Sales Visit\', \'Virtual Training\', \'Virtual Analyst Visit\', \'In-Person Visit\', \'In-Person Sales Visit\', \'In-Person Training\', \'In-Person Analyst Visit\') AND status = \'Completed\' AND ActivityDate = THIS_YEAR AND Owner.UserRole.name IN (\'CAM\', \'CAM Manager\', \'Customer Success\')';
        else query = 'SELECT Id, Subject, Minutes_Spent__c, Web_Demo__c, Analyst_Count_Data__c, Description, Type, ownerId, whatid, whoId, ActivityDate, status, recordtype.Name, Owner.UserRole.Name, Owner.Name, Case__c, (Select RelationId, TaskId, IsWhat, AccountId from TaskRelations where IsWhat = false) from task';
        return database.getQueryLocator(query);    
    }
    public void execute(Database.BatchableContext BC, List<Task> scope) {
        List<TaskRelation> taskRelList = new List<TaskRelation>();
        system.debug('scope->'+scope);
        For (Task tsk : scope) {
            try {
                Datetime activityDate = (Datetime) tsk.ActivityDate;
                Event event = new Event();
                event.Subject = tsk.Subject;
                event.Type = tsk.Type;
                event.WhatId = tsk.WhatId;
                event.whoId = tsk.whoId;
                event.StartDateTime = activityDate.addHours(20);
                event.EndDateTime = tsk.Minutes_Spent__c != null ? event.StartDateTime.addMinutes(Integer.valueOf(tsk.Minutes_Spent__c)) : event.StartDateTime;
                event.Minutes_Spent__c = tsk.Minutes_Spent__c;
                event.OwnerId = tsk.OwnerId;
                event.Status__c = tsk.Status;
                event.Case__c = tsk.Case__c;
                event.Web_Demo__c = tsk.Web_Demo__c;
                event.Description = tsk.Description; 
                event.Diagnostic_Discussion__c = tsk.Diagnostic_Discussion__c; 
                event.Campaign__c = tsk.Campaign__c;
                event.Model_Count__c = tsk.Model_Count__c; 
                insert event;
                system.debug('event->'+event);
                Set<EventRelation> relations = new Set<EventRelation>();
                for (TaskRelation tskRel : tsk.TaskRelations) {
                    if (tskRel.RelationId !=  tsk.whoId) {
                        relations.add(new EventRelation(EventId = event.Id, RelationId = tskRel.RelationId, IsWhat= tskRel.IsWhat,
                                                   IsParent = tskRel.AccountId != null ? true : false ));
                    }
                    
                }
                
                system.debug('relations->'+relations.size());
                if(!relations.isEmpty()) insert new List<EventRelation>(relations);
                event.Analyst_Count_Data__c = tsk.Analyst_Count_Data__c;
                update event;
                eventList.put(tsk.Id, event);
                // Success
            } catch(Exception e) {
                tsk.Comments__c = e.getMessage();
                withoutRelationshipTasks.put(tsk.id, tsk);
            }
        }
        
        
            /* Set<Id> contactIds = new Set<Id>();
            for (TaskRelation rel : tsk.TaskRelations) {
                String relationId = rel.RelationId;
                if(relationId.startsWith('003')) contactIds.add(rel.RelationId);
            }
            system.debug('Owner.contact_id__c->'+tsk.Owner_Contact__c);
            system.debug('contactIds->'+contactIds);
            if(!contactIds.isEmpty() && tsk.Owner_Contact__c != null && !contactIds.contains(tsk.Owner_Contact__c)) {
                withoutRelationshipTasks.put(tsk.Id, tsk);
                taskRelList.add(new TaskRelation(TaskId = tsk.Id, RelationId = tsk.Owner_Contact__c, IsWhat  = false));
            }
        }
        if(!taskRelList.isEmpty()) {
            system.debug('taskRelList->'+taskRelList.size());
            insert taskRelList;
        }*/
    }
    public void finish(Database.BatchableContext BC) {
        system.debug('withoutRelationshipTasks->'+ withoutRelationshipTasks.size());
        String generatedCSVFile ='Id, Subject, name, Owner Name, Error\n';
        for(Id id : withoutRelationshipTasks.keySet()) {
            Task tsk = withoutRelationshipTasks.get(id);
            system.debug('tsk->'+ tsk);
            String fileRow = tsk.Id + ',' + tsk.Subject.replaceAll(',', '-') + ',' + tsk.whoId + ',' + tsk.Owner.Name+ ',' + tsk.Comments__c;
            generatedCSVFile +=  fileRow + '\n';
        }
        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        Blob csvBlob = blob.valueOf(generatedCSVFile);
        String csvName = 'TaskToEventFailresult.csv';
        csvAttachment.setFileName(csvName);
        csvAttachment.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'mgupta@greenstreet.com', 'ksantos@greenstreet.com'};
            String subject = 'Task To Event Fail Records CSV';
        email.setSubject(subject);
        email.setToAddresses(toAddresses);
        String successRecords = '| ----- TaskId ------ | ---- Event Id ---- | ----- OwnerId ----- | ------  Subject  -----|\n';
        for (Id id : eventList.keySet() ) {
            Event event = eventList.get(id);
            successRecords += '| ' + id + ' | ' + event.Id + ' | ' + event.Subject + ' | ' +  event.OwnerId + ' |\n';
        }
        email.setPlainTextBody(successRecords);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }

}