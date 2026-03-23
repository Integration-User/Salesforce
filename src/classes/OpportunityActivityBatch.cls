global class OpportunityActivityBatch implements Database.Batchable<sObject>, Schedulable {
    
    global Iterable<sObject> start(Database.BatchableContext bc) {
        List<sObject> records = new List<sObject>();
                // Fetch Tasks (Calls) & Tasks (Emails)
        for (Task tsk : [SELECT Id, Subject, WhatId, Type FROM Task 
                         WHERE (Subject LIKE '%Call: Connected%' OR Subject LIKE 'Reply%') AND CreatedDate >= LAST_N_DAYS:30 AND WhatId !=null AND What.Type= 'Opportunity']) {
            String oppId = tsk.WhatId;
            if(oppId.startsWith('006')) {
                records.add(tsk);   
            }             
        }
        // Fetch Events (Meetings)
        for (Event evt : [SELECT Id, Status__c, WhatId FROM Event WHERE Status__c = 'Completed' AND Canceled_Date__c = NULL AND No_Show_Date__c = FALSE AND StartDateTime >= LAST_N_DAYS:30 AND WhatId !=null AND What.Type= 'Opportunity']) {
            String oppId = evt.WhatId;
            if(oppId.startsWith('006')) {
                records.add(evt);   
            } 
        }
        return records;        
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        Map<String, Opportunity> oppUpdates = new Map<String, Opportunity>();

        for (sObject record : scope) {
            String oppId = (String) record.get('WhatId'); // Assuming Task/Event is linked to Opportunity
            if(oppId.startsWith('006')) {
                if (!oppUpdates.containsKey(oppId)) {
                    oppUpdates.put(oppId, new Opportunity(Id = oppId));
                }
                
                Opportunity opp = oppUpdates.get(oppId);
                
                // Handle different field values based on record type
                if (record instanceof Task) {
                    if (((Task) record).Subject.contains('Call: Connected')) {
                        opp.Count_of_Calls_Last_30__c = (opp.Count_of_Calls_Last_30__c != null) ? opp.Count_of_Calls_Last_30__c + 1 : 1;
                    } else if (((Task) record).Subject.startsWith('Reply')) {
                        opp.Count_of_Emails_Last_30__c = (opp.Count_of_Emails_Last_30__c != null) ? opp.Count_of_Emails_Last_30__c + 1 : 1;
                    }
                } else if (record instanceof Event) {
                    opp.Count_of_Meetings_Last_30__c = (opp.Count_of_Meetings_Last_30__c != null) ? opp.Count_of_Meetings_Last_30__c + 1 : 1;
                }
            }
            
        }

        // Bulk update Opportunities
        update oppUpdates.values();
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('Batch Job Completed');
    }
    // Implement Schedulable Interface
    global void execute(SchedulableContext sc) {
        OpportunityActivityBatch batch = new OpportunityActivityBatch();
        Database.executeBatch(batch, 10);
    }
}