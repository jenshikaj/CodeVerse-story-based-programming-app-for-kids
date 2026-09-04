import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

class CVOutlinedButtonTheme {
  CVOutlinedButtonTheme._(); //to avoiding creating instances

  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      foregroundColor: CVAccentColor,
      side: const BorderSide(color: CVAccentColor),
      padding: const EdgeInsets.symmetric(vertical: CVButtonHeight),
    ),
  );

  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      foregroundColor: CVWhiteColor,
      side: const BorderSide(color: CVAccentColor),
      padding: const EdgeInsets.symmetric(vertical: CVButtonHeight),
    ),
  );
}
