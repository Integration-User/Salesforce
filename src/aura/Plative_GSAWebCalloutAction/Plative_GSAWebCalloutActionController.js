({
    doInit : function(component, event, helper) {
        var actionTypeVar = component.get('v.actionType');
        if(actionTypeVar != 'reset_password'){
            component.set('v.displayActivateDeactivateView',true);
        } else{
           component.set('v.displayResetView',true);
        }
        helper.fetchSObjectStatusH(component);

    },
    
    closeQuickAction : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    makeCalloutC : function(component, event, helper) {
        helper.makeCalloutH(component);
    }
})