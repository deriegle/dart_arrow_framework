part of arrow_framework_example;

@Controller('/signups/')
class SignupsController extends ArrowController {
  @Route.get('/check_status')
  void checkSignupStatus(@Param('id') int id) {
    json({
      'status': 'good',
    });
  }

  @Route.post('/email/')
  void emailSignup(@Body() User user) {
    json({
      'user': user,
    });
  }

  @Route.post('/facebook/')
  void facebookSignup(@Body() FacebookUser user) {
    json({'user': user});
  }
}
