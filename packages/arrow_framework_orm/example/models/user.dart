part of arrow_framework_orm_example;

class User extends ArrowModel<User> {
  @PrimaryKey()
  String id;

  // @Column()
  String email;

  // @Column()
  String password;
}
