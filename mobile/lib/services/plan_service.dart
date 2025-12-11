import 'package:shared_preferences/shared_preferences.dart';

class PlanService {
  // Premium anahtarı
  static const String _keyIsPremium = "is_premium";

  // Günlük reset anahtarı
  static const String _keyLastReset = "usage_last_reset";

  // Her feature için kullanım sayaçları
  static const String _keyGeneral = "usage_general";
  static const String _keyScenario = "usage_scenario";
  static const String _keyImage = "usage_image";
  static const String _keyExam = "usage_exam";

  // Demo limiti: her feature için günde sadece 1 kez
  static const int dailyLimit = 1;

  /// Kullanıcı premium mu?
  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsPremium) ?? false;
  }

  /// Kullanıcıyı premium yap
  static Future<void> setPremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, true);
    await resetAllUsage();
  }

  /// Gerekirse günlük sayaç reseti yap
  static Future<void> _resetIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().substring(0, 10);
    final lastReset = prefs.getString(_keyLastReset);

    // İlk kez çalışıyorsa veya gün değişmişse reset yapılır
    if (lastReset != today) {
      await prefs.setString(_keyLastReset, today);

      await prefs.setInt(_keyGeneral, 0);
      await prefs.setInt(_keyScenario, 0);
      await prefs.setInt(_keyImage, 0);
      await prefs.setInt(_keyExam, 0);
    }
  }

  /// Feature usage key mapping
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

  /// Feature'ın bugün kaç defa kullanıldığını getir
  static Future<int> _getUsage(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 0;
  }

  /// Kullanım kaydı arttırma
  static Future<void> _incrementUsage(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
  }

  /// Feature'ı kullanabilir mi?
  static Future<bool> canUseFeature(String feature) async {
    await _resetIfNeeded();

    // Premium ise sonsuz kullanım
    if (await isPremium()) return true;

    // Değilse sayaç kontrolü
    final key = _featureKey(feature);
    final used = await _getUsage(key);

    return used < dailyLimit;
  }

  /// Kullanım kaydı
  static Future<void> registerUsage(String feature) async {
    await _resetIfNeeded();
    final key = _featureKey(feature);
    await _incrementUsage(key);
  }

  /// Premium geçişi veya reset durumunda tüm sayaçları sıfırla
  static Future<void> resetAllUsage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyGeneral, 0);
    await prefs.setInt(_keyScenario, 0);
    await prefs.setInt(_keyImage, 0);
    await prefs.setInt(_keyExam, 0);
  }
}
