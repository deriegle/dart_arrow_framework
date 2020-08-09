part of arrow_framework;

/// Parses HTTP request body into a JSON Map<String, dynamic> object
///
/// Returns null
///   - on Error
///   - on Requests that do not have a application/json content type
///   - on Requests with methods other than POST
///
Future<Map<String, dynamic>> _parseBodyAsJson(HttpRequest request) async {
  var contentType = request.headers.contentType;

  try {
    if (request.method == 'POST' &&
        contentType != null &&
        contentType.mimeType == 'application/json') {
      var content = await utf8.decoder.bind(request).join();

      return jsonDecode(content) as Map<String, dynamic>;
    }
  } catch (e) {
    print(e);
  }

  return null;
}
