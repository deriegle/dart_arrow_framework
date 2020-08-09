# Arrow Framework

Easiest Dart server-side framework

## Usage

Make sure your controllers extend `ArrowController`. You do not need a `Controller` annotation.
It is only used to add a basePath to all routes inside the controller like the example below.
You need to make sure your controller is in the same library as the rest of your code for it to be imported.

```dart
import 'package:arrow_framework/arrow_framework.dart';

@Controller('api/v1')
class TransactionsController extends ArrowController {
  @Route.get('transactions')
  void index() {
    json({
      'transactions': Transaction.all,
    });
  }

  @Route.post('transactions')
  void create(
    @Body('name') String name,
    @Body('amount') double amount,
    @Body.optional('description') String description,
  ) {
    // save new Transaction to database
    final transaction = Transaction(
      name: name,
      amount: amount,
      description: description,
    );

    json({
      'success': true,
      'transactionId': transaction.id,
    });
  }
}

main() => serve();
```

## Set custom port/address

```dart
void main() => ArrowFramework(
  address: '92.47.32.1',
  port: 9000,
);
```

## TODO
- Add ability to have routeParams
  - Example: `/api/v1/users/:userId/transactions/:transactionId`
- Add ability to add a custom 404 handler
- Add ORM with basic database abilities
