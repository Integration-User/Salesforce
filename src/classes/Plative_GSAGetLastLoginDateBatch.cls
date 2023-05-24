global class Plative_GSAGetLastLoginDateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,GSA_ID__c,Last_Login_Date__c,Datalink_Access_New__c FROM Contact where GSA_ID__c != null AND (Contact_Status__c = \'Active\' OR Activate_Contact__c = true)';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        system.debug('scope: ' + scope.size());
        List<Contact> contactUpdateList = new List<Contact>();
        List<Integration_Log__c> logUpdateList = new List<Integration_Log__c>();
        GSA_Platform__c platform = GSA_Platform__c.getOrgDefaults();        
        HTTP http = new HTTP();
        HttpRequest request = new HttpRequest();
        HttpResponse response;
        request.setHeader('x-api-key',platform.API_Key__c);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setMethod('GET');
        for(Contact contact: scope){
            String endpoint = platform.User_Get_Last_Login__c.replace('{!gsaId}',contact.GSA_ID__c);
            try{
                request.setEndpoint(endpoint);
                response = new HttpResponse();
                response = Http.send(request);   
                if ((response.getStatusCode() == 200 || response.getStatusCode() == 201) && String.isNotBlank(response.getBody())) {
                    String responseBody = response.getBody();
                    Map<String, Object> serializedResponseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                    if(serializedResponseMap.containsKey('status') && serializedResponseMap.get('status') == 'success'){
                        if(serializedResponseMap.containsKey('data') && serializedResponseMap.get('data') != null){
                            Map<String, Object> serializedDataMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(serializedResponseMap.get('data')));
                            //Get Last Login Date
                            if(serializedDataMap.containsKey('last_login') && serializedDataMap.get('last_login') != null){
                                DateTime lastLoginDate = DateTime.valueOf((String)serializedDataMap.get('last_login'));
                                contact.Last_Login_Date__c = lastLoginDate;
                            } else {
                                //Log Error
                                GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Get Last Login Date','','', String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false,contact.Id);
                                logUpdateList.add(intLog.logObject);
                            }
                            
                            //Get TOS Sign Off
                            if(serializedDataMap.containsKey('tos_sign_off') && serializedDataMap.get('tos_sign_off') != null){
                                Date tosSignOff = Date.valueOf((String)serializedDataMap.get('tos_sign_off'));
                                contact.TOS_Sign_Off__c = tosSignOff;
                            } else {
                                //Log Error
                                GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Get TOS Sign Off','','', String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false,contact.Id);
                                logUpdateList.add(intLog.logObject);
                            }                            
                        }
                    } else {
                        //Log error
                    GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Get Last Login Date','','', String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false,contact.Id);
                    logUpdateList.add(intLog.logObject);
                    }
                    
                } else {
                    //Log error
                    GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Get Last Login Date','','', String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false,contact.Id);
                    logUpdateList.add(intLog.logObject);
                }
            } catch(Exception ex){
                GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Get Last Login Date','','', String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false,contact.Id);
                logUpdateList.add(intLog.logObject);
            }
            
            if(contact.Datalink_Access_New__c){
                endpoint = platform.User_Get_Contact_Token__c.replace('{!gsaId}',contact.GSA_ID__c);
                try{
                    request.setEndpoint(endpoint);
                    response = new HttpResponse();
                    response = Http.send(request);   
                    system.debug('response.getBody();: ' + response.getBody() );
                    if ((response.getStatusCode() == 200 || response.getStatusCode() == 201) && String.isNotBlank(response.getBody())) {
                        String responseBody = response.getBody();
                        Map<String, Object> serializedResponseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                        if(serializedResponseMap.containsKey('status') && serializedResponseMap.get('status') == 'success'){
                            if(serializedResponseMap.containsKey('data') && serializedResponseMap.get('data') != null){
                                Map<String, Object> serializedDataMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(serializedResponseMap.get('data')));
                                if(serializedDataMap.containsKey('tokens') && serializedDataMap.get('tokens') != null){
                                    Integer tokens = (Integer)serializedDataMap.get('tokens');
                                    contact.Tokens__c = tokens;
                                    system.debug('contact.Tokens__c: ' + contact.Tokens__c);
                                } else {
                                    //Log Error
                                    GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Get Datalink Tokens','','', String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false,contact.Id);
                                    logUpdateList.add(intLog.logObject);
                                }
                            }
                        } else {
                            //Log error
                            GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Get Datalink Tokens','','', String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false,contact.Id);
                            logUpdateList.add(intLog.logObject);
                        }                        
                    } else {
                        //Log error
                        GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Get Datalink Tokens','','', String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false,contact.Id);
                        logUpdateList.add(intLog.logObject);
                    }
                } catch(Exception ex){
                    GSD_IntegrationLog intLog = new GSD_IntegrationLog(endpoint, 'Get Datalink Tokens','','', String.valueOf(response.getStatusCode()), response.getBody(), response.getStatus(), false,contact.Id);
                    logUpdateList.add(intLog.logObject);
                }
            }
            contactUpdateList.add(contact);
            
        }
        
        Database.update(contactUpdateList, false);
        Database.insert(logUpdateList, false);
        
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    
}