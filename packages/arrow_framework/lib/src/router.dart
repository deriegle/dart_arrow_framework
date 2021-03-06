part of arrow_framework;

class Router {
  List<ArrowRoute> routes = [];

  Router() {
    final controllers = scanControllers();

    routes.addAll(generateArrowRoutes(controllers));
  }

  factory Router.withControllers(List<ClassMirror> controllers) {
    final r = Router();
    r.routes.addAll(generateArrowRoutes(controllers));
    return r;
  }

  /// Checks if there is a route defined that matches the incoming HTTP request
  ///
  /// @param HttpRequest request
  ///
  /// returns [RouteMatch]
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

  /// Serves an HTTP request after it has been matched
  ///
  /// Looks through handler to find required parameters and builds them based
  /// on the Body and Param annotations
  ///
  Future<void> serve(HttpRequest request, RouteMatch match) async {
    final controller = match.route.classMirror.newInstance(Symbol(''), []);
    final handler = controller.getField(match.route.methodMirror.simpleName);
    final params = <dynamic>[];
    final jsonBody = await _parseBodyAsJson(request);
    final routeParameters = match.route.extractParameters(request.uri.path);

    for (final param in match.route.methodMirror.parameters) {
      final paramMetadata = param.metadata.firstWhere(
        (el) => el.reflectee is Body || el.reflectee is Param,
        orElse: () => null,
      );

      if (paramMetadata == null) {
        throw Exception(
            'You must use the Body() or Param() annotations for controller method params');
      }

      final paramType = param.type.reflectedType;

      // Using Body annotation
      if (paramMetadata.reflectee is Body) {
        var body = paramMetadata;
        if (body == null) {
          continue;
        }

        final bodyParamName = body.getField(#paramName).reflectee;
        final bodyParamIsRequired = body.getField(#required).reflectee as bool;

        if (jsonBody == null ||
            bodyParamIsRequired &&
                bodyParamName != null &&
                !jsonBody.containsKey(bodyParamName)) {
          request.response.statusCode = HttpStatus.badRequest;
          request.response.write('${bodyParamName} body param is required.');
          await request.response.close();
          return;
        }

        var paramValue =
            bodyParamName == null ? jsonBody : jsonBody[bodyParamName];
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
        final queryParamName =
            paramMetadata.getField(#paramName).reflectee as String;
        final queryParamIsRequired =
            paramMetadata.getField(#required).reflectee as bool;
        final allParameters = {
          ...request.uri.queryParameters,
          ...routeParameters,
        };

        if (queryParamIsRequired &&
            !allParameters.containsKey(queryParamName)) {
          request.response.statusCode = HttpStatus.badRequest;
          request.response.write('${queryParamName} query param is required.');
          await request.response.close();
          return;
        }

        var queryParamValue = allParameters[queryParamName];

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

  void _addParam(List<dynamic> params, Type paramType, dynamic paramValue) {
    const dartTypes = [String, dynamic, int, Map, double, List, Symbol];

    if (!dartTypes.contains(paramType) && paramValue is Map) {
      // Using custom class with named parameter constructor
      // Initialize constructor and pass into parameters.
      // Very likely to throw an error.
      _addDynamicClassTypeToParams(params, paramType, paramValue);
      return;
    }

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
      case Symbol:
        params.add(Symbol(paramValue.toString()));
        break;
      case List:
      default:
        params.add(paramValue);
    }
  }

  void _addDynamicClassTypeToParams(
    List<dynamic> params,
    Type paramType,
    dynamic paramValue,
  ) {
    final reflectedClass = reflectClass(paramType);
    final constructors = reflectedClass.declarations.values
        .where(
          (d) => d is MethodMirror && d.isConstructor,
        )
        .toList();

    final MethodMirror constructor = constructors.firstWhere(
        (c) =>
            c is MethodMirror &&
            c.parameters.isNotEmpty &&
            !c.parameters.any((p) => !p.isNamed),
        orElse: () => null);

    if (constructor == null) {
      throw Exception(
        'You must provide a constructor that does not have positional arguments to parse',
      );
    }

    final constructorParameters = <Symbol, dynamic>{};

    for (var param in constructor.parameters) {
      if (!paramValue.containsKey(param.simpleName) && !param.isOptional) {
        throw Exception(
          '${param.simpleName} is required to initalize ${paramType}',
        );
      }

      constructorParameters[param.simpleName] =
          paramValue[symbolToString(param.simpleName)];
    }

    final dynamicClass = reflectedClass
        .newInstance(
          constructor.constructorName,
          [],
          constructorParameters,
        )
        .reflectee;

    params.add(dynamicClass);
  }
}

String symbolToString(Symbol symbol) {
  final newSymbol = symbol.toString().substring(8);
  return newSymbol.substring(0, newSymbol.length - 2);
}
