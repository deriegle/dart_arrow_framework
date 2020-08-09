part of arrow_framework;

class RouteMethodDoesNotSupportBodyError implements ArgumentError {
  RouteMethodDoesNotSupportBodyError(
    MethodMirror methodMirror,
    ParameterMirror paramMirror,
  ) : message =
            '${symbolToString(methodMirror.owner.simpleName)}.${symbolToString(methodMirror.simpleName)} has an invalid parameter: ${symbolToString(paramMirror.simpleName)}. You cannot access Body() on a GET handler.';

  @override
  final String message;

  @override
  dynamic get invalidValue => throw UnimplementedError();

  @override
  String get name => throw UnimplementedError();

  @override
  StackTrace get stackTrace => throw UnimplementedError();
}
