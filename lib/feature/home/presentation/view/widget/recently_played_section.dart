import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/core/util/constant/sizes.dart';

class RecentlyPlayedSection extends StatelessWidget {
  const RecentlyPlayedSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            'Recently Played',
            style: GoogleFonts.poppins(
              color: isDark ? AppColors.textOnPrimary : AppColors.textPrimary,
              fontSize: AppTextSizes.fontSizeMd,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
