/*
    Created By: Bartosz Jarmolinski (bjarmolinski@salesforce.com)
    The class contains methods to call Zephr API (Admin API, API v3.0 as per Zephr documentation)
    Zephr documentation: https://support.zephr.com/admin-api
*/


public with sharing class ZephrIntegration {

    String secretKey;
    String accessKey;
    public static String baseUrl = 'https://console.zephr.com';
    public Boolean testCallout;
    public String zephrTenant;

    public ZephrIntegration(String zephrTenant) {
        // query custom metadata types to get secret ket and access key
        // get urlPath as parameter
        this.zephrTenant = zephrTenant;

        String queryString = 'SELECT Id, AccessKey__c, SecretKey__c FROM ZephrSettings__mdt WHERE Type__c = \'API Access\'';
        if (!String.isBlank(this.zephrTenant)) { 
            queryString += ' AND ZephrTenant__c = \'' + this.zephrTenant + '\'';
        }
        queryString += ' LIMIT 1';
        ZephrSettings__mdt accessSettings = Database.query(queryString);

        this.secretKey = accessSettings.SecretKey__c;
        this.accessKey = accessSettings.AccessKey__c;
    }

    public String generateAuthToken(String urlPath, String httpMethod, String body) {

        String timestamp = String.valueOf(DateTime.now().getTime()); 
        // String urlPath = '/v3/users/'; // to be used as parameter
        String nonce = String.valueOf(Math.random()); 
        System.debug('timestamp' + timestamp);
        if (body == null) body = '';

        String s = secretKey + body + urlPath + httpMethod + timestamp + nonce;

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
        if (body != null) {
            req.setBody(body);
        }
        req.setHeader('Authorization', this.generateAuthToken(urlPath, httpMethod, body));
        req.setHeader('Content-Type', 'application/json');

        HttpResponse res;
        if (!Test.isRunningTest() || MultipleRequestMock.instantiated == true || this.testCallout == true) {
            res = h.send(req);
        } else {
            res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('');
        }

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

    public HttpResponse createCompany(String name, String website) {

        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeStringField('name', name);
        gen.writeStringField('website', website);
        gen.writeEndObject();

        String body = gen.getAsString();
        HttpResponse res = this.httpCallout('/v3/companies', 'POST', body);
        return res;
    }

    public HttpResponse createUser(String email, String firstName, String lastName, String companyName, String id, String jobTitle, String city, String country, String companyType, String seniority, String startDate) {

        if (email == null) return null;
        // Map<String, String> attributes = new Map<String, String>{
        //     'first-name' => firstName, 'last-name' => lastName, 'company-name' => companyName, 'salesforce_id' => id, 'job-title' => jobTitle, 
        //     'city' => city, 'country' => country, 'company-type' => companyType, 'seniority' => seniority, 'start_date' => startDate
        // }; 
        // removed seniority and company-type from the above - can be uncommented when seniority and company type values are aligned between Salesforce and  ZEphr
        // (then the below needs to be erased) 
        Map<String, String> attributes = new Map<String, String>{
            'first-name' => firstName, 'last-name' => lastName, 'company-name' => companyName, 'salesforce_id' => id, 'job-title' => jobTitle, 
            'city' => city, 'country' => country, 'start_date' => startDate
        }; 

        System.debug('INSERT LEAD MAP  Attributes >  ' + attributes);

        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeFieldName('identifiers');
        gen.writeStartObject();
        gen.writeStringField('email_address', email);
        gen.writeEndObject();
        gen.writeFieldName('attributes');
        gen.writeStartObject();
        for (String s : attributes.keySet()) {
            String value = attributes.get(s) == null ? '' : attributes.get(s);
            gen.writeStringField(s, value);
        }
        gen.writeEndObject();
        gen.writeBooleanField('email_verified', true);
        gen.writeEndObject();
        String body = gen.getAsString();

        System.debug('INSERT LEAD HTTP BODY  >  ' + JSON.serializePretty(body));

        HttpResponse res = this.httpCallout('/v3/users', 'POST', body);
        return res;
    }

    public HttpResponse createEMUser(String email, String firstName, String lastName, String companyName, String id, String jobTitle, String city, String country, String companyType, String seniority, String startDate) {

        if (email == null) return null;
        // Map<String, String> attributes = new Map<String, String>{
        //     'first-name' => firstName, 'last-name' => lastName, 'company-name' => companyName, 'salesforce_id' => id, 'job-title' => jobTitle, 
        //     'city' => city, 'country' => country, 'company-type' => companyType, 'seniority' => seniority, 'start_date' => startDate
        // }; 
        // removed seniority and company-type from the above - can be uncommented when seniority and company type values are aligned between Salesforce and  ZEphr
        // (then the below needs to be erased) 
        Map<String, String> attributes = new Map<String, String>{
            'first-name' => firstName, 'last-name' => lastName, 'company-name' => companyName, 'salesforce-id' => id, 'job-title' => jobTitle, 
            'towncity' => city, 'country' => country, 'start-date' => startDate
        }; 

        System.debug('INSERT LEAD MAP  Attributes >  ' + attributes);

        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeFieldName('identifiers');
        gen.writeStartObject();
        gen.writeStringField('email_address', email);
        gen.writeEndObject();
        gen.writeFieldName('attributes');
        gen.writeStartObject();
        for (String s : attributes.keySet()) {
            String value = attributes.get(s) == null ? '' : attributes.get(s);
            gen.writeStringField(s, value);
        }
        gen.writeEndObject();
        gen.writeBooleanField('email_verified', true);
        gen.writeEndObject();
        String body = gen.getAsString();

        System.debug('INSERT LEAD HTTP BODY  >  ' + JSON.serializePretty(body));

        HttpResponse res = this.httpCallout('/v3/users', 'POST', body);
        return res;
    }

    public HttpResponse createAccount(String companyId, String contractNumber, String publicationCode, Integer numberOfSeats, String companyName) {

        if (companyId == null) return null;

        // add attibute to describe which publication it is
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeStringField('company_id', companyId);
        gen.writeStringField('name', companyName + ' - '+ contractNumber + ' - ' + publicationCode);
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

    public HttpResponse createUserGrant(String zephrUserId, String productCode, String entId, Datetime startDate, Datetime endDate ) {
        
        String urlPath = '/v3/users/' + zephrUserId + '/grants';
        
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeStringField('entitlement_type', 'bundle');
        gen.writeStringField('entitlement_id', entId);
        gen.writeStringField('start_time', String.valueOf(startDate));
        gen.writeStringField('end_time', String.valueOf(endDate));
        gen.writeEndObject();
        String body = gen.getAsString();

        HttpResponse res = this.httpCallout(urlPath, 'POST', body);
        return res;
    }

    public HttpResponse getAccountGrants(String zephrAccountId) {
        String getUrl = '/v3/accounts/'+ zephrAccountId +'/grants';
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

        String urlPath = '/v3/accounts/' + zephrAccountId + '/grants';
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeStringField('entitlement_type', 'bundle');
        gen.writeStringField('entitlement_id', enttlId);
        gen.writeStringField('start_time', String.valueOf(startDate) + ' 00:00:00');
        gen.writeStringField('end_time', String.valueOf(endDate) + ' 23:59:00');
        gen.writeEndObject();
        String body = gen.getAsString();

        HttpResponse res = this.httpCallout(urlPath, 'POST', body);
        return res;
    }

    public HttpResponse accountUser(String zephrAccountId, String zephrUserId, String method) {

        // method: PUT for adding user, DELETE for deleting user
        // e.g. /v3/accounts/f709d2d4-eb66-42ee-b841-7add030386dc/users/d4811164-6e39-48a9-8728-a3c485afb1cb
        String urlPath = '/v3/accounts/' + zephrAccountId + '/users/' + zephrUserId;
        HttpResponse res = this.httpCallout(urlPath, method, null);

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
            if(newValue == null) newValue = '';
            gen.writeStringField(fieldName, newValue);
        }
        gen.writeEndObject();
        String body = gen.getAsString();

        HttpResponse res = this.httpCallout(urlPath, 'POST', body);

        return res;

    }

    public HttpResponse getGrant(String zephrUserId, String zephrGrantId) {
        String urlPath = '/v3/users/' + zephrUserId + '/grants/' + zephrGrantId;
        HttpResponse res = this.httpCallout(urlPath, 'GET', null);
        return res;
    }

    public static Database.SaveResult publishHttpErrorEvent( String currentUser, String endpoint, String reqBody, String resBody, Integer resCode, String origin, String httpMethod) {
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
}