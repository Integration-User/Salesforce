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
        if (!EngagementIds.isEmpty()) {
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

            if(!contactIds.isEmpty()) {
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
            if(!EngagementVsContactsMap.isEmpty()) {
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
    
}