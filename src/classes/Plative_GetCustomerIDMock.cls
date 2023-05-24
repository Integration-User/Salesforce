/**
* Created by Anisa on 13-03-2020.
*/

@isTest 
global class Plative_GetCustomerIDMock implements HttpCalloutMock{
	
    global static HTTPResponse respond(HTTPRequest req) {
        HTTPResponse response = new HTTPResponse();
        response.setBody('{"id":"11111"}');
        response.setStatusCode(200);
        response.setHeader('Content-Type', 'application/vnd.oracle.resource+json');
        return response;
    }
}