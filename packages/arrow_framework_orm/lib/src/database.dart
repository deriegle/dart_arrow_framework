part of arrow_framework_orm;

abstract class Database {
  Map<String, dynamic> configuration;

  Database(this.configuration);

  void verifyConfig() {}

  Future<void> connect();

  Future<List<dynamic>> query(String sql, {Map<String, dynamic> values});

  Future<dynamic> transaction(Function(DatabaseTransactionContext) cb);
}

abstract class DatabaseTransactionContext {
  Future<List<dynamic>> query(String sql, {Map<String, dynamic> values});
}
