import 'package:flutter/material.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/core/util/constant/sizes.dart';
import 'package:mazaj_radio/core/util/theme/custom_themes/checkbox_theme.dart';
import 'package:mazaj_radio/core/util/theme/custom_themes/chip_theme.dart';
import 'package:mazaj_radio/core/util/theme/custom_themes/elevated_button_theme.dart';
import 'package:mazaj_radio/core/util/theme/custom_themes/outlined_button_theme.dart';
import 'package:mazaj_radio/core/util/theme/custom_themes/text_field_theme.dart';
import 'package:mazaj_radio/core/util/theme/custom_themes/text_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter', // Modern, professional font
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    textTheme: ZTextTheme.lightTextTheme,
    elevatedButtonTheme: ZElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: ZOutLinedButtonTheme.lightOutlinedButtonTheme,
    checkboxTheme: ZCheckboxTheme.lightCheckboxTheme,
    chipTheme: ZChipTheme.lightChipTheme,
    inputDecorationTheme: ZTextFormFieldTheme.lightInputDecorationTheme,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      surface: AppColors.surfaceLight,
      error: AppColors.error,
      onPrimary: AppColors.textOnPrimary,
      onSecondary: AppColors.textOnsecondaryColor,
      onSurface: AppColors.textPrimary,
      onError: AppColors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
    cardTheme: CardTheme(
      elevation: AppTextSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTextSizes.cardRadiusMd),
      ),
      color: AppColors.surfaceLight,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    textTheme: ZTextTheme.darkTextTheme,
    elevatedButtonTheme: ZElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: ZOutLinedButtonTheme.darkOutlinedButtonTheme,
    checkboxTheme: ZCheckboxTheme.darkCheckboxTheme,
    chipTheme: ZChipTheme.darkChipTheme,
    inputDecorationTheme: ZTextFormFieldTheme.darkInputDecorationTheme,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
      onPrimary: AppColors.textOnPrimary,
      onSecondary: AppColors.textOnsecondaryColor,
      onSurface: AppColors.textPrimary,
      onError: AppColors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
      ),
    ),
    cardTheme: CardTheme(
      elevation: AppTextSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTextSizes.cardRadiusMd),
      ),
      color: AppColors.surfaceDark,
    ),
  );
}
