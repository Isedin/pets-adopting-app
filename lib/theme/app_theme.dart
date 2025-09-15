import 'package:flutter/material.dart';
import 'package:pummel_the_fish/theme/custom_colors.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      brightness: Brightness.light,
      primary: CustomColors.blueDark,
      onPrimary: Colors.white,
      secondary: Colors.amber,
      onSecondary: Colors.white,
      surface: Colors.white, // čišće od jarko plave
      onSurface: Colors.black87,
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
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: CustomColors.blueDark)),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: CustomColors.blueMedium)),
      focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: CustomColors.red)),
    ),
  );

  // Ako želiš “globalni” font bez parametra fontFamily u ThemeData:
  final textTheme = base.textTheme.copyWith(
    headlineLarge: const TextStyle(
      fontFamily: "Titillium Web",
      fontWeight: FontWeight.w700,
      fontSize: 20,
      color: CustomColors.blueDark,
    ),
    titleMedium: const TextStyle(
      fontFamily: "Comfortaa",
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: CustomColors.blueMedium,
    ),
    bodyLarge: const TextStyle(
      fontFamily: "Titillium Web",
      fontWeight: FontWeight.w700,
      fontSize: 16,
      color: CustomColors.blueDark,
    ),
    bodyMedium: const TextStyle(
      fontFamily: "Titillium Web",
      fontWeight: FontWeight.w700,
      fontSize: 14,
      color: CustomColors.blueDark,
    ),
    bodySmall: const TextStyle(
      fontFamily: "Titillium Web",
      fontWeight: FontWeight.w700,
      fontSize: 12,
      color: CustomColors.blueDark,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFFF8FAFC), // nježna svijetla pozadina
    textTheme: textTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        backgroundColor: CustomColors.blueDark,
        foregroundColor: Colors.white,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        backgroundColor: Colors.black87, // modernije od narančaste
        foregroundColor: Colors.white,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: const BorderSide(color: CustomColors.blueDark),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        foregroundColor: CustomColors.blueDark,
      ),
    ),
  );
}
