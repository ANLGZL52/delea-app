// lib/core/firebase_bootstrap.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

/// Firebase başlatma. [firebase_options.dart] alanlarını kendi projenle değiştir:
/// `dart pub global activate flutterfire_cli` ardından proje kökünde: `flutterfire configure`
Future<void> configureFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kDebugMode) {
    final id = DefaultFirebaseOptions.currentPlatform.projectId;
    debugPrint('Firebase başlatıldı (projectId: $id)');
  }
}
