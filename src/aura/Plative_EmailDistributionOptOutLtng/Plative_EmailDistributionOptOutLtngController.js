({
	doInit : function(component, event, helper) {
		helper.fetchStatus(component, event, helper);
	},
    
    saveEmailDistributions: function(component, event, helper) {
        helper.saveEmailDistributionsH(component, event, helper);
    }
})