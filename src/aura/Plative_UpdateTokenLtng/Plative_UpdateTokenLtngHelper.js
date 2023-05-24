({
	updateMaxTokenH: function(component, event, helper) {
        component.set('v.displaySpinner',true);
		var action = component.get('c.updateToken');
        action.setParams({ 
            contactId : component.get('v.recordId'),
            maxTokens : component.get('v.maxToken')
        });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            var responseValue = response.getReturnValue();
            if (state === 'SUCCESS') {
                if(responseValue == 'Success!'){
                    helper.displayMessage('Success!', 'Max Token Updated Successfully', 'success');
                } else {
                    helper.displayMessage('Error!', 'Failed to update max token.', 'error');
                }
                component.set('v.displaySpinner',false);
                $A.get("e.force:closeQuickAction").fire();
            }
            else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.displayMessage('Error!', errors[0].message, 'error');
                    }
                } else {
                    console.log('Unknown error');
                }
                component.set('v.displaySpinner',false);
                $A.get("e.force:closeQuickAction").fire();
            }
        });
		$A.enqueueAction(action);
	},
    
    
    displayMessage: function(titleParam, messageParam, typeParam) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: titleParam,
            message: messageParam,
            duration: '5000',
            key: 'info_alt',
            type: typeParam,
            mode: 'pester'
        });
        toastEvent.fire();
    },
    
    getContactStatus: function(component, event, helper) {
        component.set('v.displaySpinner',true);
		var action = component.get('c.fetchContact');
        action.setParams({ 
            contactId : component.get('v.recordId')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            var responseValue = response.getReturnValue();
            if (state === 'SUCCESS') {
                if(responseValue.Contact_Status__c != 'Active'){
                    helper.displayMessage('Error!', 'Cannot update token for inactive contact', 'error');
                    $A.get("e.force:closeQuickAction").fire();
                }
                component.set('v.displaySpinner',false);
            }
            else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.displayMessage('Error!', errors[0].message, 'error');
                        $A.get("e.force:closeQuickAction").fire();
                    }
                } else {
                    console.log('Unknown error');
                }
                component.set('v.displaySpinner',false);
                
            }
        });
		$A.enqueueAction(action);
    }
})