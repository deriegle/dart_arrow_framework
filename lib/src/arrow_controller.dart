part of arrow_framework;

class ArrowController {
  HttpRequest _request;

  HttpRequest get request => _request;
  HttpResponse get response => request.response;

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
