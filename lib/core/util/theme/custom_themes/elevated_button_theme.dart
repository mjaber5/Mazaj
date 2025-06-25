import 'package:flutter/material.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/core/util/constant/sizes.dart';

class ZElevatedButtonTheme {
  ZElevatedButtonTheme._();

  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: AppTextSizes.buttonElevation,
      foregroundColor: AppColors.buttonText,
      backgroundColor: AppColors.buttonPrimary,
      disabledBackgroundColor: AppColors.buttonDisabled,
      disabledForegroundColor: AppColors.greyMedium,
      side: BorderSide(color: AppColors.buttonPrimary),
      padding: EdgeInsets.symmetric(vertical: AppTextSizes.buttonHeight * 0.5),
      textStyle: TextStyle(
        fontSize: AppTextSizes.fontSizeMd,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTextSizes.buttonRadius),
      ),
    ),
  );

  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: AppTextSizes.buttonElevation,
      foregroundColor: AppColors.buttonText,
      backgroundColor: AppColors.buttonPrimary,
      disabledBackgroundColor: AppColors.buttonDisabled,
      disabledForegroundColor: AppColors.greyMedium,
      side: BorderSide(color: AppColors.buttonPrimary),
      padding: EdgeInsets.symmetric(vertical: AppTextSizes.buttonHeight * 0.5),
      textStyle: TextStyle(
        fontSize: AppTextSizes.fontSizeMd,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTextSizes.buttonRadius),
      ),
    ),
  );
}
