({
    doInit: function(component, event, helper) { 
        helper.getContactStatus(component, event, helper);
    },
     
	clearTokensC : function(component, event, helper) {
		helper.clearTokensH(component, event, helper);
	},
    
    closeQuickAction : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})