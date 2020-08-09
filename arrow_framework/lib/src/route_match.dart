part of arrow_framework;

/// Object returned when checking for matching route for an incoming HTTP request
///
/// Used with Router.matchRequest
///
class RouteMatch {
  RouteMatch([this.matched = false, this.route]);

  ArrowRoute route;
  bool matched;
}
