import 'package:codeverse/src/constants/colors.dart';
import 'package:flutter/material.dart';

class CVTextFormFieldTheme {
  CVTextFormFieldTheme._();

  static InputDecorationTheme lightInputDecorationTheme =
      const InputDecorationTheme(
          border: OutlineInputBorder(),
          prefixIconColor: CVAccentColor,
          floatingLabelStyle: TextStyle(color: CVAccentColor),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 2.0, color: CVAccentColor)));

  static InputDecorationTheme darkInputDecorationTheme =
      const InputDecorationTheme(
          border: OutlineInputBorder(),
          prefixIconColor: CVAccentColor,
          floatingLabelStyle: TextStyle(color: CVAccentColor),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 2.0, color: CVAccentColor)));
}
