import 'package:mock_request/mock_request.dart';
import 'package:test/test.dart';
import 'dart:io';
import 'dart:convert';

Future<void> expectJson(MockHttpResponse res, dynamic expected) async {
  dynamic actualJson;

  await res.done;

  expect(
    res.headers.contentType?.mimeType,
    ContentType.json.mimeType,
    reason: 'Return type was not JSON',
  );

  final actualBody = await res.transform(utf8.decoder).join();

  expect(actualBody, isNotEmpty);

  actualJson = jsonDecode(actualBody);

  expect(actualJson, expected);
}

Future<void> expectText(MockHttpResponse res, String expected) async {
  await res.done;

  final actualBody = await res.transform(utf8.decoder).join();

  expect(actualBody, expected);
}
