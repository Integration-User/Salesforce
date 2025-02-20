public class TriggerDispatcher {
    /*
        Call this method from your trigger, passing in an instance of a trigger handler.
        This method will fire the appropriate methods on the handler depending on trigger context.
    */
    public static void Run(ITriggerHandler handler) {
        System.debug(LoggingLevel.DEBUG, 'Trigger Run: '  + handler.toString());

        // Check if the trigger has been disabled. If disabled, do nothing, exist.
        if(handler.isDisabled()){
            return;
        }

        // Detect the currect trigger context and fire the relevant methods on the trigger handler.
        if (Trigger.isBefore){
            if (Trigger.isInsert){
                System.debug(LoggingLevel.DEBUG, 'Trigger Run - Before Insert - New Items: ' + Trigger.new);
                handler.BeforeInsert(Trigger.new);
            }

            if (Trigger.isUpdate){
                System.debug(LoggingLevel.DEBUG, 'Trigger Run - Before Update - Old Items: ' + Trigger.old);
                System.debug(LoggingLevel.DEBUG, 'Trigger Run - Before Update - New Items: ' + Trigger.new);
                handler.BeforeUpdate(Trigger.newMap, Trigger.oldMap);
            }

            if(Trigger.isDelete){
                System.debug(LoggingLevel.DEBUG, 'Trigger Run - Before Delete - New Items: ' + Trigger.new);
                handler.BeforeDelete(Trigger.oldMap);
            }
        }

        if (Trigger.isAfter){
            if (Trigger.isInsert){
                System.debug(LoggingLevel.DEBUG, 'Trigger Run - After Insert - New Items: ' + Trigger.new);
                handler.AfterInsert(Trigger.newMap, Trigger.oldMap);
            }

            if (Trigger.isUpdate){
                System.debug(LoggingLevel.DEBUG, 'Trigger Run - After Update - Old Items: ' + Trigger.old);
                System.debug(LoggingLevel.DEBUG, 'Trigger Run - After Update - New Items: ' + Trigger.new);
                handler.AfterUpdate(Trigger.newMap, Trigger.oldMap);
            }

            if(Trigger.isDelete){
                handler.AfterDelete(Trigger.oldMap);
            }

            if(Trigger.isUndelete){
                handler.AfterUndelete(Trigger.newMap);
            }
        }
    }
}