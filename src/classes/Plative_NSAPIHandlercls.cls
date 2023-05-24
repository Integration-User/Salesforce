/**
* Company     : Plative
* Description : Has methods for all the API callouts to Netsuite
* History     :
* [05.Mar.2020] Anisa Shaikh - Code Creation
*/

public class Plative_NSAPIHandlercls {


    /**
    * Description : Creates/Updates record in Netsuite
    **/
    public static HttpResponse upsertRecord(String reqBody, String endpoint, String header) {

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setHeader('Authorization', header);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', '*/*');
        req.setMethod('PUT');
        req.setBody(reqBody);
		req.setTimeout(120000);
        HttpResponse resp = !Test.isRunningTest() ? http.send(req) : Plative_UpsertRecordQueueableMock.respond(req);
        System.debug('Status code ' + resp.getStatusCode());
        System.debug('Body ' + resp.getBody());
        return resp;
    }

    /**
    * Description : Query record
    **/
	public static HttpResponse queryRecord(String endpoint, String header){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setHeader('Authorization', header);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', '*/*');
        req.setMethod('GET');
		req.setTimeout(120000);
        HttpResponse resp = !Test.isRunningTest() ? http.send(req) : Plative_GetCustomerIDMock.respond(req);
        //HttpResponse resp = http.send(req);
		System.debug('Status code ' + resp.getStatusCode());
        System.debug('Body ' + resp.getBody());
        return resp;
	}
}