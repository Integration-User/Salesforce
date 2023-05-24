({
    handleCancel : function(cmp, event, helper) {
        cmp.find("overlayLib").notifyClose()
    },
    
    handleDelete : function(cmp, event, helper) {
        var action = cmp.get('c.deleteRecord')
        var record = cmp.get("v.record")
        var sobjectLabel = cmp.get("v.sobjectLabel")
        action.setParams({ recordId : record.Id })
 		action.setCallback(this, function(response) {
			var toastEvent = $A.get("e.force:showToast")
            var state = response.getState()
            var result = response.getReturnValue()
            if (state === "SUCCESS" && result) {
				$A.get('e.force:refreshView').fire();
                toastEvent.setParams({
                    message: sobjectLabel + ' "' +record.Subject + '"' + ' was deleted.',
                    type: 'SUCCESS'
                });                
            }else {
                toastEvent.setParams({
                    message: sobjectLabel + ' "' +record.Subject + '"' + ' was not deleted.',
                    type: 'ERROR'
                });                
            }
            cmp.find("overlayLib").notifyClose()
            toastEvent.fire()   
        })
        $A.enqueueAction(action)
    },    
})