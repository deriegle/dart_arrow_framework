import 'package:arrow_framework_open_api_generator/arrow_framework_open_api_generator.dart';

void main() {
  ArrowFrameworkOpenApiGenerator(routes: [
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
  ])
      .addTitle('Basic Application')
      .addDescription('Example Arrow Framework OpenAPi generate')
      .addServer(
        url: 'http://localhost:3000',
        description: 'Local server',
      )
      .saveToFile('./api.json');
}
