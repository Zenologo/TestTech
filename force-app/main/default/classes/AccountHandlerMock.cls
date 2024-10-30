@isTest
public class AccountHandlerMock implements HttpCalloutMock{
    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        
        if (request.getEndpoint().contains('AWS')) {
            response.setStatusCode(200);
            response.setBody('{"success": true}');
        } else {
            response.setStatusCode(404);
        }

        return response;
    }
}
