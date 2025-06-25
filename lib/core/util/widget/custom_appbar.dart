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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color:
                  isDark
                      ? AppColors.greyDark.withOpacity(0.2)
                      : AppColors.greyLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              // ToDo: Replace with actual icon
              Icons.home,
              color:
                  isDark
                      ? AppColors.greyLight.withOpacity(0.85)
                      : AppColors.greyDark.withOpacity(0.7),
              size: 30.0,
            ),
          ),
        ],
      ),
    );
  }
}
