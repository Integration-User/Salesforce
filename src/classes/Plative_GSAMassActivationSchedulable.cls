/**
* Company     : Plative
* Description : Schedulable class for Plative_GSAMassActivationBatch
* History     : 
* [31.Aug.2020] Kunal - Code Creation 
*/

public class Plative_GSAMassActivationSchedulable implements Schedulable {
    String sObjectApiName;
    public Plative_GSAMassActivationSchedulable(String sObjectApiName){
        this.sObjectApiName = sObjectApiName;
    }
    
    public void execute(SchedulableContext sc) {
        Plative_GSAMassActivationBatch batchable = new Plative_GSAMassActivationBatch(sObjectApiName);
        Database.executeBatch(batchable,50);        
    }
}