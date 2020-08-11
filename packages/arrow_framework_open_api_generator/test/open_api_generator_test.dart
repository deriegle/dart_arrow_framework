import 'dart:convert';
import 'dart:mirrors';

import 'package:arrow_framework/arrow_framework.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:test/test.dart';
import 'package:arrow_framework_open_api_generator/arrow_framework_open_api_generator.dart';

@Controller('/api/v1')
class MockController {
  @Route.post('users')
  void bodyMethodMirror(
    @Body('email') String email,
    @Body('password') String password,
  ) {}
}

void main() {
  FileSystem fileSystem;

  setUp(() {
    fileSystem = MemoryFileSystem();
  });

  group('ArrowFrameworkOpenApiGenerator', () {
    group('when given invalid routes', () {
      test('it throws exception', () {
        expect(
          () => ArrowFrameworkOpenApiGenerator(routes: [
            'Hello, world',
          ]),
          throwsA(predicate(
            (Exception e) =>
                e is Exception &&
                e.toString().contains(
                    'Routes must be instances of ArrowRoute or OpenApiRoute. Found "String"'),
          )),
        );
      });
    });

    group('when given ArrowRoutes', () {
      ArrowFrameworkOpenApiGenerator generator;

      setUp(() {
        generator = ArrowFrameworkOpenApiGenerator(
          fileSystem: fileSystem,
          routes: [
            ArrowRoute(
              controllerRoute: '/api/v1',
              methodRoute: 'users',
              methods: ['get'],
            ),
            ArrowRoute(
              controllerRoute: '/api/v1',
              methodRoute: 'users/:userId',
              methods: ['get'],
            ),
            ArrowRoute(
                controllerRoute: '/api/v1',
                methodRoute: 'users',
                methods: ['post'],
                methodMirror: reflectClass(MockController)
                    .instanceMembers
                    .values
                    .firstWhere((m) => m.simpleName == #bodyMethodMirror)),
          ],
        )
            .addTitle('My Test Open API spec')
            .addDescription('Test description')
            .addVersion('1.0.0')
            .addServer(
              url: 'localhost:3000',
              description: 'local server',
            );
      });

      test('generator saves the file', () async {
        await generator.saveToFile('./api.json');

        final file = fileSystem.file('./api.json');
        expect(await file.exists(), true);

        final fileContents = await file.readAsString();
        expect(fileContents, isNotEmpty);
      });

      test('saves the expected metadata', () async {
        await generator.saveToFile('./api.json');
        final file = fileSystem.file('./api.json');
        final fileContents = await file.readAsString();
        final json = jsonDecode(fileContents);

        expect(json['openapi'], '3.0.0');
        expect(json['tags'], isEmpty);
        expect(json['info'], {
          'title': 'My Test Open API spec',
          'description': 'Test description',
          'version': '1.0.0'
        });
        expect(json['servers'], [
          {'url': 'localhost:3000', 'description': 'local server'}
        ]);
      });

      test('saves the expected path data', () async {
        await generator.saveToFile('./api.json');
        final file = fileSystem.file('./api.json');
        final fileContents = await file.readAsString();
        final json = jsonDecode(fileContents);
        final Map<String, dynamic> paths = json['paths'];

        expect(paths.containsKey('/api/v1/users'), true);
        expect(paths.containsKey('/api/v1/users/{userId}'), true);

        final Map<String, dynamic> usersPath = paths['/api/v1/users'];
        final Map<String, dynamic> userPath = paths['/api/v1/users/{userId}'];

        expect(usersPath.keys.toList(), ['get', 'post']);
        expect(userPath.keys.toList(), ['get']);
        expect(usersPath['get'], {
          'tags': [],
          'responses': {
            '200': {'description': ''},
          },
          'parameters': [],
        });
        expect(usersPath['post'], {
          'tags': [],
          'responses': {
            '200': {'description': ''},
          },
          'parameters': [
            {
              'name': 'email',
              'required': true,
              'in': 'body',
              'schema': {
                'type': 'string',
              }
            },
            {
              'name': 'password',
              'required': true,
              'in': 'body',
              'schema': {
                'type': 'string',
              }
            }
          ],
        });
        expect(userPath['get'], {
          'tags': [],
          'responses': {
            '200': {'description': ''},
          },
          'parameters': [
            {
              'name': 'userId',
              'required': true,
              'in': 'path',
              'schema': {
                'type': 'string',
              }
            }
          ]
        });
      });
    });

    group('when given OpenApiRoutes', () {
      ArrowFrameworkOpenApiGenerator generator;

      setUp(() {
        generator = ArrowFrameworkOpenApiGenerator(
          fileSystem: fileSystem,
          routes: [
            OpenApiRoute(route: '/api/v1/users', method: 'get', parameters: []),
            OpenApiRoute(
              route: '/api/v1/users/{userId}',
              method: 'get',
              parameters: [
                OpenApiParameter(
                  name: 'userId',
                  type: String,
                  location: OpenApiParameterLocation.path,
                  isRequired: true,
                ),
              ],
            ),
            OpenApiRoute(
              route: '/api/v1/users',
              method: 'post',
              parameters: [
                OpenApiParameter(
                  name: 'email',
                  type: String,
                  location: OpenApiParameterLocation.body,
                  isRequired: true,
                ),
                OpenApiParameter(
                  name: 'password',
                  type: String,
                  location: OpenApiParameterLocation.body,
                  isRequired: true,
                ),
              ],
            ),
          ],
        )
            .addTitle('My Test Open API spec')
            .addDescription('Test description')
            .addVersion('1.0.0')
            .addServer(
              url: 'localhost:3000',
              description: 'local server',
            );
      });

      test('generator saves the file', () async {
        await generator.saveToFile('./api.json');

        final file = fileSystem.file('./api.json');
        expect(await file.exists(), true);

        final fileContents = await file.readAsString();
        expect(fileContents, isNotEmpty);
      });

      test('saves the expected metadata', () async {
        await generator.saveToFile('./api.json');
        final file = fileSystem.file('./api.json');
        final fileContents = await file.readAsString();
        final json = jsonDecode(fileContents);

        expect(json['openapi'], '3.0.0');
        expect(json['tags'], isEmpty);
        expect(json['info'], {
          'title': 'My Test Open API spec',
          'description': 'Test description',
          'version': '1.0.0'
        });
        expect(json['servers'], [
          {'url': 'localhost:3000', 'description': 'local server'}
        ]);
      });

      test('saves the expected path data', () async {
        await generator.saveToFile('./api.json');
        final file = fileSystem.file('./api.json');
        final fileContents = await file.readAsString();
        final json = jsonDecode(fileContents);
        final Map<String, dynamic> paths = json['paths'];

        expect(paths.containsKey('/api/v1/users'), true);
        expect(paths.containsKey('/api/v1/users/{userId}'), true);

        final Map<String, dynamic> usersPath = paths['/api/v1/users'];
        final Map<String, dynamic> userPath = paths['/api/v1/users/{userId}'];

        expect(usersPath.keys.toList(), ['get', 'post']);
        expect(userPath.keys.toList(), ['get']);
        expect(usersPath['get'], {
          'tags': [],
          'responses': {
            '200': {'description': ''},
          },
          'parameters': [],
        });
        expect(usersPath['post'], {
          'tags': [],
          'responses': {
            '200': {'description': ''},
          },
          'parameters': [
            {
              'name': 'email',
              'required': true,
              'in': 'body',
              'schema': {
                'type': 'string',
              }
            },
            {
              'name': 'password',
              'required': true,
              'in': 'body',
              'schema': {
                'type': 'string',
              }
            }
          ],
        });
        expect(userPath['get'], {
          'tags': [],
          'responses': {
            '200': {'description': ''},
          },
          'parameters': [
            {
              'name': 'userId',
              'required': true,
              'in': 'path',
              'schema': {
                'type': 'string',
              }
            }
          ]
        });
      });
    });
  });
}
