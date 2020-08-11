part of arrow_framework_open_api_generator;

class OpenApiRoute {
  final String route;
  final String method;
  final List<OpenApiParameter> parameters;

  const OpenApiRoute({
    @required this.route,
    @required this.method,
    @required this.parameters,
  });
}

enum OpenApiParameterLocation {
  query,
  path,
  cookie,
  body,
}

class OpenApiParameter {
  final String name;
  final bool isRequired;
  final Type type;
  final OpenApiParameterLocation location;

  const OpenApiParameter({
    @required this.name,
    @required this.type,
    @required this.location,
    @required this.isRequired,
  });

  Map<String, dynamic> toJson() {
    final stringLocation = location
        .toString()
        .substring(location.runtimeType.toString().length + 1);

    return {
      'name': name,
      'required': isRequired,
      'in': stringLocation,
      'schema': {
        'type': type.toString().toLowerCase(),
      },
    };
  }
}

extension ArrowRouteToOpenApi on ArrowRoute {
  List<OpenApiRoute> toOpenApi() {
    return methods.map<OpenApiRoute>((method) {
      return OpenApiRoute(
        route: openApiRoute,
        method: method.toLowerCase(),
        parameters: [...pathParameters, ...bodyParameters, ...queryParameters],
      );
    }).toList();
  }

  List<OpenApiParameter> get pathParameters {
    final params = <String>[];
    regExp(params);

    return params.map<OpenApiParameter>((String pathParam) {
      return OpenApiParameter(
        name: pathParam,
        type: String,
        location: OpenApiParameterLocation.path,
        isRequired: true,
      );
    }).toList();
  }

  List<OpenApiParameter> get bodyParameters {
    final params = methodMirror?.parameters;

    if (params == null) {
      return [];
    }

    return params
        .where((p) =>
            p.metadata
                .firstWhere((m) => m.reflectee is Body, orElse: () => null) !=
            null)
        .map<OpenApiParameter>((p) {
      final Body body =
          p.metadata.firstWhere((m) => m.reflectee is Body).reflectee;
      return OpenApiParameter(
        isRequired: body.required,
        location: OpenApiParameterLocation.body,
        name: body.paramName,
        type: p.type.reflectedType,
      );
    }).toList();
  }

  List<OpenApiParameter> get queryParameters {
    final params = methodMirror?.parameters;

    if (params == null) {
      return [];
    }

    return params
        .where((p) =>
            p.metadata
                .firstWhere((m) => m.reflectee is Param, orElse: () => null) !=
            null)
        .map<OpenApiParameter>((param) {
      final Param p =
          param.metadata.firstWhere((m) => m.reflectee is Param).reflectee;
      return OpenApiParameter(
        isRequired: p.required,
        location: OpenApiParameterLocation.query,
        name: p.paramName,
        type: String,
      );
    }).toList();
  }

  String get openApiRoute {
    final reg = RegExp(':[A-Za-z1-9]+', caseSensitive: false);

    return route.replaceAllMapped(reg, (m) => '{${m[0].substring(1)}}');
  }
}
