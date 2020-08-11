part of arrow_framework_orm;

enum DatabaseType {
  memory,
  sqlite,
  postgresql,
}

class PrimaryKey {
  const PrimaryKey();
}

class Model {
  final String tableName;

  const Model({this.tableName});
}

class ArrowModel<ModelType> {
  bool _persisted = false;

  bool get persisted => _persisted;

  Future save() async {
    final reflected = reflectClass(runtimeType);
    final variables = <VariableMirror>[];
    VariableMirror primaryKey;

    reflected.declarations.forEach((key, value) {
      if (value is VariableMirror) {
        final primaryKeyMetadata = value.metadata.firstWhere(
          (e) => e.reflectee is PrimaryKey,
          orElse: () => null,
        );
        if (primaryKeyMetadata != null) {
          if (primaryKey != null) {
            throw Exception('Multiple primary keys found');
          }

          primaryKey = value;
        } else {
          variables.add(value);
        }
      }
    });

    final modelMetadataMirror =
        reflected.metadata.firstWhere((m) => m is Model, orElse: () => null);
    var tableName = _tableNameFromClassName(reflected.simpleName);

    if (modelMetadataMirror != null && modelMetadataMirror.reflectee is Model) {
      tableName = (modelMetadataMirror.reflectee as Model).tableName;
    }

    final variableNames =
        variables.map<String>((v) => _symbolToString(v.simpleName)).toList();
    final variableValues = variables.map<dynamic>(
        (v) => '\'${reflect(this).getField(v.simpleName).reflectee}\'');

    final query = '''
INSERT INTO ${tableName} (${variableNames.join(', ')})
VALUES (${variableValues.join(', ')}) 
WHERE ${_symbolToString(primaryKey.simpleName)} = '${reflect(this).getField(primaryKey.simpleName).reflectee}';
    '''
        .trim();

    _persisted = true;

    print(query);
  }

  String _symbolToString(Symbol sym) {
    final str = sym.toString().substring(8);
    return str.substring(0, str.length - 2);
  }

  String _tableNameFromClassName(Symbol className) {
    return '${_symbolToString(className).toLowerCase()}s';
  }
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
