import 'package:flutter/material.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/core/util/constant/sizes.dart';

class TitleSection extends StatelessWidget {
  const TitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            'Hot Recommended',
            style: TextStyle(
              color: isDark ? AppColors.textOnPrimary : AppColors.textPrimary,
              fontSize: AppTextSizes.fontSizeMd,
            ),
          ),
        ),
      ],
    );
  }
}
