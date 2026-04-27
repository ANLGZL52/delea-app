import 'package:flutter/material.dart';

/// Görsel dil: koyu arka plan, mavi/çivit vurgu, sakin metin hiyerarşisi.
abstract final class DeleaColors {
  static const Color background = Color(0xFF070A10);
  static const Color backgroundCard = Color(0xFF0C1018);
  static const Color surface = Color(0xFF0F1419);
  static const Color surfaceRaised = Color(0xFF131A24);
  static const Color border = Color(0xFF253047);
  static const Color borderGlow = Color(0x2F3B82F6);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color brand = Color(0xFF2563EB);
  static const Color brandLight = Color(0xFF3B82F6);
  static const Color accentViolet = Color(0xFF7C3AED);
  static const Color success = Color(0xFF22C55E);
  static const Color onAccent = Color(0xFFFFFFFF);
}

abstract final class DeleaRadii {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double full = 999;
}

abstract final class DeleaSpacing {
  static const double screenH = 20;
  static const double screenV = 12;
  static const double block = 16;
}

/// Ana sayfa gibi hero ekranlarında vurgu için (gradient, glow).
abstract final class DeleaHome {
  static const List<Color> pageGradient = [
    Color(0xFF030712),
    Color(0xFF0B1220),
    Color(0xFF080F1A),
    Color(0xFF040910),
  ];
  static const List<Color> titleShader = [
    Color(0xFFFFFFFF),
    Color(0xFF7DD3FC),
    Color(0xFF38BDF8),
    Color(0xFF3B82F6),
  ];
}
