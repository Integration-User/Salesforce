/**
 * Created by david on 23/06/2021.
 */

public with sharing class zephr_InvocableDeleteAccountUser {
	@InvocableMethod(Description='Delete a Zephr Account User') public static List<ZephrApiRequestsResponses.AccountUserGrant> deleteAccountUser(List<ZephrApiRequestsResponses.AccountUserGrant> userAccountGrantRequests) {
		List<ZephrApiRequestsResponses.AccountUserGrant> response = new List<ZephrApiRequestsResponses.AccountUserGrant>();

		try {
			Map<String, ZephrIntegrationNG> zephrIntegrationsByTenantMap = new Map<String, ZephrIntegrationNG>();

			for (ZephrApiRequestsResponses.AccountUserGrant accountUserGrantRequest : userAccountGrantRequests) {
				ZephrApiRequestsResponses.AccountUserGrant accountUserGrantResponse = new ZephrApiRequestsResponses.AccountUserGrant();
				accountUserGrantResponse.message = 'ERROR';
				accountUserGrantResponse.success = false;
				accountUserGrantResponse.salesforceId = accountUserGrantRequest.salesforceId;

				if(!zephrIntegrationsByTenantMap.containsKey(accountUserGrantRequest.tenantId)) {
					zephrIntegrationsByTenantMap.put(accountUserGrantRequest.tenantId, new ZephrIntegrationNG(accountUserGrantRequest.tenantId));
				}

				ZephrIntegrationNG zephr = zephrIntegrationsByTenantMap.get(accountUserGrantRequest.tenantId);

				try {
					HttpResponse res = zephr.accountUser(accountUserGrantRequest.account_id, accountUserGrantRequest.user_id, 'DELETE');
					if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                        accountUserGrantResponse = (ZephrApiRequestsResponses.AccountUserGrant) JSON.deserialize(res.getBody(), ZephrApiRequestsResponses.AccountUserGrant.class);
                        accountUserGrantResponse.salesforceId = accountUserGrantRequest.salesforceId;
                        accountUserGrantResponse.success = true;
                    }
					else if (res.getStatusCode() != 500) {
						accountUserGrantResponse.success = true;

					} else {
						accountUserGrantResponse.message = res.getBody();
					}
				} catch (Exception ex) {
					System.debug(LoggingLevel.ERROR, ex.getMessage() + ' - ' + ex.getStackTraceString());
					accountUserGrantResponse.message = ex.getMessage() + ' - ' + ex.getStackTraceString();
					//todo: ZephrIntegrationService.publishErrorEvent(UserInfo.getUserName(), ex.getStackTraceString(), ex.getMessage(), 'zephr_InvocableCreateAccount - api integration error');
				}
				response.add(accountUserGrantResponse);
			}
		} catch (Exception ex) {
			System.debug(LoggingLevel.ERROR, ex.getMessage() + ' - ' + ex.getStackTraceString());
			ZephrIntegrationService.publishErrorEvent(UserInfo.getUserName(), ex.getStackTraceString(), ex.getMessage(), 'zephr_InvocableDeleteAccountUser - non network error');
		}
		return response;
	}
}