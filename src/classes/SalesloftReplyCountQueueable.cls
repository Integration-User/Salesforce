public class SalesloftReplyCountQueueable implements Queueable, Database.AllowsCallouts {
    private Date startDate;
    private Integer page;

    public SalesloftReplyCountQueueable(Integer page) {
        this.page = page;
    }
    public SalesloftReplyCountQueueable() {
    }

    public void execute(QueueableContext context) {
        date.today();
        SalesloftEmailActivityResponse resp;
        if(this.page != null && this.page > 1) 
            resp = SalesloftAuthService.getEmailsActivities(this.page);
        else 
            resp = SalesloftAuthService.getEmailsActivities();
        system.debug('resp->' + resp);
        if (resp == null || resp.data == null) {
            return;
        }

        // Collect message IDs from response
        Set<String> messageIds = new Set<String>();
        for (SalesloftEmailActivityResponse.ActivityData act : resp.data) {
            system.debug('act->' + act);
            if (act.message_id != null) {
                messageIds.add('<' + act.message_id + '>');
            }
        }

        if (!messageIds.isEmpty()) {
            // Query Tasks matching Email_Message_Id__c
            Map<String, Task> taskByMessageId = new Map<String, Task>();
            for (Task t : [SELECT Id, Email_Message_Id__c, SalesLoft_Reply_Count_API__c FROM Task WHERE Email_Message_Id__c IN :messageIds]) {
                if (t.Email_Message_Id__c != null) {
                    taskByMessageId.put(t.Email_Message_Id__c, t);
                }
            }
            system.debug('taskByMessageId->' + taskByMessageId);
            List<Task> updates = new List<Task>();
            for (SalesloftEmailActivityResponse.ActivityData act : resp.data) {
                if (act.message_id != null && taskByMessageId.containsKey('<' + act.message_id + '>')) {
                    Task t = taskByMessageId.get('<' + act.message_id + '>');
                    Integer replies = (act.counts != null) ? act.counts.replies : 0;
                    t.SalesLoft_Reply_Count_API__c = replies;
                    updates.add(t);
                }
            }
            system.debug('updates->' + updates);

            if (!updates.isEmpty()) {
                update updates;
            }
        }

        // If there's a next page, enqueue another job
        if (resp.metadata != null && resp.metadata.paging != null && resp.metadata.paging.next_page != null) {
            System.enqueueJob(new SalesloftReplyCountQueueable(resp.metadata.paging.next_page));
        }
    }
}