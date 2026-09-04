import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

class CVElevatedButtonTheme {
  CVElevatedButtonTheme._(); //to avoiding creating instances

  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      foregroundColor: CVWhiteColor,
      backgroundColor: CVAccentColor,
      side: const BorderSide(color: CVAccentColor),
      padding: const EdgeInsets.symmetric(vertical: CVButtonHeight),
    ),
  );

  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      foregroundColor: CVAccentColor,
      backgroundColor: CVWhiteColor,
      side: const BorderSide(color: CVAccentColor),
      padding: const EdgeInsets.symmetric(vertical: CVButtonHeight),
    ),
  );
}
