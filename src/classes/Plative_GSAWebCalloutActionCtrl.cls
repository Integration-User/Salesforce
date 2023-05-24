/**
* Company     : Plative
* Description : Controller apex class for generic lightning component Plative_GSAWebCalloutAction.cmp
* History     :
* [21.Feb.2020] Kunal - Code Creation
*/

public class Plative_GSAWebCalloutActionCtrl {

    //This method fetches the status whether the account or contact is active or inactive
    @AuraEnabled
    public Static String fetchSObjectStatus(String recordId,String actionType){
        String status;

        //Check if it's an account record
        if(recordId.startsWith('001')){
            Account accnt = [Select Id,Account_Status__c from Account where Id = :recordId];
            //Check if the action is to active or deactivate the record.
            if(actionType == 'activate'){
                status = String.isNotBlank(accnt.Account_Status__c) && accnt.Account_Status__c == 'Active' ? 'activate' : '';
            } else {
                status = (String.isNotBlank(accnt.Account_Status__c) && accnt.Account_Status__c == 'Inactive') || (String.isBlank(accnt.Account_Status__c)) ? 'deactivate' : '';
            }
        }

        //If not an Account record then it's a Contact record
        else {
            Contact cont = [Select Id,Name,AccountId,Contact_Status__c from Contact where Id = :recordId];

            //Check if the action is to reset the password for the contact(GSA Platform user)
            if(actionType == 'reset_password'){
                if(cont.Contact_Status__c == 'Active'){
                    status = 'activate';
                }
            }

            //Check if the action is to active or deactivate the record.
            else if(actionType == 'activate'){
                status = String.isNotBlank(cont.Contact_Status__c) && cont.Contact_Status__c == 'Active' ? 'activate' : '';
            } else {
                status = (String.isNotBlank(cont.Contact_Status__c) && cont.Contact_Status__c == 'Inactive') || (String.isBlank(cont.Contact_Status__c)) ? 'deactivate' : '';
            }
        }
        return status;
    }

    //This method gets a total count of activated contacts against an account
    @AuraEnabled
    public Static Integer fetchActiveContactCountAgainstAccount(String recordId){
        Integer count = [Select count() from Contact where AccountId = :recordId AND Contact_Status__c = 'Active'];
        return count;
    }

    //This method makes a callout to activate/deactivate the account/contact record or reset password for contact record(GSA Platform User)
    @AuraEnabled
    public Static String makeCallout(String recordId, String sObjectApiName, String actionType){
        String message = Plative_GSAWebCalloutUtility.makeCallout(recordId, sObjectApiName, actionType);
        return message;
    }

}