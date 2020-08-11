part of arrow_framework_orm_example;

class User extends ArrowModel<User> {
  @PrimaryKey()
  String id;
  String email;
  String password;
}
