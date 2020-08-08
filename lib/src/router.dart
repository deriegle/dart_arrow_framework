part of arrow_framework;

class RouteMatch {
  RouteMatch([this.matched = false, this.route]);

  ArrowRoute route;
  bool matched;
}

class Router {
  List<ArrowRoute> routes = [];

  Router() {
    final controllers = scanControllers();

    print('controllers');
    print(controllers);

    routes.addAll(generateArrowRoutes(controllers));
  }

  RouteMatch matchRequest(HttpRequest request) {
    var match = RouteMatch(false);

    for (var route in routes) {
      if (route.match(request.uri, request.method)) {
        match = RouteMatch(true, route);
        break;
      }
    }

    return match;
  }

  Future<void> serve(HttpRequest request, RouteMatch match) async {
    var controller = match.route.classMirror.newInstance(Symbol(''), []);
    var handler = controller.getField(match.route.methodMirror.simpleName);
    var params = <dynamic>[];
    var jsonBody = await parseBodyAsJson(request);

    for (var param in match.route.methodMirror.parameters) {
      var paramMetadata = param.metadata.firstWhere(
          (el) => el.reflectee is Body || el.reflectee is Param,
          orElse: () => null);

      if (paramMetadata == null) {
        throw Exception(
          'You must use the Body() or Param() annotations for controller method params',
        );
      }

      var paramType = param.type.reflectedType;

      // Using Body annotation
      if (paramMetadata.reflectee is Body) {
        var body = paramMetadata;
        if (body == null) {
          continue;
        }

        final bodyParamName = body.getField(#paramName).reflectee;
        final bodyParamIsRequired = body.getField(#required).reflectee as bool;

        if (jsonBody == null ||
            bodyParamIsRequired && !jsonBody.containsKey(bodyParamName)) {
          request.response.statusCode = HttpStatus.badRequest;
          request.response.write('${bodyParamName} body param is required.');
          await request.response.close();
          return;
        }

        var paramValue = jsonBody[bodyParamName];
        var paramType = param.type.reflectedType;

        if (paramValue == null && bodyParamIsRequired) {
          request.response.statusCode = HttpStatus.badRequest;
          request.response.write('${bodyParamName} body param is required.');
          await request.response.close();
          return;
        }

        _addParam(params, paramType, paramValue);

        // Using Param annotation
      } else if (paramMetadata.reflectee is Param) {
        final queryParamName = paramMetadata.getField(#paramName) as String;
        final queryParamIsRequired =
            paramMetadata.getField(#required).reflectee as bool;

        if (queryParamIsRequired &&
            !request.uri.queryParameters.containsKey(queryParamName)) {
          request.response.statusCode = HttpStatus.badRequest;
          request.response.write('${queryParamName} query param is required.');
          await request.response.close();
          return;
        }

        var queryParamValue = request.uri.queryParameters[queryParamName];

        if (queryParamIsRequired && queryParamValue == null) {
          request.response.statusCode = HttpStatus.badRequest;
          request.response.write('${queryParamName} query param is required.');
          await request.response.close();
          return;
        }

        _addParam(params, paramType, queryParamValue);
      }
    }

    controller.invoke(#call, [
      request,
      handler.reflectee,
      params,
    ]);
  }

  void _addParam(List<dynamic> params, dynamic paramType, dynamic paramValue) {
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

  Future<Map<String, dynamic>> parseBodyAsJson(HttpRequest request) async {
    var contentType = request.headers.contentType;

    try {
      if (request.method == 'POST' &&
          contentType != null &&
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
