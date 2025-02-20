/**
 * Created by zokito on 3/2/22.
 */

({
    invoke : function(component,event,helper){
        $A.get('e.force:refreshView').fire();
    },
});