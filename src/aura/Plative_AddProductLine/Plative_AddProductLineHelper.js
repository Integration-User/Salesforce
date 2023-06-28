({
    setColumns: function(component, event, helper) {
        //Set Columns
        component.set('v.productColumns', [{
                label: 'Product Name',
                fieldName: 'Name',
                type: 'text'
            },
            {
                label: 'Description',
                fieldName: 'Description',
                type: 'text'
            }
        ]);

        component.set('v.productLinesColumns', [{
                label: 'Product Name',
                fieldName: 'productName',
                type: 'text'
            },
            {
                label: 'Start Date',
                fieldName: 'Start_Date__c',
                type: 'date-local',
                editable: true
            },
            {
                label: 'End Date',
                fieldName: 'End_Date__c',
                type: 'date-local',
                editable: true
            }
        ]);

    },


    getProductsH: function(component, event, helper) {
        component.set('v.displaySpinner', true);
        var action = component.get('c.getProducts');
        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var responseValue = response.getReturnValue();
            console.log('responseValue: ', responseValue);
            if (state === 'SUCCESS') {
                if (responseValue.length > 0) {
                    component.set('v.allProducts', responseValue);
                } else {
                    helper.displayMessage('Error!', 'No Active Product Lines found!', 'error');
                }
                this.getProductLinesH(component, event, helper);
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
            }
        });
        $A.enqueueAction(action);
    },


    getProductLinesH: function(component, event, helper) {
        //Get Account ProductLines
        var action = component.get('c.getProductLines');
        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var responseValue = response.getReturnValue();
            if (state === 'SUCCESS') {
                if (responseValue.length > 0) {
                    responseValue.forEach(function(productLine) {
                        productLine['productName'] = productLine['Product__r'].Name;
                    });
                    component.set('v.allProductLines', responseValue);
                }
                this.getFilteredOptions(component, event, helper);
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
            }
        });
        $A.enqueueAction(action);
    },

    getFilteredOptions: function(component, event, helper) {
		var allProducts = component.get('v.allProducts');
        var allProductLines = component.get('v.allProductLines');
        if(allProductLines != undefined && allProductLines != null && allProductLines.length > 0){
            if(allProducts != undefined && allProducts != null && allProducts.length > 0){
                var filteredProductsTemp = [];
                for(var i=0; i<allProducts.length; i++){
                    var lineAdded = false;
                    for(var j=0; j<allProductLines.length; j++){
                        if(allProducts[i].Id == allProductLines[j].Product__c){
                            lineAdded = true;
                            break;
                        }
                    }
                    if(!lineAdded){
                        filteredProductsTemp.push(allProducts[i]);
                    }
                }
                component.set('v.filteredProducts',filteredProductsTemp);
            }
        } else {
            component.set('v.filteredProducts',allProducts);
        }
        component.set('v.displaySpinner', false);
    },
    
    
    getAccountDetailH: function(component, event, helper) {
        var action = component.get("c.getAccountDetails");
        action.setParams({ 
            recordId: component.get('v.recordId')
        });
		action.setCallback(this, function(response) {
            var state = response.getState();
            var responseValue = response.getReturnValue();
            if (state === "SUCCESS") {
                component.set('v.account',responseValue);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.displayMessage('Error!', errors[0].message, 'error');
                    }
                } else {
                    console.log('Unknown error');
                }
                component.set('v.displaySpinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    
    saveProductLineH: function(component, event, helper) {
        component.set('v.displaySpinner', true);
        var action = component.get('c.saveProductLines');
        action.setParams({
            recordId : component.get('v.recordId'),
            newProductLines: component.get('v.allProductLines')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            var responseValue = response.getReturnValue();
            if (state === 'SUCCESS') {
                if(responseValue.indexOf('Error') == -1){
                    //Success toast
                    helper.displayMessage('Success!', responseValue, 'success');
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    //Failure toast
                    helper.displayMessage('Error!', responseValue, 'error');
                }
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
            }
            component.set('v.displaySpinner', false);
        });
		$A.enqueueAction(action);
    },
    
    
    saveAccountAccessDetail: function(component, event, helper) {
        component.set('v.displaySpinner', true);
        var action = component.get('c.saveAccountAccessDetails');
        action.setParams({
            accnt: component.get('v.account')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            var responseValue = response.getReturnValue();
            if (state === 'SUCCESS') {
                if(responseValue.indexOf('Error') == -1){
                    //Success toast
                    helper.displayMessage('Success!', 'DataLink & Website Access Updated!', 'success');
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    //Failure toast
                    helper.displayMessage('Error!', responseValue, 'error');
                }
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
            }
            component.set('v.displaySpinner', false);
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
    }
})