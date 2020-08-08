part of arrow_framework;


class RouteMatch {
  RouteMatch([this.matched = false, this.route]);

  _ArrowRoute route;
  bool matched;
}


class _Router {
  List<_ArrowRoute> routes = [];

  _Router() {
    final controllers = scanControllers();

    routes.addAll(generateArrowRoutes(controllers));
  }

  RouteMatch matchRequest(HttpRequest request) {
    var match = RouteMatch(false);

    for (var route in routes) {
      if (route.match(request)) {
        match = RouteMatch(true, route);
        break;
      }
    }

    return match;
  }

  void serve(HttpRequest request, RouteMatch match) async {
    var controller = match.route.classMirror.newInstance(Symbol(''), []);
    var handler = controller.getField(match.route.methodMirror.simpleName);
    var params = <dynamic>[];
    var jsonBody = await parseBodyAsJson(request);

    for (var param in match.route.methodMirror.parameters) {
      var body = param.metadata.firstWhere((el) => el.reflectee is Body, orElse: () => null);
      if (body == null) {
        continue;
      }

      var bodyParamNameMirror = body.getField(Symbol('paramName'));
      var bodyParamRequiredMirror = body.getField(Symbol('required'));
      final bodyParamIsRequired = bodyParamRequiredMirror.reflectee as bool;


      if (jsonBody == null || bodyParamIsRequired && !jsonBody.containsKey(bodyParamNameMirror.reflectee)) {
        request.response.statusCode = HttpStatus.badRequest;
        request.response.write('${bodyParamNameMirror.reflectee} body param is required.');
        await request.response.close();
        return;
      }

      var paramValue = jsonBody[bodyParamNameMirror.reflectee];
      var paramType = param.type.reflectedType;

      if (paramValue == null && bodyParamIsRequired) {
        request.response.statusCode = HttpStatus.badRequest;
        request.response.write('${bodyParamNameMirror.reflectee} body param is required.');
        await request.response.close();
        return;
      }

      print('bodyParamName: ${bodyParamNameMirror.reflectee}');
      print('paramType: ${paramType}');

      // TODO: Check types before trying to parse and throw helpful error message
      // TODO: Add custom type building using constructors with named params

      switch (paramType) {
        case String:
          params.add(paramValue.toString());
          break;
        case int:
          params.add(int.parse(paramValue));
          break;
        case double:
          params.add(double.parse(paramValue));
          break;
        default:
          params.add(paramValue);
      }
    }

    controller.invoke(
      Symbol('call'),
      [
        request,
        handler.reflectee,
        params,
      ]
    );
  }

Future<Map<String, dynamic>> parseBodyAsJson(HttpRequest request) async {
    var contentType = request.headers.contentType;

    try {
      if (request.method == 'POST' && contentType != null &&
          contentType.mimeType == 'application/json') {
        var content = await utf8.decoder.bind(request).join();

        return jsonDecode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      print(e);
    }

    return null;
  }
}