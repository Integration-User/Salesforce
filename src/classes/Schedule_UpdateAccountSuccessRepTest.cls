@isTest
public class Schedule_UpdateAccountSuccessRepTest {    
    
    @testSetup
    static void testSetup(){     
        
        GSA_Platform__c platform = GSA_Platform__c.getOrgDefaults();  
        //Company
        platform.Company_Activation__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/companies/activate';
        platform.Company_Deactivation__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/companies/';
        platform.Update_Downloads__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/companies/update_num_downloads';
        //User
        platform.User_Activation__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/users/activate';
        platform.User_Deactivation__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/companies/';
        platform.User_Password_Reset__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/users/';
        platform.Clear_Token__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/users/datalink/';
        platform.Update_Token__c = 'http://gsa-website-salesforce-api-dev.us-west-2.elasticbeanstalk.com/v1/users/datalink/';
        //API Key
        platform.API_Key__c = 'SAL3sf0rc3_AP1';
        insert platform;
        
        Account accnt = new Account();
        accnt.Name = 'Test Accnt';
        accnt.Secondary_Name__c = 'Test Accnt Secondary';
        accnt.Phone = '123123123';
        accnt.Website = 'http://www.website.com';
        accnt.BillingCity = 'New York';
        accnt.BillingCountry = 'United States';
        accnt.BillingPostalCode = '4123123';
        accnt.BillingState = 'New York';
        accnt.BillingStreet = 'Madison Avenue';
        accnt.Account_Status__c = 'Active';
        insert accnt;
    }
    
    
    @isTest
    static void fetchAccount(){
        Account acc = [Select Id from Account LIMIT 1];
        User u = [Select id from User where profile.name like '%System%' and isactive = true limit 1];
        acc.Force_Owner_Update__c = true;
        update acc;
        Test.startTest();
        AccountTeamMember member = new AccountTeamMember(AccountId = acc.id, TeamMemberRole = 'Customer Success', UserId=u.id);
        insert member;
        new Schedule_UpdateAccountSuccessRep().updateAccountSuccessRepField();
        Test.stopTest();
    }
    
    
}