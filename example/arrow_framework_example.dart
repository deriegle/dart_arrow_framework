library arrow_framework_example;

import 'package:meta/meta.dart';
import 'package:arrow_framework/arrow_framework.dart';

void main() => serve();

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

@Controller('/signups/')
class SignupsController extends ArrowController {
  @Route.get('/check_status')
  void checkSignupStatus(@Param('id') int id) {
    json({
      'status': 'good',
    });
  }

  @Route.post('/email/')
  void emailSignup(@Body('user') User user) {
    json({
      'user': user,
    });
  }

  @Route.post('/facebook/')
  void facebookSignup(
    @Body('facebookUserId') userId,
    @Body('facebookAuthToken') authToken,
  ) {
    json({'success': true});
  }
}
