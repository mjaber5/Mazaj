import 'package:flutter/material.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/core/util/constant/sizes.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key, required this.isDark, required this.title});
  final bool isDark;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: AppTextSizes.appBarHeight * 0.4,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color:
                    isDark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Image.asset(
                'assets/images/more.png',
                color:
                    isDark
                        ? AppColors.greyMedium.withOpacity(0.9)
                        : AppColors.greyDark.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
