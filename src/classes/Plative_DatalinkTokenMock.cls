/**
* Company     : Plative
* Description :  Mock class for Plative_UpdateDownloadsCtrl
* History     : 
* [14.May.2020] Kunal - Code Creation 
*/
@isTest
public class Plative_DatalinkTokenMock implements HttpCalloutMock {
    
    public HTTPResponse respond(HTTPRequest req) {
        HTTPResponse response = new HTTPResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setHeader('Accept','application/json');
        response.setStatusCode(200);
        
        if(req.getEndpoint().contains('update_max_tokens') ){
            Blob body = [Select Body from StaticResource where Name = 'GSA_UpdateToken'].Body;
            response.setBody(body.toString());
        } else {
            Blob body = [Select Body from StaticResource where Name = 'GSA_ClearToken'].Body;
            response.setBody(body.toString());
        }       
        
        return response;
    }
}