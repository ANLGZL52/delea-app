// lib/services/demo_limiter.dart
import 'package:shared_preferences/shared_preferences.dart';

enum SectionType { general, scenario, image, exam }

class DemoLimiter {
  static const _keyDate = 'demo_last_date';
  static const _keyPrefixCount = 'demo_count_';

  static String _sectionKey(SectionType section) => '$_keyPrefixCount${section.name}';

  /// Bugün ilgili bölümde kaç soru çözüldü? maxPerDay’den azsa true döner.
  static Future<bool> canUseSection(
    SectionType section, {
    int maxPerDay = 1,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD

    final lastDate = prefs.getString(_keyDate);
    if (lastDate != today) {
      // Yeni gün: tüm sayaçları sıfırla
      await prefs.setString(_keyDate, today);
      for (final s in SectionType.values) {
        await prefs.setInt(_sectionKey(s), 0);
      }
    }

    final count = prefs.getInt(_sectionKey(section)) ?? 0;
    return count < maxPerDay;
  }

  /// Soru çözüldüğünde sayaç artırılır.
  static Future<void> incrementSection(SectionType section) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _sectionKey(section);
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
  }
}
