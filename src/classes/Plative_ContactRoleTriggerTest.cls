/**
* Company     : Plative
* Description : Trigger for Opportunity Contact Role
* History     : 
* [17.Jun.2020] Kunal - Code Creation 
*/
@isTest
public class Plative_ContactRoleTriggerTest {
    
    @testSetup
    static void testSetup(){
        
        Account accnt = new Account();
        accnt.Name = 'Test Account';
        insert accnt;
        
        Contact ct1 = new Contact();
        ct1.FirstName = 'FName1';
        ct1.LastName = 'LName1';
        ct1.Email = 'fname1@test.com';
        ct1.AccountId = accnt.Id;
        insert ct1;
        
        Campaign camp = new Campaign();
        camp.IsActive = true;
        camp.Name = 'Test Campaign';
        camp.Event_Title__c = 'Test Campaign for Custom Influence!';
        insert camp;
        
        CampaignMember member = new CampaignMember();
        member.ContactId = ct1.Id;
        member.CampaignId = camp.Id;
        insert member;
        
        Opportunity oppty = new Opportunity();
        oppty.Name = 'Test Oppty';
        oppty.CloseDate = System.today().addDays(5);
        oppty.StageName = '2 - Conducting Needs Analysis';
        oppty.AccountId = accnt.Id;
        insert oppty;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = oppty.Id;
        ocr.ContactId = ct1.Id;
        Test.startTest();
        insert ocr;
        Test.stopTest();
    }
    
    
    @isTest
    static void insertContactRole(){
        Opportunity oppty = [Select Id,AccountId from Opportunity LIMIT 1];
        Contact ct1 = new Contact();
        ct1.FirstName = 'FName2';
        ct1.LastName = 'LName2';
        ct1.Email = 'fname2@test.com';
        ct1.AccountId = oppty.AccountId;
        insert ct1;
        
        Campaign camp = new Campaign();
        camp.IsActive = true;
        camp.Name = 'Test Campaign 2';
        camp.Event_Title__c = 'Test Campaign 2 for Custom Influence!';
        insert camp;
        
        CampaignMember member = new CampaignMember();
        member.ContactId = ct1.Id;
        member.CampaignId = camp.Id;
        insert member;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = oppty.Id;
        ocr.ContactId = ct1.Id;
        Test.startTest();
        insert ocr;
        Test.stopTest();
        
        List<CampaignInfluence> campaignInfluences = [Select Id,Influence from CampaignInfluence where OpportunityId = :oppty.Id];
        System.assertEquals(2, campaignInfluences.size());
        System.assertEquals(50, campaignInfluences[0].Influence);
        System.assertEquals(50, campaignInfluences[1].Influence);
    }
    
    
    @isTest
    static void deleteContactRole(){
        Opportunity oppty = [Select Id,AccountId from Opportunity WHERE AccountId != null LIMIT 1];
        Contact ct1 = new Contact();
        ct1.FirstName = 'FName2';
        ct1.LastName = 'LName2';
        ct1.Email = 'fname2@test.com';
        ct1.AccountId = oppty.AccountId;
        insert ct1;
        
        Campaign camp = new Campaign();
        camp.IsActive = true;
        camp.Name = 'Test Campaign 2';
        camp.Event_Title__c = 'Test Campaign 2 for Custom Influence!';
        insert camp;
        
        CampaignMember member = new CampaignMember();
        member.ContactId = ct1.Id;
        member.CampaignId = camp.Id;
        insert member;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = oppty.Id;
        ocr.ContactId = ct1.Id;
        Test.startTest();
        insert ocr;
        delete ocr; 
        Test.stopTest();
        
        List<CampaignInfluence> campaignInfluences = [Select Id,Influence from CampaignInfluence where OpportunityId = :oppty.Id];
        System.assertEquals(1, campaignInfluences.size());
        System.assertEquals(100, campaignInfluences[0].Influence);
    }
    
}