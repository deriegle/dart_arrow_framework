import 'dart:async';

Future<void> waitFor(Function call,
    [Duration duration = const Duration(seconds: 5), int maxTimes = 5]) async {
  var times = 0;

  while (times < maxTimes) {
    try {
      dynamic result = await call();

      if (result is bool && result) {
        return;
      }
    } catch (e) {
      print(e);
    } finally {
      times++;
    }
  }

  final totalSeconds = duration.inSeconds * maxTimes;

  throw TimeoutException(
      'Timed out after $totalSeconds seconds waiting for condition.');
}
