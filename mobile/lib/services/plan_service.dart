import 'package:shared_preferences/shared_preferences.dart';

class PlanService {
  static const String _keyIsPremium = "is_premium";
  /// Android/iOS sunucu doğrulamasından (expires_at_ms); yoksa sadece bayrak.
  static const String _keyPremiumExpiresAtMs = "premium_expires_at_ms";

  // Ücretsiz plan: her bölüm için cihazda toplam deneme kotası (Premium: sınırsız)
  static const String _keyGeneral = "usage_general";
  static const String _keyScenario = "usage_scenario";
  static const String _keyImage = "usage_image";
  static const String _keyExam = "usage_exam";

  static const int freeLimitPerFeature = 3;

  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_keyIsPremium) ?? false)) return false;
    final exp = prefs.getInt(_keyPremiumExpiresAtMs);
    if (exp != null) {
      if (DateTime.now().millisecondsSinceEpoch > exp) {
        await clearPremium();
        return false;
      }
    }
    return true;
  }

  /// [expiresAtMs] sunucudan (Play/App Store dönem sonu); yoksa yenileme olana kadar premium varsayılır.
  static Future<void> setPremium({int? expiresAtMs}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, true);
    if (expiresAtMs != null) {
      await prefs.setInt(_keyPremiumExpiresAtMs, expiresAtMs);
    } else {
      await prefs.remove(_keyPremiumExpiresAtMs);
    }
    await resetAllUsage();
  }

  static Future<void> clearPremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, false);
    await prefs.remove(_keyPremiumExpiresAtMs);
  }

  static String _featureKey(String f) {
    switch (f) {
      case "general":
        return _keyGeneral;
      case "scenario":
        return _keyScenario;
      case "image":
        return _keyImage;
      case "exam":
        return _keyExam;
      default:
        throw Exception("Unknown feature name: $f");
    }
  }

  static Future<int> _getUsage(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 0;
  }

  static Future<void> _incrementUsage(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
  }

  /// Ücretsiz planda: her bölümden toplam [freeLimitPerFeature] kullanım. Premium: sınırsız.
  static Future<bool> canUseFeature(String feature) async {
    if (await isPremium()) return true;
    final key = _featureKey(feature);
    final used = await _getUsage(key);
    return used < freeLimitPerFeature;
  }

  static Future<void> registerUsage(String feature) async {
    final key = _featureKey(feature);
    await _incrementUsage(key);
  }

  static Future<void> resetAllUsage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyGeneral, 0);
    await prefs.setInt(_keyScenario, 0);
    await prefs.setInt(_keyImage, 0);
    await prefs.setInt(_keyExam, 0);
  }
}
