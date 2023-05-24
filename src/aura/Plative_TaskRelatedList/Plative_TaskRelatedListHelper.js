({
    fetchData: function(component, event, helper) {
		component.set('v.columns', [
			{label: 'Subject', fieldName: 'URL', type: 'url' ,sortable:true,
			typeAttributes: { 
				label: {
					fieldName: 'subject'
				},
				target: '_blank'
				}
			},
			{label: 'Name', fieldName: 'contactName', type: 'text', sortable:true},
            {label: 'Due Date', fieldName: 'dueDate', type: 'date-local', sortable:true},
            {label: 'Status', fieldName: 'status', type: 'text',sortable:true},
			{label: 'Assigned To', fieldName: 'OwnerName', type: 'text', sortable:true},
			{label: 'Type', fieldName: 'type', type: 'text', sortable:true}
        ]);

        var columnsWithActions = [];
		var columns = component.get('v.columns');
        columnsWithActions.push(...columns);
        component.set('v.columnsWithActions', columnsWithActions);
        var action = component.get("c.fetchTasks");
        action.setParams({
                    "recordId":component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
				var records= response.getReturnValue();
				component.set("v.numberOfRecordsForTitle", records.length);
				records.forEach(function(item) {
					item['URL'] = '/lightning/r/'+item['sobjName']+'/'+ item['recordId'] + '/view';
					item['OwnerName'] = item['assignedToOwner'];
				});
                component.set("v.taskList", records);
                component.set('v.allData', records);
                component.set('v.filteredData', records);
            }
			this.preparePagination(component, records);
        });
        $A.enqueueAction(action);
	},
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.taskList");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.tableData", data);
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
    },
    preparePagination: function (component, records) {
        let countTotalPage = Math.ceil(records.length/component.get("v.pageSize"));
        let totalPage = countTotalPage > 0 ? countTotalPage : 1;
        component.set("v.totalPages", totalPage);
        component.set("v.currentPageNumber", 1);
        this.setPageDataAsPerPagination(component);
    },
    setPageDataAsPerPagination: function(component) {
        let data = [];
        let pageNumber = component.get("v.currentPageNumber");
        let pageSize = component.get("v.pageSize");
        let filteredData = component.get('v.filteredData');
        let x = (pageNumber - 1) * pageSize;
        for (; x < (pageNumber) * pageSize; x++){
            if (filteredData[x]) {
                data.push(filteredData[x]);
            }
        }
        component.set("v.tableData", data);
    },
})