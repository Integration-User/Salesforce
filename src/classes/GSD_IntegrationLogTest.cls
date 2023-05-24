/**
 * Company     : GSD Company
 * Description : 
 * ****************************************************************************************
 * Test class for Integration log classes
 * ****************************************************************************************
 * History     : 
 * [13.Aug.2019] Anisa Shaikh - Code Creation 
*/
@isTest
private class GSD_IntegrationLogTest {

	static testMethod void testWrapperClass() {
		try{	
			test.startTest();

				GSD_IntegrationLog log1 = new GSD_IntegrationLog();		
				log1.endpoint = '';
				log1.job= '';
				log1.reqHeader = '';
				log1.reqBody = '';
				log1.respCode = '';
				log1.respBody = '';
				log1.errMsg = '';
				log1.success= false;
				GSD_IntegrationLog log2 = new GSD_IntegrationLog('', '', '', '', '', '', '', false,'');		
			test.stopTest();
		}
		catch(Exception e){
			System.debug('EXCEPTION: '+e.getMessage()+e.getStackTraceString());
		}
	}

	static testMethod void testTrigger() {
		try{			
			Integration_Log__c logObject = new Integration_Log__c();
			logObject.Endpoint__c= '';
			logObject.Job__c= 'TEST';
			logObject.Request_Header__c='';
			logObject.Request_Body__c='';
			logObject.Response_Code__c='';
			logObject.Response_Body__c='';
			logObject.Error_Message__c='';
			logObject.Success__c =false;
			Test.startTest();
				insert logObject;
			Test.stopTest();
		}
		catch(Exception e){
			System.debug('EXCEPTION: '+e.getMessage()+e.getStackTraceString());
		}
	}
}