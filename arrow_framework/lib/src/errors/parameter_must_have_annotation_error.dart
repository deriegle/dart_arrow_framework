part of arrow_framework;

class ParameterMustHaveAnnotationError implements ArgumentError {
  ParameterMustHaveAnnotationError(
    MethodMirror methodMirror,
    ParameterMirror parameterMirror,
  ) : message =
            '${symbolToString(methodMirror.owner.simpleName)}.${symbolToString(methodMirror.simpleName)} has an invalid parameter: ${symbolToString(parameterMirror.simpleName)}. You must use a Body() or Param() annotation around each argument.';

  @override
  final String message;

  @override
  dynamic get invalidValue => throw UnimplementedError();

  @override
  String get name => throw UnimplementedError();

  @override
  StackTrace get stackTrace => throw UnimplementedError();
}
