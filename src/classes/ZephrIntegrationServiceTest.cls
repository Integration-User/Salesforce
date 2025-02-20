@isTest
public with sharing class ZephrIntegrationServiceTest {


    @isTest
    private static void publishErrorEvent() {
        Lead l = new Lead(); // creating lead without mandatory field to cause exception
        Database.SaveResult sr;
        try {
            insert l; // will cause exception
        } catch(Exception e) {
            Test.startTest();
            sr = ZephrIntegrationService.publishErrorEvent(UserInfo.getUserName(), e.getStackTraceString(), e.getMessage(), e.getTypeName());
            Test.stopTest();
        }
        System.assert(true, sr.isSuccess());     
    }

}