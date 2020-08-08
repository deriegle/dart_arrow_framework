part of arrow_framework;

const GET = 'GET';
const POST = 'POST';
const DELETE = 'DELETE';
const PUT = 'PUT';
const ALL_METHODS = [GET, POST, DELETE, PUT];

class Route {
  const Route(this.path, {this.method = 'GET'});

  const Route.post(this.path) : method = 'POST';
  const Route.get(this.path) : method = 'GET';
  const Route.delete(this.path) : method = 'DELETE';
  const Route.put(this.path) : method = 'PUT';
  const Route.all(this.path) : method = null;

  final String path;
  final String method;
}

class Body {
  const Body([this.paramName]) : required = true;
  const Body.optional([this.paramName]) : required = false;

  final String paramName;
  final bool required;
}

class Param {
  const Param(this.paramName, {this.required = true});
  const Param.optional([this.paramName]) : required = false;

  final String paramName;
  final bool required;
}

class Controller {
  const Controller(this.basePath);

  final String basePath;
}
