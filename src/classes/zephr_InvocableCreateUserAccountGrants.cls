/**
 * Created by david on 15/06/2021.
 */

public with sharing class zephr_InvocableCreateUserAccountGrants {
	@InvocableMethod(label='Create User Account Grants for Users' description='Takes a list of Subscription Users and creates Zephr Users and Zephr User Account Grants for the provided Subscription')
	public static void createUserAccountGrants(List<CreateUserAccountGrantsRequest> params) {
		System.debug(LoggingLevel.DEBUG, 'zephr_InvocableCreateUserAccountGrants.createUserAccountGrants');
		CreateUserAccountGrantsRequest request = params[0]; // TODO We should handle multiple requests
		SubscriptionNGHelper.upsertZephrAccountGrants(request.users, request.subscription);
	}

	public class CreateUserAccountGrantsRequest {
		@InvocableVariable(Label = 'List of Contacts' Required = true)
		public List<Subscription_User__c> users;
		@InvocableVariable(Label = 'Subscription' Required = true)
		public Subscription__c subscription;
	}
}