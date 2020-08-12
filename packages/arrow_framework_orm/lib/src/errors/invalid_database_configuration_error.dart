part of arrow_framework_orm;

class InvalidDatabaseConfigurationError extends ArgumentError {
  InvalidDatabaseConfigurationError(this.message);

  @override
  final String message;

  @override
  String toString() {
    return '$runtimeType($message)';
  }
}
