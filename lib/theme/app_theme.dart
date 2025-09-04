import 'package:flutter/material.dart';
import 'package:pummel_the_fish/theme/custom_colors.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      brightness: Brightness.light,
      primary: CustomColors.blueDark,
      onPrimary: Colors.white,
      secondary: Colors.amber,
      onSecondary: Colors.white,
      surface: CustomColors.blueLight,
      onSurface: CustomColors.white,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(
        fontFamily: "Titillium Web",
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: CustomColors.blueDark,
      ),
      floatingLabelStyle: TextStyle(
        fontFamily: "Titillium Web",
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: CustomColors.blueDark,
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: CustomColors.blueDark),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: CustomColors.blueLight),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: CustomColors.red),
      ),
    ),
    fontFamily: 'Comfortaa',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: "Titillium Web",
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: CustomColors.blueDark,
      ),
      titleMedium: TextStyle(
        fontFamily: "Comfortaa",
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: CustomColors.blueMedium,
      ),
      bodyLarge: TextStyle(
        fontFamily: "Titillium Web",
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: CustomColors.blueDark,
      ),
      bodyMedium: TextStyle(
        fontFamily: "Titillium Web",
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: CustomColors.white,
      ),
      bodySmall: TextStyle(
        fontFamily: "Titillium Web",
        fontWeight: FontWeight.w700,
        fontSize: 12,
        color: CustomColors.blueDark,
      ),
    ),
  );
}
