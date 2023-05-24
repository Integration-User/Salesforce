({
    doInit : function(component, event, helper) { 
        console.log('doInit called');
        helper.fetchStatus(component, event, helper);
    },
    
    saveEmailDistributions: function(component, event, helper) { 
        helper.saveEmailDistributionsH(component, event, helper);
    }
    
})