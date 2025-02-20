/**
 * Created by josh on 19/07/2023.
 */

public class ZephrUserContactMatcher {
	
	/**
	 * @param zephrUser
	 * @param zephrAccount
	 * @description
	 * @return Id Contact Record Id
	 */
	public static Id createMatchingContact(Zephr_User__c zephrUser, Zephr_Account__c zephrAccount) {
		System.debug(LoggingLevel.DEBUG, 'Checking for existing contact with email ' + zephrUser.Zephr_Email__c + ' and account ' + zephrAccount.Subscription__r.Account__c);
		try {
			// check if contact already exits
			List<Contact> contactRecordList = [SELECT Id FROM Contact WHERE Email =: zephrUser.Zephr_Email__c AND AccountId =: zephrAccount.Subscription__r.Account__c];
			if (contactRecordList != null && !contactRecordList.isEmpty()){
				System.debug(LoggingLevel.DEBUG, 'Found contact id ' + contactRecordList[0].Id);
				return contactRecordList[0].Id;
			}

			// if matching contact does not exist, then create one.
			System.debug(LoggingLevel.DEBUG, 'Inserting new contact');
			contactRecordList.add(
					new Contact(
							FirstName = zephrUser.Zephr_First_Name__c,
							LastName = zephrUser.Zephr_Last_Name__c,
							Email = zephrUser.Zephr_Email__c,
							AccountId = zephrAccount.Subscription__r.Account__c
					)
			);
			insert contactRecordList;
			return contactRecordList[0].Id;
		} catch (Exception ex) {
			System.debug('ZephrUserContactMatcher.createMatchingContact' + ex.getMessage());
		}

		return null;
	}
}