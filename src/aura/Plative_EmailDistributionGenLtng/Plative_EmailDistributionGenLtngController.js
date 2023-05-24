({
	doInit : function(component, event, helper) {
		helper.fetchEmailDistributions(component, event, helper);
	},
    
   fetchSelectedValue: function(component, event, helper) {
     	var selectedValue = component.find("select1").get("v.value");
        console.log('selectedValue: ' + selectedValue);
        if(selectedValue != null && selectedValue != ''){
            //Get Contacts where Opt-Out false
            helper.fetchContacts(component, event, helper, selectedValue);
        } else {
            component.set('v.emailList',[]);
        }
    },
    
    copyToClipboard: function(component, event, helper) {
        var hiddenInput = document.createElement("input");
        hiddenInput.setAttribute("value", component.get('v.emailList'));
        document.body.appendChild(hiddenInput);
        hiddenInput.select();
        document.execCommand("copy");
        document.body.removeChild(hiddenInput);
        helper.displayMessage('', 'Copied to Clipboard!', 'success');        
    },
    
    navigateToListView: function(component, event, helper) {
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "Account"
        });
        homeEvent.fire();        
    }
})