/**
 * @description       : test class for DDS Calculation Handler Test
 * @author            : Raúl Iglesias
 * @group             : 
 * @last modified on  : 02-01-2023
 * @last modified by  : Raúl Iglesias
**/
@isTest
public with sharing class DDSScoreCalculationHandlerTest {

    private static final Id RENEWAL_RT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();

    @TestSetup
    static void testPrepareData() {

        Account acc = Plative_TestDataFactory.createAccount(false);
        acc.Priority__c = 'Core';
        acc.Company_Type__c = 'Bank - Investment';
        acc.User_Count__c = 20;
        acc.Analyst_Hours__c = 20;
        acc.DDS_CREAUM__c = 100000;	
        acc.Became_Client__c = System.Today().addYears(-1);
        insert acc;

        Contact cont = Plative_TestDataFactory.createContact(acc, true);

        Id salesRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(
                        'Sales Opportunity').getRecordTypeId();

        Opportunity oppty = Plative_TestDataFactory.createOpportunity(acc, false);
        oppty.RecordTypeId = salesRT;
        oppty.Sales_Type__c = 'New';
        oppty.Contract_Start_Date__c = System.today();
        oppty.Contract_End_Date__c = System.today().addYears(1);
        insert oppty;

        Product2 product1 = Plative_TestDataFactory.createProduct(false);
        product1.ProductCode = 'DDS1';

        Product2 product2 = Plative_TestDataFactory.createProduct(false);
        product2.ProductCode = 'DDS5';

        insert new List<Product2>{product1, product2};
        
        PricebookEntry pricebookEntry1 = Plative_TestDataFactory.createPricebookEntry(product1, true);
        PricebookEntry pricebookEntry2 = Plative_TestDataFactory.createPricebookEntry(product2, true);

        OpportunityLineItem oli1 = Plative_TestDataFactory.createOLI(oppty, product1, false);
        oli1.Starting_Price__c = 10000;
        oli1.Delivery_Method__c = 'Snowflake';
        insert oli1;
        OpportunityLineItem oli2 = Plative_TestDataFactory.createOLI(oppty, product2, false);
        oli2.Starting_Price__c = 10000;
        oli2.Delivery_Method__c = 'Snowflake';
        insert oli2;
    }

    @isTest    
    static void testNewModelSalesforceData(){

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
            DDSScoreCalculationHandler ddsScore = new DDSScoreCalculationHandler(opp.Id);                               
            ddsScore.isTest = true;
            ddsScore.calculateDDSScore(); 
        Test.stopTest();
        
        opp = [SELECT Id, DDS_ScoreDebug__c, DDS_ScoreInsight__c, DDS_ScoreAssignment__c, DDS_ScoreARRResidual__c FROM Opportunity LIMIT 1]; 
        
        System.assertEquals('D', opp.DDS_ScoreAssignment__c , 'Opportunity Score is incorrect.');
        System.assertEquals(1699.96 , opp.DDS_ScoreARRResidual__c , 'Opportunity Score ARR Residual is incorrect.');
        System.assertEquals(false ,String.isBlank(opp.DDS_ScoreInsight__c) , 'Opportunity DDS_ScoreInsight__c not completed.');
        System.assertEquals(false ,String.isBlank(opp.DDS_ScoreDebug__c) , 'Opportunity DDS_ScoreDebug__c not completed.' + opp.DDS_ScoreDebug__c);

    }

    @isTest    
    static void testRenewalWithAUMSalesforceData(){

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        opp.Sales_Type__c = 'Renewal';
        opp.RecordTypeId = RENEWAL_RT;
        update opp;

        Test.startTest();
            DDSScoreCalculationHandler ddsScore = new DDSScoreCalculationHandler(opp.Id);                               
            ddsScore.isTest = true;
            ddsScore.calculateDDSScore(); 
        Test.stopTest();
        
        opp = [SELECT Id, DDS_ScoreDebug__c, DDS_ScoreInsight__c, DDS_ScoreAssignment__c, DDS_ScoreARRResidual__c FROM Opportunity LIMIT 1]; 
        
        System.assertEquals('A', opp.DDS_ScoreAssignment__c , 'Opportunity Score is incorrect.');
        System.assertEquals( 0 , opp.DDS_ScoreARRResidual__c , 'Opportunity Score ARR Residual is incorrect.');
        System.assertEquals(false ,String.isBlank(opp.DDS_ScoreInsight__c) , 'Opportunity DDS_ScoreInsight__c not completed.');
        System.assertEquals(false ,String.isBlank(opp.DDS_ScoreDebug__c) , 'Opportunity DDS_ScoreDebug__c not completed.');

    }

    @isTest    
    static void testRenewalWithoutAUMModelWithSalesforceData(){

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        opp.Sales_Type__c = 'Renewal';
        opp.RecordTypeId = RENEWAL_RT;
        update opp;

        Account acc = [SELECT Id FROM Account LIMIT 1];
        acc.DDS_CREAUM__c = null;	
        update acc;

        Test.startTest();
            DDSScoreCalculationHandler ddsScore = new DDSScoreCalculationHandler(opp.Id);                               
            ddsScore.isTest = true;
            ddsScore.calculateDDSScore(); 
        Test.stopTest();
        
        opp = [SELECT Id, DDS_ScoreDebug__c, DDS_ScoreInsight__c, DDS_ScoreAssignment__c, DDS_ScoreARRResidual__c FROM Opportunity LIMIT 1]; 
        
        System.assertEquals('F', opp.DDS_ScoreAssignment__c , 'Opportunity Score is incorrect.');
        System.assertEquals(37135029.04 , opp.DDS_ScoreARRResidual__c , 'Opportunity Score ARR Residual is incorrect.');
        System.assertEquals(false ,String.isBlank(opp.DDS_ScoreInsight__c) , 'Opportunity DDS_ScoreInsight__c not completed.');
        System.assertEquals(false ,String.isBlank(opp.DDS_ScoreDebug__c) , 'Opportunity DDS_ScoreDebug__c not completed.');
    }


    @isTest    
    static void testNewModelWithoutSalesforceData(){

        Test.startTest();
            DDSScoreCalculationHandler ddsScore = new DDSScoreCalculationHandler(
                'US_Reit',//SKU
                'New',//Sales Type
                '120',//AUM (USD)
                '30',//User Count
                'PERE_Companies',//Segment
                'Core',//Account Priority
                '2',//Customer Tenure
                '200',//Analyst Hours
                '12627',//Customer Total ARR TBD
                9,//YoY percent
                '1'//Contract Length
            );
            ddsScore.calculateDDSScore(); 
        Test.stopTest();
                
        System.assertEquals('D', ddsScore.resultWrapper.letterGrade , 'Opportunity Score is incorrect.');
        //System.assertEquals( 66.18, ddsScore.resultWrapper.absoluteARR , 'Opportunity Score ARR Residual is incorrect.');
    }

    @isTest    
    static void testErrorInput(){

        Test.startTest();
            DDSScoreCalculationHandler ddsScore = new DDSScoreCalculationHandler(
                'US_Reit',//SKU
                'Renewal',//Sales Type
                '120',//AUM (USD)
                '30',//User Count
                'PERE_Companies',//Segment
                 null,//Account Priority
                '2',//Customer Tenure
                '200',//Analyst Hours
                '12627',//Customer Total ARR TBD
                9,//YoY percent
                '1'//Contract Length
            );
            ddsScore.calculateDDSScore(); 
        Test.stopTest();
                
        System.assertEquals('ErrorInput', ddsScore.resultWrapper.letterGrade , 'Opportunity Score is incorrect.');
        System.assertEquals( null , ddsScore.resultWrapper.absoluteARR , 'Opportunity Score ARR Residual is incorrect.');
    }

    @isTest    
    static void testErrorAdmin(){

        Test.startTest();
            DDSScoreCalculationHandler ddsScore = new DDSScoreCalculationHandler(
                'US_Reit',//SKU
                'Renewal',//Sales Type
                '120',//AUM (USD)
                null,//User Count
                'PERE_Companies',//Segment
                'Core',//Account Priority
                '2',//Customer Tenure
                '200',//Analyst Hours
                '12627',//Customer Total ARR TBD
                9,//YoY percent
                '1'//Contract Length//Renewal Year
            );
            ddsScore.calculateDDSScore(); 
        Test.stopTest();
                
        System.assertEquals('ErrorAdmin', ddsScore.resultWrapper.letterGrade , 'Opportunity Score is incorrect.');
        System.assertEquals( null , ddsScore.resultWrapper.absoluteARR , 'Opportunity Score ARR Residual is incorrect.');
    }

    @isTest    
    static void testErrorInpuNoProducts(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        delete [SELECT Id FROM OpportunityLineItem];

        Test.startTest();
            DDSScoreCalculationHandler ddsScore = new DDSScoreCalculationHandler(opp.Id);                               
            ddsScore.isTest = true;
            ddsScore.calculateDDSScore();  
        Test.stopTest();
                
        System.assertEquals('ErrorInput', ddsScore.resultWrapper.letterGrade , 'Opportunity Score is incorrect.');
        System.assertEquals( null , ddsScore.resultWrapper.absoluteARR , 'Opportunity Score ARR Residual is incorrect.');
    }

    @isTest    
    static void testController(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        delete [SELECT Id FROM OpportunityLineItem];

        Test.startTest();
            DDSScoreCalculationController.getDDSScoreResult(opp.Id);
        Test.stopTest();
        
        opp = [SELECT Id, DDS_ScoreDebug__c, DDS_ScoreInsight__c, DDS_ScoreAssignment__c, DDS_ScoreARRResidual__c FROM Opportunity LIMIT 1]; 

        System.assertEquals(false ,String.isBlank(opp.DDS_ScoreInsight__c) , 'Opportunity DDS_ScoreInsight__c not completed.');
        System.assertEquals(false ,String.isBlank(opp.DDS_ScoreDebug__c) , 'Opportunity DDS_ScoreDebug__c not completed.');
    }
}
