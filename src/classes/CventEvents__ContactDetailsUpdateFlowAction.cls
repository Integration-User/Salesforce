/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ContactDetailsUpdateFlowAction {
    global ContactDetailsUpdateFlowAction() {

    }
    @InvocableMethod(label='Sync Opted-Out to Cvent' description='Method to update Cvent contact Opted-Out field value when the same contact exists in Cvent address book.')
    global static void synchronizeContactDetails(List<CventEvents.ContactDetailsUpdateFlowAction.ActionWrapper> actionWrappers) {

    }
global class ActionWrapper {
    @InvocableVariable(label='Salesforce Record' description='Provide the Salesforce record (Contact, Lead, or Person Account) you want the Opted-Out field value update to be sent for. Use "{!Record}" reference in case of the flow is initiated based on a record change.' required=true)
    global SObject sfRecord;
    global ActionWrapper() {

    }
}
}
