// File: hot_recommended_card_item.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mazaj_radio/core/services/api_srvices.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
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
      height: 280,
      child: FutureBuilder<List<RadioStation>>(
        future: apiService.fetchRadios(featured: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerList(context);
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load radios'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No featured radios available'));
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
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemBuilder: (context, index) {
        final radio = radios[index];
        final radioItem = _toRadioItem(radio);
        final cardColor = _parseColor(radio.color);
        return _buildRadioCard(context, radio, radioItem, cardColor);
      },
    );
  }

  Widget _buildRadioCard(
    BuildContext context,
    RadioStation radio,
    RadioItem radioItem,
    Color cardColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cubit = context.read<AudioPlayerCubit>();
    final radioProvider = Provider.of<RadioProvider>(context);

    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, state) {
        final isPlaying =
            state.currentRadio?.streamUrl == radioItem.streamUrl &&
            state.isPlaying;

        return GestureDetector(
          onLongPress: () => _showRadioOptions(context, radio),
          onTap: () {
            radioProvider.addRecentlyPlayed(radio);
            cubit.playRadio(radioItem, context);
            // TODO: Navigate to FullPlayerScreen
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 210,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: _buildCardContent(
              context,
              radio,
              isPlaying,
              cardColor,
              isDark,
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
    Color cardColor,
    bool isDark,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [cardColor.withOpacity(0.85), cardColor.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: radio.logo,
                        fit: BoxFit.cover,
                        width: 84,
                        height: 84,
                        placeholder:
                            (_, __) => const CircularProgressIndicator(),
                        errorWidget:
                            (_, __, ___) => const Icon(
                              Icons.radio,
                              size: 40,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTextInfo(radio, isDark),
                  const SizedBox(height: 12),
                  _buildEqualizerAndControl(isPlaying),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInfo(RadioStation radio, bool isDark) {
    return Column(
      children: [
        Text(
          radio.name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textOnPrimary : AppColors.textPrimary,
          ),
        ),
        Text(
          radio.genres,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textsecondaryColor,
          ),
        ),
        Text(
          radio.country,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildEqualizerAndControl(bool isPlaying) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isPlaying) _miniEqualizer(),
        const SizedBox(width: 10),
        Icon(
          isPlaying
              ? Icons.pause_circle_filled_rounded
              : Icons.play_circle_fill_rounded,
          size: 36,
          color: AppColors.accentColor,
        ),
      ],
    );
  }

  Widget _miniEqualizer() {
    return Row(
      children: List.generate(5, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300 + (i * 100)),
            width: 3,
            height: (10 + i * 4).toDouble(),
            decoration: BoxDecoration(
              color: Colors.greenAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  void _showRadioOptions(BuildContext context, RadioStation radio) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text("Share"),
              onTap: () {
                Share.share("Check out ${radio.name}: ${radio.streamUrl}");
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text("Report"),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Reported. Thanks for your feedback!"),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerList(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      itemBuilder: (_, __) => _shimmerCard(context),
    );
  }

  Widget _shimmerCard(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade600,
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(20),
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
    );
  }

  Color _parseColor(String color) {
    try {
      return Color(int.parse(color.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF37474F); // Default professional dark-blue-grey
    }
  }
}
