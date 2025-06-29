// recently_played_section_item.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ionicons/ionicons.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/core/util/constant/sizes.dart';
import 'package:mazaj_radio/core/util/widget/audio_player_cubit.dart';
import 'package:mazaj_radio/feature/home/data/model/radio_station.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';
import 'package:provider/provider.dart';
import 'package:mazaj_radio/feature/home/presentation/view_model/radio_provider.dart';

class RecentlyPlayedSectionItem extends StatefulWidget {
  final RadioStation radio;
  final int index;

  const RecentlyPlayedSectionItem({
    super.key,
    required this.radio,
    this.index = 0,
  });

  @override
  State<RecentlyPlayedSectionItem> createState() =>
      _RecentlyPlayedSectionItemState();
}

class _RecentlyPlayedSectionItemState extends State<RecentlyPlayedSectionItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600 + (widget.index * 100)),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
      textColor: radio.textColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radioItem = _toRadioItem(widget.radio);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
              builder: (context, state) {
                final isCurrentRadio = state.currentRadio?.id == radioItem.id;
                final isPlaying = isCurrentRadio && state.isPlaying;
                final isLoading = isCurrentRadio && state.isLoading;
                final cubit = context.read<AudioPlayerCubit>();

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4,
                  ),
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _isPressed = true),
                    onTapUp: (_) => setState(() => _isPressed = false),
                    onTapCancel: () => setState(() => _isPressed = false),
                    onTap: () => _handleTap(context, radioItem, cubit),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      transform:
                          Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 6,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getBackgroundColor(isDark, isCurrentRadio),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isCurrentRadio
                                  ? AppColors.accentColor.withOpacity(0.3)
                                  : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                isCurrentRadio
                                    ? AppColors.accentColor.withOpacity(0.2)
                                    : AppColors.black.withOpacity(
                                      isDark ? 0.3 : 0.1,
                                    ),
                            blurRadius: isCurrentRadio ? 15 : 8,
                            offset: const Offset(0, 4),
                            spreadRadius: isCurrentRadio ? 1 : -1,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _buildRadioImage(isDark, isPlaying),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildRadioInfo(
                              context,
                              isDark,
                              isCurrentRadio,
                            ),
                          ),
                          _buildPlayButton(
                            isPlaying,
                            isLoading,
                            cubit,
                            radioItem,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Color _getBackgroundColor(bool isDark, bool isCurrentRadio) {
    if (isCurrentRadio) {
      return isDark
          ? AppColors.accentColor.withOpacity(0.25)
          : AppColors.accentColor.withOpacity(0.25);
    }
    return isDark ? AppColors.greyLight.withOpacity(0.1) : AppColors.greyLight;
  }

  Widget _buildRadioImage(bool isDark, bool isPlaying) {
    return Hero(
      tag: 'recently_played_${widget.radio.id}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 55,
        height: 55,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: widget.radio.logo,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      decoration: BoxDecoration(
                        color: AppColors.greyLight.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.radio,
                        size: 30,
                        color:
                            isDark ? AppColors.greyLight : AppColors.greyDark,
                      ),
                    ),
              ),
              if (isPlaying)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: AppColors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.graphic_eq,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioInfo(
    BuildContext context,
    bool isDark,
    bool isCurrentRadio,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.radio.name,
          style: GoogleFonts.poppins(
            fontSize: AppTextSizes.fontSizeMd,
            fontWeight: FontWeight.w600,
            color:
                isCurrentRadio
                    ? AppColors.accentColor
                    : (isDark
                        ? AppColors.textOnPrimary
                        : AppColors.textPrimary),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.radio.genres,
                  style: GoogleFonts.poppins(
                    fontSize: AppTextSizes.fontSizeXs,
                    color:
                        isDark
                            ? AppColors.textOnPrimary
                            : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Ionicons.location,
              size: AppTextSizes.iconXs,
              color: isDark ? AppColors.textOnPrimary : AppColors.textPrimary,
            ),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                widget.radio.country,
                style: GoogleFonts.poppins(
                  fontSize: AppTextSizes.fontSizeXs,
                  color:
                      isDark ? AppColors.textOnPrimary : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        FutureBuilder<String>(
          future: Provider.of<RadioProvider>(
            context,
            listen: false,
          ).getLastPlayedTime(widget.radio.id),
          builder: (context, snapshot) {
            final lastPlayed = _formatLastPlayed(snapshot.data ?? 'Unknown');
            return Row(
              children: [
                Icon(
                  CupertinoIcons.clock,
                  size: AppTextSizes.iconXs,
                  color:
                      isDark ? AppColors.textOnPrimary : AppColors.textPrimary,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Last played: $lastPlayed',
                    style: GoogleFonts.poppins(
                      fontSize: AppTextSizes.fontSizeXs,
                      color:
                          isDark
                              ? AppColors.textOnPrimary
                              : AppColors.textPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildPlayButton(
    bool isPlaying,
    bool isLoading,
    AudioPlayerCubit cubit,
    RadioItem radioItem,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: AppColors.accentColor.withOpacity(isPlaying ? 1.0 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow:
            isPlaying
                ? [
                  BoxShadow(
                    color: AppColors.accentColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
                : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handlePlayButtonTap(cubit, radioItem, isPlaying),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child:
                isLoading
                    ? SizedBox(
                      width: 24,
                      height: 24,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isPlaying ? AppColors.white : AppColors.accentColor,
                          ),
                        ),
                      ),
                    )
                    : Icon(
                      isPlaying
                          ? CupertinoIcons.pause
                          : CupertinoIcons.play_arrow_solid,
                      size: 28,
                      color:
                          isPlaying ? AppColors.white : AppColors.accentColor,
                    ),
          ),
        ),
      ),
    );
  }

  void _handleTap(
    BuildContext context,
    RadioItem radioItem,
    AudioPlayerCubit cubit,
  ) {
    Provider.of<RadioProvider>(
      context,
      listen: false,
    ).addRecentlyPlayed(widget.radio);
    Provider.of<RadioProvider>(
      context,
      listen: false,
    ).setLastPlayedTime(widget.radio.id);

    cubit.playRadio(radioItem, context);
  }

  void _handlePlayButtonTap(
    AudioPlayerCubit cubit,
    RadioItem radioItem,
    bool isPlaying,
  ) {
    if (isPlaying) {
      cubit.pauseRadio(context);
    } else {
      Provider.of<RadioProvider>(
        context,
        listen: false,
      ).addRecentlyPlayed(widget.radio);
      Provider.of<RadioProvider>(
        context,
        listen: false,
      ).setLastPlayedTime(widget.radio.id);
      cubit.playRadio(radioItem, context);
    }
  }

  String _formatLastPlayed(String lastPlayedString) {
    if (lastPlayedString == 'Unknown') return 'Unknown';

    try {
      final lastPlayed = DateTime.parse(lastPlayedString);
      final now = DateTime.now();
      final difference = now.difference(lastPlayed);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
