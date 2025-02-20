/**
 * Created by david on 17/06/2021.
 */

// TODO Should be merged with ZephrIntegration once code is stable. Forked to prevent code overwrites.

public with sharing class ZephrIntegrationNG {

    String secretKey;
    String accessKey;
    public String baseUrl {
        get {
            return ('https://' + zephrTenant + '.api.zephr.com');
        }
    }
    public Boolean testCallout;
    public String zephrTenant;
    
    public Integer zephrDelayTime = Integer.valueOf(System.Label.NextGen_Zephr_Grant_Start_Delay);

    public ZephrIntegrationNG(String zephrTenant) {
        // query custom metadata types to get secret ket and access key
        // get urlPath as parameter
        this.zephrTenant = String.isNotBlank(zephrTenant) ? zephrTenant.toLowerCase() : zephrTenant;

        String queryString = 'SELECT Id, AccessKey__c, SecretKey__c FROM ZephrSettings__mdt WHERE Type__c = \'API Access\'';
        if (!String.isBlank(this.zephrTenant)) {
            queryString += ' AND ZephrTenant__c = \'' + this.zephrTenant + '\'';
            queryString += ' LIMIT 1';

            List<ZephrSettings__mdt> accessSettings = Database.query(queryString);

            if (!accessSettings.isEmpty()) {
                this.secretKey = accessSettings[0].SecretKey__c;
                this.accessKey = accessSettings[0].AccessKey__c;
            }
        }
    }

    public String generateAuthToken(String fullUrl, String httpMethod, String body) {

        String timestamp = String.valueOf(Datetime.now().getTime());
        String nonce = String.valueOf(Math.random());
        System.debug(LoggingLevel.FINE, 'fullURl ' + fullUrl);
        System.debug(LoggingLevel.FINE, 'timestamp' + timestamp);
        if (body == null) body = '';
        String[] urlParts = fullUrl.split('\\?');
        String urlPath = urlParts[0];
        String urlQuery = urlParts.size() > 1 ? urlParts[1] : '';
        String s = secretKey + body + urlPath + urlQuery + httpMethod + timestamp + nonce;
        System.debug(LoggingLevel.FINE, 'hash string ' + s);
        Blob targetBlob = Blob.valueOf(s);

        Blob hash = Crypto.generateDigest('SHA-256', targetBlob);
        System.debug(EncodingUtil.convertToHex(hash));
        String output = 'ZEPHR-HMAC-SHA256 ' + accessKey + ':' + timestamp + ':' + nonce + ':' + EncodingUtil.convertToHex(hash);
        System.debug(output);

        return output;
    }

    public HttpResponse httpCallout(String urlPath, String httpMethod, String body) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod(httpMethod);
        req.setEndpoint(baseUrl + urlPath);
        System.debug(LoggingLevel.FINE, 'ZephrIntegrationNG::httpCallout - respond - req: ' + req.getEndpoint());
        if (body != null) {
            req.setBody(body);
        }
        req.setHeader('Authorization', this.generateAuthToken(urlPath, httpMethod, body));
        req.setHeader('Content-Type', 'application/json');

        HttpResponse res;
        System.debug(LoggingLevel.FINE, 'ZephrIntegrationNG::httpCallout - req: ' + req);
        System.debug(LoggingLevel.FINE, 'ZephrIntegrationNG::httpCallout - req body: ' + req.getBody());
        res = h.send(req);

        if (res.getStatusCode() > 299) {
            Database.SaveResult sr = publishHttpErrorEvent(UserInfo.getUserName(), req.getEndpoint(), req.getBody(), res.getBody(), res.getStatusCode(), 'HTTP Request', req.getMethod());
            System.debug('SAVE RESULTS FROM CALL OUT IN PE ? > ' + sr);
        }
        return res;
    }

    public HttpResponse getUsers() {

        HttpResponse res = this.httpCallout('/v3/users/', 'GET', null);
        return res;
    }

    public HttpResponse getUser(String userId) {

        HttpResponse res = this.httpCallout('/v3/users/' + userId, 'GET', null);
        return res;
    }

    public HttpResponse createCompany(String name, String website) {

        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeStringField('name', name);
        if (website != null) {
            gen.writeStringField('website', website);
        }
        gen.writeEndObject();

        String body = gen.getAsString();
        HttpResponse res = this.httpCallout('/v3/companies', 'POST', body);
        return res;
    }

    public HttpResponse createUser(zephr_WebhookAPI.UserDetails userDetails) {

        if (userDetails.identifiers.email_address == null) return null;
        String body = JSON.serialize(userDetails, true)
                .replace('"first_name"', '"first-name"')
                .replace('"last_name"', '"last-name"')
                .replace('"company_name"', '"company-name"')
                .replace('"company_type"', '"company-type"')
                .replace('"job_title"', '"job-title"')
                .replace('"confirm_contact_pref"', '"confirm-contact-pref"')
                .replace('"contact_preference_email"', '"contact-preference-email"')
                .replace('"contact_preference_phone"', '"contact-preference-phone"')
                .replace('"contact_preference_post"', '"contact-preference-post"')
                .replace('"telephone_number"', '"telephone-number"')
                .replace('"phone_number"', '"phone-number"')
                .replace('"terms_and_conditions"', '"terms-and-conditions"')
                .replace('"alerts_timezone"', '"alerts-timezone"');

        System.debug('INSERT LEAD HTTP BODY  >  ' + body);

        HttpResponse res = this.httpCallout('/v3/users', 'POST', body);
        return res;
    }

    public HttpResponse createUser(ZephrApiRequestsResponses.User userDetails) {

        if (userDetails.identifiers.get('email_address') == null) return null;
        String body = JSON.serialize(userDetails, true);

        System.debug('INSERT LEAD HTTP BODY  >  ' + body);

        HttpResponse res = this.httpCallout('/v3/users', 'POST', body);
        return res;
    }

    public HttpResponse getUserByEmail(String email) {

        if (email == null) return null;

        HttpResponse res = this.httpCallout('/v3/users?identifiers.email_address=' + email.replace('+', '%2B'), 'GET', null);
        return res;
    }

    public HttpResponse createAccount(String companyId, String contractNumber, String publicationCode, Integer numberOfSeats, String companyName) {

        if (companyId == null) return null;

        // add attibute to describe which publication it is
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeStringField('company_id', companyId);
        gen.writeStringField('name', companyName + ' - ' + contractNumber + ' - ' + publicationCode);
        gen.writeBooleanField('allow_oversubscription', false);
        gen.writeNumberField('number_of_seats', numberOfSeats);
        gen.writeEndObject();
        String body = gen.getAsString();

        HttpResponse res = this.httpCallout('/v3/accounts', 'POST', body);
        return res;
    }

    public HttpResponse getUserGrants(String zephrUserId) {
        // returns grants of the specific user
        String urlPath = '/v3/users/' + zephrUserId + '/grants';
        HttpResponse res = this.httpCallout(urlPath, 'GET', null);
        return res;
    }

    public HttpResponse createUserGrant(String zephrUserId, String productCode, String entId, Datetime startDate, Datetime endDate) {

        String urlPath = '/v3/users/' + zephrUserId + '/grants';

        // If the start date/time is now at least 10 minutes from now, we push it forward.
        // This is because some Zephr integrations rely on webhooks that are triggered when the time passes the start time of the grant
        // Euromoney have had issues where grants were created with a start tie of now() and the calls did not complete quickly enough to trigger the webhook
        // But if the grant starts in the future, we don't want to bring it forward...
        if (startDate < Datetime.now().addMinutes(zephrDelayTime)) {
            startDate = Datetime.now().addMinutes(zephrDelayTime);
        }
        // And just in case this pushes the start date beyond the end date, we check that...
        if (endDate < startDate) {
            endDate = startDate;
        }

        Datetime endDatetime;
        if (endDate != null) {
            endDatetime = Datetime.newInstanceGmt(endDate.date(), Time.newInstance(23, 59, 59, 99));
        }

        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeStringField('entitlement_type', 'bundle');
        gen.writeStringField('entitlement_id', entId);
        gen.writeStringField('product_id', productCode == null ? '' : productCode);
        gen.writeStringField('start_time', String.valueOfGmt(startDate));
        gen.writeStringField('end_time', String.valueOfGmt(endDatetime));
        gen.writeEndObject();
        String body = gen.getAsString();
        System.debug(LoggingLevel.FINE, 'createUserGrant - body: ' + body);

        HttpResponse res = this.httpCallout(urlPath, 'POST', body);
        return res;
    }

    public HttpResponse getAccountGrants(String zephrAccountId) {
        String getUrl = '/v3/accounts/' + zephrAccountId + '/grants';
        HttpResponse resGet = this.httpCallout(getUrl, 'GET', null);
        return resGet;
    }

    public HttpResponse deleteUserGrant(String zephrUserId, String zephrGrantId) {

        String urlPath = '/v3/users/' + zephrUserId + '/grants/' + zephrGrantId;
        HttpResponse res = this.httpCallout(urlPath, 'DELETE', null);
        return res;
    }

    public HttpResponse createGrant(Date startDate, Date endDate, String productCode, String zephrAccountId, String enttlId) {

        if (enttlId == null) return null;

        // If the start date/time is not at least 10 minutes from now, we push it forward.
        // This is because some Zephr integrations rely on webhooks that are triggered when the time passes the start time of the grant
        // Euromoney have had issues where grants were created with a start tie of now() and the calls did not complete quickly enough to trigger the webhook
        // But if the grant starts in the future, we don't want to bring it forward...
        Datetime startDatetime;
        if (startDate <= Date.today()) {
            // If the provided start date is today or earlier, set the start to 10 minutes from now
            startDatetime = Datetime.now().addMinutes(zephrDelayTime);
        } else if (startDate != null) {
            // Otherwise (start date > today) we start from midnight on the provided date
            startDatetime = Datetime.newInstanceGmt(startDate, Time.newInstance(0, 0, 0, 0));
        }
        // Create a new end datetime
        Datetime endDatetime;
        if (endDate != null) {
            endDatetime = Datetime.newInstanceGmt(endDate, Time.newInstance(23, 59, 59, 99));

            // If we have pushed the start so it's now after the end time, we set them equal
            if (endDatetime < startDatetime) {
                endDatetime = startDatetime;
            }
        }
        
        String urlPath = '/v3/accounts/' + zephrAccountId + '/grants';
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeStringField('entitlement_type', 'bundle');
        gen.writeStringField('entitlement_id', enttlId);
        gen.writeStringField('product_id', productCode == null ? '' : productCode);
        gen.writeStringField('start_time', startDatetime == null ? '' : String.valueOfGmt(startDatetime));
        gen.writeStringField('end_time', endDatetime == null ? '' : String.valueOfGmt(endDatetime));
        gen.writeEndObject();
        String body = gen.getAsString();

        HttpResponse res = this.httpCallout(urlPath, 'POST', body);
        return res;
    }

    // public HttpResponse createGrant(Date startDate, Date endDate, String productCode, String zephrAccountId, String enttlId) {

    //     if (enttlId == null) return null;

    //     // If the start date/time is not at least 10 minutes from now, we push it forward.
    //     // This is because some Zephr integrations rely on webhooks that are triggered when the time passes the start time of the grant
    //     // Euromoney have had issues where grants were created with a start tie of now() and the calls did not complete quickly enough to trigger the webhook
    //     // But if the grant starts in the future, we don't want to bring it forward...
    //     Datetime startDatetime;
    //     if (startDate <= Date.today()) {
    //         // If the provided start date is today or earlier, set the start to 10 minutes from now
    //         startDatetime = Datetime.now().addMinutes(10);
    //     } else if (startDate != null) {
    //         // Otherwise (start date > today) we start from midnight on the provided date
    //         startDatetime = Datetime.newInstanceGmt(startDate, Time.newInstance(0, 0, 0, 0));
    //     }
    //     // Create a new end datetime
    //     Datetime endDatetime;
    //     if (endDate != null) {
    //         endDatetime = Datetime.newInstanceGmt(endDate, Time.newInstance(23, 59, 59, 99));

    //         // If we have pushed the start so it's now after the end time, we set them equal
    //         if (endDatetime < startDatetime) {
    //             endDatetime = startDatetime;
    //         }
    //     }

    //     String urlPath = '/v3/accounts/' + zephrAccountId + '/grants';
    //     JSONGenerator gen = JSON.createGenerator(false);
    //     gen.writeStartObject();
    //     gen.writeStringField('entitlement_type', 'bundle');
    //     gen.writeStringField('entitlement_id', enttlId);
    //     gen.writeStringField('start_time', startDatetime == null ? '' : String.valueOfGmt(startDatetime));
    //     gen.writeStringField('end_time', endDatetime == null ? '' : String.valueOfGmt(endDatetime));
    //     gen.writeEndObject();
    //     String body = gen.getAsString();

    //     HttpResponse res = this.httpCallout(urlPath, 'POST', body);
    //     return res;
    // }

    public HttpResponse accountUser(String zephrAccountId, String zephrUserId, String method) {

        // method: PUT for adding user, DELETE for deleting user
        // e.g. /v3/accounts/f709d2d4-eb66-42ee-b841-7add030386dc/users/d4811164-6e39-48a9-8728-a3c485afb1cb
        String urlPath = '/v3/accounts/' + zephrAccountId + '/users/' + zephrUserId;
        HttpResponse res = this.httpCallout(urlPath, method, null);
        System.debug(LoggingLevel.FINE, 'accountUser - res: ' + res.getStatusCode());
        System.debug(LoggingLevel.FINE, 'accountUser - res: ' + res.getBody());

        return res;
    }

    public HttpResponse deleteAccountGrant(String zephrAccountId, String zephrGrantId) {
        String urlPath = '/v3/accounts/' + zephrAccountId + '/grants/' + zephrGrantId;
        HttpResponse res = this.httpCallout(urlPath, 'DELETE', null);
        return res;
    }

    public HttpResponse updateUserAttributes(String zephrUserId, Map<String, String> attributesToUpdate) {
        String urlPath = '/v3/users/' + zephrUserId + '/attributes';
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        for (String fieldName : attributesToUpdate.keySet()) {
            String newValue = attributesToUpdate.get(fieldName);
            if (String.isNotBlank(newValue)) {
                gen.writeStringField(fieldName, newValue);
            }
        }
        gen.writeEndObject();
        String body = gen.getAsString();
        System.debug(LoggingLevel.FINE, 'updateUserAttributes - body: ' + body);

        HttpResponse res = this.httpCallout(urlPath, 'PATCH', body);

        System.debug(LoggingLevel.ERROR, 'updateUserAttributes - res: ' + res.getStatusCode());
        System.debug(LoggingLevel.ERROR, 'updateUserAttributes - res: ' + res.getBody());

        return res;

    }

    public HttpResponse getGrant(String zephrUserId, String zephrGrantId) {
        String urlPath = '/v3/users/' + zephrUserId + '/grants/' + zephrGrantId;
        HttpResponse res = this.httpCallout(urlPath, 'GET', null);
        return res;
    }

    public static Database.SaveResult publishHttpErrorEvent(String currentUser, String endpoint, String reqBody, String resBody, Integer resCode, String origin, String httpMethod) {
        ZephrIntegrationError__e syncError = new ZephrIntegrationError__e(
                CurrentUser__c = currentUser,
                Endpoint__c = endpoint,
                RequestBody__c = reqBody,
                ResponseBody__c = resBody,
                ResponseCode__c = resCode,
                ErrorOrigin__c = origin,
                HttpMethod__c = httpMethod
        );
        Database.SaveResult sr = EventBus.publish(syncError);
        return sr;
    }

    public HttpResponse createAccount(String companyId, String name, Integer numberOfSeats, Boolean allow_oversubscription) {

        if (companyId == null) return null;

        // add attibute to describe which publication it is
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeStringField('company_id', companyId);
        gen.writeStringField('name', name);
        gen.writeBooleanField('allow_oversubscription', allow_oversubscription);
        gen.writeNumberField('number_of_seats', numberOfSeats);
        gen.writeEndObject();
        String body = gen.getAsString();

        HttpResponse res = this.httpCallout('/v3/accounts', 'POST', body);
        return res;
    }

    public HttpResponse getAccount(String accountId) {
        HttpResponse res = this.httpCallout('/v3/accounts/' + accountId, 'GET', null);
        return res;
    }

    public HttpResponse updateAccount(ZephrApiRequestsResponses.Account zephrAccount) {

        if (zephrAccount.account_id == null) return null;

        // Get account from zephr
        HttpResponse accountResponse = this.getAccount(zephrAccount.account_id);
        String responseBody = accountResponse.getBody();

        if (accountResponse == null || accountResponse.getBody() == null) {
            return null;
        }
        // No account found returns an HTML document with 200 HTTP code
        if (responseBody.contains('No account')) {
            return null;
        }

        // We deserialize untyped in case Zephr adds new properties we don't know about
        Map<String,Object> zephrAccountObject = (Map<String, Object>)JSON.deserializeUntyped(responseBody);

        // Update any properties we maintain in SFDC and flag to send to Zephr
        Boolean sendUpdate = false;
        if ( zephrAccountObject.containsKey('number_of_seats')) {
            zephrAccountObject.put('number_of_seats', zephrAccount.number_of_seats);
            sendUpdate = true;
        }

        if (sendUpdate == false) {
            return null;
        }

        String body = JSON.serializePretty(zephrAccountObject, false);
        System.debug(LoggingLevel.DEBUG, 'updateAccount - sending body: ' + body);

        // push updated account back to zephr
        HttpResponse res = this.httpCallout('/v3/accounts/' + zephrAccount.account_id, 'PUT', body);
        System.debug(LoggingLevel.ERROR, 'updateAccount - res: ' + res.getStatusCode());
        System.debug(LoggingLevel.DEBUG, 'updateAccount - res: ' + res.getStatusCode());
        System.debug(LoggingLevel.DEBUG, 'updateAccount - res body: ' + res.getBody());

        return res;
    }

    public HttpResponse updateUserEmail(String zephrUserId, String email, String websiteSlug) {
        String urlPath = '/v3/users/' + zephrUserId + '/update-email';
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeFieldName('new_identifiers');
        gen.writeStartObject();
        gen.writeStringField('email_address', email);
        gen.writeEndObject();
        gen.writeStringField('siteSlug', websiteSlug);
        gen.writeEndObject();
        String body = gen.getAsString();

        HttpResponse res = this.httpCallout(urlPath, 'POST', body);

        System.debug(LoggingLevel.ERROR, 'updateUserEmail - res: ' + res.getStatusCode());
        System.debug(LoggingLevel.ERROR, 'updateUserEmail - res: ' + res.getBody());

        return res;

    }

    public HttpResponse sendResetPassword(String email, String websiteSlug) {
        System.debug(LoggingLevel.FINE, 'sendResetPassword - websiteSlug: ' + websiteSlug);
        String urlPath = '/v4/users/reset';
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeFieldName('identifiers');
        gen.writeStartObject();
        gen.writeStringField('email_address', email);
        gen.writeEndObject();
        gen.writeStringField('siteSlug', websiteSlug);
        gen.writeEndObject();
        String body = gen.getAsString();
        System.debug(LoggingLevel.FINE, 'sendResetPassword - body: ' + body);

        HttpResponse res = this.httpCallout(urlPath, 'POST', body);

        System.debug(LoggingLevel.FINE, 'sendResetPassword - res: ' + res.getStatusCode());
        System.debug(LoggingLevel.FINE, 'sendResetPassword - res: ' + res.getBody());

        return res;

    }

    public HttpResponse getAttributeDetails(String attributeSlug) {
        System.debug(LoggingLevel.FINE, 'getAttributeDetails - attributeSlug: ' + attributeSlug);
        String urlPath = '/v3/schema/users/' + attributeSlug;

        HttpResponse res = this.httpCallout(urlPath, 'GET', null);

        System.debug(LoggingLevel.FINE, 'getAttributeDetails - res: ' + res.getStatusCode());
        System.debug(LoggingLevel.FINE, 'getAttributeDetails - res: ' + res.getBody());

        return res;
    }
}