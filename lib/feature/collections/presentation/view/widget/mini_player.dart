import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/core/util/widget/audio_player_cubit.dart';
import 'package:mazaj_radio/feature/collections/presentation/view/widget/fully_player_view.dart';
import 'package:mazaj_radio/feature/home/data/model/radio_station.dart';
import 'package:provider/provider.dart';
import 'package:mazaj_radio/feature/home/presentation/view_model/radio_provider.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  Color _parseColor(String color) {
    try {
      return Color(int.parse(color.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, state) {
        if (state.currentRadio == null || !state.isPlaying) {
          return const SizedBox.shrink();
        }

        final radioItem = state.currentRadio!;
        final radioStation = RadioStation(
          id: radioItem.id,
          name: radioItem.name,
          logo: radioItem.logo,
          genres: radioItem.genres,
          streamUrl: radioItem.streamUrl,
          country: radioItem.country,
          featured: radioItem.featured,
          color: radioItem.color,
        );
        final cubit = context.read<AudioPlayerCubit>();
        final cardColor = _parseColor(radioItem.color);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullPlayerScreen(radio: radioItem),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cardColor.withAlpha(180), cardColor.withAlpha(80)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isDark
                        ? AppColors.greyLight.withAlpha(50)
                        : AppColors.greyDark.withAlpha(50),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: radioItem.logo,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorWidget:
                              (context, url, error) => Icon(
                                Icons.radio,
                                size: 30,
                                color:
                                    isDark
                                        ? AppColors.greyLight
                                        : AppColors.greyDark,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              radioItem.name,
                              style: GoogleFonts.poppins(
                                color:
                                    isDark
                                        ? AppColors.textOnPrimary
                                        : AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              radioItem.genres,
                              style: GoogleFonts.poppins(
                                color:
                                    isDark
                                        ? AppColors.textOnPrimary.withAlpha(178)
                                        : AppColors.textPrimary.withAlpha(178),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          FadeScaleTransition(
                            animation: AnimationController(
                              vsync: Navigator.of(context),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.stop_circle,
                                color: Colors.redAccent,
                                size: 30,
                              ),
                              onPressed: () => cubit.stopRadio(context),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FadeScaleTransition(
                            animation: AnimationController(
                              vsync: Navigator.of(context),
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    state.isPlaying
                                        ? Colors.redAccent
                                        : AppColors.accentColor,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  state.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () {
                                  if (state.isPlaying) {
                                    cubit.pauseRadio(context);
                                  } else {
                                    Provider.of<RadioProvider>(
                                      context,
                                      listen: false,
                                    ).addRecentlyPlayed(radioStation);
                                    cubit.playRadio(radioItem, context);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
