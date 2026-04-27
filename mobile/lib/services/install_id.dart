import 'package:shared_preferences/shared_preferences.dart';

/// Sunucu doğrulama (ör. /verify/purchase) için cihaz başına istikrarlı anonim id.
class InstallId {
  static const _key = 'delea_install_id_v1';

  static Future<String> getOrCreate() async {
    final p = await SharedPreferences.getInstance();
    var id = p.getString(_key);
    if (id == null || id.isEmpty) {
      id = 'd_${DateTime.now().toUtc().microsecondsSinceEpoch}';
      await p.setString(_key, id);
    }
    return id;
  }
}
