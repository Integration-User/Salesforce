/**
 * @description Queueable job to synchronize Do Not Contact and Do Not Call fields
 * across contacts with duplicate email addresses.
 * 
 * This job should only execute in normal synchronous/async contexts, not in batch or future.
 */
public class SyncDuplicateContactDNCQueueable implements Queueable {
    
    private List<Id> contactIds;
    private Set<String> emailsToProcess;
    
    /**
     * @description Constructor
     * @param contactIds List of contact IDs that triggered the sync
     */
    public SyncDuplicateContactDNCQueueable(List<Id> contactIds) {
        this.contactIds = contactIds;
        this.emailsToProcess = new Set<String>();
    }
    
    /**
     * @description Execute the queueable job
     */
    public void execute(QueueableContext context) {     
        try {
            syncDuplicateEmailContacts();
        } catch (Exception ex) {
            System.debug('Error in SyncDuplicateContactDNCQueueable: ' + ex.getMessage());
            System.debug(ex.getStackTraceString());
        }
    }
    
    /**
     * @description Synchronize Do Not Contact and Do Not Call fields
     * across contacts with the same email address
     */
    private void syncDuplicateEmailContacts() {
        // Query the contacts that triggered the sync
        List<Contact> triggerContacts = [SELECT Id, Email, DoNotCall, HasOptedOutOfEmail  FROM Contact  WHERE Id IN :contactIds ];
        
        // Extract emails and desired field values from trigger contacts
        Map<String, Contact> sourceContactByEmail = new Map<String, Contact>();
        for (Contact contact : triggerContacts) {
            if (String.isNotBlank(contact.Email)) {
                String normalizedEmail = contact.Email.toLowerCase();
                emailsToProcess.add(normalizedEmail);
                sourceContactByEmail.put(normalizedEmail, contact);
            }
        }
        
        if (emailsToProcess.isEmpty()) {
            return;
        }
        
        // Query all contacts with these email addresses
        List<Contact> relatedContacts = [SELECT Id, Email, DoNotCall, HasOptedOutOfEmail FROM Contact WHERE Email IN :emailsToProcess ORDER BY Email];
        
        // Group contacts by email
        Map<String, List<Contact>> emailGroupMap = new Map<String, List<Contact>>();
        
        for (Contact contact : relatedContacts) {
            String email = contact.Email.toLowerCase();
            if (!emailGroupMap.containsKey(email)) {
                emailGroupMap.put(email, new List<Contact>());
            }
            emailGroupMap.get(email).add(contact);
        }
        
        // List to hold contacts that need updating
        List<Contact> contactsToUpdate = new List<Contact>();
         System.debug('emailGroupMap.keySet()->' + emailGroupMap.keySet());
        // Process each email group
        for (String email : emailGroupMap.keySet()) {
            List<Contact> emailGroup = emailGroupMap.get(email);
            System.debug('emailGroup->' + emailGroup);
            // Only process if there are multiple contacts with the same email
            if (emailGroup.size() > 1) {
                Contact sourceContact = sourceContactByEmail.get(email);
                
                if (sourceContact == null) {
                    continue;
                }
                
                // Sync both true and false values from the changed contact to duplicates.
                for (Contact contact : emailGroup) {
                    if (contact.DoNotCall != sourceContact.DoNotCall ||
                        contact.HasOptedOutOfEmail != sourceContact.HasOptedOutOfEmail) {
                        contactsToUpdate.add(new Contact( Id = contact.Id, DoNotCall = sourceContact.DoNotCall, HasOptedOutOfEmail = sourceContact.HasOptedOutOfEmail));
                    }
                }
            }
        }
        
        // Perform bulk update if there are contacts to update
        if (!contactsToUpdate.isEmpty()) {
            Plative_ContactTriggerHandler.isDNCcheck = true;
            Database.update(contactsToUpdate, false);
        }
    }
}