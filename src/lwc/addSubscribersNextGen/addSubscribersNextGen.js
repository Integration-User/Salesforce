import {LightningElement, api} from 'lwc';
import {FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent} from 'lightning/flowSupport';
import {ShowToastEvent} from 'lightning/platformShowToastEvent'

export default class AddSubscribers extends LightningElement {
    // Inputs
    @api selectedSubscription_Input = {};
    @api listAccountContacts_Input = [];
    @api listExistingSubscriptionUsers_Input = [];

    loading = true;

    selectedRows = [];
    //used for storing all the selected rows and then preselecting when search happends
    _selectedRows = [];
    filteredContacts = [];

    //Pagination
    // Data source for data table
    @api
    get contactOptions() {
        return this._contactOptions
    };

    set contactOptions(value) {
        this._contactOptions = value;
        this.gotoPage(1); // If source data changes then we need to reset
    }

    pagedData;

    // Current page of results on display
    currentPage = 1;

    // Current maximum pages in sourceData set
    maxPages = 1;

    // Indicators to disable the paging buttons
    disabledPreviousButton = false;
    disabledNextButton = false;

    //Column Sort
    sortBy = "FirstName";
    sortDirection = "asc";

    //Records Per Page
    get displayAmount() {
        return this._displayAmount
    };

    set displayAmount(value) {
        this.displayAmount = value == null ? 10 : value;
        this.gotoPage(1);                                   // If pagination size changes then we need to reset
    }

    displayAmount = 10;

    recordsPerPagePicklist = [
        {value: '10', label: '10'},
        {value: '20', label: '20'},
        {value: '30', label: '30'},
        {value: '40', label: '40'},
        {value: '50', label: '50'}
    ];
    pageChanged = false;

    // Outputs
    @api listSelectedContacts_Output = [];

    numberOfSeats = 0;
    _contactOptions = [];

    _contactColumns = [
        {label: 'First Name', fieldName: 'FirstName', type: "text", sortable: "true"},
        {label: 'Last Name', fieldName: 'LastName', type: "text", sortable: "true"},
        {label: 'Email', fieldName: 'Email', type: "email", sortable: "true"}
    ];


    //***** Functions *****//

    connectedCallback() {
        this.listAccountContacts_Input.forEach(contact => {
            if (!this.listExistingSubscriptionUsers_Input.some(sub => sub.Contact__c === contact.Id)) {
                this.filteredContacts.push(contact);
            }
        });
        this._contactOptions = this.filteredContacts.slice();
        this.sortData(this.sortBy, this.sortDirection, true);

        this.pagedData = this._contactOptions.slice();
        this.numberOfSeats = this.selectedSubscription_Input.Seats_Remaining__c;
        this.gotoPage(this.currentPage, true);
    }

    get addBtnDisabled() {
        return !this._selectedRows.length;
    }

    get selectedContactsCount() {
        return this._selectedRows.length;
    }

    updateSearch(event) {
        this._contactOptions = [];

        const eventLowerCase = event.target.value ? event.target.value.toLowerCase() : "";
        this.filteredContacts.forEach(contact => {
            try {
                let firstNameIncludes = contact.FirstName && contact.FirstName.toLowerCase().includes(eventLowerCase);
                let lastNameIncludes = contact.LastName && contact.LastName.toLowerCase().includes(eventLowerCase);
                let fullNameIncludes = (contact.FirstName + " " + contact.LastName) && (contact.FirstName + " " + contact.LastName).toLowerCase().includes(eventLowerCase);
                let emailIncludes = contact.Email && contact.Email.toLowerCase().includes(eventLowerCase);
                if (!eventLowerCase || firstNameIncludes || lastNameIncludes || fullNameIncludes || emailIncludes) {
                    this._contactOptions.push(contact);
                }
            } catch (err) {
             console.error(err, JSON.stringify(contact));
            }
        });
        this.pagedData = this._contactOptions;
        this.sortData(this.sortBy, this.sortDirection);
        this.resetPaging();
    }

    onRowSelected(event) {
        let numberOfNewItems = event.detail.selectedRows.length - this.selectedRows.length;
        let totalSelectedSubscribers = this._selectedRows.length + numberOfNewItems;
        if ((numberOfNewItems > 0) && (totalSelectedSubscribers > this.numberOfSeats)) {
            let remainingSeats = this.numberOfSeats - this._selectedRows.length;
            const el = this.template.querySelector('lightning-datatable');
            let newElements = this._selectedRows.length ? event.detail.selectedRows.filter(elSelectedRowId => {
                return !this._selectedRows.find(contact => {
                    return (contact.Id === elSelectedRowId);
                });
            }).slice() : event.detail.selectedRows.slice();
            newElements = newElements.slice(0, remainingSeats);
            if (newElements.length) {
                this.selectedRows = newElements.map(element => element.Id);
                this.setInternalSelectedItems(newElements);
            }
            el.selectedRows = el.selectedRows.filter(elSelectedRowId => {
                return this._selectedRows.find(contact => {
                    return (contact.Id === elSelectedRowId);
                });
            }).slice();
            event.preventDefault();
            return;
        }
        if (this.pageChanged) {
            this.setTableSelectedItems();
            this.pageChanged = false;
        } else {
            this.selectedRows = event.detail.selectedRows.map(element => element.Id);
            this.setInternalSelectedItems(event.detail.selectedRows);
        }
    }

    setInternalSelectedItems(eventSelectedRows) {

        this._selectedRows = this._selectedRows.filter(element => {
            let elementIsOnCurrentPage = this.pagedData.find(contactElement1 => contactElement1.Id === element.Id);
            if (elementIsOnCurrentPage) {
                return eventSelectedRows.find(eventSelectedRow => eventSelectedRow.Id === element.Id);
            } else {
                return true;
            }
        });
        eventSelectedRows.forEach(eventSelectedRow => {
            if (!this._selectedRows.find(_selectedRow => _selectedRow.Id === eventSelectedRow.Id)) {
                this._selectedRows.push(eventSelectedRow);
            }
        });
    }

    setTableSelectedItems() {
        const filteredSelected = this._selectedRows.filter(element => {
            return this.pagedData.find(contactElement => contactElement.Id === element.Id);
        }).map(element => element.Id);
        if (this.pageChanged) {
            this.selectedRows = filteredSelected.slice();
        }
    }

    onAddClick() {
        console.log('onAddClick');
        this.listSelectedContacts_Output = this._selectedRows.slice();
        const selectedContactsChangeEvent = new FlowAttributeChangeEvent('listSelectedContacts_Output', this.listSelectedContacts_Output);
        console.log(JSON.stringify(selectedContactsChangeEvent));
        this.dispatchEvent(selectedContactsChangeEvent);

        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }

    onCancelClick() {
        console.log('onCancelClick');
        console.log(JSON.stringify(this.listSelectedContacts_Output));
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }


    // Request reset of data table
    resetPaging() {

        // Initialize data table to the first page
        this.gotoPage(this.maxPages ? 1 : 0);
    }

    // On next click
    handleButtonNext() {

        const nextPage = this.currentPage + 1;
        const maxPages = this.getMaxPages();

        if (nextPage > 0 && nextPage <= maxPages) {

            this.gotoPage(nextPage);
        }
    }

    // On previous click
    handleButtonPrevious() {

        let nextPage = this.currentPage - 1;
        let maxPages = this.getMaxPages();

        if (nextPage > 0 && nextPage <= maxPages) {

            this.gotoPage(nextPage);
        }
    }

    // How many pages of results?
    getMaxPages() {
        // There will always be 1 page, at least
        let result;
        // Number of elements on sourceData
        let arrayLength;
        // Number of elements on sourceData divided by number of rows to display in table (can be a float value)
        let divideValue;
        // Ensure sourceData has a value
        if (this._contactOptions) {
            arrayLength = this._contactOptions.length;
            // Float value of number of pages in data table
            divideValue = arrayLength / this.displayAmount;
            // Round up to the next Integer value for the actual number of pages
            result = Math.ceil(divideValue);
        } else {
            result = 0;
        }
        this.maxPages = result;
        return result;
    }

    // Change page
    gotoPage(pageNumber, isLoad) {
        this.loading = true;
        if (!isLoad) this.pageChanged = true;
        let recordStartPosition, recordEndPosition;
        let maximumPages = this.getMaxPages();

        // Validate that desired page number is available
        if (pageNumber > maximumPages || pageNumber < 0) {
            // Invalid page change. Do nothing
            this.loading = false;
            return;
        }

        // Reenable both buttons
        this.disabledPreviousButton = false;
        this.disabledNextButton = false;

        // Is data source valid?
        if (this._contactOptions) {
            // Start the records at the page position
            recordStartPosition = this.displayAmount * (pageNumber - 1);
// End the records at the record start position with an extra increment for the page size
            recordEndPosition = recordStartPosition + parseInt(this.displayAmount, 10);

            this.pagedData = this._contactOptions.slice(recordStartPosition, recordEndPosition);
            // Set global current page to the new page
            this.currentPage = pageNumber;
            // If current page is the final page then disable the next button
            this.disabledNextButton = (maximumPages === this.currentPage);
            // If current page is the first page then disable the previous button
            this.disabledPreviousButton = (this.currentPage === 1);

            this.setTableSelectedItems();
        }
        this.loading = false;
    }

    onRecordsPerPageChange(event) {
        this.displayAmount = event.detail.value;
        this.resetPaging();
    }

    handleSortdata(event) {
        // field name
        this.sortBy = event.detail.fieldName;

        // sort direction
        this.sortDirection = event.detail.sortDirection;

        // calling sortdata function to sort the data based on direction and selected field
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction, skipPaging) {
        // serialize the data before calling sort function
        let parseData = this._contactOptions.slice();

        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };

        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;

        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';

            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        this._contactOptions = parseData;

        // set the sorted data to data table data
        if (!skipPaging) this.gotoPage(this.currentPage);

    }

}