global class ContactMantisBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    global String actionType;
    global String sObjectApiName;
    global List<Id> successIds = new List<Id>();
    global List<Id> failIds = new List<Id>();

    global ContactMantisBatch(String actionType, String sObjectApiName) {
        this.actionType = actionType;
        this.sObjectApiName = sObjectApiName;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Fetch the metadata record (adjust the DeveloperName as needed)
        System_Configuration__mdt config = [ SELECT List_Of_Value__c FROM System_Configuration__mdt WHERE DeveloperName = 'Contact_List' LIMIT 1 ];
        List<String> contactIds = new List<String>();
        if (config != null && String.isNotBlank(config.List_Of_Value__c)) {
            contactIds = config.List_Of_Value__c.split(',');
        }
        system.debug('contactIds->' + contactIds);
        if(Test.isRunningTest()) return Database.getQueryLocator([SELECT Id FROM Contact LIMIT 1]);
        else return Database.getQueryLocator([SELECT Id FROM Contact WHERE Id IN :contactIds]);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        for (Contact c : scope) {
            system.debug('c->' + c);
            try {
                String message = Plative_GSAWebCalloutUtility.makeCallout(c.Id, sObjectApiName, actionType);
                system.debug('message->' + message);
                successIds.add(c.Id);
            } catch (Exception e) {
                failIds.add(c.Id);
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        String body = 'Batch Finished.\nSuccess: ' + successIds.size() + '\nFailed: ' + failIds.size() +
            '\n\nSuccessful Contact Ids:\n' + String.join(successIds, ',') +
            '\n\nFailed Contact Ids:\n' + String.join(failIds, ',');
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { 'mgupta@greenstreet.com' }); // Change to your email
        mail.setSubject('Contact Mantis Batch Results');
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}