part of arrow_framework;

/// Uses the list of ArrowController inherited controllers to generate
/// a list of ArrowRoute objects with the appropriate mirrors
///
/// Validates the presence of Body/Param annotations on parameters
/// Validates Body parameters aren't used on requests that do not have a body
///
List<ArrowRoute> generateArrowRoutes(List<ClassMirror> controllers) {
  final routes = <ArrowRoute>[];

  for (final controllerMirror in controllers) {
    final basePath = _getBasePathFromController(controllerMirror);

    for (final methodMirror in controllerMirror.instanceMembers.values) {
      final routeMetadata = methodMirror.metadata
          .firstWhere((m) => m.reflectee is Route, orElse: () => null);

      if (routeMetadata != null) {
        final methodRoute = routeMetadata.getField(#path).reflectee;
        final String httpMethod = routeMetadata.getField(#method).reflectee;

        _validateHandlerParameters(httpMethod, methodMirror);

        routes.add(
          ArrowRoute(
            methodRoute: methodRoute,
            methods: httpMethod == null ? ALL_METHODS : [httpMethod],
            controllerRoute: basePath,
            classMirror: controllerMirror,
            methodMirror: methodMirror,
            preMiddleware: [],
            postMiddleware: [],
          ),
        );
      }
    }
  }

  return routes;
}

String _getBasePathFromController(ClassMirror controllerMirror) {
  var basePath = '';

  final routeMetadata = controllerMirror.metadata
      .firstWhere((meta) => meta.reflectee is Controller, orElse: () => null);

  if (routeMetadata != null) {
    basePath = routeMetadata.getField(#basePath).reflectee;
  }

  return basePath;
}

void _validateHandlerParameters(String httpMethod, MethodMirror handlerMirror) {
  final parameterWithoutAnnotation = handlerMirror.parameters
      .firstWhere((p) => p.metadata.isEmpty, orElse: () => null);

  if (parameterWithoutAnnotation != null) {
    throw ParameterMustHaveAnnotationError(
      handlerMirror,
      parameterWithoutAnnotation,
    );
  }

  if (httpMethod == GET) {
    final bodyParameter = handlerMirror.parameters.firstWhere(
      (p) => p.metadata.first.reflectee is Body,
      orElse: () => null,
    );

    if (bodyParameter != null) {
      throw RouteMethodDoesNotSupportBodyError(
        handlerMirror,
        bodyParameter,
      );
    }
  }
}
