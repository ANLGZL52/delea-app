// lib/services/api_service.dart
import 'dart:convert';
import 'dart:typed_data' show Uint8List;

import 'package:flutter/foundation.dart'
    show kIsWeb, kReleaseMode, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;

import '../platform_check.dart';
import 'install_id.dart';

class ApiService {
  /// API_BASE_URL sadece const bağlamda okunabilir (--dart-define=API_BASE_URL=...)
  static const String _apiBaseUrlEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  /// Geliştirme: tam URL yokken kullanılan makine (varsayılan 127.0.0.1).
  /// Fiziksel iPhone’da Mac/PC’deki API için: --dart-define=API_HOST=192.168.1.10
  static const String _devApiHost = String.fromEnvironment('API_HOST', defaultValue: '127.0.0.1');

  /// Geliştirme: Android **emülatör** veya gerçek cihaz hedefi `TargetPlatform.android`
  /// iken bilgisayardaki API `10.0.2.2:8000` üzerinden gider; `127.0.0.1` yalnızca
  /// cihazın kendisini gösterir (emülatörde backend’e ulaşmaz).
  /// Fiziksel Android/iOS: aynı ağdaki PC IP’si: `--dart-define=API_BASE_URL=http://192.168.x.x:8000`
  /// veya Android’de `adb reverse tcp:8000 tcp:8000` (o zaman 127.0.0.1:8000 gidebilir).
  static String get baseUrl {
    if (_apiBaseUrlEnv.isNotEmpty) {
      if (!kIsWeb && isAndroidPlatform) {
        try {
          final u = Uri.parse(_apiBaseUrlEnv);
          if (u.hasAuthority &&
              (u.host == '127.0.0.1' || u.host == 'localhost')) {
            return u.replace(host: '10.0.2.2').toString();
          }
        } catch (_) {}
      }
      return _apiBaseUrlEnv;
    }
    // Release varsayılanı: gerçek çalışan backend. (api.delea.app henüz DNS'te
    // çözülmüyor; --dart-define=API_BASE_URL=... verilmezse bile uygulama
    // sessizce ölü adrese gitmemeli.)
    if (kReleaseMode) return 'https://delea-app-production.up.railway.app';
    if (!kIsWeb &&
        (isAndroidPlatform || defaultTargetPlatform == TargetPlatform.android)) {
      return 'http://10.0.2.2:8000';
    }
    // iOS Simülatör, masaüstü, web dışı: 127.0.0.1. Fiziksel iOS cihazda 127.0.0.1
    // cihazın kendisidir; API bilgisayardaysa API_HOST veya API_BASE_URL gerekir.
    return 'http://$_devApiHost:8000';
  }

  static const _evaluateTimeout = Duration(seconds: 300);

  /// Batch: Tüm cevapları tek istekte backend'e gönderir; backend OpenAI ile paralel değerlendirir.
  /// [items]: her öğe {bytes, filename, questionId, questionType, questionText} içermeli.
  /// Returns: [result1, result2, ...] – sıra items ile aynı.
  static Future<List<Map<String, dynamic>>> sendAudioBatch(
    List<Map<String, dynamic>> items,
  ) async {
    if (items.isEmpty) return [];
    final uri = Uri.parse('$baseUrl/evaluate-batch');
    final request = http.MultipartRequest('POST', uri);

    final metadata = items.map((e) => {
      'question_id': e['questionId'] as String? ?? '',
      'question_type': e['questionType'] as String? ?? '',
      'question_text': e['questionText'] as String? ?? '',
    }).toList();
    request.fields['metadata'] = jsonEncode(metadata);

    for (final item in items) {
      final bytes = item['bytes'] as Uint8List;
      final filename = item['filename'] as String? ?? 'audio.m4a';
      request.files.add(
        http.MultipartFile.fromBytes('files', bytes, filename: filename),
      );
    }

    final streamedResponse = await request.send().timeout(
          _evaluateTimeout,
          onTimeout: () => throw Exception(
            'Backend\'e ulaşılamadı. İnternet ve API adresini kontrol edin (gerçek cihazda --dart-define=API_BASE_URL=http://BILGISAYAR_IP:8000 gerekebilir).',
          ),
        );
    final response = await http.Response.fromStream(streamedResponse).timeout(
          _evaluateTimeout,
          onTimeout: () => throw Exception('Sunucu yanıt vermedi.'),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'Sunucu hatası: ${response.statusCode}. Değerlendirme yapılamadı.',
      );
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = body['results'];
    if (results is! List) throw Exception('Geçersiz yanıt: results listesi yok.');
    return results.cast<Map<String, dynamic>>();
  }

  /// Ses dosyası bytes ile gönder – web ve mobilde çalışır
  static Future<Map<String, dynamic>> sendAudioBytes(
    Uint8List bytes, {
    required String filename,
    required String questionId,
    required String questionType,
    required String questionText,
  }) async {
    final uri = Uri.parse('$baseUrl/evaluate');
    final request = http.MultipartRequest('POST', uri)
      ..fields['question_id'] = questionId
      ..fields['question_type'] = questionType
      ..fields['question_text'] = questionText
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

    final streamedResponse = await request.send().timeout(
          _evaluateTimeout,
          onTimeout: () => throw Exception('Bağlantı zaman aşımına uğradı.'),
        );
    final response = await http.Response.fromStream(streamedResponse).timeout(
          _evaluateTimeout,
          onTimeout: () => throw Exception('Sunucu yanıt vermedi.'),
        );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Sunucu hatası: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }

  // 1) Sınav simülasyonu – /evaluate (File veya Uint8List)
  static Future<Map<String, dynamic>> sendAudio(
    dynamic file, {
    required String questionId,
    required String questionType,
    required String questionText,
  }) async {
    return sendAudioBytes(
      await _toBytes(file),
      filename: 'audio.m4a',
      questionId: questionId,
      questionType: questionType,
      questionText: questionText,
    );
  }

  static Future<Uint8List> _toBytes(dynamic fileOrBytes) async {
    if (fileOrBytes is Uint8List) return fileOrBytes;
    return (await (fileOrBytes as dynamic).readAsBytes()) as Uint8List;
  }

  // 2) Genel sorular – /general-evaluate (File, Uint8List veya web blob yolu; bytes + filename)
  static Future<Map<String, dynamic>> sendGeneralAudio(
    dynamic file, {
    String filename = 'audio.m4a',
  }) async {
    final uri = Uri.parse('$baseUrl/general-evaluate');
    final bytes = await _toBytes(file);
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      );

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
    dynamic file, {
    required String scenarioText,
    String filename = 'audio.m4a',
  }) async {
    final uri = Uri.parse('$baseUrl/scenario-evaluate');
    final bytes = await _toBytes(file);
    final request = http.MultipartRequest('POST', uri)
      ..fields['scenario'] = scenarioText
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      );

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
    dynamic file,
    String prompt, {
    String filename = 'audio.m4a',
  }) async {
    final uri = Uri.parse('$baseUrl/image-evaluate');
    final bytes = await _toBytes(file);
    final request = http.MultipartRequest('POST', uri)
      ..fields['prompt'] = prompt
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      );

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
  // 8) Ödeme doğrulama – /verify/purchase
  static Future<Map<String, dynamic>> verifyPurchase({
    required String purchaseToken,
    required String productId,
    String packageName = 'com.delea.app',
    String? deviceId,
    String platform = 'android',
  }) async {
    final uri = Uri.parse('$baseUrl/verify/purchase');
    final resolvedDeviceId = deviceId ?? await InstallId.getOrCreate();

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'purchase_token': purchaseToken,
        'product_id': productId,
        'package_name': packageName,
        'device_id': resolvedDeviceId,
        'platform': platform,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Doğrulama hatası: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }

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
