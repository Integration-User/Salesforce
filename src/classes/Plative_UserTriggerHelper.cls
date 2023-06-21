/**
* Description : Helper class for trigger on User
* History     :
* [22.Jan.2020] Plative - Code Creation
*/
public class Plative_UserTriggerHelper  {

    /**
    * Description : Check if records to be synced
    **/
    public static void syncRecordsToNS(List<User> lstUser, 
                                       Map<Id, User> mapOldUser){

        List<User> lstUsersToSync = new List<User>();
        Set<Id> setUserIds = new Set<Id>();
        //check if real time sync is to be initiated. 
        //Add parent accounts first.
        for (User userRec : lstUser) {
            //Checks if real time sync needs to be triggered
            if (userRec.Trigger_Real_time_Sync__c && String.isBlank(userRec.Netsuite_ID__c)) {
                if(!String.isBlank(userRec.Id) && !setUserIds.contains(userRec.Id)){
                    lstUsersToSync.add(userRec);
                    setUserIds.add(userRec.Id);
                }
                if(!setUserIds.contains(userRec.Id)){
                    lstUsersToSync.add(userRec);
                    setUserIds.add(userRec.Id);
                }
            }
        }       

        if(setUserIds == null || setUserIds.isEmpty()){
            return;
        }

        //Check if sync settings exist
        Sync_Settings__mdt syncSetting = Plative_SFToNSSyncUtility.checkSyncSettings('User');
        if(syncSetting == null){
            return;
        }
        List<SObject> lstChildSobjects = new List<SObject>();

        List<API_Settings__mdt> apiSettings = [SELECT Account__c, Consumer_Key__c,
                                                      Consumer_Secret__c, Endpoint__c,
                                                      Signature_Method__c, Token_Id__c,
                                                      Token_Secret__c, Version__c
                                               FROM API_Settings__mdt
                                               WHERE DeveloperName = 'Netsuite'];

        if(lstUsersToSync.isEmpty()){
            return;
        }
        Plative_SyncQueue.getInstance().put(syncSetting.Sync_Order__c, 
                                            new Plative_UpsertRecordQueueable(
                                            lstUsersToSync,
                                            lstChildSobjects, apiSettings,
                                            syncSetting.Sync_Order__c));
        if(!Test.isRunningTest()) Plative_SFToNSSyncUtility.triggerJobsInQueue();
    }   
    
    /**
      * Description : assigned permissionset group based n department for newly created user
    **/
    public static void createPermissionSetGroup(Map<Id,User> mapNewUser, Map<Id,User> mapOldUser){    
        String setDepartment; 
        PermissionSetAssignment permSet = new PermissionSetAssignment();
        User oldUser;
        Boolean activatedUser = false;
        
        for(User u : mapNewUser.values()){
            if(mapOldUser != null){
                oldUser = mapOldUser.get(u.id);
                if(u.isActive && !oldUser.isActive){
                    setDepartment = u.Department;
                    permSet.AssigneeId = u.id;
                    activatedUser = true;
                }
            }
        }
        if(activatedUser && setDepartment != null){
            List<GetInfoForUser.UserCreateInfoInput> listUserInfo = new List<GetInfoForUser.UserCreateInfoInput>();
            GetInfoForUser.UserCreateInfoInput input = new GetInfoForUser.UserCreateInfoInput();
            input.department = setDepartment;
            listUserInfo.add(input);
            List<GetInfoForUser.UserCreateInfoOutput> listIds = GetInfoForUser.getUserInfo(listUserInfo);
            if(listIds != null && listIds.size() > 0){
                String permssionSetGrpID = listIds[0].permissionSetId;
                if(String.isNotBlank(permssionSetGrpID)) {
                    List<PermissionSetAssignment> isPresent  = [Select Id from PermissionSetAssignment 
                                                          where PermissionSetGroupId = :permssionSetGrpID AND AssigneeId =: permSet.AssigneeId];
                    if(isPresent.isEmpty()) {
                        permSet.PermissionSetGroupId = permssionSetGrpID;
                        insert permSet;
                    }
                }
            }
        }
        
    }
 
}