import 'package:arrow_framework/arrow_framework.dart';

@Controller('/api/v1')
class MockInvalidBodyParameterController extends ArrowController {
  @Route.get('signup')
  void mockGet(@Body('email') email, @Body('password') password) {}
}

@Controller('/api/v1')
class MockInvalidParameterWithoutAnnotationController extends ArrowController {
  @Route.post('users')
  void mockPost(String name) {}
}

class MockInvalidBodyOnRouteAllHandlerController extends ArrowController {
  @Route.all('signup')
  void mockAll(@Body('email') email) {}
}

@Controller('/api/v1/')
class MockController extends ArrowController {
  @Route.post('signups')
  void mockPost(@Body('email') email, @Body('password') password) {
    json({
      'user': {
        'id': 123,
        'email': email,
      }
    });
  }

  @Route.get('users')
  void mockGet(@Param('id') String id, @Param.optional('email') email) {
    json({
      'success': true,
      'user': {
        'id': id,
      },
    });
  }

  @Route.all('balloons')
  void mockBalloons() {
    json({
      'hello': true,
    });
  }

  // Does not throw with optional Body() parameter on Route.all handlers
  @Route.all('transactions')
  void mockTransactions(@Body.optional('transactionId') String transactionId) {
    json({
      'success': true,
      'transactionId': transactionId,
    });
  }
}
