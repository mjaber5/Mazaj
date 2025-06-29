import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/core/util/widget/audio_player_cubit.dart';
import 'package:mazaj_radio/core/util/widget/fully_player_view.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';

/// A compact widget that displays a mini audio player for controlling radio playback.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, state) {
        // Hide the mini player if no radio is selected or explicitly hidden
        if (state.currentRadio == null || state.isMiniPlayerVisible == false) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () => _navigateToFullPlayer(context, state.currentRadio!),
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                25,
              ), // Fixed, no rounded corners
              child: Container(
                width:
                    MediaQuery.of(context).size.width *
                    0.85, // Full width, no margins
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? AppColors.greyDark.withOpacity(0.8)
                          : AppColors.greyLight.withOpacity(0.8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      _buildRadioImage(state, isDark),
                      const SizedBox(width: 14),
                      Expanded(child: _buildRadioInfo(state, isDark)),
                      const SizedBox(width: 10),
                      _buildPlayControls(context, state, isDark),
                      const SizedBox(width: 10),
                      _buildCloseButton(context, isDark),
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

  void _navigateToFullPlayer(BuildContext context, RadioItem radio) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                FullPlayerView(radio: radio),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          var offsetAnimation = animation.drive(tween);
          var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
            ),
          );

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: fadeAnimation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  /// Builds the radio station logo image with hero animation tag.
  Widget _buildRadioImage(AudioPlayerState state, bool isDark) {
    return Hero(
      tag: 'radio_image_${state.currentRadio!.id}',
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentColor.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: CachedNetworkImage(
            imageUrl: state.currentRadio!.logo,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            placeholder:
                (_, __) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentColor.withOpacity(0.2),
                        AppColors.accentColor.withOpacity(0.4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.radio,
                    size: 24,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
            errorWidget:
                (_, __, ___) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentColor.withOpacity(0.2),
                        AppColors.accentColor.withOpacity(0.4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.radio,
                    size: 24,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
          ),
        ),
      ),
    );
  }

  /// Builds the radio station information (name and status).
  Widget _buildRadioInfo(AudioPlayerState state, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          state.currentRadio!.name,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            if (state.isPlaying) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.accentColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Live',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.accentColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                state.currentRadio!.genres.isNotEmpty
                    ? state.currentRadio!.genres
                    : 'Radio Station',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the play/pause button for controlling playback.
  Widget _buildPlayControls(
    BuildContext context,
    AudioPlayerState state,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        // Prevent the parent GestureDetector from triggering
        final cubit = context.read<AudioPlayerCubit>();
        if (state.isPlaying) {
          cubit.pauseRadio(context);
        } else {
          cubit.resumeRadio(context);
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accentColor,
              AppColors.accentColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentColor.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () {
              final cubit = context.read<AudioPlayerCubit>();
              if (state.isPlaying) {
                cubit.pauseRadio(context);
              } else {
                cubit.resumeRadio(context);
              }
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child:
                  state.isLoading
                      ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      )
                      : Icon(
                        state.isPlaying
                            ? CupertinoIcons.pause_fill
                            : CupertinoIcons.play_fill,
                        key: ValueKey(state.isPlaying),
                        color: AppColors.white,
                        size: 18,
                      ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the close button to stop the radio and hide the mini player.
  Widget _buildCloseButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () {
        debugPrint(
          'MiniPlayer: Close button pressed, stopping radio and hiding mini player',
        );
        context.read<AudioPlayerCubit>().hideMiniPlayer();
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color:
              isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              debugPrint(
                'MiniPlayer: Close button pressed, stopping radio and hiding mini player',
              );
              context.read<AudioPlayerCubit>().hideMiniPlayer();
            },
            child: Icon(
              CupertinoIcons.xmark,
              size: 16,
              color:
                  isDark
                      ? Colors.white.withOpacity(0.8)
                      : Colors.black.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }
}
