({
    fetchData: function(component, event, helper) {
		component.set('v.columns', [
			{label: 'Subject', fieldName: 'URL', type: 'url' ,sortable:true,
			typeAttributes: { 
				label: {
					fieldName: 'Subject'
				},
				target: '_blank'
				}
			},
            {label: 'Due Date', fieldName: 'ActivityDate', type: 'date', sortable:true},
            {label: 'Status', fieldName: 'Status', type: 'text'},
			{label: 'Assigned To', fieldName: 'OwnerName', type: 'text', sortable:true},
        ]);

        var customActions = [{
                label: 'Edit',
                name: 'edit'
            },
            {
                label: 'Delete',
                name: 'delete'
            }
        ];
        var columnsWithActions = [];
		var columns = component.get('v.columns');
        columnsWithActions.push(...columns);
        columnsWithActions.push({
            type: 'action',
            typeAttributes: {
                rowActions: customActions
            }
        });
        component.set('v.columnsWithActions', columnsWithActions);
        var action = component.get("c.fetchCompletedTasks");
        action.setParams({
                    "contactId":component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
				var records= response.getReturnValue();
				component.set("v.numberOfRecordsForTitle", records.length);
				records.forEach(function(item) {
					item['URL'] = '/lightning/r/Task/' + item['Id'] + '/view';
					item['OwnerName'] = item['Owner'].Name;
				});
                component.set("v.taskList", records);
            }
        });
        $A.enqueueAction(action);
	},
    editRecord: function(cmp, row) {
        var createRecordEvent = $A.get("e.force:editRecord");
        createRecordEvent.setParams({
            "recordId": row.Id
        });
        createRecordEvent.fire();
    },
    removeRecord: function(cmp, row) {
        var modalBody;
        var modalFooter;
        var sobjectLabel = cmp.get('v.sobjectLabel')
        $A.createComponents([
                ["c:Plative_deleteRecordContent", {
                    sobjectLabel: sobjectLabel
                }],
                ["c:Plative_deleteRecordFooter", {
                    record: row,
                    sobjectLabel: sobjectLabel
                }]
            ],
            function(components, status) {
                if (status === "SUCCESS") {
                    modalBody = components[0];
                    modalFooter = components[1];
                    cmp.find('overlayLib').showCustomModal({
                        header: "Delete " + sobjectLabel,
                        body: modalBody,
                        footer: modalFooter,
                        showCloseButton: true
                    })
                }
            }
        );
        cmp.set('v.displaySpinner', false);
    },
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.taskList");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.taskList", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
})