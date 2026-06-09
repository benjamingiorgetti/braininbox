import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// Core brand colors
// ---------------------------------------------------------------------------
const kPrimary       = Color(0xFF4286E6);
const kPrimaryLight  = Color(0xFF51A5F1);
const kPrimaryDark   = Color(0xFF2B64D3);
const kBackground    = Color(0xFFF7F9FC);
const kCard          = Color(0xFFFFFFFF);
const kTextPrimary   = Color(0xFF121E49);
const kTextSecondary = Color(0xFF64748B);
const kDivider       = Color(0xFFEEF2F7);
const kError         = Color(0xFFEF4444);

// Mascot / emotional palette
const kMascotPink       = Color(0xFFEFBEF7);
const kMascotLilac      = Color(0xFFE4ABF3);
const kMascotPurple     = Color(0xFFD595EE);
const kMascotDeepPurple = Color(0xFF7263BA);

// Semantic
const kSuccess = Color(0xFF22C55E);
const kWarning = Color(0xFFF59E0B);

ThemeData buildTheme() {
  final base = ThemeData(brightness: Brightness.light, useMaterial3: true);

  return base.copyWith(
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: kPrimary,
      onPrimary: Colors.white,
      secondary: kPrimaryDark,
      onSecondary: Colors.white,
      error: kError,
      onError: Colors.white,
      surface: kCard,
      onSurface: kTextPrimary,
    ),
    scaffoldBackgroundColor: kBackground,
    cardColor: kCard,
    dividerColor: kDivider,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: kTextPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: kTextPrimary,
        letterSpacing: -0.3,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: kTextPrimary,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: kTextPrimary,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: kTextPrimary,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: kTextSecondary,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: kTextSecondary,
        letterSpacing: 0.5,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: kBackground,
      foregroundColor: kTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: kTextPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kCard,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kPrimary, width: 2),
      ),
      hintStyle: GoogleFonts.plusJakartaSans(color: kTextSecondary),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return kPrimary;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: const BorderSide(color: kDivider, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: kBackground,
      selectedColor: kPrimary.withAlpha(30),
      side: const BorderSide(color: kDivider),
      labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

BoxDecoration kCardDecoration({double radius = 20}) => BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14121E49), // 8% Deep Navy
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ],
    );

BoxDecoration kButtonShadowDecoration({double radius = 16}) => BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [
        BoxShadow(
          color: Color(0x474286E6), // 28% primary blue
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ],
    );
