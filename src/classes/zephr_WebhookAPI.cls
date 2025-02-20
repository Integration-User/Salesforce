/**
* @author Zoran Zunko
* @date 8/30/21
*
*/

public without sharing class zephr_WebhookAPI {
    public abstract class BaseAPI {
        public String tenantId;
        public String subTenantId;
        public String type;
        public Long x_time;
        public String webhook;
    }

    public class TestEmails extends BaseAPI {
    }

    public class GeneralInformation extends BaseAPI {
    }

    public class GrantInformation extends BaseAPI {
        public GrantDetails details;
    }

    public class GrantDetails {
        public String tenantId;
        public String subTenantId;
        public String grant_id;
        public String user_id;
        public String expiry_state;
        public String entitlement_type;
        public String entitlement_id;
        public String product_id;
        public String start_time;
        public String end_time;

        public Date getStartTime() {
            if (String.isNotBlank(start_time)) {
                String timeString = start_time.split(' ')[0];
                String[] dateParts = timeString.split('-');
                return Date.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
            } else {
                return Date.today();
            }
        }

        // 2021-10-14 16:17:54
        public Date getEndTime() {
            if (String.isNotBlank(end_time)) {
                String timeString = end_time.split(' ')[0];
                String[] dateParts = timeString.split('-');
                return Date.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
            } else {
                return Date.today();
            }
        }

    }

    public class AccountGrantInformation extends BaseAPI {
        public AccountGrantDetails details;
    }

    public class AccountGrantDetails {
        public String tenantId;
        public String subTenantId;
        public String grant_id;
        public String account_id;
        public String expiry_state;
        public String entitlement_type;
        public String entitlement_id;
        public String product_id;
        public String start_time;
        public String end_time;

        public Date getStartTime() {
            if (String.isNotBlank(start_time)) {
                String timeString = start_time.split(' ')[0];
                String[] dateParts = timeString.split('-');
                return Date.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
            } else {
                return Date.today();
            }
        }

        // 2021-10-14 16:17:54
        public Date getEndTime() {
            if (String.isNotBlank(end_time)) {
                String timeString = end_time.split(' ')[0];
                String[] dateParts = timeString.split('-');
                return Date.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
            } else {
                return Date.today();
            }
        }

    }

    public class UserInformation extends BaseAPI {
        public UserDetails details;
    }

    public class EmailInformation extends BaseAPI {
        public EmailDetails details;
    }
    public class EmailDetails {
        public Identifiers identifiers;
        public Identifiers previous_identifiers;
        public String tracking_id;
    }
    public class AccountUserInformation extends BaseAPI {
        public AccountUserDetails details;
    }
    public class AccountUserDetails {
        public UserDetails accountUser;
        public Integer currentNumberOfUsers;
        public String accountId;
    }

    public class UserDetails {
        public String user_id;
        public Identifiers identifiers;
        public UserAttributes attributes;
        public String tenantId;
        public String subTenantId;
        public Boolean email_verified;
        public String tracking_id;
        //public Datetime registered;
        public String registration_state;

        public UserDetails() {
            this.attributes = new UserAttributes();
            this.identifiers = new Identifiers();
        }
    }

    public class Identifiers {
        public String email_address;

    }
    public class UserAttributes {
        public String first_name; //first-name
        public String last_name; //last-name
        public String company_name; //company-name
        public String company_type; //company-type
        public String organisation_type; //organisation-type
        public String salesforce_id; //salesforce_id
        public String job_title; //job-title
        public String city;
        public String country;
        public String start_date;
        public String confirm_contact_pref;//confirm-contact-pref
        public String contact_preference_email;//contact-preference-email
        public String contact_preference_phone;//contact-preference-phone
        public String contact_preference_post;//contact-preference-post
        public String telephone_number;//telephone-number
        public String terms_and_conditions;//terms-and-conditions
        public String seniority;
        public String telephone;
        //afj
        public String phone;
        //ij
        public String company;
        public String phone_number;
        //thedeal
        public String alerts_timezone;
    }

    public abstract class ObjectHandler {
        public virtual BaseAPI handleMethod(String jsonRequest, String method) {
            if (method == 'POST') {
                return handlePost(jsonRequest);
            } else if (method == 'PUT') {
                return handlePut(jsonRequest);
            } else if (method == 'DELETE') {
                return handleDelete(jsonRequest);
            } else {
                return null;
            }
        }
        public abstract BaseAPI handlePost(String jsonRequest);
        public abstract BaseAPI handlePut(String jsonRequest);
        public abstract BaseAPI handleDelete(String jsonRequest);
    }

    public class ZephrUserHandler extends ObjectHandler {
        public override BaseAPI handlePost(String jsonRequest) {
            System.debug(LoggingLevel.FINE, 'handlePost - jsonRequest: ' + jsonRequest);
            return processUserData(jsonRequest);
        }
        public override BaseAPI handlePut(String jsonRequest) {
            System.debug(LoggingLevel.FINE, 'handlePut - jsonRequest: ' + jsonRequest);
            return processUserData(jsonRequest);
        }
        public override BaseAPI handleDelete(String jsonRequest) {
            return null;
        }

        @TestVisible BaseAPI processUserData(String jsonRequest) {
            //Map<String, Object> tokenObjectMap = (Map<String, Object>) JSON.deserializeUntyped(jsonRequest);
            //Datetime dtRegistered = datetime.newinstance(long.valueOf(String.valueOf(tokenObjectMap.get('registered'))));
            //tokenObjectMap.put('registered', dtRegistered);
            ///jsonRequest = JSON.serialize(tokenObjectMap);

            UserInformation userInfo = (UserInformation) JSON.deserialize(jsonRequest.replace('first-name', 'first_name')
                    .replace('"last-name"', '"last_name"')
                    .replace('"company-name"', '"company_name"')//replacing this one due to uniform assignment below
                    .replace('"company"', '"company_name"')//replacing this one due to uniform assignment below
                    .replace('"company-type"', '"company_type"')
                    .replace('"organisation-type"', '"company_type"')
                    .replace('"job-title"', '"job_title"')
                    .replace('"confirm-contact-pref"', '"confirm_contact_pref"')
                    .replace('"contact-preference-email"', '"contact_preference_email"')
                    .replace('"contact-preference-phone"', '"contact_preference_phone"')
                    .replace('"contact-preference-post"', '"contact_preference_post"')
                    .replace('"telephone-number"', '"telephone_number"')
                    .replace('"phone-number"', '"telephone_number"')
                    .replace('"phone"', '"telephone_number"')
                    .replace('"terms-and-conditions"', '"terms_and_conditions"')
                    .replace('"alerts-timezone"', '"alerts_timezone"')
                    .replace('"true"', 'true')
                    , UserInformation.class);
            Zephr_User__c zephrUser = new Zephr_User__c();
            zephrUser.Zephr_Id__c = userInfo.details.user_id;
            zephrUser.Zephr_Tracking_Id__c = userInfo.details.tracking_id;
            zephrUser.Zephr_Tenant__c = userInfo.tenantId;
            zephrUser.Zephr_Integration_Status__c = 'Synced';
            zephrUser.Zephr_Integration_Message__c = 'Webhook';
            zephrUser.Zephr_Email__c = userInfo.details.identifiers.email_address;
            zephrUser.Zephr_Email_Verified__c = userInfo.details.email_verified;
            zephrUser.Zephr_First_Name__c = userInfo.details.attributes.first_name;
            zephrUser.Zephr_Last_Name__c = userInfo.details.attributes.last_name;
            zephrUser.Zephr_Company_Name__c = userInfo.details.attributes.company_name;
            zephrUser.Zephr_Company_Type__c = userInfo.details.attributes.company_type;
            zephrUser.Zephr_Country__c = CountryIsoCodeHelper.ReverseCountryIsoCodeHelper(userInfo.details.attributes.country).get('Name');
            zephrUser.Zephr_City__c = userInfo.details.attributes.city;
            zephrUser.Zephr_Telephone_Number__c = String.isBlank(userInfo.details.attributes.telephone) ? userInfo.details.attributes.telephone_number : userInfo.details.attributes.telephone;
            zephrUser.Zephr_Seniority__c = userInfo.details.attributes.seniority;
            zephrUser.Zephr_Job_Title__c = userInfo.details.attributes.job_title;
            zephrUser.Zephr_Confirm_Contact_Pref__c = (userInfo.details.attributes.confirm_contact_pref != null) && (Boolean.valueOf(userInfo.details.attributes.confirm_contact_pref));
            zephrUser.Zephr_Contact_Preference_Email__c = userInfo.details.attributes.contact_preference_email != null && (Boolean.valueOf(userInfo.details.attributes.contact_preference_email));
            zephrUser.Zephr_Contact_Preference_Phone__c = userInfo.details.attributes.contact_preference_phone != null && (Boolean.valueOf(userInfo.details.attributes.contact_preference_phone));
            zephrUser.Zephr_Contact_Preference_Post__c = userInfo.details.attributes.contact_preference_post != null && (Boolean.valueOf(userInfo.details.attributes.contact_preference_post));
            zephrUser.Zephr_Terms_and_Conditions__c = userInfo.details.attributes.terms_and_conditions != null && (Boolean.valueOf(userInfo.details.attributes.terms_and_conditions));

            List<Zephr_User__c> existingUsers = [SELECT Id, Zephr_Tenant__c, Email_Address__c, Zephr_Id__c FROM Zephr_User__c WHERE Zephr_Tenant__c = :zephrUser.Zephr_Tenant__c AND Zephr_Id__c = :zephrUser.Zephr_Id__c];
            //first we check for Zephr Id
            if (existingUsers.size() == 1) {
                zephrUser.Id = existingUsers[0].Id;
                update zephrUser;
            } else {
                existingUsers = [SELECT Id, Zephr_Tenant__c, Email_Address__c, Zephr_Id__c FROM Zephr_User__c WHERE Zephr_Tenant__c = :zephrUser.Zephr_Tenant__c AND Email_Address__c = :zephrUser.Zephr_Email__c];
                if (existingUsers.isEmpty()) {
                    upsert zephrUser Zephr_Id__c;
                } else if (existingUsers.size() == 1) {
                    zephrUser.Id = existingUsers[0].Id;
                    update zephrUser;
                    //that if we have more than one matching in the database?
                } else {
                    //check to see if one has a mtching external id
                    for (Zephr_User__c existingUser : existingUsers) {
                        if (existingUser.Zephr_Id__c == zephrUser.Zephr_Id__c) {
                            zephrUser.Id = existingUser.Id;
                            update zephrUser;
                            break;
                        }
                    }
                    //no matching external ids that any one that has no external id
                    if (zephrUser.Id == null) {
                        for (Zephr_User__c existingUser : existingUsers) {
                            if (existingUser.Zephr_Id__c == null) {
                                zephrUser.Id = existingUser.Id;
                                update zephrUser;
                                break;
                            }
                        }
                    }
                }
            }

            return userInfo;
        }
    }
    public class UserEmailConfirmedHandler extends ObjectHandler {
        public override BaseAPI handleDelete(String jsonRequest) {
            return null;
        }

        public override BaseAPI handlePost(String jsonRequest) {
            return null;
        }

        public override BaseAPI handlePut(String jsonRequest) {
            UserInformation userInfo = (UserInformation) JSON.deserialize(jsonRequest, UserInformation.class);
            Zephr_User__c zephrUser = new Zephr_User__c();
            zephrUser.Zephr_Id__c = userInfo.details.user_id;
            zephrUser.Zephr_Tenant__c = userInfo.tenantId;
            zephrUser.Zephr_Integration_Status__c = 'Synced';
            zephrUser.Zephr_Email_Verified__c = true;

            upsert zephrUser Zephr_Id__c;

            return userInfo;
        }
    }

    public class UserEmailChangeHandler extends ObjectHandler {
        public override BaseAPI handlePost(String jsonRequest) {
            return null;
        }

        public override BaseAPI handleDelete(String jsonRequest) {
            return null;
        }

        public override BaseAPI handlePut(String jsonRequest) {
            EmailInformation emailInfo = (EmailInformation) JSON.deserialize(jsonRequest, EmailInformation.class);
            Zephr_User__c zephrUser = [SELECT Zephr_Email__c, Zephr_Email_Verified__c FROM Zephr_User__c WHERE Zephr_Tenant__c = :emailInfo.tenantId AND Zephr_Email__c = :emailInfo.details.previous_identifiers.email_address];

            zephrUser.Zephr_Email__c = emailInfo.details.identifiers.email_address;
            zephrUser.Zephr_Email_Verified__c = false;

            update zephrUser;

            return emailInfo;
        }
    }

    public class GrantCreatedHandler extends ObjectHandler {
        public override BaseAPI handlePost(String jsonRequest) {
            GrantInformation grantInfo = (GrantInformation) JSON.deserialize(jsonRequest, GrantInformation.class);

            List<Zephr_User_Grant__c> userGrants = [SELECT Id FROM Zephr_User_Grant__c WHERE Zephr_Id__c = :grantInfo.details.grant_id];
            if (userGrants.isEmpty()) {
                Savepoint sPoint = Database.setSavepoint();
                try {
                    List<Zephr_User__c> zephrUsers = [
                            SELECT
                                    Id,
                                    Lead__c,
                                    Contact__c,
                                    Zephr_Id__c,
                                    Zephr_Tenant__c,
                                    Zephr_Email__c,
                                    Zephr_Email_Verified__c,
                                    Zephr_First_Name__c,
                                    Zephr_Last_Name__c,
                                    Zephr_Company_Name__c,
                                    Zephr_Company_Type__c,
                                    Zephr_Country__c,
                                    Zephr_City__c,
                                    Zephr_Job_Title__c,
                                    Zephr_Confirm_Contact_Pref__c,
                                    Zephr_Contact_Preference_Email__c,
                                    Zephr_Contact_Preference_Phone__c,
                                    Zephr_Contact_Preference_Post__c,
                                    Zephr_Telephone_Number__c,
                                    Zephr_Seniority__c,
                                    Zephr_Terms_and_Conditions__c
                            FROM Zephr_User__c
                            WHERE Zephr_Id__c = :grantInfo.details.user_id AND Zephr_Tenant__c = :grantInfo.tenantId
                    ];

                    List<Product2> grantedProducts = [SELECT Id, Free_Trial_Duration__c, Primary_Brand__c, Primary_Brand_Group__c, Primary_Business_Unit__c, Campaign__c FROM Product2 WHERE (Zephr_Product_Slug__c = :grantInfo.details.product_id OR ZephrEntitlementId__c = :grantInfo.details.entitlement_id ) AND Zephr_Tenant__c = :grantInfo.tenantId];

                    if (grantedProducts.isEmpty()) {
                        ObjectHandlerException ohEx = new ObjectHandlerException();
                        ohEx.setMessage('Zephr Product not existing');
                        throw ohEx;
                    }

                    if (zephrUsers.isEmpty()) {
                        return null;
                    }

                    Set<String> testEmailAddresses = getZephrTestEmails();

                    if (testEmailAddresses.contains(zephrUsers[0].Zephr_Email__c)) {
                        return new TestEmails();
                    }

                    Subscription__c subscription = new Subscription__c();
                    subscription.Type__c = 'Individual';
                    subscription.Status__c = 'Trial';
                    subscription.Number_of_Seats__c = 1;
                    insert subscription;

                    Subscription_Product__c subscriptionProduct = new Subscription_Product__c();
                    subscriptionProduct.Start_Date__c = grantInfo.details.getStartTime();
                    subscriptionProduct.End_Date__c = grantInfo.details.getEndTime();
                    subscriptionProduct.Product__c = grantedProducts[0].Id;
                    subscriptionProduct.Subscription__c = subscription.Id;

                    Subscription_User__c subscriptionUser = new Subscription_User__c();
                    subscriptionUser.Subscription_NG__c = subscription.Id;
                    if (zephrUsers[0].Contact__c != null) {
                        subscriptionUser.Contact__c = zephrUsers[0].Contact__c;
                    }

                    //create a new Lead - new trial added
                    Lead newLead = new Lead();
                    newLead.FirstName = zephrUsers[0].Zephr_First_Name__c;
                    newLead.LastName = zephrUsers[0].Zephr_Last_Name__c;
                    newLead.Company = zephrUsers[0].Zephr_Company_Name__c;
                    newLead.Email = zephrUsers[0].Zephr_Email__c;
                    newLead.Company_Type__c = zephrUsers[0].Zephr_Company_Type__c;
                    newLead.Seniority__c = zephrUsers[0].Zephr_Seniority__c;
                    newLead.Phone = zephrUsers[0].Zephr_Telephone_Number__c;
                    newLead.Title = zephrUsers[0].Zephr_Job_Title__c;
                    newLead.Country = zephrUsers[0].Zephr_Country__c;
                    newLead.Primary_Business_Unit__c = grantedProducts[0].Primary_Business_Unit__c;
                    newLead.Primary_Brand__c = grantedProducts[0].Primary_Brand__c;
                    newLead.Primary_Brand_Group__c = grantedProducts[0].Primary_Brand_Group__c;
                    insert newLead;
                    zephrUsers[0].Lead__c = newLead.Id;
                    update zephrUsers[0];
                    subscriptionUser.Lead__c = newLead.Id;
                    insert new List<SObject>{
                            subscriptionProduct, subscriptionUser
                    };

                    if(grantedProducts[0].Campaign__c != null) {
                        CampaignMember campaignMember = new CampaignMember();
                        campaignMember.LeadId = newLead.Id;
                        campaignMember.CampaignId = grantedProducts[0].Campaign__c;
                        insert campaignMember;
                    }

                    Zephr_User_Grant__c userGrant = new Zephr_User_Grant__c();
                    userGrant.Zephr_User__c = zephrUsers[0].Id;
                    userGrant.Zephr_Tenant__c = grantInfo.tenantId;
                    userGrant.Product__c = subscriptionProduct.Product__c;
                    userGrant.Zephr_Id__c = grantInfo.details.grant_id;
                    userGrant.Subscription__c = subscription.Id;
                    userGrant.Subscription_User__c = subscriptionUser.Id;
                    userGrant.Zephr_Integration_Status__c = 'Synced';
                    userGrant.Zephr_Integration_Message__c = 'Webhook';
                    userGrant.Start_Date__c = grantInfo.details.getStartTime();
                    userGrant.End_Date__c = grantInfo.details.getEndTime();

                    insert userGrant;

                    subscriptionUser.Zephr_User_Grant__c = userGrant.Id;
                    update subscriptionUser;
                } catch (Exception ex) {
                    System.debug(LoggingLevel.ERROR, ex.getMessage() + ' - ' + ex.getStackTraceString());
                    Database.rollback(sPoint);
                    return null;
                }
            }
            return grantInfo;
        }

        public override BaseAPI handlePut(String jsonRequest) {
            return null;
        }

        public override BaseAPI handleDelete(String jsonRequest) {
            return null;
        }
    }

    public static Set<String> getZephrTestEmails() {
        Set<String> testEmailAddresses = new Set<String>();
        for (Zephr_Test_Emails__mdt ztm : [SELECT Email__c FROM Zephr_Test_Emails__mdt]) {
            testEmailAddresses.add(ztm.Email__c);
        }
        return testEmailAddresses;
    }

    public class AccountGrantCreatedHandler extends ObjectHandler {
        public override BaseAPI handlePost(String jsonRequest) {
            AccountGrantInformation accountGrantInformation = (AccountGrantInformation) JSON.deserialize(jsonRequest, AccountGrantInformation.class);
            List<Zephr_Account_Grant__c> accountGrants = [SELECT Id FROM Zephr_Account_Grant__c WHERE Zephr_Id__c = :accountGrantInformation.details.grant_id];
            if (accountGrants.isEmpty()) {
                List<Zephr_Account__c> zephrAccounts = [SELECT Id, Subscription__c, Number_of_Seats__c FROM Zephr_Account__c WHERE Zephr_Id__c = :accountGrantInformation.details.account_id AND Zephr_Tenant__c = :accountGrantInformation.tenantId];
                List<Product2> grantedProducts = [SELECT Id, Free_Trial_Duration__c, Primary_Brand__c, Primary_Brand_Group__c, Primary_Business_Unit__c FROM Product2 WHERE (Zephr_Product_Slug__c = :accountGrantInformation.details.product_id OR ZephrEntitlementId__c = :accountGrantInformation.details.entitlement_id) AND Zephr_Tenant__c = :accountGrantInformation.tenantId];
                if (zephrAccounts.isEmpty()) {
                    ObjectHandlerException ohEx = new ObjectHandlerException();
                    ohEx.setMessage('Zephr Account not existing');
                    throw ohEx;
                }
                if (grantedProducts.isEmpty()) {
                    ObjectHandlerException ohEx = new ObjectHandlerException();
                    ohEx.setMessage('Zephr Product not existing');
                    throw ohEx;
                }

                Subscription_Product__c subscriptionProduct = new Subscription_Product__c();
                subscriptionProduct.Start_Date__c = accountGrantInformation.details.getStartTime();
                subscriptionProduct.End_Date__c = accountGrantInformation.details.getEndTime();
                subscriptionProduct.Product__c = grantedProducts[0].Id;
                subscriptionProduct.Subscription__c = zephrAccounts[0].Subscription__c;
                insert new List<SObject>{
                        subscriptionProduct
                };
            }
            return accountGrantInformation;
        }


        public override BaseAPI handlePut(String jsonRequest) {
            return null;
        }

        public override BaseAPI handleDelete(String jsonRequest) {
            return null;
        }
    }

    public class UserAccountGrantCreatedHandler extends ObjectHandler {
        public override BaseAPI handlePost(String jsonRequest) {
            AccountUserInformation accountGrantInformation = (AccountUserInformation) JSON.deserialize(jsonRequest, AccountUserInformation.class);
            List<Zephr_User_Account_Grant__c> zephrUserAccountGrants = [SELECT Id, Subscription_User__c FROM Zephr_User_Account_Grant__c WHERE Zephr_Account__r.Zephr_Id__c = :accountGrantInformation.details.accountId AND Zephr_User__r.Zephr_Id__c = :accountGrantInformation.details.accountUser.user_id];
//            System.debug(LoggingLevel.ERROR, 'handlePost - : ' + zephrUserAccountGrants[0]?.Id);
            if (zephrUserAccountGrants.isEmpty()) {
                List<Zephr_Account__c> zephrAccounts = [SELECT Id, Subscription__c, Number_of_Seats__c, Subscription__r.Account__c, Subscription__r.Zephr_Signup_Enabled__c, Subscription__r.End_Date__c FROM Zephr_Account__c WHERE Zephr_Id__c = :accountGrantInformation.details.accountId AND Zephr_Tenant__c = :accountGrantInformation.tenantId];
                List<Zephr_User__c> zephrUsers = [SELECT Id, Contact__c, Lead__c, Lead__r.Email, Zephr_Email__c, Zephr_First_Name__c, Zephr_Last_Name__c FROM Zephr_User__c WHERE Zephr_Id__c = :accountGrantInformation.details.accountUser.user_id AND Zephr_Tenant__c = :accountGrantInformation.tenantId];
                if (zephrAccounts.isEmpty()) {
                    ObjectHandlerException ohEx = new ObjectHandlerException();
                    ohEx.setMessage('Zephr Account does not exist - ' + accountGrantInformation.details.accountId);
                    throw ohEx;
                }
                //sequence is user/account grant/user grant
                //user grant creates a lead so we will try to wait for it
                if (zephrUsers.isEmpty()) {
                    // ObjectHandlerException ohEx = new ObjectHandlerException();
                    // ohEx.setMessage('Zephr User does not exist - ' + accountGrantInformation.details.accountUser.user_id);
                    // throw ohEx;
                    // We return null which forces zephr_WebHookServer to retry processing the webhook as a queueable
                    return null;
                }

                Set<String> testEmailAddresses = getZephrTestEmails();

                if (testEmailAddresses.contains(zephrUsers[0].Zephr_Email__c)) {
                    return new TestEmails();
                }
                
                if (zephrUsers[0].Lead__c == null && zephrUsers[0].Contact__c == null) {
                    if (zephrAccounts[0].Subscription__c != null && zephrAccounts[0].Subscription__r.Zephr_Signup_Enabled__c == TRUE) {
                        zephrUsers[0].Contact__c = ZephrUserContactMatcher.createMatchingContact(zephrUsers[0], zephrAccounts[0]);
                        update zephrUsers[0];
                    }
                    else {
                        ObjectHandlerException ohEx = new ObjectHandlerException();
                        ohEx.setMessage('Zephr User is not linked to an existing Contact and Zephr signup is not enabled for this Zephr subscription');
                        throw ohEx;
                    }
                }

                Subscription_User__c newSubscriptionUser = new Subscription_User__c();
                newSubscriptionUser.Lead__c = zephrUsers[0].Lead__c;
                newSubscriptionUser.Contact__c = zephrUsers[0].Contact__c;
                newSubscriptionUser.Subscription_NG__c = zephrAccounts[0].Subscription__c;
                newSubscriptionUser.Subscriber_Start_Date__c = Datetime.now();
                newSubscriptionUser.Subscriber_End_Date__c = zephrAccounts[0].Subscription__r.End_Date__c;
                newSubscriptionUser.Subscriber_Status__c = 'Active';
                insert newSubscriptionUser;

                Zephr_User_Account_Grant__c zephrUserAccountGrant = new Zephr_User_Account_Grant__c();
                zephrUserAccountGrant.Zephr_User__c = zephrUsers[0].Id;
                zephrUserAccountGrant.Zephr_Account__c = zephrAccounts[0].Id;
                zephrUserAccountGrant.Zephr_Integration_Status__c = 'Synced';
                zephrUserAccountGrant.Zephr_Integration_Message__c = 'Webhook';
                zephrUserAccountGrant.Subscription_User__c = newSubscriptionUser.Id;
                insert zephrUserAccountGrant;

                if (zephrUsers[0].Lead__c != null && zephrUsers[0].Contact__c == null) {
                    List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :zephrAccounts[0].Subscription__r.Account__c AND Email = :zephrUsers[0].Zephr_Email__c];
                    Database.LeadConvert lc = new Database.LeadConvert();
                    lc.setLeadId(zephrUsers[0].Lead__c);
                    lc.setDoNotCreateOpportunity(true);
                    lc.setAccountId(zephrAccounts[0].Subscription__r.Account__c);
                    lc.setConvertedStatus('Converted');
                    if (!contacts.isEmpty()) {
                        lc.setContactId(contacts[0].Id);
                    }
                    Database.LeadConvertResult lcr = Database.convertLead(lc);
                }
            }
            return accountGrantInformation;
        }


        public override BaseAPI handlePut(String jsonRequest) {
            return null;
        }

        public override BaseAPI handleDelete(String jsonRequest) {
            AccountUserInformation accountGrantInformation = (AccountUserInformation) JSON.deserialize(jsonRequest, AccountUserInformation.class);
            // DR 2022-09-14 Set subscriber status to inactive rather than deleting them
            // delete [SELECT Id FROM Subscription_User__c WHERE Zephr_User_Account_Grant__r.Zephr_Account__r.Zephr_Id__c = :accountGrantInformation.details.accountId AND Zephr_User_Account_Grant__r.Zephr_User__r.Zephr_Id__c = :accountGrantInformation.details.accountUser.user_id];

            List<Subscription_User__c> subscriptionUser = [SELECT Id, Subscriber_Status__c, Subscriber_End_Date__c FROM Subscription_User__c WHERE Zephr_User_Account_Grant__r.Zephr_Account__r.Zephr_Id__c = :accountGrantInformation.details.accountId AND Zephr_User_Account_Grant__r.Zephr_User__r.Zephr_Id__c = :accountGrantInformation.details.accountUser.user_id LIMIT 1];

            if (subscriptionUser != null && !subscriptionUser.isEmpty() && subscriptionUser[0].Subscriber_Status__c == 'Active') {
                subscriptionUser[0].Subscriber_End_Date__c = DateTime.now();
                subscriptionUser[0].Subscriber_Status__c = 'Inactive';
                Database.update(subscriptionUser);
            }
            delete [SELECT Id FROM Zephr_User_Account_Grant__c WHERE Zephr_Account__r.Zephr_Id__c = :accountGrantInformation.details.accountId AND Zephr_User__r.Zephr_Id__c = :accountGrantInformation.details.accountUser.user_id];
            return accountGrantInformation;
        }
    }


    public class ObjectHandlerException extends Exception {

    }
}