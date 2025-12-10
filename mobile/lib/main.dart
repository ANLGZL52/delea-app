// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/main_home_screen.dart';

void main() {
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
    );
  }
}
