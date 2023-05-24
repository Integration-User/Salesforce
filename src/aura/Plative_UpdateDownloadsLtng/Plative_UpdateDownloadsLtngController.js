({
	doInit: function(component, event, helper) {
        helper.getAccountStatus(component, event, helper); 
    }, 
    
    
    updateDownloads: function(component, event, helper) {
        var downloadCount = component.get('v.downloadCount');
        if(downloadCount == undefined || downloadCount == null || downloadCount == ''){
            helper.displayMessage('Error!', '# of Downloads is required!', 'error');
        } else {
            helper.updateDownloadsH(component, event, helper);    
        }
		
	},    
    
    closeQuickAction: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();		      
    }
})