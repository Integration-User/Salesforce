({
    doInit: function(component, event, helper) {
        helper.getContactStatus(component, event, helper);
    },   
    
    
	updateMaxTokenC: function(component, event, helper) {
        var maxToken = component.get('v.maxToken');
        if(maxToken == undefined || maxToken == null || maxToken == ''){
            helper.displayMessage('Error!', 'Max Token is required!', 'error');
        } else {
            helper.updateMaxTokenH(component, event, helper);    
        }
		
	},
    
    
    closeQuickAction: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();		      
    }
})