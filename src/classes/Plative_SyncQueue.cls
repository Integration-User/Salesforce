/**
* Company     : Plative
* Description : Singleton used to queue and order queueable jobs
* [20.Mar.2020] Anisa - Code Creation 
**/

public class Plative_SyncQueue  {
	
    // private static variable referencing the class
    private static Map<Decimal, Plative_UpsertRecordQueueable> instance = null;

    // The constructor is private
    private Plative_SyncQueue(){
    }
    // a static method that returns the instance of the queue
    public static Map<Decimal, Plative_UpsertRecordQueueable> getInstance(){
        // lazy load the queue - only initialize if it doesn't already exist
        if(instance == null) instance = new Map<Decimal, Plative_UpsertRecordQueueable>();
        return instance;
    }
}