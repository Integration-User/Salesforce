({
    doInit: function(component, event, helper) {
        helper.setColumns(component, event, helper);
        helper.getProductsH(component, event, helper);
        helper.getAccountDetailH(component, event, helper);
    },

    onSelectAvailableOptions: function(component, event, helper) {
        component.set('v.selectedProducts', event.getParam('selectedRows'));
    },

    onSelectSelectedOptions: function(component, event, helper) {
        component.set('v.selectedProductLines', event.getParam('selectedRows'));
    },

    addProducts: function(component, event, helper) {
        var selectedProducts = component.get('v.selectedProducts');
        var filteredProducts = component.get('v.filteredProducts');
        var allProductLines = component.get('v.allProductLines');
        var recordId = component.get('v.recordId');

        for (var i = 0; i < selectedProducts.length; i++) {
            var newProductLine = {
                'Account__c': recordId,
                'Product__c': selectedProducts[i].Id,
                'productName': selectedProducts[i].Name
            };
            allProductLines.unshift(newProductLine);
        }
        component.set('v.allProductLines', allProductLines);

        var filteredProductsTemp = [];
        for (var i = 0; i < filteredProducts.length; i++) {
            var lineAdded = false;
            for (var j = 0; j < allProductLines.length; j++) {
                if (filteredProducts[i].Id == allProductLines[j].Product__c) {
                    lineAdded = true;
                }
            }
            if (!lineAdded) {
                filteredProductsTemp.push(filteredProducts[i]);
            }
        }
        component.set('v.filteredProducts', filteredProductsTemp);
        component.set('v.selectedProducts', []);

    },

    removeProducts: function(component, event, helper) {
        var selectedProductLines = component.get('v.selectedProductLines');
        var allProductLines = component.get('v.allProductLines');
        var filteredProducts = component.get('v.filteredProducts');
        var allProducts = component.get('v.allProducts');

        for (var i = 0; i < selectedProductLines.length; i++) {
            for (j = 0; j < allProducts.length; j++) {
                if (selectedProductLines[i].Product__c == allProducts[j].Id) {
                    filteredProducts.push(allProducts[j]);
                }
            }
        }
        component.set('v.filteredProducts', filteredProducts);

        var tempProductLineArr = [];
        for (var i = 0; i < allProductLines.length; i++) {
            var lineToRemove = false;
            for (var j = 0; j < selectedProductLines.length; j++) {
                if (allProductLines[i].Product__c == selectedProductLines[j].Product__c) {
                    lineToRemove = true;
                    break;
                }
            }
            if (!lineToRemove) {
                tempProductLineArr.push(allProductLines[i]);
            }
        }
        component.set('v.allProductLines', tempProductLineArr);
        component.set('v.selectedProductLines', []);
    },


    updateDraftValues: function(component, event, helper) {

        var draftValues = event.getParam('draftValues');
        var allProductLines = component.get('v.allProductLines');
        
        for (var i = 0; i < draftValues.length; i++) {
            for (var j = 0; j < allProductLines.length; j++) {
                if (draftValues[i].Product__c == allProductLines[j].Product__c) {
                    allProductLines[j].Start_Date__c = (draftValues[i].Start_Date__c != undefined && draftValues[i].Start_Date__c != null && draftValues[i].Start_Date__c != '') ? draftValues[i].Start_Date__c: allProductLines[j].Start_Date__c;
                    allProductLines[j].End_Date__c = (draftValues[i].End_Date__c != undefined && draftValues[i].End_Date__c != null && draftValues[i].End_Date__c != '') ? draftValues[i].End_Date__c : allProductLines[j].End_Date__c;
                }
            }
        }

        component.get('v.allProductLines', allProductLines);
    },

    saveProductLine: function(component, event, helper) {
        var accountVar = component.get('v.account');
        console.log('--: ' + accountVar.DataLink_Access__c);
        console.log('--: ' + accountVar.Website_Access__c);
        if(accountVar.DataLink_Access__c == false && accountVar.Website_Access__c == false){
            helper.displayMessage('Error!','Access for at least one needs to be specified. Datalink or Website or both!', 'error');
        } else {
            helper.saveProductLineH(component, event, helper);
        	helper.saveAccountAccessDetail(component, event, helper);
        }
        
    }


})