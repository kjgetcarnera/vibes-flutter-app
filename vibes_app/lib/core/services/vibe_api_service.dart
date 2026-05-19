import 'dart:io';
import 'package:http/http.dart' as http;

class VibeApiService {
  static const String _baseUrl = 'https://api.vibesapp.io'; // replace with real endpoint

  /// Submits the onboarding vibe check.
  /// [firstName] and [age] come from UserInfoScreen.
  /// [audioFile] is the recorded passage file.
  static Future<void> submitVibeCheck({
    required String firstName,
    required int age,
    required File audioFile,
  }) async {
    final uri = Uri.parse('$_baseUrl/v1/vibe-check');
    final request = http.MultipartRequest('POST', uri)
      ..fields['first_name'] = firstName
      ..fields['age'] = age.toString()
      ..files.add(
        await http.MultipartFile.fromPath('audio', audioFile.path),
      );

    final response = await request.send();
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('VibeCheck API failed: ${response.statusCode}');
    }
  }
}
