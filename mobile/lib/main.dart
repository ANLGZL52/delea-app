import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/firebase_bootstrap.dart';
import 'screens/main_home_screen.dart';
import 'screens/premium_screen.dart';
import 'services/plan_service.dart';
import 'services/purchase_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureFirebase();
  await PurchaseService.instance.init();
  await PlanService.isPremium();

  // Masaüstü / web geliştirmede telefon çerçevesi ve cihaz seçici (sürüm dışı).
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const DlaPlusApp(),
    ),
  );
}

class DlaPlusApp extends StatelessWidget {
  const DlaPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'DLA +',
      debugShowCheckedModeBanner: false,
      theme: AppDeleaTheme.dark,
      home: const MainHomeScreen(),
      routes: {
        '/premium': (context) => const PremiumScreen(),
      },
    );
  }
}
