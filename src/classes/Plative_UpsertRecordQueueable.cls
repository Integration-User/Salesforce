/**
* Company     : Plative
* Description : Queueable class to upsert records in Netsuite
* History     :
* [05.Mar.2020] Anisa Shaikh - Code Creation
*/
public class Plative_UpsertRecordQueueable implements Queueable, Database.AllowsCallouts {

    public List<Sobject> lstSobjects;
	public List<SObject> lstChildRecords;
	public List<API_Settings__mdt> apiSettings;
	public Decimal currentSequence;
	public Map<Decimal, Plative_UpsertRecordQueueable> queue;

    public Plative_UpsertRecordQueueable(List<Sobject> lstSobjects, 
										 List<SObject> lstChildRecords,	
										 List<API_Settings__mdt> apiSettings,
										 Decimal currentSequence) {
        this.lstSobjects = lstSobjects;
		this.lstChildRecords = lstChildRecords;
		this.apiSettings = apiSettings;
		this.currentSequence=currentSequence;
    }

	public void updateQueue(Map<Decimal, Plative_UpsertRecordQueueable> queue){	
		this.queue = queue;
	}

    public void execute(QueueableContext context) {
		
		System.debug('lstSobjects '+lstSobjects);
		System.debug('apiSettings '+apiSettings);
		System.debug('lstChildRecords '+lstChildRecords);
		System.debug('QUEUE BEFORE PROCESSING'+queue);


 		List<SObject> lstUnprocessedSobjects = Plative_SFToNSSyncUtility.upsertRecord(
											   lstSobjects, lstChildRecords,apiSettings, 
											   'Trigger_Real_time_Sync__c');
        //Process the unprocessed records
        if (lstUnprocessedSobjects != null && !lstUnprocessedSobjects.isEmpty() && !Test.isRunningTest()) {
			System.debug('UNPROCESSED ');
            System.enqueueJob(new Plative_UpsertRecordQueueable(lstUnprocessedSobjects,
                                                                lstChildRecords,apiSettings,currentSequence));
        }
		else{
			System.debug('QUEUE BEFORE REMOVING '+queue);
			//All records processed for current job, remove job from queue
			queue.remove(currentSequence);
			System.debug('QUEUE AFTER REMOVING '+queue);
		}
		//Enqueue next job in queue
		if(!queue.isEmpty()){
			for(Decimal seqNo: queue.keySet()){
				queue.get(seqNo).updateQueue(queue);
				if(!Test.isRunningTest()){
					System.enqueueJob(queue.get(seqNo));	
				}	
				break;		
			}	
		}
    }
}