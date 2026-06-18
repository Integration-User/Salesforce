global class Plative_UpdateActivatedUserBatch
implements Database.Batchable<SObject>, Database.AllowsCallouts {

    private Set<Id> contactIds;

    global Plative_UpdateActivatedUserBatch(Set<Id> contactIds) {
        this.contactIds = contactIds;
    }

    // Start method
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([ SELECT Id, Name, AccountId, Account.GSA_ID__c, Account.Account_Status__c, Contact_Status__c, FirstName, LastName,
                   Email, Username__c, GSA_ID__c, Activation_Date__c FROM Contact WHERE Id IN :contactIds AND Account.Account_Status__c = 'Active']);
    }

    // Execute method (runs per batch scope)
    global void execute(Database.BatchableContext bc, List<Contact> scope) {

        if (scope.isEmpty()) return;
        List<Integration_Log__c > integrationLogInsertList = new List<Integration_Log__c>(); 
        // Lock records to avoid conflicts
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Username__c, GSA_ID__c, Contact_Status__c, Activation_Date__c FROM Contact WHERE Id IN :scope];

        GSA_Platform__c platform = GSA_Platform__c.getOrgDefaults();

        Http http = new Http();

        List<Contact> contactsToUpdate = new List<Contact>();
        List<Integration_Log__c> logs = new List<Integration_Log__c>();

        for (Contact cont : contacts) {
            String endpoint = platform.Update_Name__c.replace('{!gsContactID}', cont.GSA_ID__c);
            //String endpoint = 'https://mantis-ext.stg.greenstreet.com/v2/users/' + cont.GSA_ID__c + '/update_name';
            String statusCode = '';
            String responseBody = '';
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('PUT');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            req.setHeader('x-api-key', platform.API_Key__c);
            Map<String, Object> payloadMap = new Map<String, Object>{
                'username' => cont.Username__c,
                    'first_name' => cont.FirstName,
                    'last_name' => cont.LastName
                    };
                        
            String body = JSON.serialize(payloadMap);
            req.setBody(body);
            System.debug('Request: ' + body);
            try {
                HttpResponse res = http.send(req);
                statusCode = String.valueOf(res.getStatusCode());
                responseBody = res.getBody();
                System.debug('Response: ' + res.getBody());

                if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                    Date activationDate = cont.Contact_Status__c != 'Active' ? System.today() : cont.Activation_Date__c;
                    contactsToUpdate.add(new Contact( Id = cont.Id, Contact_Status__c = 'Active', Activation_Date__c = activationDate, Activate_Contact__c=true ));

                } else {
                    logs.add(new Integration_Log__c( Endpoint__c = endpoint, Response_Code__c = String.valueOf(res.getStatusCode()), Response_Body__c = responseBody,
                                                    Request_Body__c = body, Related_Record_Id__c = cont.Id ));
                }

            } catch (Exception e) {
                logs.add(new Integration_Log__c( Endpoint__c = endpoint, Response_Code__c = statusCode, Response_Body__c = responseBody,
                                                Request_Body__c = body, Error_Message__c = e.getMessage(), Related_Record_Id__c = cont.Id ));            
            }
        }

        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }

        if (!logs.isEmpty()) {
            insert logs;
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Batch completed');
    }
}