import 'package:flutter/material.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/core/util/constant/sizes.dart';

class ZChipTheme {
  ZChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: AppColors.greyMedium.withOpacity(0.4),
    labelStyle: TextStyle(
      color: AppColors.textPrimary,
      fontSize: AppTextSizes.fontSizeSm,
      fontFamily: 'Inter',
    ),
    selectedColor: AppColors.secondaryColor,
    padding: EdgeInsets.symmetric(
      horizontal: AppTextSizes.sm,
      vertical: AppTextSizes.xs,
    ),
    checkmarkColor: AppColors.textOnPrimary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTextSizes.borderRadiusSm),
    ),
  );

  static ChipThemeData darkChipTheme = ChipThemeData(
    disabledColor: AppColors.greyDark.withOpacity(0.4),
    labelStyle: TextStyle(
      color: AppColors.textOnPrimary,
      fontSize: AppTextSizes.fontSizeSm,
      fontFamily: 'Inter',
    ),
    selectedColor: AppColors.secondaryColor,
    padding: EdgeInsets.symmetric(
      horizontal: AppTextSizes.sm,
      vertical: AppTextSizes.xs,
    ),
    checkmarkColor: AppColors.textOnPrimary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTextSizes.borderRadiusSm),
    ),
  );
}
