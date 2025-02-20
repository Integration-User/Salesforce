/**
* @author Zoran Zunko
* @date 6/4/21
*
*/

public with sharing class zephr_InvocableCreateUser {
    //todo refactor to allow for all the attributes in zephr
    //write a doc with a how to add new attribute and post to confluence.
    @InvocableMethod public static List<ZephrApiRequestsResponses.User> createZephrUser(List<ZephrApiRequestsResponses.CreateUserRequest> userRequests) {
        List<ZephrApiRequestsResponses.User> response = new List<ZephrApiRequestsResponses.User>();

        try {
            Map<String, ZephrIntegrationNG> zephrIntegrationsByTenantMap = new Map<String, ZephrIntegrationNG>();

            for (ZephrApiRequestsResponses.CreateUserRequest userRequest : userRequests) {
                ZephrApiRequestsResponses.User userResponse = new ZephrApiRequestsResponses.User();
                userResponse.message = 'ERROR';
                userResponse.success = false;
                userResponse.salesforceId = userRequest.salesforceId;

                if (!zephrIntegrationsByTenantMap.containsKey(userRequest.tenantId)) {
                    zephrIntegrationsByTenantMap.put(userRequest.tenantId, new ZephrIntegrationNG(userRequest.tenantId));
                }

                ZephrIntegrationNG zephr = zephrIntegrationsByTenantMap.get(userRequest.tenantId);

                try {
                    Map<String, String> isoCode;
                    try {
                        isoCode = CountryIsoCodeHelper.CountryIsoCodeHelper(userRequest.country);
                    } catch (Exception ex) {
                        System.debug(LoggingLevel.FINE, ex.getMessage() + ' - ' + ex.getStackTraceString());
                    }
                    if (isoCode == null) {
                        userResponse.message = userRequest.country + ' not found in the country metadata map. Please fix and then try again';
                    } else if (String.isBlank(userRequest.email)) {
                        userResponse.message = 'No Email address provided. Please fix and then try again';
                    } else {
                        //first we check if user exists
                        HttpResponse res = zephr.getUserByEmail(userRequest.email);
                        if (res.getStatusCode() == 200) {
                            userResponse = (ZephrApiRequestsResponses.User) JSON.deserialize(res.getBody(), ZephrApiRequestsResponses.User.class);
                            userResponse.success = true;
                            userResponse.salesforceId = userRequest.salesforceId;
                            userResponse.message = 'User successfully found in Zephr - using existing user id.';
                        }
                        //if not then create user
                        else {
                            zephr_WebhookAPI.UserDetails userDetails = new zephr_WebhookAPI.UserDetails();
                            userDetails.identifiers.email_address = userRequest.email;
                            userDetails.attributes.first_name = userRequest.firstName;
                            userDetails.attributes.last_name = userRequest.lastName;
                            userDetails.attributes.country = isoCode.get('2Fig');
// DR - Removed 2021-12-01 because pushing invalid data to Zephr causes sync issues, and values are different between tenants
                            // userDetails.attributes.company_type = userRequest.companyType;
                            userDetails.attributes.job_title = userRequest.jobTitle;
                            userDetails.attributes.terms_and_conditions = String.valueOf(userRequest.termsAndConditions);
                            userDetails.email_verified = userRequest?.emailVerified;

                            Set<String> companyTypeValues = ZephrCompanyTypeValuesManager.getZephrCompanyTypeValues().get(userRequest.tenantId);
                            String companyTypeValue =
                                    companyTypeValues == null ? null : (companyTypeValues.isEmpty() ? userRequest.companyType : (companyTypeValues.contains(userRequest.companyType) ? userRequest.companyType : null));
                            if (userRequest.tenantId == 'euromoney') {
                                userDetails.attributes.organisation_type = companyTypeValue;
                            } else {
                                userDetails.attributes.company_type = companyTypeValue;
                            }

                            if (userRequest.tenantId == 'ij') {
                                userDetails.attributes.company = userRequest.companyName;
                                userDetails.attributes.phone_number = userRequest.telephoneNumber;
                            } else if (userRequest.tenantId == 'thedeal') {
                                userDetails.attributes.company_name = userRequest.companyName;
                                userDetails.attributes.phone_number = userRequest.telephoneNumber;
                                //if it's not set default to EST
                                userDetails.attributes.alerts_timezone = String.isBlank(userRequest.alertsTimezone) ? '21' : userRequest.alertsTimezone;
                            } else if (userRequest.tenantId == 'afj') {
                                userDetails.attributes.company = userRequest.companyName;
                                userDetails.attributes.phone = userRequest.telephoneNumber;
                                userDetails.attributes.terms_and_conditions = null;
                            } else if (userRequest.tenantId == 'lmg') {
                                userDetails.attributes.company = userRequest.companyName;
                                userDetails.attributes.phone_number = userRequest.telephoneNumber;
                                userDetails.attributes.terms_and_conditions = null;
                            } else if (userRequest.tenantId == 'der-gig') {
                                userDetails.attributes.company_name = userRequest.companyName;
                                userDetails.attributes.telephone_number = userRequest.telephoneNumber;
                                userDetails.attributes.terms_and_conditions = null;
                            } else if (userRequest.tenantId == 'der-td') {
                                userDetails.attributes.company_name = userRequest.companyName;
                                userDetails.attributes.telephone_number = userRequest.telephoneNumber;
                                userDetails.attributes.terms_and_conditions = null;
                            } else {
                                userDetails.attributes.city = userRequest.city;
                                userDetails.attributes.company_name = userRequest.companyName;
                                userDetails.attributes.confirm_contact_pref = String.valueOf(userRequest.confirmContactPref);
                                userDetails.attributes.contact_preference_email = String.valueOf(userRequest.contactPreferenceEmail);
                                userDetails.attributes.contact_preference_phone = String.valueOf(userRequest.contactPreferencePhone);
                                userDetails.attributes.contact_preference_post = String.valueOf(userRequest.contactPreferencePost);
                                userDetails.attributes.telephone_number = userRequest.telephoneNumber;
                                userDetails.attributes.start_date = String.valueOf(userRequest.startDate);
                            }
                            res = zephr.createUser(userDetails);

                            if (res.getStatusCode() == 201) {
                                userResponse = (ZephrApiRequestsResponses.User) JSON.deserialize(res.getBody(), ZephrApiRequestsResponses.User.class);
                                userResponse.success = true;
                                userResponse.salesforceId = userRequest.salesforceId;
                                if (userRequest?.sendPasswordReset) {
                                    res = zephr.sendResetPassword(userRequest.email, userRequest.tenantId + '|' + userRequest.websiteName);
                                    if (res.getStatusCode() == 201 || res.getStatusCode() == 200) {
                                        userResponse.message = 'User created successfully and password reset link sent.';
                                    } else {
                                        userResponse.message = 'User created successfully but password reset link was not sent.';
                                    }
                                } else {
                                    userResponse.message = 'User created successfully but password reset link was not required.';
                                }
                            } else {
                                userResponse.message = res.getBody();
                            }
                        }
                    }
                } catch (Exception ex) {
                    System.debug(LoggingLevel.ERROR, ex.getMessage() + ' - ' + ex.getStackTraceString());
                    userResponse.message = ex.getMessage() + ' - ' + ex.getStackTraceString();
                }
                response.add(userResponse);
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + ' - ' + ex.getStackTraceString());
//            ZephrIntegrationService.publishErrorEvent(UserInfo.getUserName(), ex.getStackTraceString(), ex.getMessage(), 'zephr_InvocableCreateUser - non network error');
        }
        return response;
    }
}