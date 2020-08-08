part of arrow_framework;

const defaultAddress = '0.0.0.0';
const defaultPort = 8080;

void serve() {
 var router = _Router();
 
 HttpServer.bind(defaultAddress, defaultPort).then((server) {
   print('Listening on port $defaultPort');

   server.listen((HttpRequest request) {
     print(request);

     var match = router.matchRequest(request);

     print('matched: ${match.matched}');

     if (match.matched) {
       router.serve(request, match);
     } else {
       request.response.statusCode = HttpStatus.notFound;
       request.response.close();
     }
   },
   onError: (e, stackTrace) {
     print('Error!');
     print(e);
   });
 });
}