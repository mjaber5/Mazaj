// mini_player.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/core/util/widget/audio_player_cubit.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.fastOutSlowIn),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AudioPlayerCubit, AudioPlayerState>(
      listener: (context, state) {
        if (state.currentRadio != null && state.currentRadio!.id.isNotEmpty) {
          if (!_slideController.isCompleted) {
            _slideController.forward();
          }
          if (state.isPlaying && !_pulseController.isAnimating) {
            _pulseController.repeat(reverse: true);
          } else if (!state.isPlaying) {
            _pulseController.stop();
            _pulseController.reset();
          }
        } else {
          if (_slideController.isCompleted) {
            _slideController.reverse().then((_) {
              _pulseController.stop();
              _pulseController.reset();
            });
          }
        }
      },
      builder: (context, state) {
        if (state.currentRadio == null || state.currentRadio!.id.isEmpty) {
          return const SizedBox.shrink();
        }

        return SlideTransition(
          position: _slideAnimation,
          child: Container(
            margin: const EdgeInsets.only(
              left: 12.0,
              right: 12.0,
              bottom: 12.0, // Adjusted for better positioning
            ),
            child: _buildMiniPlayerContainer(context, state, isDark),
          ),
        );
      },
    );
  }

  Widget _buildMiniPlayerContainer(
    BuildContext context,
    AudioPlayerState state,
    bool isDark,
  ) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color:
            isDark
                ? const Color(0xFF1A1A1A).withOpacity(0.95)
                : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 40,
            offset: const Offset(0, 16),
            spreadRadius: -8,
          ),
        ],
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: _buildMiniPlayerContent(context, state, isDark),
        ),
      ),
    );
  }

  Widget _buildMiniPlayerContent(
    BuildContext context,
    AudioPlayerState state,
    bool isDark,
  ) {
    final cubit = context.read<AudioPlayerCubit>();

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to full player
      },
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! > 300) {
          _handleClose(context, cubit);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildRadioImage(state, isDark),
            const SizedBox(width: 16),
            Expanded(child: _buildRadioInfo(state, isDark)),
            const SizedBox(width: 12),
            _buildPlayControls(context, state, cubit, isDark),
            const SizedBox(width: 12),
            _buildCloseButton(context, cubit, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioImage(AudioPlayerState state, bool isDark) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: state.isPlaying ? _pulseAnimation.value : 1.0,
          child: Hero(
            tag: 'mini_player_${state.currentRadio!.id}',
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentColor.withOpacity(
                      state.isPlaying ? 0.4 : 0.2,
                    ),
                    blurRadius: state.isPlaying ? 12 : 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    CachedNetworkImage(
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
                    if (state.isPlaying)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.graphic_eq,
                            color: Colors.white,
                            size: 16,
                          ),
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
        Row(
          children: [
            if (state.isPlaying && !state.isLoading) ...[
              _buildMiniEqualizer(),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                state.isLoading
                    ? 'Connecting...'
                    : state.isPlaying
                    ? 'Now Playing'
                    : 'Paused',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color:
                      state.isPlaying && !state.isLoading
                          ? AppColors.accentColor
                          : isDark
                          ? Colors.white.withOpacity(0.6)
                          : Colors.black.withOpacity(0.6),
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

  Widget _buildMiniEqualizer() {
    return SizedBox(
      width: 12,
      height: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (i) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (i * 100)),
            width: 2,
            height: [6, 10, 8][i].toDouble(),
            decoration: BoxDecoration(
              color: AppColors.accentColor,
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPlayControls(
    BuildContext context,
    AudioPlayerState state,
    AudioPlayerCubit cubit,
    bool isDark,
  ) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.accentColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentColor.withOpacity(0.3),
            blurRadius: state.isPlaying ? 8 : 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
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

  Widget _buildCloseButton(
    BuildContext context,
    AudioPlayerCubit cubit,
    bool isDark,
  ) {
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
          onTap: () => _handleClose(context, cubit),
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

  void _handleClose(BuildContext context, AudioPlayerCubit cubit) {
    // Stop the radio completely which will dispose the mini player
    cubit.stopRadio(context);
  }
}
