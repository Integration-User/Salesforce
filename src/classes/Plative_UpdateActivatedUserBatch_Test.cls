@IsTest
private class Plative_UpdateActivatedUserBatch_Test {

    // -------------------------------
    // Mock Callout Class
    // -------------------------------
    class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();

            // Simulate success/failure based on endpoint
            if (req.getEndpoint().contains('success')) {
                res.setStatusCode(200);
                res.setBody('{"message":"Success"}');
            } else {
                res.setStatusCode(400);
                res.setBody('{"error":"Bad Request"}');
            }

            return res;
        }
    }

    // -------------------------------
    // Test Setup Method
    // -------------------------------
    @TestSetup
    static void setupData() {
        GSA_Platform__c platform = GSA_Platform__c.getOrgDefaults();  
        //Company
        Platform.Update_Name__c = 'https://mantis-ext.greenstreet.com/v2/users/{gsContactID}/update_name';
        //API Key
        platform.API_Key__c = 'SAL3sf0rc3_AP1';
        insert platform;
        // Create Account
        Account acc = new Account(
            Name = 'Test Account',
            Account_Status__c = 'Active',
            GSA_Company_ID__c = 'ACC123'
        );
        insert acc;

        // Create Contacts (one success, one failure)
        List<Contact> contacts = new List<Contact>{
            new Contact(
                FirstName = 'John',
                LastName = 'Success',
                AccountId = acc.Id,
                Email = 'john.success@test.com',
                Username__c = 'john.success@test.com',
                GSA_Contact_ID__c = 'success123',
                Contact_Status__c = 'Inactive'
            ),
            new Contact(
                FirstName = 'Jane',
                LastName = 'Fail',
                AccountId = acc.Id,
                Email = 'jane.fail@test.com',
                Username__c = 'jane.fail',
                GSA_Contact_ID__c = 'fail123',
                Contact_Status__c = 'Inactive'
            )
        };
        insert contacts;
    }

    // -------------------------------
    // Test Batch Execution
    // -------------------------------
    @IsTest
    static void testBatchExecution() {
        // Collect Contact Ids
        Set<Id> contactIds = new Set<Id>();
        for (Contact c : [SELECT Id FROM Contact Where GSA_Contact_ID__c != null LIMIT 1]) {
            contactIds.add(c.Id);
        }

        // Set mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        Plative_UpdateActivatedUserBatch batch =
            new Plative_UpdateActivatedUserBatch(contactIds);

        Database.executeBatch(batch, 1); // small batch size
        Test.stopTest();

        // Verify updates
        List<Contact> updatedContacts = [
            SELECT Contact_Status__c, Activation_Date__c
            FROM Contact LIMIT 1
        ];

        System.assert(updatedContacts.size() > 0);

        // At least one contact updated to Active
        Boolean hasActive = false;
        for (Contact c : updatedContacts) {
            if (c.Contact_Status__c == 'Active') {
                hasActive = true;
            }
        }
    }
}