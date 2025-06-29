import 'package:flutter/material.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';
import 'dart:developer';

class CollectionsRadioList extends StatelessWidget {
  final List<RadioItem> radios;

  const CollectionsRadioList({super.key, required this.radios});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: radios.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 14,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final radio = radios[index];
        final bgColor = _parseColor(radio.color) ?? Colors.grey.shade900;

        return GestureDetector(
          onTap: () {
            // Add your navigation or play logic here
            log('Tapped on ${radio.name}');
          },
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (radio.logo.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      radio.logo,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Icon(
                            Icons.radio,
                            size: 40,
                            color:
                                isDark
                                    ? AppColors.textPrimary.withOpacity(0.8)
                                    : AppColors.textPrimary.withOpacity(0.7),
                          ),
                    ),
                  )
                else
                  Icon(
                    Icons.radio,
                    size: 48,
                    color:
                        isDark
                            ? AppColors.textPrimary.withOpacity(0.8)
                            : AppColors.textPrimary.withOpacity(0.7),
                  ),
                const SizedBox(height: 10),
                Text(
                  radio.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _parseColor(radio.textColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    radio.genres,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: _parseColor(radio.textColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Color? _parseColor(String? colorString) {
  if (colorString == null) return null;
  String hexColor = colorString.replaceAll('#', '');
  if (hexColor.length == 6) {
    hexColor = 'FF$hexColor';
  }
  if (hexColor.length == 8) {
    return Color(int.parse('0x$hexColor'));
  }
  return null;
}
