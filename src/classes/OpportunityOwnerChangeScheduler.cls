public class OpportunityOwnerChangeScheduler implements Schedulable {
    
    public void execute(SchedulableContext sc) {
		Database.executeBatch(new OpportunityOwnerChangeBatch(false), 1);
    }
}