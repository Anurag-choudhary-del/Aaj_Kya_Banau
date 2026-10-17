import 'dart:convert';
import 'package:http/http.dart' as http;

class IngredientRecognitionService {
  static const String _baseUrl = String.fromEnvironment('AI_API_BASE_URL');

  Future<List<Map<String, String>>> recognize(
    String imageBase64,
    String mimeType, {
    String language = 'English',
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('AI service abhi configure nahi hai. GitHub mein AI_API_BASE_URL variable aur backend secrets set karne honge.');
    }
    final uri = Uri.tryParse('${_baseUrl.replaceFirst(RegExp(r'/+$'), '')}/recognize');
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw Exception('AI service URL galat hai. AI_API_BASE_URL ko https:// se shuru hone wala Worker URL set karo.');
    }
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'imageBase64': imageBase64,
        'mimeType': mimeType,
        'language': ['English', 'Hinglish', 'Hindi'].contains(language) ? language : 'English',
      }),
    ).timeout(const Duration(seconds: 60));
    if (response.statusCode != 200) {
      String message = 'AI photo process nahi kar saka (HTTP ${response.statusCode}).';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['error'] is String) message = body['error'] as String;
      } catch (_) {}
      throw Exception(message);
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map || decoded['items'] is! List) {
      throw Exception('AI response samajh nahi aaya. Dobara photo try karo.');
    }
    final result = <Map<String, String>>[];
    for (final value in decoded['items'] as List) {
      if (value is! Map || value['name'] is! String) continue;
      final name = (value['name'] as String).trim();
      if (name.isEmpty || name.length > 60) continue;
      final displayName = value['displayName'] is String
          ? (value['displayName'] as String).trim()
          : name;
      result.add({
        'name': name,
        'displayName': displayName.isEmpty ? name : displayName,
        'emoji': value['emoji'] is String ? value['emoji'] as String : '🥬',
      });
    }
    return result;
  }
}
