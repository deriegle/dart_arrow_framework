part of arrow_framework;

class ArrowRoute {
  String controllerRoute;
  String methodRoute;
  List<String> methods;
  List<ClassMirror> preMiddleware;
  List<ClassMirror> postMiddleware;
  ClassMirror classMirror;
  MethodMirror methodMirror;

  ArrowRoute({
    @required this.methodRoute,
    @required this.methods,
    this.preMiddleware = const [],
    this.postMiddleware = const [],
    this.classMirror,
    this.methodMirror,
    this.controllerRoute = '/',
  });

  bool match(Uri uri, String method) {
    if (methods.isEmpty || methods.contains(method)) {
      return uri.path == route;
    }

    return false;
  }

  String get route {
    if (controllerRoute == null || controllerRoute.isEmpty) {
      return '/${_stripSlashes(methodRoute)}';
    } else {
      return '/${_stripSlashes(controllerRoute)}/${_stripSlashes(methodRoute)}';
    }
  }

  @override
  String toString() {
    return '[${methods.join(',')}] $route';
  }

  String _stripSlashes(String route) {
    if (route.startsWith('/')) {
      route = route.substring(1);
    }

    if (route.endsWith('/')) {
      route = route.substring(0, route.length - 1);
    }

    return route;
  }
}

String realname(DeclarationMirror mirror) {
  return mirror.simpleName.toString().split('"')[1];
}
