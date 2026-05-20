// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/vibe_check_result.dart';
import 'auth_session.dart';

class VibeApiException implements Exception {
  VibeApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'VibeApiException($statusCode): $message';
}

class VibeApiService {
  static const String _baseUrl =
      'http://vibes--ecsap-trtfwism8oul-104387100.us-east-1.elb.amazonaws.com';

  /// POST /api/v1/score  (phase = pre)
  ///
  /// Uploads the recording and returns scored results.
  /// Stores the returned session_id in AuthSession for later post-session use.
  static Future<VibeCheckResult> submitPreScore({
    required File audioFile,
    int? currentJourneyId,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/score');
    final journeyId = currentJourneyId ??
        (100000000 + Random().nextInt(900000000)); // 9-digit random

    final audioSize = await audioFile.length();
    print('');
    print('━━━━━━━━━━━━ [VIBE] REQUEST ━━━━━━━━━━━━');
    print('[VIBE] POST $uri');
    print('[VIBE] Headers:');
    print('         Authorization: Bearer ${AuthSession.instance.accessToken?.substring(0, 20)}...');
    print('         accept: application/json');
    print('[VIBE] Fields (multipart/form-data):');
    print('         phase            = pre');
    print('         current_journey_id = $journeyId');
    print('[VIBE] File:');
    print('         audio  path=${audioFile.path}');
    print('         audio  size=${(audioSize / 1024).toStringAsFixed(1)} KB');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = AuthSession.instance.authHeader
      ..headers['accept'] = 'application/json'
      ..fields['phase'] = 'pre'
      ..fields['current_journey_id'] = journeyId.toString()
      ..files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioFile.path,
          filename: 'recording.m4a',
        ),
      );

    try {
      final stopwatch = Stopwatch()..start();
      final streamed = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);
      stopwatch.stop();

      print('');
      print('━━━━━━━━━━━━ [VIBE] RESPONSE ━━━━━━━━━━━━');
      print('[VIBE] Status  : ${response.statusCode}');
      print('[VIBE] Duration: ${stopwatch.elapsedMilliseconds} ms');
      print('[VIBE] Body:');
      try {
        final pretty = const JsonEncoder.withIndent('  ').convert(jsonDecode(response.body));
        print(pretty);
      } catch (_) {
        print(response.body);
      }
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('');

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = VibeCheckResult.fromJson(body);
        // Store session_id so the post-session call can reference it
        if (result.sessionId.isNotEmpty) {
          AuthSession.instance.saveSessionId(result.sessionId);
        }
        print('[VIBE] Score received. sessionId=${result.sessionId}');
        return result;
      }

      final message = _extractError(body, response.statusCode);
      print('');
      print('━━━━━━━━━━━━ [VIBE] ERROR ━━━━━━━━━━━━');
      print('[VIBE] Status : ${response.statusCode}');
      print('[VIBE] Message: $message');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('');
      throw VibeApiException(message, statusCode: response.statusCode);
    } catch (e, st) {
      if (e is VibeApiException) rethrow;
      print('');
      print('━━━━━━━━━━━━ [VIBE] EXCEPTION ━━━━━━━━━━━━');
      print('[VIBE] $e');
      print('[VIBE] StackTrace:');
      print(st);
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('');
      rethrow;
    }
  }

  static String _extractError(Map<String, dynamic> body, int statusCode) {
    if (body.containsKey('detail')) {
      final detail = body['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map) return first['msg']?.toString() ?? 'Validation error';
      }
    }
    if (body.containsKey('message')) return body['message'].toString();
    return 'Server error ($statusCode)';
  }
}
