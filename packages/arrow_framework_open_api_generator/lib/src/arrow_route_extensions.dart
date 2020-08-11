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
      final pathParameters = <String>[];
      regExp(pathParameters);

      return OpenApiRoute(
        route: route,
        method: method.toLowerCase(),
        parameters: [
          ...pathParameters.map<OpenApiParameter>((String pathParam) {
            return OpenApiParameter(
              name: pathParam,
              type: String,
              location: OpenApiParameterLocation.path,
              isRequired: true,
            );
          }),
        ],
      );
    });
  }
}
