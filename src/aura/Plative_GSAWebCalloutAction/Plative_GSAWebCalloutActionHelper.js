({
    fetchSObjectStatusH: function(component, helper) {
        component.set('v.displaySpinner', true);
        var actionTypeVar = component.get('v.actionType');
        var action = component.get('c.fetchSObjectStatus');
        action.setParams({
            recordId: component.get('v.recordId'),
            actionType: actionTypeVar
        });

        // Create a callback that is executed after
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            var responseValue = response.getReturnValue();
            console.log('responseValue: ' + responseValue);
            console.log('actionTypeVar: ' + actionTypeVar);
            console.log('sobjectapiname: ' + component.get('v.sObjectApiName').toLowerCase());
            if (state === 'SUCCESS') {
                if (actionTypeVar != 'reset_password') {
                    if (actionTypeVar == responseValue) {
                        $A.get("e.force:closeQuickAction").fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Info',
                            message: 'Record is already ' + responseValue + 'd!',
                            duration: ' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        component.set('v.displaySpinner', false);
                    } else if (component.get('v.sObjectApiName').toLowerCase() == 'account' && actionTypeVar == 'deactivate' && responseValue == '') {
                        //this.fetchActiveContactCountAgainstAccountH(component);
                        component.set('v.displaySpinner', false);
                    } else {
                        component.set('v.displaySpinner', false);
                    }

                } else if (responseValue != 'activate') {
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error',
                        message: 'Cannot Reset Password for an Inactive User!',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    component.set('v.displaySpinner', false);
                } else {
                    component.set('v.displaySpinner', false);
                }
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        $A.get("e.force:closeQuickAction").fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Error',
                            message: errors[0].message,
                            duration: ' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                } else {
                    console.log('Unknown error');
                }
                component.set('v.displaySpinner', false);
            }
        });
        $A.enqueueAction(action);
    },

    fetchActiveContactCountAgainstAccountH: function(component) {
        var action = component.get('c.fetchActiveContactCountAgainstAccount');
        action.setParams({
            recordId: component.get('v.recordId')
        });

        // Create a callback that is executed after
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            var responseValue = response.getReturnValue();
            if (state === 'SUCCESS') {
                if (responseValue == 0) {
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error',
                        message: 'Cannot deactivate Account where there are no active users!',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    component.set('v.displaySpinner', false);
                } else {
                    component.set('v.displaySpinner', false);
                }
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        $A.get("e.force:closeQuickAction").fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Error',
                            message: errors[0].message,
                            duration: ' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                } else {
                    console.log("Unknown error");
                }
                component.set('v.displaySpinner', false);
            }
        });
        $A.enqueueAction(action);
    },

    makeCalloutH: function(component) {
        component.set('v.displaySpinner', true);
        var actionTypeVar = component.get('v.actionType');
        var action = component.get('c.makeCallout');
        action.setParams({
            recordId: component.get('v.recordId'),
            sObjectApiName: component.get('v.sObjectApiName'),
            actionType: component.get('v.actionType')
        });

        // Create a callback that is executed after
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            var responseValue = response.getReturnValue();
            if (state === 'SUCCESS') {
                if (responseValue.indexOf('Error') == -1) {
                    var actionTypeVar = component.get('v.actionType');
                    if (actionTypeVar != 'reset_password') {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Success',
                            message: component.get('v.sObjectApiName') + ' ' + actionTypeVar + 'd' + ' successfully!',
                            duration: ' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        $A.get('e.force:refreshView').fire();
                    } else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Success',
                            message: responseValue,
                            duration: ' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        $A.get('e.force:refreshView').fire();
                    }
                    $A.get("e.force:closeQuickAction").fire();

                } else {
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error',
                        message: responseValue,
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
                component.set('v.displaySpinner', false);
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        $A.get("e.force:closeQuickAction").fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Error',
                            message: errors[0].message,
                            duration: '5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                } else {
                    console.log('Unknown error');
                }
                component.set('v.displaySpinner', false);
            }
        });
        $A.enqueueAction(action);
    }
})