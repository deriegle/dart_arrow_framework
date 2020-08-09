import 'package:arrow_framework/arrow_framework.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

ArrowRoute buildMockArrowRoute({
  @required String methodRoute,
  String controllerRoute,
  List<String> methods = const [GET],
}) {
  return ArrowRoute(
    methodRoute: methodRoute,
    controllerRoute: controllerRoute,
    methods: methods,
  );
}

void main() {
  group('ArrowRoute', () {
    test('route works as expected', () {
      expect(
        buildMockArrowRoute(methodRoute: 'transactions').route,
        '/transactions',
      );

      expect(
        buildMockArrowRoute(
          methodRoute: 'transactions',
          controllerRoute: '/api/v1/',
        ).route,
        '/api/v1/transactions',
      );
    });

    group('match', () {
      test('matches correctly', () {
        final route = buildMockArrowRoute(methodRoute: 'transactions');

        expect(route.match(Uri.parse('/transactions'), 'GET'), true);
      });
    });
  });
}
