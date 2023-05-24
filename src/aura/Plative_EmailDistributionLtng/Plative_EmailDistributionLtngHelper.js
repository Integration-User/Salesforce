({
    fetchStatus: function(component, event, helper) {
        console.log('fetchStatus called');
        component.set('v.displaySpinner', true);
        var action = component.get('c.getAccountStatus');
        action.setParams({
            recordId: component.get('v.recordId')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            var responseValue = response.getReturnValue();
            if (state === 'SUCCESS') {
                if (responseValue != null && responseValue != '' && responseValue == 'Active') {
                    component.set('v.displaySpinner', false);
                    helper.fetchDistributionList(component, event, helper);
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


    fetchDistributionList: function(component, event, helper) {
        console.log('fetchDistributionList called');
        component.set('v.displaySpinner', true);
        var action = component.get('c.getEmailDistributionList');
        action.setParams({
            recordId: component.get('v.recordId')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            var responseValue = response.getReturnValue();
            console.log('responseValue: ', responseValue);
            if (state === 'SUCCESS') {
                var allEmailDistributions = responseValue[0];
                console.log('allEmailDistributions: ', allEmailDistributions);
                var relatedEmailDistributions = responseValue[1];
                console.log('relatedEmailDistributions: ', relatedEmailDistributions);
                if (allEmailDistributions.length > 0) {
                    var selectedEmailDistribution = [];
                    if (relatedEmailDistributions.length > 0) {
                        for (var i = 0; i < relatedEmailDistributions.length; i++) {
                            selectedEmailDistribution.push(relatedEmailDistributions[i].Email_Distribution__c);
                        }
                    }
                    var options = [];
                    var optionsAdded = [];
                    for (var i = 0; i < allEmailDistributions.length; i++) {
                        if (optionsAdded.indexOf(allEmailDistributions[i].Name) == -1) {
                                optionsAdded.push(allEmailDistributions[i].Name);
                                var opt = {
                                    label: allEmailDistributions[i].Name,
                                    value: allEmailDistributions[i].Name
                                }
                                options.push(opt);
                            }
                    }
                    component.set('v.options', options);
                    component.set('v.selectedOptions', selectedEmailDistribution);
                    component.set('v.dualListView', true)
                    component.set('v.displaySpinner', false);
                } else {
                    component.set('v.displaySpinner', false);
                    helper.displayMessage('Error!', 'No relevant Email Distributions found!', 'error');
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
        var action = component.get('c.saveEmailDistribution');
        action.setParams({
            recordId: component.get('v.recordId'),
            emailDistributionList: component.get('v.selectedOptions')
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