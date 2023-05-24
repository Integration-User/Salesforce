@isTest
public class Plative_UpdateDownloadsMock implements HttpCalloutMock {
    
    public HTTPResponse respond(HTTPRequest req) {
        HTTPResponse response = new HTTPResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setHeader('Accept','application/json');
        response.setStatusCode(200);
        Blob body = [Select Body from StaticResource where Name = 'GSA_UpdateDownloads'].Body;
        response.setBody(body.toString());
        return response;     
    }

}