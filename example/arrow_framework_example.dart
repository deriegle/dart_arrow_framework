library arrow_framework_example;

import 'package:arrow_framework/arrow_framework.dart';

void main() => serve();

class User {
  User(this.id, this.email, this._password);

  final int id;
  final String email;
  final String _password;

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
  void emailSignup(@Body('email') String email, @Body('password') String password) {
   final user = User(1, email, '1234');

    json({
      'user': user,
    });
  }

  @Route.post('/facebook/')
  void facebookSignup(
      @Body('facebookUserId') userId,
      @Body('facebookAuthToken') authToken,
  ) {

   json({ 'success': true });
  }
}

