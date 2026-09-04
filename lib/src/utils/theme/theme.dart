import 'package:codeverse/src/utils/theme/widget_themes/elevated_button_theme.dart';
import 'package:codeverse/src/utils/theme/widget_themes/outlined_button_theme.dart';
import 'package:codeverse/src/utils/theme/widget_themes/text_field_theme.dart';
import 'package:codeverse/src/utils/theme/widget_themes/text_theme.dart';
import 'package:flutter/material.dart';

class CVAppTheme {
  CVAppTheme._();

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    textTheme: CVTextTheme.lightTextTheme,
    outlinedButtonTheme: CVOutlinedButtonTheme.lightOutlinedButtonTheme,
    elevatedButtonTheme: CVElevatedButtonTheme.lightElevatedButtonTheme,
    inputDecorationTheme: CVTextFormFieldTheme.lightInputDecorationTheme,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    textTheme: CVTextTheme.darkTextTheme,
    outlinedButtonTheme: CVOutlinedButtonTheme.darkOutlinedButtonTheme,
    elevatedButtonTheme: CVElevatedButtonTheme.darkElevatedButtonTheme,
    inputDecorationTheme: CVTextFormFieldTheme.darkInputDecorationTheme,
  );
}
