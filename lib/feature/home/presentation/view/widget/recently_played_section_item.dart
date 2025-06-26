import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/core/util/widget/audio_player_cubit.dart';
import 'package:mazaj_radio/feature/home/data/model/radio_station.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';
import 'package:provider/provider.dart';
import 'package:mazaj_radio/feature/home/presentation/view_model/radio_provider.dart';

class RecentlyPlayedSectionItem extends StatelessWidget {
  final RadioStation radio;

  const RecentlyPlayedSectionItem({super.key, required this.radio});

  RadioItem _toRadioItem(RadioStation radio) {
    return RadioItem(
      id: radio.id,
      name: radio.name,
      logo: radio.logo,
      genres: radio.genres,
      streamUrl: radio.streamUrl,
      country: radio.country,
      featured: radio.featured,
      color: radio.color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radioItem = _toRadioItem(radio);

    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, state) {
        final isPlaying =
            state.currentRadio?.id == radioItem.id && state.isPlaying;
        final cubit = context.read<AudioPlayerCubit>();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
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
                child: CachedNetworkImage(
                  imageUrl: radio.logo,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorWidget:
                      (context, url, error) => Icon(
                        Icons.radio,
                        size: 40,
                        color:
                            isDark ? AppColors.greyLight : AppColors.greyDark,
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      radio.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark
                                ? AppColors.textOnPrimary
                                : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      radio.genres,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color:
                            isDark
                                ? AppColors.textOnPrimary
                                : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder<String>(
                      future: Provider.of<RadioProvider>(
                        context,
                        listen: false,
                      ).getLastPlayedTime(radio.id),
                      builder: (context, snapshot) {
                        final lastPlayed = snapshot.data ?? 'Unknown';
                        return Text(
                          'Last played: $lastPlayed',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textsecondaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill_rounded,
                  size: 38,
                  color: AppColors.accentColor,
                ),
                onPressed: () {
                  if (isPlaying) {
                    cubit.pauseRadio(context);
                  } else {
                    Provider.of<RadioProvider>(
                      context,
                      listen: false,
                    ).addRecentlyPlayed(radio);
                    cubit.playRadio(radioItem, context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
