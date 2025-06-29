import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';

class CollectionsRadioList extends StatelessWidget {
  final List<RadioItem> radios;

  const CollectionsRadioList({super.key, required this.radios});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: radios.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final radio = radios[index];
        final bgColor =
            _parseColor(radio.color) ??
            (isDark ? AppColors.greyDark : AppColors.white);
        final textColor =
            _parseColor(radio.textColor) ??
            (isDark ? AppColors.white : AppColors.black);

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: 1.0),
          duration: const Duration(milliseconds: 200),
          builder: (context, scale, child) {
            return GestureDetector(
              onTapDown: (_) => {},
              onTapUp: (_) => {},
              onTap: () => debugPrint('Tapped on ${radio.name}'),
              child: AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 150),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  splashColor: AppColors.white.withOpacity(0.1),
                  highlightColor: Colors.transparent,
                  onTap: () => debugPrint("Play ${radio.name}"),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Stack(
                          children: [
                            // Radio image
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: radio.logo,
                                height: 130,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => Container(
                                      height: 130,
                                      color: AppColors.black.withOpacity(0.05),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                errorWidget:
                                    (_, __, ___) => Container(
                                      height: 130,
                                      color: AppColors.black.withOpacity(0.05),
                                      child: const Center(
                                        child: Icon(
                                          Icons.radio,
                                          size: 48,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                              ),
                            ),

                            // isPlaying indicator
                            // if (radio.isPlaying == true)
                            //   Positioned(
                            //     top: 8,
                            //     right: 8,
                            //     child: Container(
                            //       decoration: BoxDecoration(
                            //         color: AppColors.black.withOpacity(0.5),
                            //         borderRadius: BorderRadius.circular(8),
                            //       ),
                            //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            //       child: const Icon(
                            //         Icons.graphic_eq,
                            //         color: AppColors.greenAccent,
                            //         size: 20,
                            //       ),
                            //     ),
                            //   ),
                          ],
                        ),

                        // Station details
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Text(
                                radio.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                radio.genres,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: textColor.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

Color? _parseColor(String? appColorstring) {
  if (appColorstring == null) return null;
  String hexColor = appColorstring.replaceAll('#', '');
  if (hexColor.length == 6) hexColor = 'FF$hexColor';
  if (hexColor.length == 8) {
    try {
      return Color(int.parse('0x$hexColor'));
    } catch (_) {
      return null;
    }
  }
  return null;
}
