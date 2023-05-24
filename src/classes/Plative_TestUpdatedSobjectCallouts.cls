/**
* Company     : Plative
* Description : Test class for Batch class
* [17.Feb.2019] Tejkaran - Code Creation 
*/
@isTest
public class Plative_TestUpdatedSobjectCallouts {
    @isTest static void testUpdateBatch(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.lastName = 'testlastname';
        con.Email = 'test@plative.com';
        con.Preferred_Name__c = 'TP';
        con.dynamic_CheckBox__c = true;
        insert con;
        
    }

}