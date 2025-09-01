global class OpportunityLast120DaysActivityBatch implements Database.Batchable<sObject>, Schedulable {
    
    global Iterable<sObject> start(Database.BatchableContext bc) {
        List<sObject> records = new List<sObject>();
        // Fetch Tasks (Calls)
        records.addAll([SELECT Id, Subject, WhatId, Type FROM Task WHERE Type = 'Call' AND SalesLoft1__Call_Disposition__c ='Connected' AND CreatedDate >= LAST_N_DAYS:120 AND WhatId !=null]);
        // Fetch Tasks (Emails)
        records.addAll([SELECT Id, Subject, WhatId, Type FROM Task WHERE Type = 'Email' AND SalesLoft1__SalesLoft_Replies_Count__c > 0 AND CreatedDate >= LAST_N_DAYS:120 AND WhatId !=null]);
        // Fetch Events (Meetings)
        records.addAll([SELECT Id, Status__c, WhatId FROM Event WHERE Status__c = 'Completed' AND StartDateTime >= LAST_N_DAYS:120 AND WhatId !=null]);
        
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
                    if (((Task) record).Type == 'Call') {
                        opp.Count_of_Connected_Calls_Last_120_Days__c = (opp.Count_of_Connected_Calls_Last_120_Days__c != null) ? opp.Count_of_Connected_Calls_Last_120_Days__c + 1 : 1;
                    } else if (((Task) record).Type == 'Email') {
                        opp.Count_of_Email_Replies_Last_120_Days__c = (opp.Count_of_Email_Replies_Last_120_Days__c != null) ? opp.Count_of_Email_Replies_Last_120_Days__c + 1 : 1;
                    }
                } 
                if (record instanceof Event) {
                    opp.Count_of_Meeting_Attended_Last_120_Days__c = (opp.Count_of_Meeting_Attended_Last_120_Days__c != null) ? opp.Count_of_Meeting_Attended_Last_120_Days__c + 1 : 1;
                }
                oppUpdates.put(oppId, new Opportunity(Id = oppId));
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
        OpportunityLast120DaysActivityBatch batch = new OpportunityLast120DaysActivityBatch();
        Database.executeBatch(batch, 5);
    }
}