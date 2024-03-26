/**
 * Created by Anisa on 22-06-2020.
 */

@isTest 
private class Plative_ActivitySecurityUtilTest {

    @IsTest
    static void testTask() {

		Plative_TestDataFactory.createCustomSettings();

		Account acc = Plative_TestDataFactory.createAccount(true);

        Contact cont = Plative_TestDataFactory.createContact(acc, true);

		//query user from Advisory group
		List<GroupMember> lstGroupMember = [SELECT Id, UserOrGroupId FROM GroupMember 
											WHERE Group.Name = 'Advisory' LIMIT 1];

		Task newTask = new Task();
		newTask.OwnerId = lstGroupMember[0].UserOrGroupId;
		newTask.Subject = 'Test Subject';
		newTask.WhoId = cont.Id;
		newTask.WhatId = acc.Id;
		newTask.ActivityDate = System.today()+10;


		Test.startTest();
			insert newTask;
		Test.stopTest();

		//Query shadow contact record
		List<Shadow_Contact__c> lstShadowRecord = [SELECT ID from Shadow_Contact__c
													WHERE Contact__c =: cont.Id];
		
		System.assertEquals(lstShadowRecord.size(),1);
    }

    @IsTest
    static void testEvent() {

		Plative_TestDataFactory.createCustomSettings();

		Account acc = Plative_TestDataFactory.createAccount(true);

        Contact cont = Plative_TestDataFactory.createContact(acc, true);

		//query user from Advisory group
		List<GroupMember> lstGroupMember = [SELECT Id, UserOrGroupId FROM GroupMember 
											WHERE Group.Name = 'Advisory' LIMIT 1];

		Event evt = new Event();
		evt.OwnerId = lstGroupMember[0].UserOrGroupId;
		evt.ActivityDateTime = System.now().addDays(10);
		evt.StartDateTime = evt.ActivityDateTime;
		evt.EndDateTime = evt.StartDateTime.addMinutes(60);
		evt.WhoId = cont.Id;
		evt.WhatId = acc.Id;
		evt.Subject = 'Test Event';
		evt.Type = 'Visit';
		evt.DurationInMinutes = 60;
        
        Event evt1 = new Event();
		evt1.OwnerId = lstGroupMember[0].UserOrGroupId;
		evt1.ActivityDateTime = System.now().addDays(11);
		evt1.StartDateTime = evt1.ActivityDateTime;
		evt1.EndDateTime = evt1.StartDateTime.addMinutes(60);
		evt1.WhoId = cont.Id;
		evt1.WhatId = acc.Id;
		evt1.Subject = 'Test Event';
		evt1.Type = 'In-Person Training';
		evt1.DurationInMinutes = 60;
		evt1.Feedback_Entered__c = 'No';
        evt1.Minutes_Spent__c = 1;
        evt1.Web_Demo__c = 'No';
        evt1.Status__c = 'Completed';
        evt1.Products_Discussed__c = 'Onboarding';
        evt1.Description = 'Completed Test';
        evt.Objective__c = 'Completed Test';
        evt.Strategy__c = 'Completed Test';
        evt1.Client_Use_Case__c = 'Completed Test';
        evt1.Status__c = 'Completed';

		Test.startTest();
        insert evt;
        insert evt1;
		Test.stopTest();

		//Query shadow contact record
		List<Shadow_Contact__c> lstShadowRecord = [SELECT ID from Shadow_Contact__c
													WHERE Contact__c =: cont.Id];
		
		System.assertEquals(lstShadowRecord.size(),1);
    }

    @IsTest
    static void testRelatedListController() {

		Plative_TestDataFactory.createCustomSettings();

		Account acc = Plative_TestDataFactory.createAccount(true);

        Contact cont = Plative_TestDataFactory.createContact(acc, true);

		//query user from Advisory group
		List<GroupMember> lstGroupMember = [SELECT Id, UserOrGroupId FROM GroupMember 
											WHERE Group.Name = 'Advisory' LIMIT 1];

		Task newTask = new Task();
		newTask.OwnerId = lstGroupMember[0].UserOrGroupId;
		newTask.Subject = 'Test Subject';
		newTask.WhoId = cont.Id;
		newTask.ActivityDate = System.today()+10;
		insert newTask;
        
        Shadow_Contact__c shadow = new Shadow_Contact__c();
        shadow.Name = cont.Name;
        shadow.Contact__c = cont.Id;
        insert shadow;

		Test.startTest();
		List<Plative_ActivityWrapper> wrapperList = Plative_TaskRelatedListController.fetchTasks(cont.Id);	
		Test.stopTest();
			
    }
}