({
    fetchStatus: function(component, event, helper) {
        console.log('fetchStatus called');
        component.set('v.displaySpinner', true);
        var action = component.get('c.getContactStatus');
        action.setParams({
            recordId: component.get('v.recordId')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            var responseValue = response.getReturnValue();
            if (state === 'SUCCESS') {
                if (responseValue != null && responseValue != '' && responseValue == 'Active') {
                    component.set('v.displaySpinner', false);
                    helper.getContactEmailDistributionsH(component, event, helper);
                } else {
                    component.set('v.displaySpinner', false);
                    helper.displayMessage('Error!', 'Can\'t select Email Distribution for Inactive Account', 'error');
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

    getContactEmailDistributionsH: function(component, event, helper) {
        console.log('getContactEmailDistributions called');
        component.set('v.displaySpinner', true);
        var action = component.get('c.getContactEmailDistributions');
        action.setParams({
            recordId: component.get('v.recordId')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            var responseValue = response.getReturnValue();
            console.log('responseValue: ', responseValue);
            if (state === 'SUCCESS') {
                if (responseValue.length > 0) {
                    var options = [];
                    var optionsAdded = [];
                    var selectedOptions = [];
                    for (var i = 0; i < responseValue.length; i++) {
                        if (optionsAdded.indexOf(responseValue[i].Email_Distribution__c) == -1) {
                            optionsAdded.push(responseValue[i].Email_Distribution__c);
                            var opt = {
                                label: responseValue[i].Email_Distribution__c,
                                value: responseValue[i].Email_Distribution__c
                            }
                            options.push(opt);
                            if (responseValue[i].Opt_Out__c == true) {
                                selectedOptions.push(responseValue[i].Email_Distribution__c);
                            }
                        }
                    }
                    component.set('v.selectedOptions', selectedOptions);
                    component.set('v.options', options);
                    component.set('v.displaySpinner', false);
                } else {
                    component.set('v.displaySpinner', false);
                    helper.displayMessage('Error!', 'No Email Distributions found!', 'error');
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
    
    
    saveEmailDistributionsH: function(component, event, helper) {
        component.set('v.displaySpinner', true);
        var action = component.get('c.saveEmailOptOut');
        action.setParams({
            recordId: component.get('v.recordId'),
            emailOptOutList: component.get('v.selectedOptions')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            var responseValue = response.getReturnValue();
            console.log('responseValue: ', responseValue);
            if (state === 'SUCCESS') {
                if(responseValue == 'Success!'){
                    helper.displayMessage('Success!', responseValue, 'success');
                } else {
                    helper.displayMessage('Error!', responseValue, 'error');
                }
                component.set('v.displaySpinner', false);
                $A.get('e.force:refreshView').fire();
                $A.get('e.force:closeQuickAction').fire();
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