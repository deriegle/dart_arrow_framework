part of arrow_framework_orm;

enum DatabaseType {
  memory,
  sqlite,
  postgresql,
}

class ArrowFrameworkOrm {
  final String modelsFolder;
  final DatabaseType databaseType;

  const ArrowFrameworkOrm._({
    @required this.modelsFolder,
    @required this.databaseType,
  });

  factory ArrowFrameworkOrm.init({
    String modelsFolder = '',
    DatabaseType databaseType,
  }) {
    return ArrowFrameworkOrm._(
      modelsFolder: modelsFolder,
      databaseType: databaseType ?? DatabaseType.memory,
    );
  }
}

class Queriable {
  final String tableName;

  const Queriable({this.tableName});
}
