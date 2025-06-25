import 'package:flutter/material.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/core/util/constant/sizes.dart';

class ZOutLinedButtonTheme {
  ZOutLinedButtonTheme._();

  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: AppColors.textPrimary,
      side: BorderSide(color: AppColors.borderFocus, width: 1.5),
      textStyle: TextStyle(
        fontSize: AppTextSizes.fontSizeMd,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      padding: EdgeInsets.symmetric(
        vertical: AppTextSizes.buttonHeight * 0.5,
        horizontal: AppTextSizes.lg,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTextSizes.buttonRadius),
      ),
    ),
  );

  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: AppColors.textOnPrimary,
      side: BorderSide(color: AppColors.borderFocus, width: 1.5),
      textStyle: TextStyle(
        fontSize: AppTextSizes.fontSizeMd,
        color: AppColors.textOnPrimary,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      padding: EdgeInsets.symmetric(
        vertical: AppTextSizes.buttonHeight * 0.5,
        horizontal: AppTextSizes.lg,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTextSizes.buttonRadius),
      ),
    ),
  );
}
