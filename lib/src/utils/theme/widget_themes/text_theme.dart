import 'package:codeverse/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CVTextTheme {
  CVTextTheme._();

  static TextTheme lightTextTheme = TextTheme(
    titleLarge: const TextStyle(
      fontFamily: 'PetitCochon',
      color: CVAccentColor,
      fontSize: 60.0,
      fontWeight: FontWeight.bold,
    ),
    headlineLarge: GoogleFonts.montserrat(
      color: CVDarkColor,
      fontSize: 28.0,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: GoogleFonts.montserrat(
      color: CVDarkColor,
      fontSize: 24.0,
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: GoogleFonts.poppins(
      color: CVDarkColor,
      fontSize: 22.0,
      fontWeight: FontWeight.w700,
    ),
    bodyLarge: GoogleFonts.workSans(
      color: CVDarkColor,
      fontSize: 16.0,
    ),
    bodyMedium: GoogleFonts.poppins(
      color: CVDarkColor,
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
    ),
    bodySmall: GoogleFonts.poppins(
      color: CVDarkColor,
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
    ),
    labelLarge: GoogleFonts.poppins(
      color: CVDarkColor,
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
    ),
  );
  static TextTheme darkTextTheme = TextTheme(
    titleLarge: const TextStyle(
      fontFamily: 'PetitCochon',
      color: CVAccentColor,
      fontSize: 60.0,
      fontWeight: FontWeight.bold,
    ),
    headlineLarge: GoogleFonts.montserrat(
      color: CVWhiteColor,
      fontSize: 28.0,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: GoogleFonts.montserrat(
      color: CVWhiteColor,
      fontSize: 24.0,
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: GoogleFonts.poppins(
      color: CVWhiteColor,
      fontSize: 24.0,
      fontWeight: FontWeight.w700,
    ),
    bodyLarge: GoogleFonts.poppins(
      color: CVWhiteColor,
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
    ),
    bodyMedium: GoogleFonts.poppins(
      color: CVWhiteColor,
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
    ),
    bodySmall: GoogleFonts.poppins(
      color: CVWhiteColor,
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
    ),
    labelLarge: GoogleFonts.poppins(
      color: CVWhiteColor,
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
    ),
  );
}
