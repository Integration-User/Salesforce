@SuppressWarnings('PMD.ApexSharingViolations, PMD.ApexCRUDViolation')
public class SalesloftAuthService {
    
    private static final String TOKEN_URL = 'https://accounts.salesloft.com/oauth/token'; ////SalesLoft_Reply_Count_API__c
    private static final String PROVIDER_NAME = 'SalesloftAuthProvider';
    private static final String SCOPE = 'emails:read';
    
    public static String getAccessToken() {
        AuthProvider provider = [SELECT ConsumerKey, ConsumerSecret FROM AuthProvider WHERE DeveloperName = :PROVIDER_NAME LIMIT 1];
        if (provider == null) {
            throw new CalloutException('AuthProvider not found');
        }
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(TOKEN_URL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        String body = 'grant_type=client_credentials&client_id=' + EncodingUtil.urlEncode(provider.ConsumerKey, 'UTF-8') +
            '&client_secret=' + EncodingUtil.urlEncode(provider.ConsumerSecret, 'UTF-8') +
            '&scope=' + EncodingUtil.urlEncode(SCOPE, 'UTF-8');
        
        req.setBody(body);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) responseMap.get('access_token');
        } else {
            throw new CalloutException('Failed to get access token: ' + res.getStatusCode() + ' ' + res.getStatus());
        }
    }
    
    public static SalesloftEmailActivityResponse getEmailsActivities() {
        Date today = Date.today().addDays(-Integer.valueOf(System.Label.SalesloftLastActivityDays));
        Time zeroTime = Time.newInstance(0, 0, 0, 0); 
        String midnight = Datetime.newInstance(today, zeroTime).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        System.debug(midnight);
        String token = getAccessToken();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.salesloft.com/v2/activities/emails');
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        req.setHeader('per_page', '100');
        req.setHeader('include_paging_counts', 'true');
        req.setHeader('sent_at%5Bgte%5D', midnight);
        req.setHeader('has_replies', 'true');
        //req.setHeader('page', '2');
        
        req.setHeader('Authorization', 'Bearer ' + token);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug(' req - > ' + req);
        System.debug(' HttpResponse -> ' + res.getBody());
        if (res.getStatusCode() == 200) {
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return parseEmailActivityResponse(parsed);
        } else {
            throw new CalloutException('Failed to get emails activities: ' + res.getStatusCode() + ' ' + res.getStatus());
        }
    }
    
    /**
* Fetches a page of email activity data starting at the provided
* date.  The <code>page</code> parameter corresponds to the
* <code>metadata.paging.nextPage</code> value returned by the API.
* If <code>page</code> is null the first page is returned.
*
* @param startDate date from which to pull activities (inclusive)
* @param page      page number or null for first page
* @return parsed response object
*/
    public static SalesloftEmailActivityResponse getEmailsActivities(Integer page) {
        Date today = Date.today().addDays(-Integer.valueOf(System.Label.SalesloftLastActivityDays));
        Time zeroTime = Time.newInstance(0, 0, 0, 0); 
        String midnight = Datetime.newInstance(today, zeroTime).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        System.debug(midnight);
        String token = getAccessToken();
        String endpoint = 'https://api.salesloft.com/v2/activities/emails?has_replies=true&per_page=100&include_paging_counts=true';
        endpoint += '&sent_at%5Bgte%5D=' + midnight;
        
        if (page != null) {
            endpoint += '&page=' + page;
        }
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + token);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug(' req -- > ' + req);
        System.debug(' HttpResponse --> ' + res.getBody());
        if (res.getStatusCode() == 200) {
            // manually map snake_case JSON fields to camelCase Apex properties
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return parseEmailActivityResponse(parsed);
        } else {
            throw new CalloutException('Failed to get emails activities: ' + res.getStatusCode() + ' ' + res.getStatus());
        }
    }
    
    private static SalesloftEmailActivityResponse parseEmailActivityResponse(Map<String, Object> raw) {
        SalesloftEmailActivityResponse result = new SalesloftEmailActivityResponse();
        result.metadata = new SalesloftEmailActivityResponse.Metadata();
        result.metadata.paging = new SalesloftEmailActivityResponse.Paging();
        Map<String, Object> meta = (Map<String, Object>) raw.get('metadata');
        if (meta != null) {
            Map<String, Object> paging = (Map<String, Object>) meta.get('paging');
            if (paging != null) {
                result.metadata.paging.per_page = (Integer) paging.get('per_page');
                result.metadata.paging.current_page = (Integer) paging.get('current_page');
                result.metadata.paging.next_page = (Integer) paging.get('next_page');
                result.metadata.paging.total_pages = (Integer) paging.get('total_pages');
                result.metadata.paging.total_count = (Integer) paging.get('total_count');
            }
        }
        
        result.data = new List<SalesloftEmailActivityResponse.ActivityData>();
        List<Object> dataList = (List<Object>) raw.get('data');
        if (dataList != null) {
            for (Object item : dataList) {
                Map<String, Object> itemMap = (Map<String, Object>) item;
                SalesloftEmailActivityResponse.ActivityData actData = new SalesloftEmailActivityResponse.ActivityData();
                system.debug('result.ActivityData actData-> ' + actData.message_id);
                actData.message_id = (String) itemMap.get('message_id');
                
                Map<String, Object> counts = (Map<String, Object>) itemMap.get('counts');
                if (counts != null) {
                    actData.counts = new SalesloftEmailActivityResponse.ActivityCounts();
                    actData.counts.clicks = (Integer) counts.get('clicks');
                    actData.counts.views = (Integer) counts.get('views');
                    actData.counts.replies = (Integer) counts.get('replies');
                    actData.counts.uniqueDevices = (Integer) counts.get('unique_devices');
                    actData.counts.uniqueLocations = (Integer) counts.get('unique_locations');
                    actData.counts.attachments = (Integer) counts.get('attachments');
                }
                result.data.add(actData);
            }
        }
        
        return result;
    }
}