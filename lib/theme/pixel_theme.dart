import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PixelTheme {
  // Global reactive dark mode state
  static final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);
  static bool get isDark => isDarkMode.value;

  static void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
  }

  // Dynamic Backgrounds (Strawberry Milk in Light, Cyber Midnight Plum in Dark)
  static Color get bg => isDark ? const Color(0xFF180A18) : const Color(0xFFFFF0F5);
  static Color get bgSurface => isDark ? const Color(0xFF261226) : const Color(0xFFFFFAFD);
  static Color get bgCard => isDark ? const Color(0xFF331733) : const Color(0xFFFFEBF2);
  static Color get lightPastelPink => isDark ? const Color(0xFF2F142F) : const Color(0xFFFFF5F8);
  static Color get babyPink => isDark ? const Color(0xFF421A42) : const Color(0xFFFFDDE6);
  static Color get inputFill => isDark ? const Color(0xFF200E20) : Colors.white;
  static Color get cardFill => isDark ? const Color(0xFF281328) : Colors.white;

  // Pink Palette (Vibrant neon & pastel pinks)
  static const Color primaryPink = Color(0xFFFF6B97); // Cute vibrant berry pink
  static const Color sweetPink = Color(0xFFFF8DAF);
  static const Color softPink = Color(0xFFFFB6C1);

  // Outlines & Shadows
  static Color get borderDark => isDark ? const Color(0xFFFF8DAF) : const Color(0xFF3B1A34);
  static Color get shadowDark => isDark ? const Color(0xFF0A030A) : const Color(0xFF241020);

  // Text Colors
  static Color get textPrimary => isDark ? const Color(0xFFFFF0F5) : const Color(0xFF3B1A34);
  static Color get textSecondary => isDark ? const Color(0xFFFFB6C1) : const Color(0xFF6E3D60);
  static Color get textMuted => isDark ? const Color(0xFFB58BA5) : const Color(0xFF8A5A7B);

  // Accents
  static const Color accentYellow = Color(0xFFFFE066); // Star yellow
  static const Color accentMint = Color(0xFF7AE582); // Cute mint green
  static const Color accentBlue = Color(0xFF90E0EF); // Cute sky blue
  static const Color accentPurple = Color(0xFFC77DFF); // Lavender

  // Pixel Shadow Helper
  static List<BoxShadow> pixelShadow({
    Color? color,
    double offset = 4.0,
  }) {
    return [
      BoxShadow(
        color: color ?? shadowDark,
        offset: Offset(offset, offset),
        blurRadius: 0,
        spreadRadius: 0,
      ),
    ];
  }

  // Pixel Border Helper
  static Border pixelBorder({
    Color? color,
    double width = 3.0,
  }) {
    return Border.all(
      color: color ?? borderDark,
      width: width,
    );
  }

  // Typography - Retro Pixel Fonts
  static TextStyle pixel({
    double fontSize = 16,
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
    double? letterSpacing = 1.0,
  }) {
    return GoogleFonts.silkscreen(
      fontSize: fontSize,
      color: color ?? textPrimary,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle pixelHeading({
    double fontSize = 24,
    Color? color,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return GoogleFonts.silkscreen(
      fontSize: fontSize,
      color: color ?? (isDark ? primaryPink : borderDark),
      fontWeight: fontWeight,
      letterSpacing: 1.5,
    );
  }

  static TextStyle retroText({
    double fontSize = 20,
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return GoogleFonts.vt323(
      fontSize: fontSize,
      color: color ?? textPrimary,
      fontWeight: fontWeight,
      letterSpacing: 0.8,
    );
  }
}
