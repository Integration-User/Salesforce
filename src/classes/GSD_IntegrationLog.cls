/**
 * Company     : GSD Company
 * Description : 
 * ****************************************************************************************
 * Generic log class to create integration log object records.
 * ****************************************************************************************
 * History     : 
 * [05.Aug.2019] Anisa Shaikh - Code Creation 
**/
public class GSD_IntegrationLog  {
	
	public Integration_Log__c logObject;
	public String endPoint{get;set;}
	public String job{get;set;}
	public String reqHeader{get;set;}
	public String reqBody{get;set;}
	public String respCode{get;set;}
	public String respBody{get;set;}
	public String errMsg{get;set;}
	public Boolean success{get;set;}
	public String relatedRecordId{get;set;}
	
	public Integration_Log__c getlogObject(){
		return this.logObject;
	}


	/**
	 * Company     : GSD Company
	 * ****************************************************************************************
	 * Default constructor
	 * ****************************************************************************************
	**/
	public GSD_IntegrationLog(){

	}

	/**
	 * Company     : GSD Company
	 * ****************************************************************************************
	 * Parameterized constructor
	 * ****************************************************************************************
	**/
	public GSD_IntegrationLog(String endPoint, String job, String reqHeader, String reqBody,
							  String respCode, String respBody, String errMsg, boolean success,
							  String relatedRecordId){
		this.logObject = new Integration_Log__c();
		this.logObject.Endpoint__c= endPoint;
		this.logObject.Job__c= job;
		this.logObject.Request_Header__c=reqHeader;
		this.logObject.Request_Body__c=reqBody;
		this.logObject.Response_Code__c=respCode;
		this.logObject.Response_Body__c=respBody;
		this.logObject.Error_Message__c=errMsg;
		this.logObject.Success__c =success;
		this.logObject.Related_Record_Id__c = relatedRecordId;
	}

}