global class Plative_GSAGetLastLoginDateScheduler implements Schedulable  {
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new Plative_GSAGetLastLoginDateBatch(),25);
    }
    
}