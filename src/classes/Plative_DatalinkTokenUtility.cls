/**
* Company     : Plative
* Description :  Controller class for Plative_ClearTokenLtng & Plative_UpdateTokenLtng
* History     : 
* [6.May.2020] Kunal - Code Creation 
*/

public without sharing class Plative_DatalinkTokenUtility {
    
    @AuraEnabled 
    public static contact fetchContact(String contactId){
        Contact contact = [Select Id,Website_Access_New__c,Datalink_Access_New__c,Contact_Status__c from Contact where Id = :contactId];
        return contact; 
    }
    
    //Method to update token for a contact
    @AuraEnabled
    public static String updateToken(String contactId, Integer maxTokens){
        String responseValue = '';
        String gsContactID = [Select Id,GSA_ID__c from Contact where Id = :contactId].GSA_ID__c;
        //String endpoint = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/users/datalink/' + gsContactID +'/update_max_tokens';
        String endpoint = GSA_Platform__c.getInstance().Update_Token__c + gsContactID + '/update_max_tokens';
        JSONGenerator payload = JSON.createGenerator(true);
        payload.writeStartObject();
        payload.writeNumberField('max_tokens',maxTokens);
        payload.writeEndObject();
        HttpResponse response = makeCallout(endpoint,payload.getAsString());
        system.debug('response status code: ' + response.getStatusCode());
        system.debug('response body: ' + response.getBody());
        if ((response.getStatusCode() == 200 || response.getStatusCode() == 201) && String.isNotBlank(response.getBody())) {
            String responseBody = response.getBody();
            Map<String, Object> serializedResponseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            if (serializedResponseMap.containsKey('status') && String.isNotBlank((String) serializedResponseMap.get('status')) && ((String) serializedResponseMap.get('status') == 'success')) {
                String responseCheck = checkUpdateTokenResponse(responseBody,'max_tokens');
                if(String.isNotBlank(responseCheck) && responseCheck == String.valueOf(maxTokens)){
                    responseValue = 'Success!';
                } else {
                    responseValue = 'Unknown Error!';
                    //Log Error
                    GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Salesforce to GSA Update Token','', payload.getAsString(), String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false,gsContactID);
                    insert intLog.logObject;
                }
            } else {
                //Log error and return error
                responseValue = 'Unknown Error!';
                GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Salesforce to GSA Update Token','', payload.getAsString(), String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false,gsContactID);
                insert intLog.logObject;
            }
        } else {
            //Log Error and return error
            GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Salesforce to GSA Update Token','', payload.getAsString(), String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false, gsContactID);
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
    
    
    //Method to clear tokens for a contact
    @AuraEnabled
    public static String clearToken(String contactId){
        String responseValue = '';
        String gsContactID = [Select Id,GSA_ID__c from Contact where Id = :contactId].GSA_ID__c;
        //String endpoint = 'http://gsa-website-salesforce-api-stg.us-west-2.elasticbeanstalk.com/v1/users/datalink/' + gsContactID + '/clear_tokens';
        String endpoint = GSA_Platform__c.getInstance().Clear_Token__c + gsContactID + '/clear_tokens';
        HttpResponse response = makeCallout(endpoint,null);
        system.debug('response status code: ' + response.getStatusCode());
        system.debug('response body: ' + response.getBody());
        if ((response.getStatusCode() == 200 || response.getStatusCode() == 201) && String.isNotBlank(response.getBody())) {
            String responseBody = response.getBody();
            Map<String, Object> serializedResponseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            if (serializedResponseMap.containsKey('status') && String.isNotBlank((String) serializedResponseMap.get('status')) && ((String) serializedResponseMap.get('status') == 'success')) {
                String responseCheck = checkUpdateTokenResponse(responseBody,'tokens_cleared');
                if(responseCheck == 'true'){
                    responseValue = 'Success!';
                } else {
                    responseValue = 'Unknown Error!';
                    //Log Error
                    GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Salesforce to GSA Clear Token','', '', String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false, gsContactID);
                    insert intLog.logObject;
                }
            } else {
                //Log error and return error
                responseValue = 'Unknown Error!';
                GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Salesforce to GSA Clear Token','', '', String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false, gsContactID);
                insert intLog.logObject;
            }
        } else {
            //Log Error and return error
            responseValue = 'Unknown Error!';
            GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Salesforce to GSA Clear Token','','', String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false, gsContactID);
            insert intLog.logObject;
        }
        return responseValue;
    }
    
    //Common method to make callouts for token manipulation
    private static HttpResponse makeCallout(String endpoint,String body){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        request.setHeader('x-api-key', 'SAL3sf0rc3_AP1');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setEndpoint(endpoint);
        request.setMethod('PUT');
        if(body != null){ 
            request.setBody(body); 
        }
        
        response = Http.send(request);        
        return response;
    }
    
}