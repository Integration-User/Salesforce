/**
* Created by Kunal Jain on 13-03-2020.
*/

public with sharing class Plative_UpsertRecordQueueableMock implements HttpCalloutMock{
    
    public static HTTPResponse respond(HTTPRequest req) {
        HTTPResponse response = new HTTPResponse();
        response.setBody('');
        response.setStatusCode(204);
        response.setHeader('Content-Type', 'application/json');
		if(req.getEndpoint().containsIgnoreCase('JOB')){
			//return null;
		}
        return response;
    }
}