public class SalesloftReplyCountScheduler implements Schedulable {
   public void execute(SchedulableContext sc) {
        // Enqueue the first Queueable job starting from page 1
        System.enqueueJob(new SalesloftReplyCountQueueable());
    }
}