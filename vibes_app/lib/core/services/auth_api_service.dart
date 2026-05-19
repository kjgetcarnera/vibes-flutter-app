// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_result.dart';

class AuthException implements Exception {
  final String message;
  final int? statusCode;
  const AuthException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AuthApiService {
  static const String _baseUrl =
      'http://vibes--ecsap-trtfwism8oul-104387100.us-east-1.elb.amazonaws.com';

  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/auth/login');
    final requestBody = {'email': email, 'password': password};

    print('[AUTH] LOGIN → $uri');
    print('[AUTH] Request body: $requestBody');

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

      print('[AUTH] Response status: ${response.statusCode}');
      print('[AUTH] Response body: ${response.body}');

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResult.fromJson(body);
      }

      final message = _extractError(body, response.statusCode);
      print('[AUTH] Error: $message');
      throw AuthException(message, statusCode: response.statusCode);
    } catch (e, st) {
      if (e is AuthException) rethrow;
      print('[AUTH] Exception: $e');
      print('[AUTH] StackTrace: $st');
      rethrow;
    }
  }

  static Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/auth/register');
    final requestBody = {'email': email, 'password': password};

    print('[AUTH] SIGNUP → $uri');
    print('[AUTH] Request body: $requestBody');

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

      print('[AUTH] Response status: ${response.statusCode}');
      print('[AUTH] Response body: ${response.body}');

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResult.fromJson(body);
      }

      final message = _extractError(body, response.statusCode);
      print('[AUTH] Error: $message');
      throw AuthException(message, statusCode: response.statusCode);
    } catch (e, st) {
      if (e is AuthException) rethrow;
      print('[AUTH] Exception: $e');
      print('[AUTH] StackTrace: $st');
      rethrow;
    }
  }

  /// Parses error message from API response body.
  static String _extractError(Map<String, dynamic> body, int statusCode) {
    // { "message": "..." }
    if (body['message'] is String) return body['message'] as String;

    // { "detail": [ { "msg": "..." } ] }
    final detail = body['detail'];
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map && first['msg'] is String) return first['msg'] as String;
    }

    // { "detail": "..." }
    if (detail is String) return detail;

    switch (statusCode) {
      case 401:
        return 'Invalid email or password.';
      case 422:
        return 'Please check your details and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
