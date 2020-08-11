part of arrow_framework;

class ArrowController {
  HttpRequest _request;

  HttpRequest get request => _request;
  HttpRequest get req => request;

  HttpResponse get response => request.response;
  HttpResponse get res => response;

  dynamic get cookies => request.cookies;

  void setCookie({@required String name, @required String value}) {
    res.cookies.add(Cookie(name, value));
  }

  void json(Map<String, dynamic> json) {
    response.headers.contentType = ContentType.json;
    response.write(jsonEncode(json));
    response.close();
  }

  void call(HttpRequest request, Function handler,
      [List<dynamic> params = const []]) {
    _request = request;

    Function.apply(
      handler,
      params,
    );
  }
}
