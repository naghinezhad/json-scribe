import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class AppColors {
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color grey = Colors.grey;

  static Color get grey200 => Colors.grey.shade200;

  AppColors._();
}

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    TextTheme textTheme(Color textColor) => TextTheme(
          displayLarge: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            fontSize: 57,
            color: textColor,
          ),
          displayMedium: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            fontSize: 45,
            color: textColor,
          ),
          displaySmall: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            fontSize: 36,
            color: textColor,
          ),
          headlineLarge: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            fontSize: 32,
            color: textColor,
          ),
          headlineMedium: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            fontSize: 28,
            color: textColor,
          ),
          headlineSmall: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            fontSize: 24,
            color: textColor,
          ),
          titleLarge: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            fontSize: 22,
            color: textColor,
          ),
          titleMedium: GoogleFonts.roboto(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: textColor,
          ),
          titleSmall: GoogleFonts.roboto(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: textColor,
          ),
          bodyLarge: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: textColor,
          ),
          bodyMedium: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: textColor,
          ),
          bodySmall: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: textColor,
          ),
          labelLarge: GoogleFonts.roboto(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: textColor,
          ),
          labelMedium: GoogleFonts.roboto(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: textColor,
          ),
          labelSmall: GoogleFonts.roboto(
            fontWeight: FontWeight.w500,
            fontSize: 11,
            color: textColor,
          ),
        );

    return isDarkTheme
        ? FlexThemeData.dark(
            scheme: FlexScheme.blue,
            surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
            blendLevel: 13,
            subThemesData: const FlexSubThemesData(
              blendOnLevel: 20,
              useMaterial3Typography: true,
              useM2StyleDividerInM3: true,
              alignedDropdown: true,
              useInputDecoratorThemeInDialogs: true,
            ),
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            useMaterial3: true,
            swapLegacyOnMaterial3: true,
            fontFamily: GoogleFonts.roboto().fontFamily,
            textTheme: textTheme(AppColors.white),
          )
        : FlexThemeData.light(
            scheme: FlexScheme.blue,
            surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
            blendLevel: 7,
            subThemesData: const FlexSubThemesData(
              blendOnLevel: 10,
              blendOnColors: false,
              useMaterial3Typography: true,
              useM2StyleDividerInM3: true,
              alignedDropdown: true,
              useInputDecoratorThemeInDialogs: true,
            ),
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            useMaterial3: true,
            swapLegacyOnMaterial3: true,
            fontFamily: GoogleFonts.roboto().fontFamily,
            textTheme: textTheme(AppColors.black),
          );
  }
}
