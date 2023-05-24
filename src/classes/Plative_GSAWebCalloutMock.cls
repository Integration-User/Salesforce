@isTest
public class Plative_GSAWebCalloutMock implements HttpCalloutMock {
    
    public HTTPResponse respond(HTTPRequest req) {
        system.debug('Mock Called');
        HTTPResponse response = new HTTPResponse();
		response.setHeader('Content-Type', 'application/json');
        response.setHeader('Accept','application/json');
        response.setStatusCode(200);
        String resourceToQuery = '';
        
        if(req.getEndpoint().contains('companies') && req.getEndpoint().contains('activate') && !req.getEndpoint().contains('deactivate')){
            resourceToQuery = 'GSA_AccountActivation';
        } else if(req.getEndpoint().contains('companies') && req.getEndpoint().contains('deactivate')){
            resourceToQuery = 'GSA_AccountDeActivation';
        } else if(req.getEndpoint().contains('users') && req.getEndpoint().contains('activate') && !req.getEndpoint().contains('deactivate')){
            resourceToQuery = 'GSA_ContactActivation';
        } else if(req.getEndpoint().contains('users') && req.getEndpoint().contains('deactivate')){
            resourceToQuery = 'GSA_ContactDeActivation';
        } else if(req.getEndpoint().contains('users') && req.getEndpoint().contains('reset_password')){
            resourceToQuery = 'GSA_ResetPasswordForContact';
        } else if(req.getEndpoint().contains('companies') && req.getEndpoint().contains('edit')){
            resourceToQuery = 'GSA_AccountUpdation';
        }
        system.debug('StaticResource: ' + resourceToQuery);
        Blob body = [Select Body from StaticResource where Name = :resourceToQuery].Body;
        response.setBody(body.toString());        
        return response;
        
    }
    
}