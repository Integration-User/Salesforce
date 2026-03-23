global class OpportunityLast120DaysActivityBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    global Set<Id> OppIdsProcessed = new Set<Id>();
    Map<String, Opportunity> oppUpdates = new Map<String, Opportunity>();
    global Iterable<sObject> start(Database.BatchableContext bc) {
        List<sObject> records = new List<sObject>();
        // Fetch Tasks (Calls) & Tasks (Emails)
        for (Task tsk : [SELECT Id, Subject, WhatId, Type FROM Task 
                         WHERE (Subject LIKE '%Call: Connected%' OR Subject LIKE 'Reply%') AND CreatedDate >= LAST_N_DAYS:120 AND WhatId !=null AND What.Type= 'Opportunity']) {
            String oppId = tsk.WhatId;
            if(oppId.startsWith('006')) {
                records.add(tsk);   
            }             
        }
        // Fetch Events (Meetings)
        for (Event evt : [SELECT Id, Status__c, WhatId FROM Event WHERE Status__c = 'Completed' AND Canceled_Date__c = NULL AND No_Show_Date__c = FALSE AND StartDateTime >= LAST_N_DAYS:120 AND WhatId !=null AND What.Type= 'Opportunity']) {
            String oppId = evt.WhatId;
            if(oppId.startsWith('006')) {
                records.add(evt);   
            } 
        }
        return records;
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        Set<String> oppIds = new Set<String>();
        for (sObject record : scope) {
            oppIds.add((String) record.get('WhatId'));
        }
        System_Configuration__mdt config = System_Configuration__mdt.getInstance('OpportunityLast120DaysActivityRecordType');
        List<String> recordTypeNames = config.Value__c.split(',');
        Map<Id, Opportunity> oppMap = New Map<Id, Opportunity>([SELECT Id,Count_of_Connected_Calls_Last_120_Days__c, Count_of_Email_Replies_Last_120_Days__c,
                                                                Count_of_Meeting_Attended_Last_120_Days__c FROM Opportunity 
                                                                WHERE Id IN:oppIds AND IsClosed = FALSE AND RecordType.DeveloperName IN :recordTypeNames]);
        for (sObject record : scope) {
            String oppId = (String) record.get('WhatId'); // Assuming Task/Event is linked to Opportunity
            if(oppMap.containsKey(oppId)) {
                Opportunity opp = new Opportunity(Id = oppId);
                if (oppUpdates.containsKey(oppId)) {
                    opp = oppUpdates.get(oppId);
                }
                if(!OppIdsProcessed.contains(oppId)) {
                    opp.Count_of_Connected_Calls_Last_120_Days__c = 0;
                    opp.Count_of_Meeting_Attended_Last_120_Days__c = 0;
                    opp.Count_of_Email_Replies_Last_120_Days__c = 0;
                }
                OppIdsProcessed.add(oppId);
                // Handle different field values based on record type
                if (record instanceof Task) {
                    if (((Task) record).Subject.contains('Call: Connected')) {
                        opp.Count_of_Connected_Calls_Last_120_Days__c = (opp.Count_of_Connected_Calls_Last_120_Days__c != null) ? opp.Count_of_Connected_Calls_Last_120_Days__c + 1 : 1;
                    } else if (((Task) record).Subject.startsWith('Reply')) {
                        opp.Count_of_Email_Replies_Last_120_Days__c = (opp.Count_of_Email_Replies_Last_120_Days__c != null) ? opp.Count_of_Email_Replies_Last_120_Days__c + 1 : 1;
                    }
                } 
                if (record instanceof Event) {
                    opp.Count_of_Meeting_Attended_Last_120_Days__c = (opp.Count_of_Meeting_Attended_Last_120_Days__c != null) ? opp.Count_of_Meeting_Attended_Last_120_Days__c + 1 : 1;
                }
                oppUpdates.put(oppId, opp);
            }
        }
        System.debug('oppUpdates-->' + oppUpdates);
        // Bulk update Opportunities
        update oppUpdates.values();
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('Batch Job Completed');
    }
    // Implement Schedulable Interface
    global void execute(SchedulableContext sc) {
        OpportunityLast120DaysActivityBatch batch = new OpportunityLast120DaysActivityBatch();
        Database.executeBatch(batch, 10);
    }
}