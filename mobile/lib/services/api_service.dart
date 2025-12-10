// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Windows desktop'tan backend'e: 127.0.0.1
  // Android emulator kullanırsan: 10.0.2.2
  static const String baseUrl = 'http://127.0.0.1:8000';

  // 1) Sınav simülasyonu – /evaluate (genel endpoint)
  static Future<Map<String, dynamic>> sendAudio(
    File file, {
    required String questionId,
    required String questionType,
    required String questionText,
  }) async {
    final uri = Uri.parse('$baseUrl/evaluate');

    final request = http.MultipartRequest('POST', uri)
      ..fields['question_id'] = questionId
      ..fields['question_type'] = questionType
      ..fields['question_text'] = questionText
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Sunucu hatası: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }

  // 2) Genel sorular – /general-evaluate
  static Future<Map<String, dynamic>> sendGeneralAudio(File file) async {
    final uri = Uri.parse('$baseUrl/general-evaluate');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Sunucu hatası: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }

  // 3) Senaryolar – /scenario-evaluate
  static Future<Map<String, dynamic>> sendScenarioAudio(
    File file, {
    required String scenarioText,
  }) async {
    final uri = Uri.parse('$baseUrl/scenario-evaluate');

    final request = http.MultipartRequest('POST', uri)
      ..fields['scenario'] = scenarioText
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Sunucu hatası: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }

  // 4) Resim açıklama – /image-evaluate
  static Future<Map<String, dynamic>> sendImageAudio(
    File file,
    String prompt,
  ) async {
    final uri = Uri.parse('$baseUrl/image-evaluate');

    final request = http.MultipartRequest('POST', uri)
      ..fields['prompt'] = prompt
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Sunucu hatası: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }

  // 5) Sözlük – /dictionary
  static Future<Map<String, dynamic>> lookupWord(String word) async {
    final uri = Uri.parse('$baseUrl/dictionary');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'word': word}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Sunucu hatası: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }

  // 6) Soru Gönder – /submit-question
  static Future<bool> submitUserQuestion({
    required String category,
    required String question,
    String? email,
  }) async {
    final uri = Uri.parse('$baseUrl/submit-question');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'category': category,
        'question': question,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['ok'] == true;
    } else {
      throw Exception(
        'Sunucu hatası: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }

  // 7) Çeviri – /translate (EN -> TR vb.)
  static Future<String> translateQuestion(
    String text, {
    String targetLang = 'tr',
  }) async {
    final uri = Uri.parse('$baseUrl/translate');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'text': text,
        'target_lang': targetLang,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final translated = data['translated_text'] ?? text;
      return translated.toString();
    } else {
      throw Exception(
        'Çeviri hatası: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }
}
