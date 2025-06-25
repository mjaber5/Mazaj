import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';

class RecentlyPlayedSectionItem extends StatelessWidget {
  final String radioName;
  final String radioGenre;
  final String logoUrl;
  final String lastPlayed;
  final VoidCallback onPlay;

  const RecentlyPlayedSectionItem({
    super.key,
    required this.radioName,
    required this.radioGenre,
    required this.logoUrl,
    required this.lastPlayed,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              logoUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Icon(
                    Icons.radio,
                    size: 40,
                    color: isDark ? AppColors.greyLight : AppColors.greyDark,
                  ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  radioName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark
                            ? AppColors.textOnPrimary
                            : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  radioGenre,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color:
                        isDark
                            ? AppColors.textOnPrimary
                            : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last played: $lastPlayed',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textsecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_fill_rounded),
            iconSize: 38,
            color: AppColors.accentColor,
            onPressed: onPlay,
          ),
        ],
      ),
    );
  }
}
