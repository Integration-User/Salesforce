@isTest
public class DeleteIntegrationLogsBatchTest {
    @TestSetup
    static void testSetup() {

        Plative_TestDataFactory.createCustomSettings();
        Plative_TestDataFactory.createIntegrationSettings();

        Account acc = Plative_TestDataFactory.createAccount(true);

        Contact cont = Plative_TestDataFactory.createContact(acc, true);

        Id advisoryRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(
                        System.label.Advisory_RT).getRecordTypeId();

        Opportunity oppty = Plative_TestDataFactory.createOpportunity(acc, false);
        oppty.RecordTypeId = advisoryRT;
        oppty.StageName = 'Closed Lost';
        insert oppty;

        Project__c proj = Plative_TestDataFactory.createProject(oppty,false);
        proj.Customer__c = acc.Id;
        insert proj;

        Product2 product = Plative_TestDataFactory.createProduct(true);

        PricebookEntry pricebookEntry = Plative_TestDataFactory.createPricebookEntry(product, true);

        OpportunityLineItem oli = Plative_TestDataFactory.createOLI(oppty, product, true);
        oli.Finance_Effective_Date__c = null;
        update oli;

    }
    @isTest public static void method1() {
        
        Integration_Log__c logObject = new Integration_Log__c();
        logObject.Endpoint__c= '';
        logObject.Job__c= 'TEST';
        logObject.Request_Header__c='';
        logObject.Request_Body__c='';
        logObject.Response_Code__c='200';
        logObject.Response_Body__c='';
        logObject.Error_Message__c='';
        logObject.Success__c =false;
        insert logObject;
        Datetime testingday = Datetime.now().addDays(-35);
        Test.setCreatedDate(logObject.Id, testingday);
        Test.startTest();
        String CRON_EXP = '0 0 23 * * ?';
        DeleteIntegrationLogsBatch s = new DeleteIntegrationLogsBatch();
        System.schedule('Started At1', CRON_EXP, s);
        Test.stopTest();
    }
    @isTest public static void method2() {
        Test.startTest();
        Database.executeBatch(new UpdateFinanceEffectiveDateBatch(), 1000);
        Test.stopTest();
    }

}