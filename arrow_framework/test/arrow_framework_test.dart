import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';
import 'package:arrow_framework/arrow_framework.dart';
import 'package:mock_request/mock_request.dart';
import 'package:test/test.dart';
import './support/expectations.dart';
import './support/mock_controllers.dart';

void main() {
  group('ArrowFramework', () {
    ArrowFramework framework;

    setUp(() {
      final router = Router.withControllers([
        reflectClass(MockController),
      ]);

      framework = ArrowFramework(
        autoInit: false,
        router: router,
      );
    });

    test('GET request to Route.all handler', () async {
      final request = MockHttpRequest(GET, Uri.parse('/api/v1/balloons'));
      await request.close();
      await framework.handleRequest(request);
      await expectJson(request.response, {
        'hello': true,
      });
    });

    test('POST request to Route.post handler', () async {
      final request = MockHttpRequest(
        POST,
        Uri.parse('/api/v1/signups'),
      );

      request.headers.contentType = ContentType.json;
      request.write(
        jsonEncode({'email': 'test@example.com', 'password': 'password'}),
      );

      await request.close();
      await framework.handleRequest(request);
      await expectJson(request.response, {
        'user': {
          'id': 123,
          'email': 'test@example.com',
        }
      });
    });

    test('GET request to Route.get handler without optional params', () async {
      final request = MockHttpRequest(
        GET,
        Uri.parse('/api/v1/users?id=12345678910'),
      );

      await request.close();
      await framework.handleRequest(request);
      await expectJson(request.response, {
        'success': true,
        'user': {
          'id': '12345678910',
        }
      });
    });

    test('GET request to Route.get handler without required params', () async {
      final request = MockHttpRequest(
        GET,
        Uri.parse('/api/v1/users'),
      );

      await request.close();
      await framework.handleRequest(request);
      await expectText(request.response, 'id query param is required.');
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
      expect(routes.length, 4);
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

    group('when given invalid controllers', () {
      ClassMirror controller;

      group('GET handler with a Body() parameter', () {
        setUp(() {
          controller = reflectClass(MockInvalidBodyParameterController);
          controllers = [];
          controllers.add(controller);
        });

        test('throws RouteMethodDoesNotSupportBodyError', () {
          expect(
            () => generateArrowRoutes(controllers),
            throwsA(predicate((e) => e is RouteMethodDoesNotSupportBodyError)),
          );
        });

        test('throws helpful error message', () {
          expect(() => generateArrowRoutes(controllers), throwsA(predicate((e) {
            final errorMessage =
                'MockInvalidBodyParameterController.mockGet has an invalid parameter: email. You cannot access Body() on a GET handler.';

            return e is RouteMethodDoesNotSupportBodyError &&
                e.message == errorMessage;
          })));
        });
      });

      group('Handler with no annotations on parameters', () {
        setUp(() {
          controller =
              reflectClass(MockInvalidParameterWithoutAnnotationController);
          controllers = [];
          controllers.add(controller);
        });

        test('throws ParameterMustHaveAnnotationError', () {
          expect(
            () => generateArrowRoutes(controllers),
            throwsA(predicate((e) => e is ParameterMustHaveAnnotationError)),
          );
        });

        test('throws helpful error message', () {
          expect(() => generateArrowRoutes(controllers), throwsA(predicate((e) {
            final errorMessage =
                'MockInvalidParameterWithoutAnnotationController.mockPost has an invalid parameter: name. You must use a Body() or Param() annotation around each argument.';

            return e is ParameterMustHaveAnnotationError &&
                e.message == errorMessage;
          })));
        });
      });

      group('Route.all handler with a Body() parameter', () {
        setUp(() {
          controller = reflectClass(MockInvalidBodyOnRouteAllHandlerController);
          controllers = [];
          controllers.add(controller);
        });

        test('throws RouteMethodDoesNotSupportBodyError', () {
          expect(
            () => generateArrowRoutes(controllers),
            throwsA(predicate((e) => e is RouteMethodDoesNotSupportBodyError)),
          );
        });

        test('throws helpful error message', () {
          expect(() => generateArrowRoutes(controllers), throwsA(predicate((e) {
            final errorMessage =
                'MockInvalidBodyOnRouteAllHandlerController.mockAll has an invalid parameter: email. You cannot access Body() on a GET handler.';

            return e is RouteMethodDoesNotSupportBodyError &&
                e.message == errorMessage;
          })));
        });
      });
    });
  });
}
