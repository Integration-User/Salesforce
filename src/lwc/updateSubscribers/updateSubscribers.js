/**
 * Created by zokito on 7/5/21.
 */

import {LightningElement, api} from 'lwc';
import {loadScript} from 'lightning/platformResourceLoader';
import {CloseActionScreenEvent} from 'lightning/actions';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import createContacts from '@salesforce/apex/script_UpdateSubscribersCtrl.createContacts';
import pushToZephr from '@salesforce/apex/script_UpdateSubscribersCtrl.pushToZephr';


import {reduceErrors} from 'c/ldsUtils';

//csv parser generates array of of objects as if the csv was JSON
import PARSER from '@salesforce/resourceUrl/papaparse';
import {NavigationMixin} from "lightning/navigation";
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
const START_DATE = { header: 'START_DATE', apiName: 'SubscriberStartDate'}
const END_DATE = { header: 'END_DATE', apiName: 'SubscriberEndDate'}

export default class UpdateSubscribers extends NavigationMixin(LightningElement) {
    parserInitialized = false;
    allErrors = true;
    loading = false;
    _parsedRows;
    _parsedSubscriberUsers;
    _rows;
    @api recordId;

    get showConfirmTable() {
        return (this._parsedRows && this._parsedRows.length && !(this._rows && this._rows.length));
    }

    get showUploadTable() {
        return (this._rows && this._rows.length);
    }

    get showInitialScreen() {
        return !(this.showUploadTable || this.showConfirmTable);
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
            {label: START_DATE.header, fieldName: START_DATE.apiName},
            {label: END_DATE.header, fieldName: END_DATE.apiName},
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
            console.log('UploadSubscribers::handleInputChange::this: ');
            Papa.parse(file, {
                quoteChar: '"',
                header: 'true',
                complete: (results) => {
                    this._parsedRows = results.data.map(row => {
                        console.log('UploadSubscribers::handleInputChange::row: ', JSON.stringify(row));
                        let response = {};
                        response[FIRSTNAME.apiName] = row[FIRSTNAME.header];
                        response[SURNAME.apiName] = row[SURNAME.header];
                        response[JOBTITLE.apiName] = row[JOBTITLE.header];
                        response[ADDRESS.apiName] = row[ADDRESS.header];
                        response[CITY.apiName] = row[CITY.header];
                        response[POSTCODE.apiName] = row[POSTCODE.header];
                        response[COUNTRY.apiName] = row[COUNTRY.header];
                        response[STATE.apiName] = row[STATE.header];
                        response[EMAIL.apiName] = row[EMAIL.header];
                        response[START_DATE.apiName] = row[START_DATE.header];
                        response[END_DATE.apiName] = row[END_DATE.header];
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
                            (!row[STATE.apiName] || !row[STATE.apiName].replace(" ", "")) &&
                            (!row[EMAIL.apiName] || !row[EMAIL.apiName].replace(" ", "")));
                    });

                    this._parsedSubscriberUsers = results.data.map(row => {
                        console.log('UploadSubscribers::handleInputChange::row: ', JSON.stringify(row));
                        let response = {};
                        response[EMAIL.apiName] = row[EMAIL.header];
                        response[START_DATE.apiName] = typeof row[START_DATE.header] === 'string' && row[START_DATE.header].trim().length === 0 ? null : row[START_DATE.header];
                        response[END_DATE.apiName] = typeof row[END_DATE.header] === 'string' && row[END_DATE.header].trim().length === 0 ? null : row[END_DATE.header];
                        return response;
                    }).filter(row => {
                        console.log('UploadSubscribers::row::row: ', row);
                        return !(
                            (!row[START_DATE.apiName] || !row[START_DATE.apiName].replace(" ", "")) &&
                            (!row[END_DATE.apiName] || !row[END_DATE.apiName].replace(" ", "")) &&
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

    uploadContacts() {
        this.loading = true;
        let request = {};
        request.contacts = this._parsedRows;
        request.subscriptionId = this.recordId;
        request.subscriptionUsers = this._parsedSubscriberUsers;
        console.log('UploadSubscribers::complete::request: ', JSON.stringify(request));
        createContacts({request: JSON.stringify(request)})
            .then((result) => {
                console.log('UploadSubscribers::createContacts::result: ', JSON.stringify(result));
                let results = JSON.parse(result);
                this._rows = results.map(contactWrapper => {
                    let row = contactWrapper.con;
                    row.created = contactWrapper.created;
                    row.duplicate = contactWrapper.duplicate;
                    row.error = contactWrapper.error;
                    row.message = contactWrapper.message;
                    row.SubscriberStartDate = contactWrapper.startDate;
                    row.SubscriberEndDate = contactWrapper.endDate;
                    return row;
                });
                this.allErrors = this._rows.reduce((allErrors, row) => row.error && allErrors, true);
                console.log('UploadSubscribers:::this.allErrors:: ', this.allErrors);
                this.error = undefined;
            })
            .catch((error) => {
                let message = reduceErrors(error).reduce((prev, curr) => {
                    if (prev) return (prev + ", " + curr);
                    else return curr;
                }, '');
                console.log('UploadSubscribers::error::error: ', JSON.stringify(message));
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

    pushToZephr() {
        this.loading = true;
        pushToZephr({subscriptionId: this.recordId})
            .then((result) => {
                const event = new ShowToastEvent({
                    "title": "Success!",
                    "variant": "success",
                    "message": "Zephr Provisioning Started.",
                    "mode": "pester"
                });
                this.dispatchEvent(event);
            })
            .catch((error) => {
                const event = new ShowToastEvent({
                    "title": "Error!",
                    "variant": "error",
                    "message": "There was an error while starting Zephr Provisioning",
                    "mode": "pester"
                });
                this.dispatchEvent(event);
            }).finally(() => {
            this.loading = false;
            this.cancel();
        });
    }

    cancel() {
        if(this.showUploadTable) {
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