library arrow_framework_orm_example;

import 'package:arrow_framework_orm/arrow_framework_orm.dart';

part './models/user.dart';

void main() async {
  final user = User()
    ..email = 'riegledevin@gmail.com'
    ..password = 'cats';

  print('saved: ' + user.persisted.toString());

  await user.save();

  print('saved: ' + user.persisted.toString());
}
