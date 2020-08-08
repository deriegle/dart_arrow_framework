part of arrow_framework;

List<_ArrowRoute> generateArrowRoutes(List<ClassMirror> controllers) {
  var routes = <_ArrowRoute>[];

  for (var mirror in controllers) {
    var basePath = '';

    var routeMetadata = mirror.metadata.firstWhere((meta) => meta.reflectee is Controller, orElse: () => null);

    if (routeMetadata != null) {
      var basePathMirror = routeMetadata.getField(Symbol('basePath'));
      basePath = basePathMirror.reflectee;
    }

    for (var methodMirror in mirror.instanceMembers.values) {
      var routeMetadata = methodMirror.metadata.firstWhere((m) => m.reflectee is Route, orElse: () => null);

      if (routeMetadata != null) {
        var methodPathMirror = routeMetadata.getField(Symbol('path'));
        var httpMethodMirror = routeMetadata.getField(Symbol('method'));
        var httpMethod = httpMethodMirror.reflectee;

        print('methodRoute: ${methodPathMirror.reflectee}');
        print('methods: [${httpMethodMirror.reflectee}]');

        routes.add(
          _ArrowRoute(
            methodRoute: methodPathMirror.reflectee,
            methods: httpMethod == null
              ? ALL_METHODS
              : [httpMethodMirror.reflectee],
            controllerRoute: basePath,
            classMirror: mirror,
            methodMirror: methodMirror,
            preMiddleware: [],
            postMiddleware: [],
          )
        );
      }
    }
  }

  return routes;
}