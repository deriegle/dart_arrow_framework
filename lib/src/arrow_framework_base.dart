part of arrow_framework;

const defaultAddress = '0.0.0.0';
const defaultPort = 8080;

class ArrowFramework {
  final Router _router;
  final String _address;
  final int _port;
  StreamSubscription _subscription;

  ArrowFramework({
    bool autoInit = true,
    String address = defaultAddress,
    int port = defaultPort,
    Router router,
  })  : _address = address,
        _port = port,
        _router = router ?? Router() {
    if (autoInit) {
      init();
    }
  }

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

  Future<void> handleRequest(HttpRequest request) async {
    print(request);

    final match = _router.matchRequest(request);

    print(match);
    print(match.matched);

    if (match.matched) {
      await _router.serve(request, match);
    } else {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
    }
  }
}
