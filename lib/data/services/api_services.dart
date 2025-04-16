import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://affairs.digitalnoticeboard.biz';
  // static const String baseUrl =
  //     'https://consumeraffairs.digitalnoticeboard.biz';

  Future<http.Response> get(String endpoint,
      {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.get(url, headers: headers);
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> postFormData(
    String endpoint,
    Map<String, dynamic> body, {
    String bearerToken = '',
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    print("Sending form data to $endpoint: $body");

    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    if (bearerToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }

    return await http.post(
      url,
      headers: headers,
      body: body,
    );
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String endpoint,
      {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: body != null ? jsonEncode(body) : null,
    );
  }
}
