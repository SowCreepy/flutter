import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._();
  AuthService._();

  final _storage = const FlutterSecureStorage();
  final _http = http.Client();

  String? _accessToken;
  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;

  String? get accessToken => _accessToken;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoggedIn => _accessToken != null && _currentUser != null;
  bool get isLoading => _isLoading;
  String get userId => _currentUser?['id'] ?? '';

  Future<bool> tryAutoLogin() async {
    try {
      final storedRefresh = await _storage.read(key: 'refreshToken');
      if (storedRefresh == null) return false;
      return await refreshToken();
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _http.post(
      Uri.parse('${ApiClient.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'username': username,
      }),
    );

    if (response.statusCode >= 400) {
      final body = jsonDecode(response.body);
      throw ApiException(
        statusCode: response.statusCode,
        message: body['error'] ?? 'Registration failed',
      );
    }

    return jsonDecode(response.body);
  }

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _http.post(
        Uri.parse('${ApiClient.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode >= 400) {
        final body = jsonDecode(response.body);
        throw ApiException(
          statusCode: response.statusCode,
          message: body['error'] ?? 'Login failed',
        );
      }

      final body = jsonDecode(response.body);
      _accessToken = body['accessToken'];
      _currentUser = body['user'];

      final cookies = response.headers['set-cookie'];
      if (cookies != null) {
        final refreshMatch = RegExp(
          r'refreshToken=([^;]+)',
        ).firstMatch(cookies);
        if (refreshMatch != null) {
          await _storage.write(
            key: 'refreshToken',
            value: refreshMatch.group(1),
          );
        }
      }

      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> refreshToken() async {
    final storedRefresh = await _storage.read(key: 'refreshToken');
    if (storedRefresh == null) return false;

    try {
      final response = await _http.post(
        Uri.parse('${ApiClient.baseUrl}/auth/refresh'),
        headers: {'Cookie': 'refreshToken=$storedRefresh'},
      );

      if (response.statusCode >= 400) {
        await logout();
        return false;
      }

      final body = jsonDecode(response.body);
      _accessToken = body['accessToken'];

      final cookies = response.headers['set-cookie'];
      if (cookies != null) {
        final refreshMatch = RegExp(
          r'refreshToken=([^;]+)',
        ).firstMatch(cookies);
        if (refreshMatch != null) {
          await _storage.write(
            key: 'refreshToken',
            value: refreshMatch.group(1),
          );
        }
      }

      if (_currentUser == null) {
        try {
          _currentUser = await ApiClient.instance.get('/players/me');
        } catch (_) {}
      }

      notifyListeners();
      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final storedRefresh = await _storage.read(key: 'refreshToken');
      if (_accessToken != null) {
        await _http.post(
          Uri.parse('${ApiClient.baseUrl}/auth/logout'),
          headers: {
            'Authorization': 'Bearer $_accessToken',
            if (storedRefresh != null) 'Cookie': 'refreshToken=$storedRefresh',
          },
        );
      }
    } catch (_) {
    } finally {
      _accessToken = null;
      _currentUser = null;
      await _storage.delete(key: 'refreshToken');
      notifyListeners();
    }
  }

  void updateUser(Map<String, dynamic> user) {
    _currentUser = user;
    notifyListeners();
  }
}
