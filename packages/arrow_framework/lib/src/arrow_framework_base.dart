part of arrow_framework;

const _defaultAddress = '0.0.0.0';
const _defaultPort = 8080;

class ArrowFramework {
  final Router _router;
  final String _address;
  final int _port;
  StreamSubscription _subscription;

  ArrowFramework({
    bool autoInit = true,
    String address = _defaultAddress,
    int port = _defaultPort,
    Router router,
  })  : _address = address,
        _port = port,
        _router = router ?? Router() {
    if (autoInit) {
      init();
    }
  }

  Router get router => _router;

  /// Binds the HTTP Server to desired address/port
  ///
  /// Listens for requests and forwards to the router for matching
  ArrowFramework init() {
    runZoned(() {
      HttpServer.bind(_address, _port).then((server) {
        print('Listening on port $_port');
        _subscription = server.listen(handleRequest);
      });
    }, onError: (e) {
      print('Error occurred');
      print(e);
      dispose();
    });

    return this;
  }

  void dispose() {
    _subscription?.cancel();
  }

  /// Handles incoming HTTP requests
  ///
  /// Asks router for matching routes or returns 404
  Future<void> handleRequest(HttpRequest request) async {
    final match = _router.matchRequest(request);

    if (match.matched) {
      await _router.serve(request, match);
    } else {
      // No route found for request
      // Status Code: 404
      // TODO: Add ability to customize 404 page/result

      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
    }
  }
}
