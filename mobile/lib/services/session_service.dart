import 'package:shared_preferences/shared_preferences.dart';

/// Yerel oturum (sunucu hesabı yok); çıkış Apple incelemesinde görünür olmalı.
class SessionService {
  SessionService._();

  static const String _keySignedIn = 'session_signed_in';
  static const String _keyDisplayName = 'session_display_name';
  static const String _keyEmail = 'session_email';

  static const String guestDisplayName = 'Misafir';
  static const String guestEmail = '—';

  static Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySignedIn) ?? true;
  }

  static Future<String> displayName() async {
    if (!await isSignedIn()) return guestDisplayName;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDisplayName) ?? 'Kullanıcı';
  }

  static Future<String> email() async {
    if (!await isSignedIn()) return guestEmail;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail) ?? guestEmail;
  }

  /// İlk kurulum veya eski sürümler için varsayılan profil.
  static Future<void> ensureDefaultProfile({
    String defaultName = 'Kullanıcı',
    String defaultEmail = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_keyDisplayName) == null && defaultName.isNotEmpty) {
      await prefs.setString(_keyDisplayName, defaultName);
    }
    if (prefs.getString(_keyEmail) == null && defaultEmail.isNotEmpty) {
      await prefs.setString(_keyEmail, defaultEmail);
    }
    if (!prefs.containsKey(_keySignedIn)) {
      await prefs.setBool(_keySignedIn, true);
    }
  }

  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySignedIn, false);
  }

  static Future<void> signIn({
    required String displayName,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySignedIn, true);
    await prefs.setString(_keyDisplayName, displayName);
    await prefs.setString(_keyEmail, email);
  }
}
