/*
    Created by: Bartosz Jarmolinski (bjarmolinski@salesforce.com) on 13th January 2021
    As per the article: https://developer.salesforce.com/blogs/developer-relations/2013/03/testing-apex-callouts-using-httpcalloutmock.html
    The class handles mock responses for test classes with multiple callouts in one execution context
*/


public class MultipleRequestMock implements HttpCalloutMock {
    
    Map<String, HttpCalloutMock> requests;
    public static Boolean instantiated = false;

    public MultipleRequestMock(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
        instantiated = true; 
    }

    public HttpResponse respond(HttpRequest req) {
        HttpCalloutMock mock = requests.get(req.getEndpoint());
        if (mock != null) {
            return mock.respond(req);
        } else {
            return null;
        }
    }

    public void addRequestMock(String url, HttpCalloutMock mock) {
        requests.put(url, mock);
    }
}