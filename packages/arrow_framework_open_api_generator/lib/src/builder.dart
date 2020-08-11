part of arrow_framework_open_api_generator;

class _OpenApiBuilder {
  final _routes = <OpenApiRoute>[];
  final _servers = <Map<String, dynamic>>[];
  String title;
  String description;
  String version;

  void addRoutes(List<OpenApiRoute> routes) {
    _routes.addAll(routes);
  }

  void addServer(Map<String, dynamic> server) {
    _servers.add(server);
  }

  Map<String, dynamic> toJson() {
    return {
      'openapi': '3.0.0',
      'info': {
        'title': title,
        'description': description,
        'version': version,
      },
      'paths': _routesToPaths(),
      'components': {},
      'tags': [],
      'servers': _servers,
    };
  }

  Map<String, dynamic> _routesToPaths() {
    final paths = <String, dynamic>{};

    for (final route in _routes) {
      if (paths.containsKey(route.route)) {
        if (paths[route.route].containsKey(route.method)) {
          throw Exception(
              'Route and method exist already: [${route.method.toUpperCase()}] ${route.route}');
        } else {
          // route exists, but method does not
          paths[route.route][route.method] = {
            'tags': [],
            'responses': {
              '200': {
                'description': '',
              }
            },
            'parameters': route.parameters.map((p) => p.toJson()).toList(),
          };
        }
      } else {
        paths[route.route] = {
          route.method: {
            'tags': [],
            'responses': {
              '200': {
                'description': '',
              }
            },
            'parameters': route.parameters.map((p) => p.toJson()).toList(),
          }
        };
      }
    }

    return paths;
  }
}
