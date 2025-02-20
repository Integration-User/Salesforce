/**
* @author Zoran Zunko
* @date 8/12/21
*
*/
@IsTest
global class zephr_TestMock implements HttpCalloutMock {

    global class MockConfig {
        public String body ;
        public String status ;
        public Integer code ;
        public Boolean throwException;
        public String method;

        public MockConfig(
                String body,
                String status,
                Integer code,
                Boolean throwException,
                String method
        ) {
            this.body = body;
            this.status = status;
            this.code = code;
            this.throwException = throwException;
            this.method = method;
        }
    }

    public Map<String, MockConfig> mockConfigs;

    global zephr_TestMock(Map<String, MockConfig> mockConfigs) {
        this.mockConfigs = mockConfigs;
    }

    global HttpResponse respond(HttpRequest req) {
        System.debug(LoggingLevel.ERROR, 'respond - req: ' + req.getEndpoint());

        for (String str : mockConfigs.keySet()) {
//                System.debug(LoggingLevel.ERROR, 'respond - ' + (req.getEndpoint().contains(str) && req.getMethod() == mockConfigs.get(str).method));
            System.debug(LoggingLevel.ERROR, 'respond - str: ' + str);
            System.debug(LoggingLevel.ERROR, 'respond - str: ' + mockConfigs.get(str).method);
            System.debug(LoggingLevel.ERROR, 'respond - req.getMethod(): ' + req.getMethod());
            Pattern kitSerialPattern = Pattern.compile(str);
            Matcher pm = kitSerialPattern.matcher(req.getEndpoint());
            System.debug(LoggingLevel.ERROR, 'respond - pm.matches(): ' + pm.matches());
            if (pm.matches() && req.getMethod() == mockConfigs.get(str).method) {
                MockConfig mConfig = mockConfigs.get(str);
                if (mConfig.throwException) {
                    Integer divideByZero = 2 / 0;
                }
                HttpResponse res = new HttpResponse();

                System.assert(req != null);
//			System.assertEquals(method, req.getMethod());
                res.setBody(mConfig.body);
                res.setStatusCode(mConfig.code);
                res.setStatus(mConfig.status);
                return res;
            }
        }
        return null;

    }
}