/**
* Description : Queueable class to create/delete OCR records by chaining
*				to work around governor limits
* [21.Mar.2021] Plative - Created
**/
public class Plative_AddOrDeleteOCRQueueable implements Queueable{

	public List<OpportunityContactRole> lstOCRs = new List<OpportunityContactRole>();
	public Boolean doInsert;

	 //Constructor - Accepts set of contacts Ids
	 public Plative_AddOrDeleteOCRQueueable(	List<OpportunityContactRole> lstOCRs
											,	Boolean doInsert){
		this.lstOCRs = lstOCRs;
		this.doInsert = doInsert;
	 }

	 //Overriding execute method from Queueable interface
	 public void execute(QueueableContext context) {	
		
		try{
			if(lstOCRs.size() <= 200){
				performDML(lstOCRs);
			}
			//Process 10K at a time
			else{
				chunkAndProcess();
			}
		}
		catch(Exception e){
			System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
		}
	 }

 	/**
	* Description : Splits the list into smaller list and performs DML. It will invoke
	*				the queueable class to process the remainder
	**/  
	public void chunkAndProcess(){

		List<OpportunityContactRole> lstRecordsToProcess = new List<OpportunityContactRole>();
		List<OpportunityContactRole> lstUnprocessed = new List<OpportunityContactRole>();

		Integer counter = 0;
		for(OpportunityContactRole ocr : lstOCRs){
			if(counter < 200){
				lstRecordsToProcess.add(ocr);
			}
			else{
				lstUnprocessed.add(ocr);
			}
			counter++;
		}

		if(!lstRecordsToProcess.isEmpty()){
			performDML(lstRecordsToProcess);
		}

		if(!lstUnprocessed.isEmpty() && !Test.isRunningTest()){
			System.enqueueJob(new Plative_AddOrDeleteOCRQueueable(lstUnprocessed, doInsert));
		}
	}

 	/**
	* Description : Performs insert or delete operation based on flag set in contructor
	**/ 
	public void performDML(List<OpportunityContactRole> lstRecordsToProcess){		
		if(doInsert){
			insert lstRecordsToProcess;
		}
		else{
			delete lstRecordsToProcess;
		}
	}
}