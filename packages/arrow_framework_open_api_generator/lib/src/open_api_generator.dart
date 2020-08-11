part of arrow_framework_open_api_generator;

class ArrowFrameworkOpenApiGenerator {
  final _builder = _OpenApiBuilder();
  final FileSystem _fileSystem;

  ArrowFrameworkOpenApiGenerator({
    List<dynamic> routes = const [],
    FileSystem fileSystem,
  }) : _fileSystem = fileSystem ?? LocalFileSystem() {
    routes.forEach((route) {
      if (route is ArrowRoute) {
        _builder.addRoutes(route.toOpenApi());
      } else if (route is OpenApiRoute) {
        _builder.addRoutes([route]);
      } else {
        throw Exception(
          'Routes must be instances of ArrowRoute or OpenApiRoute. Found "${route.runtimeType}".',
        );
      }
    });
  }

  ArrowFrameworkOpenApiGenerator addTitle(String newTitle) {
    _builder.title = newTitle;
    return this;
  }

  ArrowFrameworkOpenApiGenerator addVersion(String newVersion) {
    _builder.version = newVersion;
    return this;
  }

  ArrowFrameworkOpenApiGenerator addDescription(String newDescription) {
    _builder.description = newDescription;
    return this;
  }

  ArrowFrameworkOpenApiGenerator addServer({String url, String description}) {
    _builder.addServer({
      'url': url,
      'description': description,
    });

    return this;
  }

  Future saveToFile(String fileName) async {
    final file = _fileSystem.file(fileName);
    final encoder = JsonEncoder.withIndent('    ');
    file.openWrite().write(encoder.convert(_builder.toJson()));
  }
}
