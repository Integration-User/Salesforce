/**
* Company     : Plative
* Description : Schedulable Apex for Plative_SyncGSAWebsiteSubscriptionBatch			
* History     : 
* [21.Jul.2020] Kunal - Code Creation 
*/
public class Plative_SyncGSAWebsiteSubscriptionSched implements Schedulable {
    
    public void execute(SchedulableContext SC) {
        Database.executeBatch(new Plative_SyncGSAWebsiteSubscriptionBatch(),50);
    }
    
}