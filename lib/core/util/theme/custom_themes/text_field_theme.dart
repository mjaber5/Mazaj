import 'package:flutter/material.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/core/util/constant/sizes.dart';

class ZTextFormFieldTheme {
  ZTextFormFieldTheme._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: AppColors.greyMedium,
    suffixIconColor: AppColors.greyMedium,
    labelStyle: TextStyle(
      fontSize: AppTextSizes.fontSizeSm,
      color: AppColors.textsecondaryColor,
      fontFamily: 'Inter',
    ),
    hintStyle: TextStyle(
      fontSize: AppTextSizes.fontSizeSm,
      color: AppColors.textsecondaryColor,
      fontFamily: 'Inter',
    ),
    errorStyle: TextStyle(
      fontSize: AppTextSizes.fontSizeXs,
      color: AppColors.error,
      fontFamily: 'Inter',
    ),
    floatingLabelStyle: TextStyle(
      fontSize: AppTextSizes.fontSizeSm,
      color: AppColors.textPrimary,
      fontFamily: 'Inter',
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTextSizes.inputFieldRadius),
      borderSide: BorderSide(width: 1, color: AppColors.borderPrimary),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTextSizes.inputFieldRadius),
      borderSide: BorderSide(width: 1, color: AppColors.borderPrimary),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTextSizes.inputFieldRadius),
      borderSide: BorderSide(width: 1.5, color: AppColors.borderFocus),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTextSizes.inputFieldRadius),
      borderSide: BorderSide(width: 1, color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTextSizes.inputFieldRadius),
      borderSide: BorderSide(width: 1.5, color: AppColors.warning),
    ),
  );

  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: AppColors.greyMedium,
    suffixIconColor: AppColors.greyMedium,
    labelStyle: TextStyle(
      fontSize: AppTextSizes.fontSizeSm,
      color: AppColors.textsecondaryColor,
      fontFamily: 'Inter',
    ),
    hintStyle: TextStyle(
      fontSize: AppTextSizes.fontSizeSm,
      color: AppColors.textsecondaryColor,
      fontFamily: 'Inter',
    ),
    errorStyle: TextStyle(
      fontSize: AppTextSizes.fontSizeXs,
      color: AppColors.error,
      fontFamily: 'Inter',
    ),
    floatingLabelStyle: TextStyle(
      fontSize: AppTextSizes.fontSizeSm,
      color: AppColors.textOnPrimary,
      fontFamily: 'Inter',
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTextSizes.inputFieldRadius),
      borderSide: BorderSide(width: 1, color: AppColors.borderDark),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTextSizes.inputFieldRadius),
      borderSide: BorderSide(width: 1, color: AppColors.borderDark),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTextSizes.inputFieldRadius),
      borderSide: BorderSide(width: 1.5, color: AppColors.borderFocus),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTextSizes.inputFieldRadius),
      borderSide: BorderSide(width: 1, color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTextSizes.inputFieldRadius),
      borderSide: BorderSide(width: 1.5, color: AppColors.warning),
    ),
  );
}
