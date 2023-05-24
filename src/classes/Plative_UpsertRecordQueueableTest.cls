/**
 * Created by Kunal Jain on 13-03-2020.
 */

@isTest
public with sharing class Plative_UpsertRecordQueueableTest {

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
        insert oppty;

        Project__c proj = Plative_TestDataFactory.createProject(oppty,false);
        proj.Customer__c = acc.Id;
        insert proj;

        Product2 product = Plative_TestDataFactory.createProduct(true);

        PricebookEntry pricebookEntry = Plative_TestDataFactory.createPricebookEntry(product, true);

        OpportunityLineItem oli = Plative_TestDataFactory.createOLI(oppty, product, true);
    }

    @IsTest
    static void syncToNSOnOpportunityClosedWon() {

        Opportunity oppty = [Select Id,Billing_Contact__c,AccountId,Trigger_Real_time_Sync__c
                             from Opportunity LIMIT 1];
        oppty.StageName = 'Closed Won';
        oppty.Close_Reason__c = 'Due Diligence';
        oppty.Advisory_Only_Notes__c = 'test';
        oppty.Description = 'test';
        oppty.Repeat_Client__c = 'Yes';
        oppty.Real_Estate_Capital_Markets_Public__c = 'Yes';
        oppty.AP_Email__c = 'test@gs.com';
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Plative_UpsertRecordQueueableMock());
            update oppty;
        Test.stopTest();
    }

    @IsTest
    static void markProjectTest() {

        Opportunity oppty = [Select Id,Synced__c
                             from Opportunity LIMIT 1];
        oppty.Synced__c = 'Yes';
        Test.startTest();
            update oppty;
        Test.stopTest();
    }

    @IsTest
    static void updateCustOnProjectTest() {

        List<Project__c> projList = [Select Id,Sync_to_Netsuite__c,Customer__c
                                from Project__c LIMIT 1];
        Test.startTest();
            Plative_UpdCustOnProjQueueable queue = new Plative_UpdCustOnProjQueueable(projList);
            System.enqueueJob(queue);
        Test.stopTest();
    }
    @IsTest
    static void processProjectSchedulableTest() {

        Project__c proj = [Select Id,Sync_to_Netsuite__c
                             from Project__c LIMIT 1];
        proj.Sync_to_Netsuite__c = true;
        proj.Synced__c = 'Yes';
        update proj;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Plative_UpsertRecordQueueableMock());
            Plative_ProjectSyncSchedulable sch = new Plative_ProjectSyncSchedulable();
            sch.execute(null);
        Test.stopTest();
    }

    @IsTest
    static void upsertOppTest() {
        
        List<JSON_Mapping__mdt> lstJSONMapping = [SELECT Default_Value__c,Field_API_Name__c,
                                                           Group__c,JSON_Node__c,Object_API_Name__c,
                                                           Order__c,Parent_Node__c,Type_of_Node__c,
                                                           Data_type__c,Child_Object_API_Name__c,
                                                           Null_Check_field__c
                                                     FROM JSON_Mapping__mdt
                                                     WHERE Object_API_Name__c = 'Opportunity'];
        string query = Plative_SFToNSSyncUtility.createQueryFromMapping('Opportunity', lstJSONMapping);
        Map<Id, SObject> opptyList = new Map<Id, SObject>(Database.query(query));

        //Check if sync settings exist
        Sync_Settings__mdt syncSetting = Plative_SFToNSSyncUtility.checkSyncSettings(
                                                                    'Opportunity');
        List<SObject> lstChildSobjects;
        // Check if child records are to be sent in payload
        if(syncSetting.Sync_Child_Records__c){
            lstChildSobjects = Plative_SFToNSSyncUtility.getChildRecordsToSync(syncSetting,
                                                                               opptyList.keySet(),
                                                                               'Opportunity'); 
            System.debug('lstChildSobjects '+lstChildSobjects);
        }
        //Get API settings
        List<API_Settings__mdt> apiSettings = [SELECT Account__c, Consumer_Key__c,
                                                      Consumer_Secret__c, Endpoint__c,
                                                      Signature_Method__c, Token_Id__c,
                                                      Token_Secret__c, Version__c
                                               FROM API_Settings__mdt
                                               WHERE DeveloperName = 'Netsuite'];
        
        Map<Decimal, Plative_UpsertRecordQueueable> currentQ = new Map<Decimal, 
                                                               Plative_UpsertRecordQueueable>();
        currentQ.putAll(Plative_SyncQueue.getInstance());
        currentQ.put(syncSetting.Sync_Order__c, 
                                             new Plative_UpsertRecordQueueable(
                                             opptyList.values(),
                                             lstChildSobjects, apiSettings,
                                             syncSetting.Sync_Order__c));
        Plative_SyncQueue.getInstance().clear();
        Plative_SyncQueue.getInstance().putAll(currentQ);

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Plative_UpsertRecordQueueableMock());
            Plative_SFToNSSyncUtility.triggerJobsInQueue();
        Test.stopTest();
    }

    @IsTest
    static void upsertOppExceptionTest() {
        
        Map<Id, Opportunity> opptyList = new Map<Id, Opportunity>([SELECT Id FROM Opportunity]);

        //Check if sync settings exist
        Sync_Settings__mdt syncSetting = Plative_SFToNSSyncUtility.checkSyncSettings(
                                                                    'Opportunity');
        List<SObject> lstChildSobjects;
        // Check if child records are to be sent in payload
        if(syncSetting.Sync_Child_Records__c){
            lstChildSobjects = Plative_SFToNSSyncUtility.getChildRecordsToSync(syncSetting,
                                                                               opptyList.keySet(),
                                                                               'Opportunity'); 
            System.debug('lstChildSobjects '+lstChildSobjects);
        }
        //Get API settings
        List<API_Settings__mdt> apiSettings = [SELECT Account__c, Consumer_Key__c,
                                                      Consumer_Secret__c, Endpoint__c,
                                                      Signature_Method__c, Token_Id__c,
                                                      Token_Secret__c, Version__c
                                               FROM API_Settings__mdt
                                               WHERE DeveloperName = 'Netsuite'];
        
        Map<Decimal, Plative_UpsertRecordQueueable> currentQ = new Map<Decimal, 
                                                               Plative_UpsertRecordQueueable>();
        currentQ.putAll(Plative_SyncQueue.getInstance());
        currentQ.put(syncSetting.Sync_Order__c, 
                                             new Plative_UpsertRecordQueueable(
                                             opptyList.values(),
                                             lstChildSobjects, apiSettings,
                                             syncSetting.Sync_Order__c));
        Plative_SyncQueue.getInstance().clear();
        Plative_SyncQueue.getInstance().putAll(currentQ);

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Plative_UpsertRecordQueueableMock());
            Plative_SFToNSSyncUtility.triggerJobsInQueue();
        Test.stopTest();
    }

    @IsTest
    static void syncUserTest() {

        User newUser = new User();
        newUser.Id = UserInfo.getUserId();
        newUser.Trigger_Real_time_Sync__c = true;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Plative_UpsertRecordQueueableMock());
            update newUser;         
        Test.stopTest();
    }


    @IsTest
    static void accountUpdateTest() {
        Account acc = [Select id,Synced__c from Account limit 1];
        acc.Synced__c = 'Yes';
        update acc;

        acc.Company_Type__c = 'Hedge Fund - Generalist';
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Plative_UpsertRecordQueueableMock());
            update acc;         
        Test.stopTest();
    }

    /**
    @isTest
    public static void testBillingContactChecked(){
        Contact billingContact = [SELECT Id, Billing_Contact__c FROM Contact limit 1];
        billingContact.Billing_Contact__c = true;

        Test.startTest();
        update billingContact;
        billingContact.Billing_Contact__c = false;
        update billingContact;
        Test.stopTest();
    }**/

    @isTest
    public static void testBillingContactUnChecked(){
        Contact billingContact = [SELECT Id, Billing_Contact__c FROM Contact limit 1];
        Test.startTest();
        billingContact.Billing_Contact__c = false;
        update billingContact;
        billingContact.Billing_Contact__c = true;
        update billingContact;
        Test.stopTest();
    }

    @isTest
    public static void testRemoveOCRQueueable(){
        Contact billingContact = [SELECT Id, Billing_Contact__c FROM Contact limit 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        List<OpportunityContactRole> lstOCR = new List<OpportunityContactRole>();
        for(Integer i=0; i< 210; i++){
            OpportunityContactRole ocr = new OpportunityContactRole();
            ocr.Role = 'Billing Contact';
            ocr.OpportunityId = opp.Id;
            ocr.ContactId = billingContact.Id;
            lstOCR.add(ocr);
        }
        System.enqueueJob(new Plative_AddOrDeleteOCRQueueable(lstOCR, false));
        Test.stopTest();
    }
    @isTest
    public static void testgetProductCategoryName(){
        List<String> productName = new List<String>{'US Portfolio Tools;NEWS - ABAlert'};
        List<String> categories = Plative_SFToNSSyncUtility.getProductCategoryName(productName);
        system.assertEquals('Research Only', categories[0]);
    }
}