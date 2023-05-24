public class UpdateContactOwner {
    @InvocableMethod(label='Update Contact Owner From Account' description='Return Boolean' category='Contact')
    public static List<UpdateContactOwnerOutput> updateContactsOwnerForAccount(List<UpdateContactOwnerInput> inputs) {
        List<UpdateContactOwnerOutput> listOutput = new List<UpdateContactOwnerOutput>();

        if (!inputs.isEmpty() && inputs[0].accountId != null && inputs[0].ownerId != null) {
            UpdateContactOwnerOutput output = new UpdateContactOwnerOutput();
            try {
                List<Contact> updateConList = new List<Contact>();
                for (Contact con : [Select Id, OwnerId FROM Contact Where AccountId =: inputs[0].accountId 
                                    AND Contact_Account_Owners_Match__c = FALSE 
                                    AND (NOT owner.userRole.Name LIKE '%Advisory%')]) {
                                        con.OwnerId = inputs[0].ownerId;
                                        updateConList.add(con);                             
                                    }
                System.debug('updateConList-->'+updateConList.size()); 
                if (!updateConList.isEmpty() && updateConList.size() > 0) update updateConList;   
                output.result = 'Successfully Updated';
            } catch(Exception e) {
               System.debug('Exception-->'+e.getMessage()); 
                output.result = 'Failed';
            }
            listOutput.add(output);
        }
        return listOutput;
    }
    public class UpdateContactOwnerInput{
        @InvocableVariable(required=true)
        Public String accountId;
        @InvocableVariable(required=true)
        Public String ownerId;
    }
    public class UpdateContactOwnerOutput{
        @InvocableVariable
        public String result;
    }
}