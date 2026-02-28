import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Colori ───────────────────────────────────────────────────────────────────
const Color kBackground   = Color(0xFFFFFFFF);
const Color kCard         = Color(0xFFF0F4FA);
const Color kCardBorder   = Color(0xFFBBD0F0);
const Color kPurple       = Color(0xFF1565C0);
const Color kPurpleDark   = Color(0xFF0D47A1);
const Color kGold         = Color(0xFF1E88E5);
const Color kText         = Color(0xFF0D2B6B);
const Color kTextSecond   = Color(0xFF3D5FA0);
const Color kTextMuted    = Color(0xFF6A8CC0);
const Color kSuccess      = Color(0xFF4CAF50);
const Color kWarning      = Color(0xFFFF9800);
const Color kError        = Color(0xFFF44336);

// ─── Gradienti per i colori evento ────────────────────────────────────────────
const Map<String, List<Color>> kEventGradients = {
  '#8B1A1A': [Color(0xFF8B1A1A), Color(0xFF3D0A0A)],
  '#1A3A5C': [Color(0xFF1A3A5C), Color(0xFF0A1A2E)],
  '#3D6B3D': [Color(0xFF3D6B3D), Color(0xFF1A3A1A)],
  '#7A3B00': [Color(0xFF7A3B00), Color(0xFF3A1A00)],
  '#4A1A6B': [Color(0xFF4A1A6B), Color(0xFF1A0A3A)],
  '#1A4A4A': [Color(0xFF1A4A4A), Color(0xFF0A2A2A)],
};

List<Color> getEventGradient(String? colorHex) {
  return kEventGradients[colorHex?.toUpperCase()] ??
      kEventGradients['#4A1A6B']!;
}

// ─── TextStyle helpers ────────────────────────────────────────────────────────
TextStyle headingLarge({double fontSize = 48, Color color = kText, FontStyle fontStyle = FontStyle.normal}) =>
    GoogleFonts.cormorantGaramond(fontSize: fontSize, fontWeight: FontWeight.w300, color: color, fontStyle: fontStyle);

TextStyle headingMedium({double fontSize = 28, Color color = kText}) =>
    GoogleFonts.cormorantGaramond(fontSize: fontSize, fontWeight: FontWeight.w300, color: color);

TextStyle headingSmall({double fontSize = 22, Color color = kText}) =>
    GoogleFonts.cormorantGaramond(fontSize: fontSize, fontWeight: FontWeight.w600, color: color);

TextStyle bodyLarge({double fontSize = 15, Color color = kText, FontWeight fontWeight = FontWeight.w400}) =>
    GoogleFonts.montserrat(fontSize: fontSize, color: color, fontWeight: fontWeight);

TextStyle bodyMedium({double fontSize = 13, Color color = kText, FontWeight fontWeight = FontWeight.w400}) =>
    GoogleFonts.montserrat(fontSize: fontSize, color: color, fontWeight: fontWeight);

TextStyle labelSmall({double fontSize = 11, Color color = kTextSecond, double letterSpacing = 1.0}) =>
    GoogleFonts.montserrat(fontSize: fontSize, color: color, fontWeight: FontWeight.w500, letterSpacing: letterSpacing);

// ─── ThemeData ────────────────────────────────────────────────────────────────
ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: kBackground,
    colorScheme: const ColorScheme.light(
      primary: kPurple,
      secondary: kGold,
      surface: kCard,
      error: kError,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xF0FFFFFF),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    dividerColor: kCardBorder,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFEEF2FC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kCardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kCardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kPurple),
      ),
      hintStyle: GoogleFonts.montserrat(color: const Color(0xFF9AA8C0), fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPurpleDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: kPurple),
    ),
  );
}
