import 'package:flutter/material.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/core/util/constant/sizes.dart';

Widget buildGreetingHeader(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final hour = DateTime.now().hour;
  final greeting =
      hour < 12
          ? 'Good Morning'
          : hour < 18
          ? 'Good Afternoon'
          : 'Good Evening';

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    child: Text(
      '$greeting 👋',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontSize: AppTextSizes.fontSizeLg,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.textOnPrimary : AppColors.textPrimary,
      ),
    ),
  );
}
