part of arrow_framework_example;

class User {
  User({
    @required this.id,
    @required this.email,
    @required this.password,
  });

  final int id;
  final String email;
  final String password;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
    };
  }
}
