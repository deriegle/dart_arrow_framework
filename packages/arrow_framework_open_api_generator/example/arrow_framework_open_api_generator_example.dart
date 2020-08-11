import 'package:arrow_framework/arrow_framework.dart';
import 'package:arrow_framework_open_api_generator/arrow_framework_open_api_generator.dart';

@Controller('/api/v1')
class MockController extends ArrowController {
  @Route.get('users')
  void getAllUsers() {}

  @Route.get('users/:userId')
  void getUser(@Param('userId') String userId) {}

  @Route.post('users')
  void createUser(
    @Body('email') String email,
    @Body('password') String password,
  ) {}
}

void main() {
  final framework = ArrowFramework(autoInit: false);

  ArrowFrameworkOpenApiGenerator.fromFramework(framework)
      .addTitle('Basic Application')
      .addVersion('1.0.0')
      .addDescription('Example Arrow Framework OpenAPI generate')
      .addServer(url: 'http://localhost:3000', description: 'Local server')
      .saveToFile(
          './packages/arrow_framework_open_api_generator/example/api.json');
}
