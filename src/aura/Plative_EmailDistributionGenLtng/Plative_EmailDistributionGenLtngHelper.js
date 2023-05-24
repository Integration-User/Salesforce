({
	fetchEmailDistributions : function(component, event, helper) {
		component.set('v.displaySpinner', true);
        var action = component.get('c.getEmailDistributions');
        action.setCallback(this, function(response) {
            var state = response.getState();
            var responseValue = response.getReturnValue();
            if (state === 'SUCCESS') {
                if (responseValue.length > 0) {
                    var selectOptions = [];
                    for(var i=0; i<responseValue.length; i++){
                        var opt = {
                            label: responseValue[i].Name,
                            value: responseValue[i].Name
                        }
                        selectOptions.push(opt);
                    }
                    component.set('v.emailDistributionsOptions',selectOptions);
                    component.set('v.displaySpinner', false);
                } else {
                    component.set('v.displaySpinner', false);
                    helper.displayMessage('Error!', 'Email Distributions not found!', 'error');
                    $A.get('e.force:closeQuickAction').fire();
                }
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.displayMessage('Error!', errors[0].message, 'error');
                    }
                } else {
                    console.log('Unknown error');
                }
                component.set('v.displaySpinner', false);
                $A.get('e.force:closeQuickAction').fire();
            }
        });
        $A.enqueueAction(action);
	},
    
    fetchContacts: function(component, event, helper, selectedValue) {
        component.set('v.displaySpinner', true);
        var action = component.get('c.getRelatedContacts');
        action.setParams({
            selectedEmailDistribution: selectedValue
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var responseValue = response.getReturnValue();
            if (state === 'SUCCESS') {
                console.log('responseValue: ' , responseValue);
                console.log('state: ' , state);
                if (responseValue.length > 0) {
                    var emailAddresses = '';
                    var seperator = component.get('v.seperator');
                    for(var i=0; i<responseValue.length; i++){
                        emailAddresses += responseValue[i].Contact__r.Email + seperator + responseValue[i].Contact__r.Account.GSA_ID__c + seperator + responseValue[i].Contact__r.GSA_ID__c + '\n';
                    }
                    //Contact__r.GSA_ID__c,Contact__r.Account.GSA_ID__c
                    emailAddresses = emailAddresses.substring(0, emailAddresses.length - 1);
                    component.set('v.emailList', emailAddresses);
                    component.set('v.displaySpinner', false);
                } else {
                    component.set('v.emailList',[]);
                    component.set('v.displaySpinner', false);
                    helper.displayMessage('Error!', 'Contacts not found for selected email distribution', 'error');
                    $A.get('e.force:closeQuickAction').fire();
                }
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.displayMessage('Error!', errors[0].message, 'error');
                    }
                } else {
                    console.log('Unknown error');
                }
                component.set('v.emailList', []);
                component.set('v.displaySpinner', false);
                $A.get('e.force:closeQuickAction').fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    
    displayMessage: function(titleParam, messageParam, typeParam) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            title: titleParam,
            message: messageParam,
            duration: '5000',
            key: 'info_alt',
            type: typeParam,
            mode: 'pester'
        });
        toastEvent.fire();
    }
})