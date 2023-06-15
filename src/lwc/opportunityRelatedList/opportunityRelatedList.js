import { LightningElement, api, track, wire } from 'lwc';
import FORM_FACTOR from "@salesforce/client/formFactor";
import getAllOpportunityLineItems from '@salesforce/apex/ConsolidatedOpportunity.getAllOpportunityLineItems';

const columns = [
    { label: 'Product', fieldName: 'productUrl', type: 'url', wrapText: true,
        typeAttributes: {label: { 
            fieldName: 'productName'
        }, target : '_blank'}},
    { label: 'Start Date', fieldName: 'startDate', type: 'date', sortable: "true",
        typeAttributes: {
        day: "numeric",
        month: "numeric",
        year: "numeric"}},
    { label: 'End Date', fieldName: 'endDate', type: 'date', sortable: "true", 
        typeAttributes: {
        day: "numeric",
        month: "numeric",
        year: "numeric"} },
    { label: 'Sales Type', fieldName: 'salesType', type: 'String', sortable: "true"},
    { label: 'Lost Product', fieldName: 'lostProduct', type: 'boolean', sortable: "true"},
]

 
export default class FilteredRelatedCaseList extends LightningElement {
 
    columns = columns;
    @api recordId;
    OpportunityLineItem = [];
    showCases = false;
    isDesktop;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    
    get cardLabel() {
        this.showCases = this.OpportunityLineItem.length > 0 ? true : false;
        return 'Opportunity Products (' + this.OpportunityLineItem.length + ')';
    }
    
 
    @track error;
    @wire(getAllOpportunityLineItems, {caseId:'$recordId'})
    wiredOppLineItems({ error, data }) {
        if (data) {
            this.OpportunityLineItem = data;
            this.showCases = this.OpportunityLineItem.length > 0 ? true : false;
        } else if (error) {
            console.log(error);
            this.error = error;
            console.log(JSON.stringify(this.error))
        }
    }
    handleFormFactor() {
        if (FORM_FACTOR === "Large") {
            this.isDesktop = true;
        } else if (FORM_FACTOR === "Medium") {
            this.isDesktop = false;
        } else if (FORM_FACTOR === "Small") {
            this.isDesktop = false;
        }
    }
    connectedCallback() {
        this.handleFormFactor();
    }
    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.OpportunityLineItem];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.OpportunityLineItem = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
}