import 'package:flutter/material.dart';
import 'screens/main_home_screen.dart';
import 'screens/premium_screen.dart';
import 'services/purchase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Satın alma servisini başlat
  await PurchaseService.instance.init();

  runApp(const DeleaApp());
}

class DeleaApp extends StatelessWidget {
  const DeleaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeLeA – DLA Exam Trainer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF050509),
      ),
      home: const MainHomeScreen(),
      routes: {
        '/premium': (_) => const PremiumScreen(),
      },
    );
  }
}
