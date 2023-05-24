/****************************************************************************
Author : Prachi Gadewar
Date : 25-11-2021
Name : Schedule_UpdateAccountSuccessRep 
Test Class : Schedule_UpdateAccountSuccessRep 
Description : Class is scheduled on daily basis to update the Customer Success Rep field with its owner
****************************************************************************/

public without sharing class Schedule_UpdateAccountSuccessRep Implements Schedulable  {
    public void execute(SchedulableContext sc){
        updateAccountSuccessRepField();
    }

    public void updateAccountSuccessRepField(){
        
        Map<Id,Account> mapAccounts = new Map<Id,Account>([Select id,Customer_Success_Rep__c,Is_Customer_Rep_Changed__c from Account where Is_Customer_Rep_Changed__c = true]);
        List<AccountTeamMember> listAccountMembers = [SELECT AccountId,Account.Customer_Success_Rep__c,TeamMemberRole,Title,User.name FROM AccountTeamMember 
                                      WHERE TeamMemberRole = 'Customer Success' AND Account.Type = 'Client'
                                      AND Account.Is_Customer_Rep_Changed__c = true ORDER BY LastModifiedDate DESC];
    
        map<Id, Account> updateAccounts = new map<id, Account>();
        for(AccountTeamMember accMember : listAccountMembers ){
            if(accMember.Account.Customer_Success_Rep__c != accMember.User.name && !updateAccounts.containsKey(accMember.AccountId)){
                Account acc = mapAccounts.get(accMember.AccountId);
                acc.Customer_Success_Rep__c = accMember.User.name;
                acc.Is_Customer_Rep_Changed__c = false;
                updateAccounts.put(accMember.AccountId, acc);
            }
        }
        /* for(Account acc : mapAccounts.values()){
            acc.Force_Owner_Update__c = false;
        }*/
        
        if(!updateAccounts.isEmpty() && updateAccounts.keyset().size() > 0)
            update updateAccounts.values();
    }
}