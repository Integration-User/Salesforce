/**
 * Created by zokito on 7/22/21.
 */
import {LightningElement, api} from 'lwc';
import {loadScript} from 'lightning/platformResourceLoader';
import {CloseActionScreenEvent} from 'lightning/actions';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import deleteContacts from '@salesforce/apex/script_DeleteSubscribersCtrl.deleteContacts';
import {NavigationMixin} from 'lightning/navigation';


import {reduceErrors} from 'c/ldsUtils';

//csv parser generates array of of objects as if the csv was JSON
import PARSER from '@salesforce/resourceUrl/papaparse';
//this is not an array due to easier readability of the code
const FIRSTNAME = {header: 'FIRST_NAME', apiName: 'FirstName'};
const SURNAME = {header: 'SURNAME', apiName: 'LastName'};
const JOBTITLE = {header: 'JOB_TITLE', apiName: 'Title'};
const ADDRESS = {header: 'ADDRESS', apiName: 'MailingStreet'};
const CITY = {header: 'CITY', apiName: 'MailingCity'};
const POSTCODE = {header: 'POST_CODE', apiName: 'MailingPostalCode'};
const STATE = {header: 'STATE', apiName: 'MailingState'};
const COUNTRY = {header: 'COUNTRY', apiName: 'MailingCountry'};
const EMAIL = {header: 'EMAIL', apiName: 'Email'};
const ID = {header: 'ID', apiName: 'Id'};
const MESSAGE = {header: 'MESSAGE', apiName: 'message'};

export default class DeleteSubscribers extends NavigationMixin(LightningElement) {
    parserInitialized = false;
    loading = false;
    _parsedRows;
    _rows;
    @api recordId;


    get showConfirmTable() {
        return (this._parsedRows && this._parsedRows.length && !(this._rows && this._rows.length));
    }
    get showResultsTable() {
        return (this._rows && this._rows.length);
    }
    get showInitialScreen() {
        return !(this.showResultsTable || this.showConfirmTable);
    }

    get columns() {
        return [
            // {label: ID.header, fieldName: ID.apiName},
            {label: FIRSTNAME.header, fieldName: FIRSTNAME.apiName},
            {label: SURNAME.header, fieldName: SURNAME.apiName},
            // {label: JOBTITLE.header, fieldName: JOBTITLE.apiName},
            {label: ADDRESS.header, fieldName: ADDRESS.apiName},
            {label: CITY.header, fieldName: CITY.apiName},
            {label: POSTCODE.header, fieldName: POSTCODE.apiName},
            {label: COUNTRY.header, fieldName: COUNTRY.apiName},
            {label: STATE.header, fieldName: STATE.apiName},
            {label: EMAIL.header, fieldName: EMAIL.apiName},
            {label: MESSAGE.header, fieldName: MESSAGE.apiName}
        ];
    }

    get parsedRows() {
        if (this._parsedRows) {
            return this._parsedRows;
        }
        return [];
    }

    get rows() {
        if (this._rows) {
            return this._rows;
        }
        return [];
    }

    renderedCallback() {
        if (!this.parserInitialized) {
            loadScript(this, PARSER)
                .then(() => {
                    this.parserInitialized = true;
                })
                .catch(error => console.error(error));
        }
    }

    handleInputChange(event) {
        if (event.target.files.length > 0) {
            const file = event.target.files[0];
            this.loading = true;
            console.log('DeleteSubscribers::handleInputChange::this: ', this);
            Papa.parse(file, {
                quoteChar: '"',
                header: 'true',
                complete: (results) => {
                    this._parsedRows = results.data.map(row => {
                        console.log('DeleteSubscribers::handleInputChange::row: ', JSON.stringify(row));
                        let response = {};
                        response[FIRSTNAME.apiName] = row[FIRSTNAME.header];
                        response[SURNAME.apiName] = row[SURNAME.header];
                        response[JOBTITLE.apiName] = row[JOBTITLE.header];
                        response[ADDRESS.apiName] = row[ADDRESS.header];
                        response[CITY.apiName] = row[CITY.header];
                        response[POSTCODE.apiName] = row[POSTCODE.header];
                        response[COUNTRY.apiName] = row[COUNTRY.header];
                        response[EMAIL.apiName] = row[EMAIL.header];
                        return response;
                    }).filter(row => {
                        console.log('UploadSubscribers::row::row: ', row);
                        return !(
                            (!row[FIRSTNAME.apiName] || !row[FIRSTNAME.apiName].replace(" ", "")) &&
                            (!row[SURNAME.apiName] || !row[SURNAME.apiName].replace(" ", "")) &&
                            (!row[JOBTITLE.apiName] || !row[JOBTITLE.apiName].replace(" ", "")) &&
                            (!row[ADDRESS.apiName] || !row[ADDRESS.apiName].replace(" ", "")) &&
                            (!row[CITY.apiName] || !row[CITY.apiName].replace(" ", "")) &&
                            (!row[POSTCODE.apiName] || !row[POSTCODE.apiName].replace(" ", "")) &&
                            (!row[COUNTRY.apiName] || !row[COUNTRY.apiName].replace(" ", "")) &&
                            (!row[EMAIL.apiName] || !row[EMAIL.apiName].replace(" ", "")));
                    });
                    console.log('inputCSV::results.data::: ', results.data);
                    this.loading = false;
                },
                error: (error) => {
                    console.error(error);
                    this.loading = false;
                }
            })
        }
    }

    deleteSubscribers( ) {
        this.loading = true;

        let request = {};
        request.contacts = this._parsedRows;
        request.subscriptionId = this.recordId;
        console.log('DeleteSubscribers::complete::request: ', JSON.stringify(request));
        deleteContacts({request: JSON.stringify(request)})
            .then((result) => {
                console.log('DeleteSubscribers::deleteContacts::result: ', JSON.stringify(result));
                let results = JSON.parse(result);
                this._rows = results.map(contactWrapper => {
                    let row = contactWrapper.con;
                    row.deleted = contactWrapper.deleted;
                    row.duplicate = contactWrapper.duplicate;
                    row.error = contactWrapper.error;
                    row.message = contactWrapper.message;
                    return row;
                });
                this.error = undefined;
            })
            .catch((error) => {
                let message = reduceErrors(error).reduce((prev, curr) => {
                    if (prev) return (prev + ", " + curr);
                    else return curr;
                }, '');
                console.log('DeleteSubscribers::error::error: ', JSON.stringify(message));
                let event = new ShowToastEvent({
                    "title": "Error!",
                    "variant": "error",
                    "message": message,
                    "mode": "pester"
                });
                this.dispatchEvent(event);
                this._rows = undefined;
            }).finally(() => {
            this.loading = false
        });
    }

    cancel() {
        if(this.showResultsTable) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    actionName: 'view'
                },
            });
        }
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}