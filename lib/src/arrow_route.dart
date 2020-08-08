part of arrow_framework;

class _ArrowRoute {
  String controllerRoute;
  String methodRoute;
  List<String> methods;
  List<ClassMirror> preMiddleware;
  List<ClassMirror> postMiddleware;
  ClassMirror classMirror;
  MethodMirror methodMirror;

  _ArrowRoute({
    @required this.methodRoute,
    @required this.methods,
    this.preMiddleware = const [],
    this.postMiddleware = const [],
    this.classMirror,
    this.methodMirror,
    this.controllerRoute = '',
  });

  bool match(HttpRequest request) {
    print('methods: $methods');
    print('requestMethod: ${request.method}');
    if (methods.isEmpty || methods.contains(request.method)) {
      return request.uri.path == route;
    }

    return false;
  }

  String get route {
    if (controllerRoute == null || controllerRoute.isEmpty) {
      return methodRoute;
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


