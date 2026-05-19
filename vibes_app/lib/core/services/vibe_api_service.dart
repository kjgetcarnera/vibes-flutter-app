import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/vibe_check_result.dart';
import 'auth_session.dart';

class VibeApiService {
  static const String _baseUrl = 'https://api.vibesapp.io'; // replace with real endpoint

  /// Submits the onboarding vibe check and returns the analysis result.
  static Future<VibeCheckResult> submitVibeCheck({
    required String firstName,
    required int age,
    required File audioFile,
  }) async {
    final uri = Uri.parse('$_baseUrl/v1/vibe-check');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = AuthSession.instance.authHeader
      ..fields['first_name'] = firstName
      ..fields['age'] = age.toString()
      ..files.add(await http.MultipartFile.fromPath('audio', audioFile.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('VibeCheck API failed: ${response.statusCode}');
    }

    return VibeCheckResult.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
