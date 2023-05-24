/**
 * Company     : GSD Company
 * History     : 
 * [05.Aug.2019] Anisa Shaikh - Code Creation 
**/
trigger GSD_IntegrationLog on Integration_Log__c (after insert)  { 
	
	/**
	//Get custom setting information 
	List<Alert__mdt> lstAlertMdt;
	try{
		lstAlertMdt = [SELECT Alert__c, Email__c, Job__c from Alert__mdt];
	}
	catch(Exception e){
		System.debug('EXCEPTION'+e.getMessage()+e.getStackTraceString());
	}
	Map<String, List<Integration_Log__c>> mapEmailToLogRecord = new Map<String, 
																List<Integration_Log__c>>();
	Map<Id, Set<String>> mapLogRecordToEmail = new Map<Id, Set<String>>();
	if(lstAlertMdt != null &&  !lstAlertMdt.isEmpty()){
		Set<String> setEmails;
		for(Integration_Log__c logObject: Trigger.newMap.values()){
			for(Alert__mdt metadata: lstAlertMdt){
				setEmails = new Set<String>();
				//If Email populated, check if more than 1 to split
				if(metadata.Email__c != null && metadata.Email__c != ''){
					setEmails.addAll(metadata.Email__c.split(','));
					System.debug('EMAILS'+setEmails);
					mapLogRecordToEmail.put(logObject.Id, setEmails);
				}
				//Iterate over set of Emails
				for(String email : setEmails){
					if(metadata.Job__c == logObject.Job__c && 
						mapEmailToLogRecord.containsKey(email)){
						mapEmailToLogRecord.get(email).add(logObject);
					}
					else if(metadata.Job__c == logObject.Job__c && 
						!mapEmailToLogRecord.containsKey(email)) {
						mapEmailToLogRecord.put(email, new Integration_Log__c[]{logObject});
					}
				}
			}
		}
	}
	Map<String, User> mapEmailToUsers = new Map<String, User>();
	try{
		//Check if any active user exists for the mails, if yes then use different email method
		Map<Id, User> mapUsers = new Map<Id, User>([SELECT Id, Email FROM User 
												   WHERE Email IN :mapEmailToLogRecord.keySet()]);
		System.debug('mapUsers'+mapUsers);
		if(mapEmailToUsers != null && !mapEmailToUsers.isEmpty()){
			for(Id userId :  mapUsers.keySet()){
				mapEmailToUsers.put(mapUsers.get(userId).Email,mapUsers.get(userId));
			}
		}
	}
	catch(Exception e){
		System.debug('EXCEPTION'+e.getMessage()+e.getStackTraceString());
	}	
	//Get Email template name
	List<Log_Setting__mdt> logSettings;
	String templateId='';
	try{
		logSettings = [SELECT Log_Template_Id__c FROM  Log_Setting__mdt];
	}
	catch(Exception e){
		System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
	}
	if(logSettings != null && !logSettings.isEmpty()){
		templateId = logSettings[0].Log_Template_Id__c;
	}
	String subject = UserInfo.getOrganizationId()+' '+UserInfo.getOrganizationName();
	// Strings to hold the email addresses to which you are sending the email.
	String[] toAddresses; 
	//Iterate over all the records and send email to users notifying them of the error
	Messaging.SingleEmailMessage mail;
	Set<Messaging.Email> emails = new Set<Messaging.Email>();
	Integer counter=0;
	Integer mapIndex=0;
	Messaging.SendEmailResult[] results;
	try{
		for(Id recId : mapLogRecordToEmail.keySet()){
			mail = new Messaging.SingleEmailMessage();
			toAddresses = new String[]{};
			toAddresses.addAll(mapLogRecordToEmail.get(recId)); 
			mail.setToAddresses(toAddresses);
			mail.setSubject(subject);
			mail.setPlainTextBody('ERROR:\n'+Trigger.newMap.get(recId).Error_Message__c);
			emails.add(mail);
			counter++;
			mapIndex++;
			if(counter == 10 || mapIndex == mapLogRecordToEmail.size()){
				results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
				counter = 0;
			}		
		}	
	}
	catch(Exception e){
		System.debug('EXCEPTION'+e.getMessage()+e.getStackTraceString());
	}**/
}