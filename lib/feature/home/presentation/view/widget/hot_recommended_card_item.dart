// hot_recommended_card_item.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mazaj_radio/core/services/api_srvices.dart';
import 'package:mazaj_radio/core/util/widget/audio_player_cubit.dart';
import 'package:mazaj_radio/feature/home/data/model/radio_station.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';
import 'package:provider/provider.dart';
import 'package:mazaj_radio/feature/home/presentation/view_model/radio_provider.dart';

class HotRecommendedCardItem extends StatelessWidget {
  const HotRecommendedCardItem({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    return SizedBox(
      height:
          MediaQuery.of(context).size.height *
          0.42, // Increased height to accommodate content
      child: FutureBuilder<List<RadioStation>>(
        future: apiService.fetchRadios(featured: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerList(context);
          } else if (snapshot.hasError) {
            return _buildErrorCard(context);
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyCard(context);
          }
          return _buildRadioList(context, snapshot.data!);
        },
      ),
    );
  }

  Widget _buildRadioList(BuildContext context, List<RadioStation> radios) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: radios.length,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final radio = radios[index];
        final radioItem = _toRadioItem(radio);
        final cardColor = _parseColor(radio.color);
        return _buildRadioCard(context, radio, radioItem, cardColor, index);
      },
    );
  }

  Widget _buildRadioCard(
    BuildContext context,
    RadioStation radio,
    RadioItem radioItem,
    Color cardColor,
    int index,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cubit = context.read<AudioPlayerCubit>();
    final radioProvider = Provider.of<RadioProvider>(context, listen: false);

    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, state) {
        final isCurrentRadio =
            state.currentRadio?.streamUrl == radioItem.streamUrl;
        final isPlaying = isCurrentRadio && state.isPlaying;
        final isLoading = isCurrentRadio && state.isLoading;

        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 90)),
          curve: Curves.easeOutBack,
          width: MediaQuery.of(context).size.width * 0.55,
          margin: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
          child: GestureDetector(
            onTap:
                () => _handleCardTap(
                  context,
                  radio,
                  radioItem,
                  radioProvider,
                  cubit,
                ),
            onLongPress: () => _showRadioOptions(context, radio),
            child: Hero(
              tag: 'radio_card_${radio.id}',
              child: Material(
                color: Colors.transparent,
                child: _buildCardContent(
                  context,
                  radio,
                  isPlaying,
                  isLoading,
                  cardColor,
                  isDark,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    RadioStation radio,
    bool isPlaying,
    bool isLoading,
    Color cardColor,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: cardColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.white.withOpacity(0.2),
              width: 1,
            ),
            color: AppColors.accentColor.withOpacity(isDark ? 0.1 : 0.05),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16), // Reduced padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.004,
                ), // Reduced space
                _buildRadioImage(radio, isPlaying, context),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.005,
                ), // Reduced space
                _buildRadioInfo(radio, isDark),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.004,
                ), // Reduced space
                _buildPlayControls(isPlaying, isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioImage(
    RadioStation radio,
    bool isPlaying,
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.2,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background image
            CachedNetworkImage(
              imageUrl: radio.logo,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder:
                  (_, __) => Container(
                    color: AppColors.greyDark.withOpacity(0.1),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    ),
                  ),
              errorWidget:
                  (_, __, ___) => Container(
                    color: AppColors.black.withOpacity(0.1),
                    child: const Center(
                      child: Icon(Icons.radio, size: 40, color: Colors.white),
                    ),
                  ),
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.black.withOpacity(0.05),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),

            // Equalizer icon when playing
            if (isPlaying)
              Align(
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.graphic_eq,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioInfo(RadioStation radio, bool isDark) {
    return Column(
      children: [
        Text(
          radio.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 14, // Reduced font size
            fontWeight: FontWeight.w700,
            color: _parseColor(radio.textColor),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.greyDark.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            radio.genres,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 10, // Reduced font size
              fontWeight: FontWeight.w500,
              color: _parseColor(radio.textColor),
            ),
          ),
        ),
        // const SizedBox(height: 2),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Icon(
        //       Ionicons.location,
        //       size: 12,
        //       color: AppColors.greyDark.withOpacity(0.7),
        //     ),
        // const SizedBox(width: 2),
        // Flexible(
        //   child: Text(
        //     radio.country,
        //     style: GoogleFonts.poppins(
        //       fontSize: 10, // Reduced font size
        //       color: _parseColor(radio.textColor),
        //     ),
        //     maxLines: 1,
        //     overflow: TextOverflow.ellipsis,
        //   ),
        // ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildPlayControls(bool isPlaying, bool isLoading) {
    return Container(
      width: double.infinity,
      height: 46, // Slightly reduced height
      decoration: BoxDecoration(
        color: AppColors.greyDark.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.greyMedium.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isPlaying && !isLoading) ...[
            _buildAdvancedEqualizer(),
            const SizedBox(width: 12),
          ],
          if (isLoading)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isPlaying
                    ? CupertinoIcons.pause
                    : CupertinoIcons.play_arrow_solid,
                key: ValueKey(isPlaying),
                size: 28,
                color: Colors.white,
              ),
            ),
          const SizedBox(width: 8),
          Text(
            isLoading
                ? 'Loading...'
                : (isPlaying ? 'Now Playing' : 'Tap to Play'),
            style: GoogleFonts.poppins(
              fontSize: 11, // Reduced font size
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedEqualizer() {
    return Row(
      children: List.generate(4, (i) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (i * 100)),
          margin: const EdgeInsets.symmetric(horizontal: 1),
          width: 3,
          height: [8, 16, 12, 20][i].toDouble(),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:
            isDark ? Colors.red.shade900.withOpacity(0.3) : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Failed to load featured radios',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Pull to refresh or try again later',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.red.shade300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:
            isDark
                ? AppColors.greyMedium.withOpacity(0.3)
                : AppColors.greyMedium,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radio_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No featured radios available',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.greyDark.withOpacity(isDark ? 0.9 : 1.0),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for updates',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.greyDark.withOpacity(isDark ? 0.7 : 1.0),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleCardTap(
    BuildContext context,
    RadioStation radio,
    RadioItem radioItem,
    RadioProvider radioProvider,
    AudioPlayerCubit cubit,
  ) {
    radioProvider.addRecentlyPlayed(radio);
    radioProvider.setLastPlayedTime(radio.id);
    cubit.playRadio(radioItem, context);
  }

  void _showRadioOptions(BuildContext context, RadioStation radio) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              _buildOptionTile(ctx, Icons.share_rounded, 'Share Radio', () {
                Share.share(
                  "🎵 Listen to ${radio.name} on Mazaj Radio!\n"
                  "Genre: ${radio.genres}\n"
                  "Country: ${radio.country}\n"
                  "${radio.streamUrl}",
                );
                Navigator.pop(ctx);
              }, isDark),
              _buildOptionTile(
                ctx,
                Icons.favorite_outline,
                'Add to Favorites',
                () {
                  Provider.of<RadioProvider>(
                    context,
                    listen: false,
                  ).addFavorite(radio);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Added ${radio.name} to favorites!"),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                isDark,
              ),
              _buildOptionTile(
                ctx,
                Icons.report_outlined,
                'Report Station',
                () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Thank you for your feedback!"),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                isDark,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
    bool isDark,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.white : AppColors.black).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDark ? AppColors.white : AppColors.black,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.white : AppColors.black,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildShimmerList(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (_, index) => _shimmerCard(context, index),
    );
  }

  Widget _shimmerCard(BuildContext context, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      width: 240,
      margin: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
      child: Shimmer.fromColors(
        baseColor:
            isDark ? AppColors.greyMedium : AppColors.greyDark.withOpacity(0.6),
        highlightColor:
            isDark ? AppColors.greyMedium : AppColors.greyDark.withOpacity(0.3),
        child: Container(
          decoration: BoxDecoration(
            color:
                isDark
                    ? AppColors.greyMedium
                    : AppColors.greyDark.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
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

  Color _parseColor(String color) {
    try {
      return Color(int.parse(color.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF6366F1); // Modern indigo
    }
  }
}
