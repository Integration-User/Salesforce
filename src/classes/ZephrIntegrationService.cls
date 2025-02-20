public without sharing class ZephrIntegrationService {

    public static Database.SaveResult publishErrorEvent(String currentUser, String stackTrace, String message, String origin) {
        ZephrIntegrationError__e err = new ZephrIntegrationError__e(
            CurrentUser__c = currentUser,
            StackTrace__c = stackTrace,
            Message__c = message,
            ErrorOrigin__c = origin
        );
        Database.SaveResult sr = EventBus.publish(err);
        return sr;
    }

}