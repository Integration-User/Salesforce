/**
* Company     : Plative
* Description :  Controller class for Plative_UpdateDownloadsLtng aura component
* History     : 
* [18.May.2020] Kunal - Code Creation 
*/
public class Plative_UpdateDownloadsCtrl {    
    
    @AuraEnabled
    public static Account fetchAccount(Id recordId){
        Account accnt = [Select Id,Account_Status__c from Account where Id = :recordId];
        return accnt;
    }
    
    
    //Method to update token for a contact
    @AuraEnabled
    public static String updateDownload(String accountId, Integer downloadCount){
        //Get Custom setting org defaults for endpoints
        GSA_Platform__c platform = GSA_Platform__c.getOrgDefaults();        
        String responseValue = '';
        String endpoint = platform.Update_Downloads__c;
        JSONGenerator payload = JSON.createGenerator(true);
        Account accnt = [Select Id,GSA_Id__c from Account where Id = :accountId];
        payload.writeStartObject();
        payload.writeFieldName('downloads');
        payload.writeStartObject();      
        payload.writeStringField('gsCompanyID',accnt.GSA_ID__c);
        payload.writeNumberField('numDownloads',downloadCount);
        payload.writeEndObject();
        payload.writeEndObject();
        HttpResponse response = makeCallout(endpoint,payload.getAsString(),platform.API_Key__c);
        if ((response.getStatusCode() == 200 || response.getStatusCode() == 201) && String.isNotBlank(response.getBody())) {
            String responseBody = response.getBody();
            Map<String, Object> serializedResponseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            if (serializedResponseMap.containsKey('status') && String.isNotBlank((String) serializedResponseMap.get('status')) && ((String) serializedResponseMap.get('status') == 'success')) {
                String responseCheck = checkUpdateTokenResponse(responseBody,'numDownloads');
                if(String.isNotBlank(responseCheck) && responseCheck == String.valueOf(downloadCount)){
                    responseValue = 'Success!';
                } else {
                    responseValue = 'Unknown Error!';
                    //Log Error
                    GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Salesforce to GSA Update Downloads','', payload.getAsString(), String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false, '');
                    insert intLog.logObject;
                }
            } else {
                //Log error and return error
                responseValue = 'Unknown Error!';
                GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Salesforce to GSA Update Downloads','', payload.getAsString(), String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false,'');
                insert intLog.logObject;
            }
        } else {
            //Log Error and return error
            GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Salesforce to GSA Update Downloads','', payload.getAsString(), String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false,'');
            insert intLog.logObject;
        }
        return responseValue;
    }
    
    
    //Checks if the token has been updated successfully
    public static String checkUpdateTokenResponse(String responseBody, String mainKey){
        String response = '';
        Map<String, Object> serializedResponseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if(serializedResponseMap.containsKey('data') && serializedResponseMap.get('data') != null){
            Map<String,Object> serializedDataMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(serializedResponseMap.get('data')));
            if(serializedDataMap.containsKey(mainKey) && serializedDataMap.get(mainKey) != null){
                response = String.valueOf(serializedDataMap.get(mainKey));
            }
        }
        return response;
    }
    
    
    //Common method to make callouts for token manipulation
    private static HttpResponse makeCallout(String endpoint,String body, String apiKey){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        request.setHeader('x-api-key', apiKey);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        if(body != null){ 
            request.setBody(body); 
        }
        
        response = Http.send(request);        
        return response;
    }
    
    
    
}