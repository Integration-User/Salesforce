/**
 *
 *
 *
* @author Zoran Zunko
* @date 6/4/21
*
*/

public with sharing class zephr_InvocableCreateCompany {
    @InvocableMethod public static List<ZephrApiRequestsResponses.Company> createZephrCompany(List<ZephrApiRequestsResponses.CreateCompanyRequest> companyRequests) {
        List<ZephrApiRequestsResponses.Company> response = new List<ZephrApiRequestsResponses.Company>();

        try {
            Map<String, ZephrIntegrationNG> zephrIntegrationsByTenantMap = new Map<String, ZephrIntegrationNG>();


            for (ZephrApiRequestsResponses.CreateCompanyRequest companyRequest : companyRequests) {
                ZephrApiRequestsResponses.Company companyResponse = new ZephrApiRequestsResponses.Company();
                companyResponse.message = 'ERROR';
                companyResponse.name = companyRequest.name;
                companyResponse.website = companyRequest.website;
                companyResponse.salesforceId = companyRequest.salesforceId;
                companyResponse.success = false;

                if(!zephrIntegrationsByTenantMap.containsKey(companyRequest.tenant)) {
                    zephrIntegrationsByTenantMap.put(companyRequest.tenant, new ZephrIntegrationNG(companyRequest.tenant));
                }

                ZephrIntegrationNG zephr = zephrIntegrationsByTenantMap.get(companyRequest.tenant);

                try {
                    HttpResponse res = zephr.createCompany(companyRequest.name, companyRequest.website == null ? '' : companyRequest.website );
                    System.debug(LoggingLevel.FINE, 'createZephrCompany - res.getBody(): ' + res.getBody());
                    System.debug(LoggingLevel.FINE, 'createZephrCompany - res.getBody(): ' + res.getStatusCode());
                    if (res.getStatusCode() == 201) {
                        companyResponse = (ZephrApiRequestsResponses.Company) JSON.deserialize(res.getBody(), ZephrApiRequestsResponses.Company.class);
                        companyResponse.success = true;
                        companyResponse.salesforceId = companyRequest.salesforceId;

                    } else {
                        companyResponse.message = res.getBody();
                    }
                } catch (Exception ex) {
                    System.debug(LoggingLevel.ERROR, ex.getMessage() + ' - ' + ex.getStackTraceString());
                    companyResponse.message = ex.getMessage() + ' - ' + ex.getStackTraceString();
                    //todo: ZephrIntegrationService.publishErrorEvent(UserInfo.getUserName(), ex.getStackTraceString(), ex.getMessage(), 'zephr_InvocableCreateCompany - api integration error');
                }
                response.add(companyResponse);
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + ' - ' + ex.getStackTraceString());
//            ZephrIntegrationService.publishErrorEvent(UserInfo.getUserName(), ex.getStackTraceString(), ex.getMessage(), 'zephr_InvocableCreateCompany - non network error');
        }
        return response;
    }
}