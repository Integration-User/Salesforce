@isTest
private class Plative_UserTriggerHandlerTest {
    @testSetup static void setup() {
        insert new Trigger_Control_Setting__c(SetupOwnerId=UserInfo.getOrganizationId(), User__c=true);

        Profile p = [SELECT Id FROM Profile WHERE Name='GSA Sales User'];
        
        List<User> updateUserList = new List<User>();
        
        // User email needs to be updated
        User u1 = new User(FirstName = 'Abel', LastName = 'Axiom', Alias = 'aaxio',
                           Email = 'abel.axiom@sunoco.com.invalid',Username = 'abel.axiom@sunoco.com',
                           CommunityNickname = 'aaxio', isActive = false, ProfileId = p.Id,
                           EmailEncodingKey='UTF-8',LocaleSidKey = 'en_US', 
                           LanguageLocaleKey='en_US', TimeZoneSidKey='America/Chicago', Department = 'US Sale' ); 
        insert u1;
        
        User u2 = new User(FirstName = 'Bob', LastName = 'Builder', Alias = 'bbuil',
                           Email = 'bob.builder@sunoco.com.invalid',Username = 'bob.builder@sunoco.com',
                           CommunityNickname = 'bbuil', isActive = False, ProfileId = p.Id,
                           EmailEncodingKey='UTF-8',LocaleSidKey = 'en_US',Netsuite_ID__c ='232323',
                           LanguageLocaleKey='en_US', TimeZoneSidKey='America/Chicago', Department = 'US Sale'  ); 
        insert u2;

    }
    @isTest static void testUsers() {
        //Get Profile id of Admin
        Test.startTest();
        List<User> updateUserList = new List<User>();
        for (User usr : [SELECT Id, isActive, ProfileId FROM User where Username IN ('abel.axiom@sunoco.com', 'bob.builder@sunoco.com')]) {
            system.debug('usr->'+usr);
            usr.IsActive = true;
            usr.Trigger_Real_time_Sync__c = true;
            updateUserList.add(usr);
        }          
		update updateUserList;
        Test.stopTest();
    }
}