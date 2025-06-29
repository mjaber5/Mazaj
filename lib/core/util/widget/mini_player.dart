import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/core/util/widget/audio_player_cubit.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, state) {
        if (state.currentRadio == null || !state.isPlaying) {
          return const SizedBox.shrink();
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: MediaQuery.of(context).size.width - 32,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isDark
                          ? AppColors.white.withOpacity(0.1)
                          : AppColors.black.withOpacity(0.1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
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
        );
      },
    );
  }

  Widget _buildRadioImage(AudioPlayerState state, bool isDark) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: CachedNetworkImage(
          imageUrl: state.currentRadio!.logo,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          placeholder:
              (_, __) => Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.radio,
                  size: 24,
                  color: Colors.grey.withOpacity(0.6),
                ),
              ),
          errorWidget:
              (_, __, ___) => Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.radio,
                  size: 24,
                  color: Colors.grey.withOpacity(0.6),
                ),
              ),
        ),
      ),
    );
  }

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
        Text(
          state.isLoading ? 'Connecting...' : 'Now Playing',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.accentColor,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPlayControls(
    BuildContext context,
    AudioPlayerState state,
    bool isDark,
  ) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.accentColor,
        borderRadius: BorderRadius.circular(22),
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
            duration: const Duration(milliseconds: 200),
            child:
                state.isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Icon(
                      state.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      key: ValueKey(state.isPlaying),
                      color: Colors.white,
                      size: 22,
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context, bool isDark) {
    return Container(
      width: 36,
      height: 36,
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
            context.read<AudioPlayerCubit>().stopRadio(context);
          },
          child: Icon(
            Icons.close_rounded,
            size: 18,
            color:
                isDark
                    ? Colors.white.withOpacity(0.8)
                    : Colors.black.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
