@isTest
public class AccountHandlerMock implements HttpCalloutMock{
    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');

        System.debug('mock : ' + request.getEndpoint());
        System.debug('Authorization: ' + request.getHeader('Authorization'));
        System.debug('accept: ' + request.getHeader('accept'));
        System.debug('Content-Type: ' + request.getHeader('Content-Type'));
        System.debug('Auth: ' + request.getHeader('Auth'));
        System.debug('client-id: ' + request.getHeader('client-id'));
        
        if (request.getEndpoint().contains('AWS')) {
            response.setStatusCode(200);
            response.setBody('{"success": true}');
        } else {
            response.setStatusCode(404);
        }

        return response;
    }
}