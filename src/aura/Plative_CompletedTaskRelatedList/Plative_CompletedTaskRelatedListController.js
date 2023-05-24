({
    init: function(cmp, event, helper) {
		helper.fetchData(cmp, event, helper);
    },
    handleRowAction: function(cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        var onRowActionHandler = cmp.get('v.onRowActionHandler');

        if (onRowActionHandler) {
            $A.enqueueAction(onRowActionHandler)
        } else {
            switch (action.name) {
                case 'edit':
                    helper.editRecord(cmp, row)
                    break;
                case 'delete':
                    helper.removeRecord(cmp, row)
                    break;
            }
        }
    },
    createRecord: function(cmp, row) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Task"
        });
        createRecordEvent.fire();
    },
    logCall : function( cmp, event, helper) {
        var actionAPI = cmp.find("quickActionAPI");
        var fields = { Subject: {value:"Test"}};
        var args = { actionName :"LogACall",entityName: "Contact", targetFields: fields};
		console.log('record id '+cmp.get("v.recordId"));
        var actionAPI = cmp.find("quickActionAPI");

        actionAPI.setActionFieldValues(args).then(function(){
            actionAPI.invokeAction(args);
        }).catch(function(e){
            console.error(e.errors);
        });
        /**
            var actionAPI = cmp.find("quickActionAPI");
            actionAPI.getAvailableActions().then(function(result){
                console.log(result.actions);
            }).catch(function(e){
            if(e.errors){

            }
            });
                var actionAPI = cmp.find("quickActionAPI");
                var args = {actionName :"Contact.LogACall", entityName:"Contact" };
                actionAPI.getAvailableActionFields(args).then(function(result){
                     console.log(result.actions);
                }).catch(function(e){
                if(e.errors){
                //If the specified action isn't found on the page, show an error message
                }
            });**/
    },
	refresh : function( cmp, event, helper) {
		var actionAPI = cmp.find("quickActionAPI");
        actionAPI.refresh().then(function(result){
            
        }).catch(function(e){
        if(e.errors){
    
        }
        });		
    },
    // Client-side controller called by the onsort event handler
    updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        // assign the latest attribute with the sorted column fieldName and sorted direction
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    }
})