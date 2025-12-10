// lib/services/plan_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_plan.dart';

class PlanService {
  static const _keyIsPremium = 'user_is_premium';
  static const _keyDemoUsesLeft = 'user_demo_uses_left';

  /// Şu anki planı SharedPreferences'tan yükler.
  /// Eğer kayıt yoksa: DEMO + 1 kullanım hakkı ile başlar.
  static Future<UserPlan> getCurrentPlan() async {
    final prefs = await SharedPreferences.getInstance();

    final isPremium = prefs.getBool(_keyIsPremium) ?? false;
    final demoUsesLeft = prefs.getInt(_keyDemoUsesLeft);

    // Hiç kayıt yoksa default: demo + 1 hak
    if (!isPremium && demoUsesLeft == null) {
      return UserPlan.initialDemo();
    }

    return UserPlan(
      isPremium: isPremium,
      demoUsesLeft: demoUsesLeft ?? 0,
    );
  }

  /// Kullanıcıyı premium yapar (in-app purchase sonrası çağrılacak).
  static Future<void> setPremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, true);

    // Premiumda demo hakkına gerek yok, 0 yapıyoruz (opsiyonel)
    await prefs.setInt(_keyDemoUsesLeft, 0);
  }

  /// Demo modunu başa sarmak istersen (test için kullanışlı)
  static Future<void> resetDemo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, false);
    await prefs.setInt(_keyDemoUsesLeft, 1);
  }

  /// Sınav başlatmadan ÖNCE çağır:
  /// - Premium ise: HER ZAMAN true
  /// - Demo ise: hak varsa true, yoksa false
  static Future<bool> canStartExam() async {
    final plan = await getCurrentPlan();
    if (plan.isPremium) return true;
    return plan.demoUsesLeft > 0;
  }

  /// Sınavı gerçekten başlattıysan:
  /// - Premium ise: hiçbir şey yapmaz
  /// - Demo ise: 1 hakkı düşürür
  static Future<void> registerExamUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool(_keyIsPremium) ?? false;

    if (isPremium) {
      // Premium kullanıcının kullanım sayısını takip etmiyoruz
      return;
    }

    final currentLeft = prefs.getInt(_keyDemoUsesLeft);

    // Hiç kayıt yoksa: default 1 hak varmış gibi düşün → 0'a düşür
    if (currentLeft == null) {
      await prefs.setInt(_keyDemoUsesLeft, 0);
    } else {
      final updated = currentLeft > 0 ? currentLeft - 1 : 0;
      await prefs.setInt(_keyDemoUsesLeft, updated);
    }
  }
}
