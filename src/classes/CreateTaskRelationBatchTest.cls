@isTest
private class CreateTaskRelationBatchTest {
    
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
        
        Database.executeBatch(new CreateTaskRelationBatch(), 1);
    }
    
}