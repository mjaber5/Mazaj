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
      duration: const Duration(milliseconds: 50),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
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
        debugPrint(
          'MiniPlayer state: currentRadio=${state.currentRadio?.id}, isPlaying=${state.isPlaying}, isLoading=${state.isLoading}',
        );
        if (state.currentRadio != null && state.currentRadio!.id.isNotEmpty) {
          if (!_slideController.isCompleted) {
            _slideController.forward();
            _pulseController.repeat(reverse: true);
          }
        } else {
          if (_slideController.isCompleted) {
            _slideController.reverse();
            _pulseController.stop();
          }
        }
      },
      builder: (context, state) {
        debugPrint(
          'MiniPlayer builder: currentRadio=${state.currentRadio?.id}',
        );
        if (state.currentRadio == null || state.currentRadio!.id.isEmpty) {
          return const SizedBox.shrink();
        }

        return SlideTransition(
          position: _slideAnimation,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Colors.black.withOpacity(0.8)
                            : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: _buildMiniPlayerContent(context, state, isDark),
                ),
              ),
            ),
          ),
        );
      },
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
          cubit.stopRadio(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildRadioImage(state, isDark),
            const SizedBox(width: 16),
            Expanded(child: _buildRadioInfo(state, isDark)),
            _buildPlayControls(context, state, cubit),
            const SizedBox(width: 8),
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentColor.withOpacity(0.3),
                    blurRadius: state.isPlaying ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: state.currentRadio!.logo,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder:
                          (_, __) => Container(
                            color: Colors.grey.withOpacity(0.3),
                            child: const Icon(Icons.radio, size: 25),
                          ),
                      errorWidget:
                          (_, __, ___) => Container(
                            color: Colors.grey.withOpacity(0.3),
                            child: Icon(
                              Icons.radio,
                              size: 25,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                    ),
                    if (state.isPlaying)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.graphic_eq,
                            color: Colors.white,
                            size: 20,
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
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textOnPrimary : AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            if (state.isPlaying) ...[
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
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color:
                      state.isPlaying
                          ? AppColors.accentColor
                          : AppColors.textsecondaryColor,
                  fontWeight: FontWeight.w500,
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (i * 100)),
          margin: const EdgeInsets.symmetric(horizontal: 0.5),
          width: 2,
          height: [4, 8, 6][i].toDouble(),
          decoration: BoxDecoration(
            color: AppColors.accentColor,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }

  Widget _buildPlayControls(
    BuildContext context,
    AudioPlayerState state,
    AudioPlayerCubit cubit,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildControlButton(
          icon: Icons.skip_previous,
          onPressed: () {
            // TODO: Implement previous track
          },
          size: 32,
          isEnabled: false,
        ),
        const SizedBox(width: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.accentColor,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentColor.withOpacity(0.4),
                blurRadius: state.isPlaying ? 8 : 4,
                offset: const Offset(0, 2),
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
                duration: const Duration(milliseconds: 100),
                child:
                    state.isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Icon(
                          state.isPlaying ? Icons.pause : Icons.play_arrow,
                          key: ValueKey(state.isPlaying),
                          color: Colors.white,
                          size: 24,
                        ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildControlButton(
          icon: Icons.skip_next,
          onPressed: () {
            // TODO: Implement next track
          },
          size: 32,
          isEnabled: false,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
    bool isEnabled = true,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: isEnabled ? onPressed : null,
          child: Icon(
            icon,
            size: size * 0.6,
            color:
                isEnabled
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)
                    : Colors.grey,
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
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            cubit.stopRadio(context);
          },
          child: Icon(
            Icons.close,
            size: 20,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
