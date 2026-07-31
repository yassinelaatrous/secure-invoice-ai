import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand palette ──────────────────────────────────────────────
  static const Color primary = Color(0xFF012D1D); // deep forest green
  static const Color primaryContainer = Color(0xFF1B4332); // medium forest green
  static const Color accent = Color(0xFFB8F04A); // bright lime green
  static const Color accentGreen = Color(0xFF0E6C4A); // Stitch secondary green
  static const Color accentOrange = Color(0xFFF4841F); // CEO-IT Orange
  static const Color warning = Color(0xFFE8A020);
  static const Color error = Color(0xFFBA1A1A); // Stitch error red
  static const Color errorCrimson = Color(0xFFA4161A); // Stitch crimson red
  static const Color secondary = accent;

  // ── Light cream surfaces ────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFFCF9F6); // Warm Off-White/Cream
  static const Color surfaceLight = Color(0xFFFCF9F6); // Warm Off-White/Cream
  static const Color surfaceCard = Color(0xFFF0EDEA); // Light Cream Card Container
  static const Color surfaceCreamDark = Color(0xFFF0EDE9); // Recessed/nested card
  static const Color cardBorder = Color(0xFFE5E2DF); // Subtle grey border



  // ── Text colors ─────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1C1B); // Deep Charcoal
  static const Color textSecondary = Color(0xFF414844); // Muted Sage Grey
  static const Color textMuted = Color(0xFF717973); // Light Sage outline

  static TextStyle get headlineLarge => creamTheme.textTheme.headlineLarge!;
  static TextStyle get headlineMedium => creamTheme.textTheme.headlineMedium!;
  static TextStyle get bodyLarge => creamTheme.textTheme.bodyLarge!;
  static TextStyle get bodyMedium => creamTheme.textTheme.bodyMedium!;
  static TextStyle get labelLarge => creamTheme.textTheme.labelLarge!;
  static TextStyle get labelMedium => creamTheme.textTheme.labelMedium!;

  static ThemeData get creamTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: Colors.white,
      secondary: accent,
      onSecondary: primary,
      tertiary: accentGreen,
      onTertiary: Colors.white,
      surface: surfaceLight,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceCard,
      onSurfaceVariant: textSecondary,
      error: error,
      onError: Colors.white,
      outline: cardBorder,
      outlineVariant: Color(0xFFCCC8BE),
    ),
    scaffoldBackgroundColor: backgroundLight,
    textTheme: GoogleFonts.dmSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: textMuted,
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textMuted,
          letterSpacing: 0.5,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: cardBorder, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      labelStyle: const TextStyle(color: textMuted),
      hintStyle: const TextStyle(color: textMuted),
    ),
    dividerTheme: const DividerThemeData(
      color: cardBorder,
      thickness: 1,
      space: 0,
    ),
  );

  static ThemeData get lightTheme => creamTheme;
}
