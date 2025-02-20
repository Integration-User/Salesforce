/**
* @author Zoran Zunko
* @date 6/10/21
*
*/
public with sharing class zephr_InvocableStartSubProvisioning {
    @InvocableMethod public static List<Boolean> startSubscriptionProvisioningQueueable(List<String> subscriptionIds) {
        zephr_QueueableProvisionSubscription queueableProvisionSubscription = new zephr_QueueableProvisionSubscription();
        queueableProvisionSubscription.subscriptionIds = subscriptionIds;
        System.enqueueJob(queueableProvisionSubscription);

        List<Boolean> response = new List<Boolean>();
        for (String subscriptionId : subscriptionIds) {
            response.add(true);
        }

        return response;
    }
}