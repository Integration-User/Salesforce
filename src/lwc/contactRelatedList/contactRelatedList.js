import { LightningElement, api, track, wire } from 'lwc';
import FORM_FACTOR from "@salesforce/client/formFactor";
import getAllContacts from '@salesforce/apex/ConsolidatedOpportunity.getAllContacts';

const columns = [
    { label: 'Contact Name', fieldName: 'contactUrl', type: 'url', wrapText: true,
        typeAttributes: {label: { 
            fieldName: 'name'
        }, target : '_blank'}},
    { label: 'Tittle', fieldName: 'tittle', type: 'String', sortable: "true"},
    { label: '3x3 Level', fieldName: 'x3x3Level', type: 'String', sortable: "true"},
]

 
export default class FilteredRelatedCaseList extends LightningElement {
 
    columns = columns;
    @api recordId;
    contactList = [];
    firstList = [];
    showCases = false;
    isDesktop;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    
    get cardLabel() {
        this.showCases = this.contactList.length > 0 ? true : false;
        return 'Main Contacts (' + this.contactList.length + ')';
    }
    
 
    @track error;
    @wire(getAllContacts, {opportunityId:'$recordId'})
    wiredContactList({ error, data }) {
        if (data) {
            this.contactList = data.contactList;
            this.firstList = data.firstList;
            this.showCases = this.contactList.length > 0 ? true : false;
        } else if (error) {
            console.log(error);
            this.error = error;
            console.log(JSON.stringify(this.error))
        }
    }
    handleGotoRelatedList() {
        this.firstList = this.contactList;
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
        const cloneData = [...this.contactList];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.contactList = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
}