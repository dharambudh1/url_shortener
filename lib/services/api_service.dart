import "dart:convert";
import "dart:developer";

import "package:http/http.dart" as http;

enum APIVersion { v0, v1 }

class APIService {
  factory APIService() {
    return _singleton;
  }

  APIService._internal();
  static final APIService _singleton = APIService._internal();

  final http.Client _client = http.Client();

  final String base = "spoo.me";

  String apiKey = ""; // Generate API key: https://spoo.me/api/docs

  bool _isValidURL({required String url}) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && uri.isAbsolute && uri.hasAuthority;
  }

  Future<String> _fetchData({
    required String url,
    APIVersion version = APIVersion.v0,
  }) async {
    try {
      http.Response response = http.Response("", 500);

      switch (version) {
        case APIVersion.v0:
          response = await _client.post(
            Uri.https(base),
            headers: <String, String>{
              "Accept": "application/json",
              "Content-Type": "application/x-www-form-urlencoded",
            },
            body: <String, String>{"url": url},
          );
          break;

        case APIVersion.v1:
          response = await _client.post(
            Uri.https(base, "/api/v1/shorten"),
            headers: <String, String>{
              "Authorization": "Bearer $apiKey",
              "Content-Type": "application/json",
            },
            body: jsonEncode(<String, String>{"long_url": url}),
          );
          break;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic data = jsonDecode(response.body);

        if (data is Map<String, dynamic> && data.containsKey("short_url")) {
          final String value = data["short_url"] as String;
          log("Success: $value", name: "fetchData");
          return value;
        } else {
          log("Unexpected response format", name: "fetchData");
        }
      } else if (response.statusCode == 429) {
        log("Rate limit exceeded. Please wait.", name: "fetchData");
      } else {
        log("Error: ${response.statusCode}", name: "fetchData");
      }
    } on Exception catch (error, stackTrace) {
      log("Exception", error: error, stackTrace: stackTrace, name: "fetchData");
    }

    return "";
  }

  Future<String> generate({
    required String url,
    APIVersion version = APIVersion.v0,
  }) async {
    try {
      final bool isValid = _isValidURL(url: url);

      if (!isValid) {
        log("Invalid URL provided.", name: "generate");
        return "";
      }

      if (version == APIVersion.v1 && apiKey.isEmpty) {
        log("For v1 - Set APIService().apiKey = '<api_key>'", name: "generate");
        return "";
      }

      return await _fetchData(url: url, version: version);
    } on Exception catch (error, stackTrace) {
      log("Exception", error: error, stackTrace: stackTrace);
    }

    return "";
  }
}
