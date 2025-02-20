/**
 * Created by bjarmolinski on 2020-02-14.
 */
@isTest
global class CalloutMockForHttp implements HttpCalloutMock {

    String body;
    Integer statusCode;

    global CalloutMockForHttp(String body, Integer statusCode) {
        this.body = body;
        this.statusCode = statusCode;
    }

    global HttpResponse respond(HttpRequest req) {

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(this.body);
        res.setStatusCode(this.statusCode);

        return res;
    }

    global HttpResponse respond() {

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(this.body);
        res.setStatusCode(this.statusCode);

        return res;
    }
}