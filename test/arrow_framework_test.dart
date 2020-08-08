import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';
import 'package:arrow_framework/arrow_framework.dart';
import 'package:mock_request/mock_request.dart';
import 'package:test/test.dart';
import './support/wait_for.dart';

@Controller('/api/v1/')
class MockController extends ArrowController {
  @Route.post('signups')
  void mockPost() {}

  @Route.get('users')
  void mockGet() {}

  @Route.all('balloons')
  void mockBalloons() {
    print('mock balloons called');
    this.json({
      'hello': true,
    });
  }
}

Future<void> expectJson(MockHttpResponse res, dynamic expected) async {
  String actualBody;
  dynamic actualJson;

  await waitFor(() async {
    actualBody = await res.transform(utf8.decoder).join();
    expect(res.headers.contentType, ContentType.json);
    if (actualBody.isEmpty) {
      return false;
    }

    actualJson = jsonDecode(actualBody);
  });

  expect(actualJson, expected);
}

void main() {
  group('ArrowFramework', () {
    ArrowFramework framework;

    setUp(() {
      final router = Router();
      framework = ArrowFramework(
        autoInit: false,
        router: router,
      );
    });

    test('works', () async {
      // final request = MockHttpRequest('GET', Uri.parse('/api/v1/balloons'));
      // await request.close();
      // await framework.handleRequest(request);
      // await expectJson(request.response, {});
    });
  });

  group('generateArrowRoutes', () {
    List<ClassMirror> controllers;
    List<ArrowRoute> routes;

    setUp(() {
      controllers = [];
      controllers.add(reflectClass(MockController));
      routes = generateArrowRoutes(controllers);
    });

    test('has expected number of routes', () {
      expect(routes.length, 3);
    });

    test('has expected routes', () {
      expect(routes[0].methods, [POST]);
      expect(routes[0].route, '/api/v1/signups');
      expect(routes[0].controllerRoute, '/api/v1/');
      expect(routes[0].methodRoute, 'signups');

      expect(routes[1].methods, [GET]);
      expect(routes[1].route, '/api/v1/users');
      expect(routes[1].controllerRoute, '/api/v1/');
      expect(routes[1].methodRoute, 'users');

      expect(routes[2].methods, ALL_METHODS);
      expect(routes[2].route, '/api/v1/balloons');
      expect(routes[2].controllerRoute, '/api/v1/');
      expect(routes[2].methodRoute, 'balloons');
    });

    test('matches routes correctly', () {
      var uri = Uri(path: '/api/v1/signups');
      expect(routes[0].match(uri, POST), true);
      expect(routes[0].match(uri, GET), false);
      expect(routes[0].match(uri, PUT), false);
      expect(routes[0].match(uri, DELETE), false);

      uri = Uri(path: '/api/v1/users');
      expect(routes[1].match(uri, GET), true);
      expect(routes[1].match(uri, POST), false);
      expect(routes[1].match(uri, PUT), false);
      expect(routes[1].match(uri, DELETE), false);

      uri = Uri(path: '/api/v1/balloons');

      ALL_METHODS.forEach((method) {
        expect(routes[2].match(uri, method), true);
      });
    });
  });
}
