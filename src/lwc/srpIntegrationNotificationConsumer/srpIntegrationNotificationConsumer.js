/**
 * Created by zoran on 05/12/2022.
 */

import {LightningElement, api} from "lwc";
import {
    subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled,
} from "lightning/empApi";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import Id from '@salesforce/user/Id';

const SRP_INTEGRATION_STATUS = {
    'Success': 'success',
    'Error': 'error'
}
export default class SrpIntegrationNotificationConsumer extends LightningElement {
    @api recordId;
    userId = Id;
    channelName = '/event/SRP_Integration_Event__e';
    subscription = {};

    connectedCallback() {
        // Register error listener
        this.registerErrorListener();
        this.handleSubscribe();
    }

    registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            console.error('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }

    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const thisReference = this;
        const messageCallback = function (response) {
            console.log('New message received 1: ', JSON.stringify(response));
            console.log('New message received 2: ', response);

            var obj = JSON.parse(JSON.stringify(response));
            console.log('New message received 4: ', obj.data.payload.Message__c);
            console.log('New message received 5: ', thisReference.channelName);
            console.log('messageCallback::messageCallback::thisReference.recordId: ', thisReference.recordId);
            console.log('messageCallback::messageCallback::obj.data.payload.Subscription_ID__c: ', obj.data.payload.Subscription_Id__c);
            console.log('messageCallback::messageCallback::thisReference.userId: ', thisReference.userId);
            console.log('messageCallback::messageCallback::obj.data.payload.User_Id__c: ', obj.data.payload.User_Id__c);
            if ((thisReference.recordId === obj.data.payload.Subscription_Id__c) && (thisReference.userId.indexOf(obj.data.payload.User_Id__c) != -1)) {
                console.log('messageCallback::messageCallback::thisReference[obj.data.payload.Status__c]: ', thisReference[obj.data.payload.Status__c]);
                const evt = new ShowToastEvent({
                    title: obj.data.payload.Status__c,
                    message: obj.data.payload.Message__c,
                    variant: SRP_INTEGRATION_STATUS[obj.data.payload.Status__c],
                    mode: "sticky",
                });

                thisReference.dispatchEvent(evt);
            }
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(thisReference.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('SrpIntegrationNotificationConsumer::response::: ', JSON.stringify(response));
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }
}