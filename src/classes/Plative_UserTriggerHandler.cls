/**
* Description : Handler class for trigger on User
* History     :
* [22.Jan.2020] Plative - Code Creation
*/
public class Plative_UserTriggerHandler  {

    //Variable to handler recursion
    public static Boolean afterUpdateRun = false;
    public static Boolean afterInsertRun = false;

    /**
    * Description : After update dml event
    **/
    public static void afterUpdate(Map<Id, User> triggerNewMap, Map<Id, User> triggerOldMap) {
        if (!Plative_UserTriggerHandler.afterUpdateRun) {
            Plative_UserTriggerHelper.syncRecordsToNS(triggerNewMap.values(), triggerOldMap);
            Plative_UserTriggerHandler.afterUpdateRun = true;
        }
        Plative_UserTriggerHelper.createPermissionSetGroup(triggerNewMap, triggerOldMap);

    }
    
    public static void beforeInsert(Map<Id, User> triggerNewMap) {
    }
}