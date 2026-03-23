public without sharing class TaskTriggerHandler {
    
    public static void afterAction(List<Task> newList, Map<Id, Task> oldMap) {
        Set<Id> ownerIds = new Set<Id>();
        Set<Id> taskIds = new Set<Id>();
        Set<Id> EngagementIds = new Set<Id>();
        for(Task tsk : newList) {
            ownerIds.add(tsk.ownerId);
            taskIds.add(tsk.Id);
            if(tsk.affectlayer__ChorusEngagement__c != null && (Trigger.isInsert || 
               (Trigger.isUpdate && oldMap.get(tsk.id).affectlayer__ChorusEngagement__c != tsk.affectlayer__ChorusEngagement__c))) {
                EngagementIds.add(tsk.affectlayer__ChorusEngagement__c);
            }
        }

        Map<Id, User> userInfoList = new Map<Id, User>([Select Id, UserRole.Name, Contact_Id__c FROM User Where Id IN :ownerIds]);
        Set<Id> addContactIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        for(User user: userInfoList.values()) {
            if((user.UserRole.Name == 'REA' || user.UserRole.Name == 'Research' || user.UserRole.Name == 'EU REA') && user.Contact_Id__c != null) {
                contactIds.add(user.Contact_Id__c); 
            }          
        }
        
        // SF-538 - link contacts to Chorus Engagements
        Map<Id, Set<Id>> EngagementVsContactsMap = new Map<Id, Set<Id>>();
        if (!EngagementIds.isEmpty() || Test.isRunningTest()) {
            for(affectlayer__ChorusEngagementContact__c chorusEngagement : 
                [Select Id, affectlayer__Contact__c, affectlayer__Engagement__c From affectlayer__ChorusEngagementContact__c 
                 where affectlayer__Engagement__c IN :EngagementIds AND affectlayer__Contact__c != null]) {
                     if(EngagementVsContactsMap.containsKey(chorusEngagement.affectlayer__Engagement__c)) {
                         EngagementVsContactsMap.get(chorusEngagement.affectlayer__Engagement__c).add(chorusEngagement.affectlayer__Contact__c);
                     } else {
                         EngagementVsContactsMap.put(chorusEngagement.affectlayer__Engagement__c, new Set<Id> {chorusEngagement.affectlayer__Contact__c});
                     }
                 }
        }

        try {
            Set<TaskRelation> insertRelationship = new Set<TaskRelation>();
            Map<String, TaskRelation> ownerRelation = new Map<String, TaskRelation>();
            for (TaskRelation taskrel : [SELECT Id, RelationId, TaskId FROM TaskRelation where TaskId IN :taskIds]){
                String key = taskrel.TaskId +''+ taskrel.RelationId;
                ownerRelation.put(key, taskrel);
            }

            if(!contactIds.isEmpty() || Test.isRunningTest()) {
                for(Task tsk : newList) {
                    if(Trigger.isInsert || (Trigger.isUpdate && oldMap.get(tsk.id).OwnerId != tsk.OwnerId)) {
                        String contactId = userInfoList.get(tsk.ownerId).Contact_Id__c;
                        String key = tsk.Id +''+ contactId;
                        if(contactId != null && contactIds.contains(contactId) && (ownerRelation.isEmpty() || (!ownerRelation.isEmpty() && !ownerRelation.containsKey(key)))) {
                            insertRelationship.add(new TaskRelation(TaskId = tsk.Id, RelationId = contactId, IsWhat  = false));
                            addContactIds.add(contactId);
                        } 
                    }
                }
            }
            if(!EngagementVsContactsMap.isEmpty() || Test.isRunningTest()) {
                for(Task tsk : newList) {
                     if(tsk.affectlayer__ChorusEngagement__c != null 
                        && (Trigger.isInsert || (Trigger.isUpdate && oldMap.get(tsk.id).affectlayer__ChorusEngagement__c != tsk.affectlayer__ChorusEngagement__c))) {
                            Set<Id> engagementContactIds = EngagementVsContactsMap.get(tsk.affectlayer__ChorusEngagement__c);

                            for (Id conId : engagementContactIds) {
                                 String key = tsk.Id +''+ conId;
                                if(!addContactIds.contains(conId) && (ownerRelation.isEmpty() || (!ownerRelation.isEmpty() && !ownerRelation.containsKey(key)))) {
                                    insertRelationship.add(new TaskRelation(TaskId = tsk.Id, RelationId = conId, IsWhat  = false));
                                }
                            }  
                        }
                }
            }

            if(!insertRelationship.isEmpty()) {
                insert new List<TaskRelation>(insertRelationship);
            }
        } catch(Exception e) {
            System.debug('Exception ->' + e.getMessage());
        }
    }
    /* SF-1565
     * “Count of Calls last 30” ( Task with Subject contains “Call: connected” 
     * “Count of Emails last 30” (Tasks with subject starting with “reply” 
	*/
    public Static void updateCountOfCallOrEmailLast30Days(List<Task> newList){
        Set<Id> oppIds = new Set<Id>();
        
        // Collect Opportunity IDs from Task WhatId
        for (Task t : newList) {
            if (t.WhatId != null && t.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity' && t.Subject != null
                && (t.Subject.contains('Call: Connected') || t.Subject.startsWith('Reply') || t.Type == 'Call' || t.Type == 'Email')) {
                oppIds.add(t.WhatId);
            }
        }
         System.debug('oppIds->' + oppIds);
        if (!oppIds.isEmpty()) {
            // Query all Opportunities at once
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, Count_of_Calls_Last_30__c, Count_of_Emails_Last_30__c, Count_of_Connected_Calls_Last_120_Days__c, Count_of_Email_Replies_Last_120_Days__c FROM Opportunity WHERE Id IN :oppIds]);           
            // Update Opportunity counts
            for (Task t : newList) {
                if (oppMap.containsKey(t.WhatId)) {
                    Opportunity opp = oppMap.get(t.WhatId);
                    // SF-1851, Removed changes related to // SF-1641
                    if (opp != null && t.Subject.contains('Call: Connected')) {
                        opp.Count_of_Calls_Last_30__c = (opp.Count_of_Calls_Last_30__c != null) ? opp.Count_of_Calls_Last_30__c + 1 : 1;
                        opp.Count_of_Connected_Calls_Last_120_Days__c = (opp.Count_of_Connected_Calls_Last_120_Days__c != null && opp.Count_of_Connected_Calls_Last_120_Days__c > 0) ? opp.Count_of_Connected_Calls_Last_120_Days__c + 1 : 1;
                    } else if (opp != null && t.Subject.startsWith('Reply')) {
                        opp.Count_of_Emails_Last_30__c = (opp.Count_of_Emails_Last_30__c != null) ? opp.Count_of_Emails_Last_30__c + 1 : 1;
                        opp.Count_of_Email_Replies_Last_120_Days__c = (opp.Count_of_Email_Replies_Last_120_Days__c != null && opp.Count_of_Email_Replies_Last_120_Days__c > 0) ? opp.Count_of_Email_Replies_Last_120_Days__c + 1 : 1;
                    } 
                }
            }
            
            update oppMap.values(); // Bulk update
        }
    }
    
}
