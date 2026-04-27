import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'delea_tokens.dart';

/// Tüm ekranlarda tutarlı Material 3 koyu tema.
class AppDeleaTheme {
  AppDeleaTheme._();

  static ThemeData get dark {
    final baseScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: DeleaColors.brand,
      onPrimary: DeleaColors.onAccent,
      secondary: DeleaColors.accentViolet,
      onSecondary: DeleaColors.onAccent,
      error: const Color(0xFFF87171),
      onError: const Color(0xFF0F0F0F),
      surface: DeleaColors.surface,
      onSurface: DeleaColors.textPrimary,
      surfaceContainerHighest: DeleaColors.surfaceRaised,
      outline: DeleaColors.border,
    );

    final textTheme = TextTheme(
      displayLarge: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.15,
        color: DeleaColors.textPrimary,
      ),
      titleLarge: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: DeleaColors.textPrimary,
      ),
      titleMedium: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: DeleaColors.textPrimary,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        height: 1.5,
        color: DeleaColors.textPrimary,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        height: 1.5,
        color: DeleaColors.textSecondary,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        height: 1.4,
        color: DeleaColors.textMuted,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: DeleaColors.textPrimary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: baseScheme,
      scaffoldBackgroundColor: DeleaColors.background,
      brightness: Brightness.dark,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: DeleaColors.textPrimary,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: DeleaColors.backgroundCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DeleaRadii.lg),
          side: const BorderSide(color: DeleaColors.border, width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DeleaRadii.xl),
          ),
          elevation: 0,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: DeleaColors.surfaceRaised,
        contentTextStyle: const TextStyle(
          color: DeleaColors.textPrimary,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DeleaRadii.md),
          side: const BorderSide(color: DeleaColors.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: DeleaColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DeleaRadii.xl),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyLarge?.copyWith(
          color: DeleaColors.textSecondary,
        ),
      ),
    );
  }
}
