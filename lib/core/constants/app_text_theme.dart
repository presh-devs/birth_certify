import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextTheme {
  static TextTheme get lightTextTheme => TextTheme(
        displayLarge: GoogleFonts.albertSans(
          fontSize: 80,
          fontWeight: FontWeight.w900,
          height: 1.3,
        ),
        displayMedium: GoogleFonts.albertSans(
          fontSize: 72,
          fontWeight: FontWeight.w800,
          height: 1.4,
        ),
        displaySmall: GoogleFonts.albertSans(
          fontSize: 64,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
        headlineLarge: GoogleFonts.albertSans(
          fontSize: 56,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.albertSans(
          fontSize: 48,
          fontWeight: FontWeight.w500,
        ),
        headlineSmall: GoogleFonts.albertSans(
          fontSize: 40,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: GoogleFonts.albertSans(
          fontSize: 36,
          fontWeight: FontWeight.w400,
        ),
        titleMedium: GoogleFonts.albertSans(
          fontSize: 32,
          fontWeight: FontWeight.w300,
        ),
        titleSmall: GoogleFonts.albertSans(
          fontSize: 28,
          fontWeight: FontWeight.w300,
        ),
        bodyLarge: GoogleFonts.ibmPlexSerif(
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.ibmPlexSerif(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.ibmPlexSerif(
          fontSize: 12,
          fontWeight: FontWeight.w300,
        ),
        labelLarge: GoogleFonts.ibmPlexSerif(
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
        labelMedium: GoogleFonts.ibmPlexSerif(
          fontSize: 14,
          fontWeight: FontWeight.w300,
        ),
        labelSmall: GoogleFonts.ibmPlexSerif(
          fontSize: 12,
          fontWeight: FontWeight.w300,
        ),
      );
}
