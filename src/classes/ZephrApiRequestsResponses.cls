/**
 * Contains strongly typed Zephr responses
 * https://support.zephr.com/admin-api
* @author Zoran Zunko
* @date 6/3/21
*
*/
global class ZephrApiRequestsResponses {
    global class CreateCompanyRequest {
        @InvocableVariable(Label = 'Company Name' Required = true Description = 'Name of the Company to be created in Zephr')
        global String name;
        @InvocableVariable(Label = 'Company Website' Required = true Description = 'Website associated to the Company to be created in Zephr')
        global String website;
        @InvocableVariable(Label = 'Tenant' Required = true Description = 'Zephr Tenant against which the Company will be created')
        global String tenant;
        @InvocableVariable(Label = 'Salesforce Id' Required = false)
        global String salesforceId;
    }

    global class CreateUserRequest {
        @InvocableVariable(Label = 'Salesforce Id' Required = false)
        public String salesforceId;
        @InvocableVariable(Label = 'First Name' Required = true)
        global String firstName;
        @InvocableVariable(Label = 'Last Name' Required = true)
        global String lastName;
        @InvocableVariable(Label = 'Email' Required = true)
        global String email;
        @InvocableVariable(Label = 'Company Name' Required = true)
        global String companyName;
        @InvocableVariable(Label = 'Salesforce Id Mapped' Required = true Description='Mapped Contact or Lead Id')
        global String salesforceIdMapped;
        @InvocableVariable(Label = 'Job Title' Required = false)
        global String jobTitle;
        @InvocableVariable(Label = 'City' Required = false)
        global String city;
        @InvocableVariable(Label = 'Country' Required = false)
        global String country;
        @InvocableVariable(Label = 'Company Type' Required = false)
        global String companyType;
        @InvocableVariable(Label = 'Start Date' Required = false)
        global Date startDate;
        @InvocableVariable(Label = 'Tenant Id' Required = true Description = 'Zephr Tenant')
        public String tenantId;
        @InvocableVariable(Label = 'Send password reset?'  Required = false Description = 'If true password reset email will be sent to the new user.')
        public Boolean sendPasswordReset;
        @InvocableVariable(Label = 'Zephr Website'  Required = false Description = 'The users password for this site will be reset.')
        public String websiteName;
        @InvocableVariable(Label = 'Confirm Contact Pref' Required = false)
        public Boolean confirmContactPref;//confirm-contact-pref
        @InvocableVariable(Label = 'Contact Preference Email' Required = false)
        public Boolean contactPreferenceEmail;//contact-preference-email
        @InvocableVariable(Label = 'Contact Preference Phone' Required = false)
        public Boolean contactPreferencePhone;//contact-preference-phone
        @InvocableVariable(Label = 'Contact Preference Post' Required = false)
        public Boolean contactPreferencePost;//contact-preference-post
        @InvocableVariable(Label = 'Telephone Number' Required = false)
        public String telephoneNumber;//telephone-number
        @InvocableVariable(Label = 'Accepted Terms And Conditions' Required = false)
        public Boolean termsAndConditions;//terms-and-conditions
        @InvocableVariable(Label = 'User Email Verified' Required = false)
        public Boolean emailVerified;//terms-and-conditions
        @InvocableVariable(Label = 'The Deal Alerts Timezone' Required = false)
        public String alertsTimezone;//terms-and-conditions
    }

    global class UpdateUserRequest {
        @InvocableVariable(Label = 'User Id from Zephr' Required = false Description = 'Zephr User Id')
        public String user_id;
        @InvocableVariable(Label = 'First Name' Required = false)
        global String firstName;
        @InvocableVariable(Label = 'Last Name' Required = false)
        global String lastName;
        @InvocableVariable(Label = 'Email' Required = false)
        global String email;
        @InvocableVariable(Label = 'Company Name' Required = false)
        global String companyName;
//        @InvocableVariable(Label = 'Salesforce Id' Required = true)
//        global String salesforceId;
        @InvocableVariable(Label = 'Job Title' Required = false)
        global String jobTitle;
        @InvocableVariable(Label = 'City' Required = false)
        global String city;
        @InvocableVariable(Label = 'Country' Required = false)
        global String country;
        @InvocableVariable(Label = 'State' Required = false)
        global String state;
        @InvocableVariable(Label = 'Postal Code' Required = false)
        global String postcodeZip;
        @InvocableVariable(Label = 'Street Address' Required = false)
        global String streetAddress;
        @InvocableVariable(Label = 'Company Type' Required = false)
        global String companyType;
        @InvocableVariable(Label = 'Start Date' Required = false)
        global Date startDate;
        @InvocableVariable(Label = 'Tenant Id' Required = true Description = 'Zephr Tenant')
        public String tenantId;
    }

    global class UpdateUserEmailRequest {
        @InvocableVariable(Label = 'User Id from Zephr' Required = true Description = 'Zephr User Id')
        public String user_id;
        @InvocableVariable(Label = 'Email' Required = true)
        global String email;
        @InvocableVariable(Label = 'Tenant Id' Required = true Description = 'Zephr Tenant')
        public String tenantId;
        @InvocableVariable(Label = 'Website Slug' Required = false)
        global String websiteSlug;
    }

    global class ResetUserPasswordRequest {
        @InvocableVariable(Label = 'Email' Required = true)
        global String email;
        @InvocableVariable(Label = 'Website Slug' Required = true)
        global String websiteSlug;
        @InvocableVariable(Label = 'Tenant Id' Required = true Description = 'Zephr Tenant')
        public String tenantId;
    }

    public class CreateUserGrantRequest {
        @InvocableVariable(Label = 'Tenant Id' Required = true Description = 'Zephr Tenant against which the Grant was created')
        public String tenantId;
        public String subTenantId;
        @InvocableVariable(Label = 'Message' Required = false Description = 'Zephr Status Message')
        public String message;
        @InvocableVariable(Label = 'API URI' Required = false Description = 'Zephr console api link to the record created.')
        public String uri;
        @InvocableVariable(Label = 'Salesforce Id' Required = false)
        public String salesforceId;
        @InvocableVariable(Label = 'Success' Required = false Description = 'If false error occurred')
        public Boolean success;

        @InvocableVariable(Label = 'Grant Id' Required = false Description = 'Zephr User Grant Id.')
        public String grant_id;
        @InvocableVariable(Label = 'User Id' Required = true Description = 'Id of the Zephr User for the grant')
        public String user_id;
        @InvocableVariable(Label = 'Entitlement Id' Required = true Description = 'Id of the Zephr Entitlement for the grant')
        public String entitlement_id;

//        public String start_time;
//        public String end_time;
        @InvocableVariable(Label = 'Grant Start Date' Required = true Description = 'Starting date of the Grant')
        public Date startTime;
        @InvocableVariable(Label = 'Grant End Date' Required = true Description = 'End date of the Grant')
        public Date endTime;
        @InvocableVariable(Label = 'Product Slug' Required = true Description = 'The Zephr Product Slug for this product')
        public String product_id;
    }
    //used for create/update and get responses
    global class Company {
        @InvocableVariable(Label = 'Tenant Id' Required = true Description = 'Zephr Tenant against which the Company was created')
        public String tenantId;
        public String subTenantId;
        @InvocableVariable(Label = 'Name' Required = true Description = 'Zephr Name')
        public String name;
        @InvocableVariable(Label = 'Message' Required = false Description = 'Zephr Status Message')
        public String message;
        @InvocableVariable(Label = 'API URI' Required = false Description = 'Zephr console api link to the record created.')
        public String uri;
        @InvocableVariable(Label = 'Success' Required = false Description = 'If false error occurred')
        public Boolean success;

        @InvocableVariable(Label = 'Company Id' Required = true Description = 'Zephr Id of the created company')
        public String company_id;
        @InvocableVariable(Label = 'Description' Required = false Description = 'Description of the created company')
        public String description;
        @InvocableVariable(Label = 'Salesforce Id' Required = false Description = 'Id of the corresponding Saleforce record')
        public String salesforceId;
        public String website;
        public String contact;
        public String account_manager;
    }
    public class Account {
        @InvocableVariable(Label = 'Tenant Id' Required = true Description = 'Zephr Tenant against which the Company was created')
        public String tenantId;
        public String subTenantId;
        @InvocableVariable(Label = 'Name' Required = true Description = 'Zephr Name')
        public String name;
        @InvocableVariable(Label = 'Message' Required = false Description = 'Zephr Status Message')
        public String message;
        @InvocableVariable(Label = 'API URI' Required = false Description = 'Zephr console api link to the record created.')
        public String uri;
        @InvocableVariable(Label = 'Salesforce Id' Required = false)
        public String salesforceId;
        @InvocableVariable(Label = 'Success' Required = false Description = 'If false error occurred')
        public Boolean success;

        @InvocableVariable(Label = 'Company Id' Required = true Description = 'Zephr Id of the associated Company')
        public String company_id;
        @InvocableVariable(Label = 'Account Id' Required = false Description = 'Zephr Id of the associated account')
        public String account_id;
        @InvocableVariable(Label = 'Number of Seats' Required = false Description = 'Number of seats for a subscription')
        public Integer number_of_seats;
        @InvocableVariable(Label = 'Allow Oversubscription' Required = false Description = 'true/false')
        public Boolean allow_oversubscription = false;
        public Boolean notify_when_account_oversubscribed;
        public Boolean notify_on_each_registration_when_account_is_oversubscribed;
        public String registration_code;
        public String ip_addresses;
        public String registration_domains;
        public String email_address;
    }

    //used for both account and user grants in Zephr
    public class Grant {
        @InvocableVariable(Label = 'Tenant Id' Required = true Description = 'Zephr Tenant against which the Grant was created')
        public String tenantId;
        public String subTenantId;
        @InvocableVariable(Label = 'Message' Required = false Description = 'Zephr Status Message')
        public String message;
        @InvocableVariable(Label = 'API URI' Required = false Description = 'Zephr console api link to the record created.')
        public String uri;
        @InvocableVariable(Label = 'Salesforce Id' Required = false)
        public String salesforceId;
        @InvocableVariable(Label = 'Success' Required = false Description = 'If false error occurred')
        public Boolean success;

        @InvocableVariable(Label = 'Grant Id' Required = false Description = 'Zephr Account Grant Id.')
        public String grant_id;
        @InvocableVariable(Label = 'Account Id' Required = true Description = 'Id of the Zephr Account for the grant')
        public String account_id;
        public String user_id;
        public String expiry_state;
        public String entitlement_type;
        @InvocableVariable(Label = 'Entitlement Id' Required = true Description = 'Id of the Zephr Entitlement for the grant')
        public String entitlement_id;

//        public String start_time;
//        public String end_time;
        @InvocableVariable(Label = 'Grant Start Date' Required = true Description = 'Starting date of the Grant')
        public Date startTime;
        @InvocableVariable(Label = 'Grant End Date' Required = true Description = 'End date of the Grant')
        public Date endTime;
        @InvocableVariable(Label = 'Product Slug' Required = true Description = 'The Zephr Product Slug for this product')
        public String product_id;
    }

    public class AccountUserGrant {
        @InvocableVariable(Label = 'Tenant Id' Required = true Description = 'Zephr Tenant against which the Grant was created')
        public String tenantId;
        public String subTenantId;
        @InvocableVariable(Label = 'Message' Required = false Description = 'Zephr Status Message')
        public String message;
        @InvocableVariable(Label = 'API URI' Required = false Description = 'Zephr console api link to the record created.')
        public String uri;
        @InvocableVariable(Label = 'Salesforce Id' Required = false)
        public String salesforceId;
        @InvocableVariable(Label = 'Success' Required = false Description = 'If false error occurred')
        public Boolean success;

        @InvocableVariable(Label = 'User Id' Required = true Description = 'Zephr user to create Account Grant for')
        public String user_id;
        @InvocableVariable(Label = 'User Type' Required = false Description = 'Type of the User')
        public String user_type;
        @InvocableVariable(Label = 'Account Id' Required = true Description = 'Zephr account to create Account Grant for')
        public String account_id;
        @InvocableVariable(Label = 'User Email' Required = false Description = 'Email of the User')
        public String user_email;
    }

    public class User {
        public User() {
            identifiers = new Map<String, String>();
            attributes = new Map<String, String>();
        }
        @InvocableVariable(Label = 'Salesforce Id' Required = false)
        public String salesforceId;
        @InvocableVariable(Label = 'Success' Required = false Description = 'If false error occurred')
        public Boolean success;
        @InvocableVariable(Label = 'Message' Required = false Description = 'Zephr Status Message')
        public String message;
        @InvocableVariable(Label = 'API URI' Required = false Description = 'Zephr console api link to the record created.')
        public String uri;

        //no tenant in response
        @InvocableVariable(Label = 'User Id from Zephr' Required = false Description = 'Zephr User Id')
        public String user_id;
        public Map<String, String> identifiers;
        public Map<String, String> attributes;
        public Boolean email_verified;
        @InvocableVariable(Label = 'Tracking Id from Zephr' Required = false Description = 'Zephr Tracking Id')
        public String tracking_id;
        public String registered;
        public String registration_state;
    }
    public class UserGrant {
        //no tenant in response
        public String user_id;
        public Map<String, String> identifiers;
        public Map<String, String> attributes;
        public String email_verified;
        public String tracking_id;
        public String registered;
        public String registration_state;
    }


}