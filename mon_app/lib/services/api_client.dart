import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:3000/api';

  static final ApiClient instance = ApiClient._();
  ApiClient._();

  final _http = http.Client();

  Map<String, String> get _authHeaders {
    final token = AuthService.instance.accessToken;
    if (token != null) {
      return <String, String>{'Authorization': 'Bearer $token'};
    }
    return <String, String>{};
  }

  Map<String, String> get _jsonHeaders {
    return <String, String>{
      'Content-Type': 'application/json',
      ..._authHeaders,
    };
  }

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _request(
      () => _http.get(Uri.parse('$baseUrl$path'), headers: _jsonHeaders),
    );
    return _decode(response);
  }

  Future<List<dynamic>> getList(String path) async {
    final response = await _request(
      () => _http.get(Uri.parse('$baseUrl$path'), headers: _jsonHeaders),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final response = await _request(
      () => _http.post(
        Uri.parse('$baseUrl$path'),
        headers: body != null ? _jsonHeaders : _authHeaders,
        body: body != null ? jsonEncode(body) : null,
      ),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final response = await _request(
      () => _http.patch(
        Uri.parse('$baseUrl$path'),
        headers: body != null ? _jsonHeaders : _authHeaders,
        body: body != null ? jsonEncode(body) : null,
      ),
    );
    return _decode(response);
  }

  Future<http.Response> _request(
    Future<http.Response> Function() doRequest,
  ) async {
    var response = await doRequest();

    if (response.statusCode == 401) {
      final refreshed = await AuthService.instance.refreshToken();
      if (refreshed) {
        response = await doRequest();
      }
    }

    if (response.statusCode >= 400) {
      final body = jsonDecode(response.body);
      throw ApiException(
        statusCode: response.statusCode,
        message: body['error'] ?? body['message'] ?? 'Unknown error',
      );
    }

    return response;
  }

  Map<String, dynamic> _decode(http.Response response) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
