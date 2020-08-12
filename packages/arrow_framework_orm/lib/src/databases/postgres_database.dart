part of arrow_framework_orm;

class PostgresDatabaseTransactionContext implements DatabaseTransactionContext {
  final PostgreSQLExecutionContext _context;

  PostgresDatabaseTransactionContext(this._context);

  @override
  Future<List> query(String sql, {Map<String, dynamic> values}) {
    return _context.query(sql, substitutionValues: values);
  }
}

class PostgresDatabase implements Database {
  final PostgreSQLConnection _connection;

  PostgresDatabase(this.configuration)
      : _connection = PostgreSQLConnection(
          configuration['host'],
          configuration['port'],
          configuration['databaseName'],
        );

  @override
  void verifyConfig() {
    if (configuration.containsKey('host') &&
        configuration.containsKey('port') &&
        configuration.containsKey('databaseName')) {
      return;
    }

    throw InvalidDatabaseConfigurationError(
      'Host, port, and databaseName are required for Postgres.',
    );
  }

  @override
  Map<String, dynamic> configuration;

  @override
  Future<void> connect() {
    verifyConfig();
    return _connection.open();
  }

  @override
  Future<List> query(String sql, {Map<String, dynamic> values}) async {
    return await _connection.query(sql, substitutionValues: values);
  }

  @override
  Future transaction(Function(DatabaseTransactionContext) cb) =>
      _connection.transaction((connection) {
        final context = PostgresDatabaseTransactionContext(connection);
        return cb(context);
      });
}
