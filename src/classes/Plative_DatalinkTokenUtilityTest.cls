/**
* Company     : Plative
* Description :  Test class for Plative_DatalinkTokenUtility
* History     : 
* [14.May.2020] Kunal - Code Creation 
*/

@isTest
public class Plative_DatalinkTokenUtilityTest {
    
    @testSetup
    static void testSetup(){
        
        Account accnt = new Account();
        accnt.Name = 'Test Accnt';
        accnt.Secondary_Name__c = 'Test Accnt Secondary';
        accnt.Phone = '123123123';
        accnt.Website = 'www.google.com';
        accnt.BillingCity = 'New York';
        accnt.BillingCountry = 'United States';
        accnt.BillingPostalCode = '4123123';
        accnt.BillingState = 'New York';
        accnt.BillingStreet = 'Madison Avenue';
        accnt.Account_Status__c = 'Active';
        insert accnt;
        
        Contact cont = new Contact();
        cont.AccountId = accnt.Id;
        cont.FirstName = 'FName';
        cont.LastName = 'LName';
        cont.Email = 'test@email.com';
        cont.Phone = '123123123';
        cont.Contact_Status__c = 'Active';
        insert cont;
        
    }
    
    
    @isTest
    static void fetchContactTest(){
       	Id contactId = [Select Id from Contact LIMIT 1].Id;
        Test.startTest();
        Plative_DatalinkTokenUtility.fetchContact(contactId);
        Test.stopTest();
    }
    
    @isTest
    static void updateTokenTest(){
        Test.setMock(HttpCalloutMock.class, new Plative_DatalinkTokenMock());  
        Id contactId = [Select Id from Contact LIMIT 1].Id;
        Test.startTest();
        String response = Plative_DatalinkTokenUtility.updateToken(contactId,10);
        system.assertEquals('Success!', response);
        Test.stopTest();
    }
    
    @isTest
    static void updateTokenExceptionTest(){
        Test.setMock(HttpCalloutMock.class, new Plative_DatalinkTokenMock());  
        Id contactId = [Select Id from Contact LIMIT 1].Id;
        Test.startTest();
        String response = Plative_DatalinkTokenUtility.updateToken(contactId,50);
        system.assertEquals('Unknown Error!', response);
        Test.stopTest();
    }
    
    
    @isTest
    static void clearTokenTest(){
        Test.setMock(HttpCalloutMock.class, new Plative_DatalinkTokenMock());  
        Id contactId = [Select Id from Contact LIMIT 1].Id;
        Test.startTest();
        String response = Plative_DatalinkTokenUtility.clearToken(contactId);
        system.assertEquals('Success!', response);
        Test.stopTest();
    }
    
}