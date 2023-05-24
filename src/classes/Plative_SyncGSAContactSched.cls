/**
* Company     : Plative
* Description : Schedulable Apex for Plative_SyncGSAContactBatch			
* History     : 
* [21.Jul.2020] Kunal - Code Creation 
*/
public class Plative_SyncGSAContactSched implements Schedulable {
    
    public void execute(SchedulableContext SC) {
        Database.executeBatch(new Plative_SyncGSAContactBatch(),25);
    }
    
}