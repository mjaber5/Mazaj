import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/feature/home/data/model/radio_station.dart';
import 'package:mazaj_radio/feature/home/presentation/view_model/radio_provider.dart';
import 'package:provider/provider.dart';

class RadioDetailsView extends StatelessWidget {
  final RadioStation station;

  const RadioDetailsView({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.accentColor,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              /// RADIO LOGO with Hero
              Hero(
                tag: station.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: station.logo,
                    width: size.width * 0.5,
                    height: size.width * 0.5,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => const CircularProgressIndicator(),
                    errorWidget:
                        (context, url, error) =>
                            const Icon(Iconsax.radio, size: 100),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                station.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${station.genres} • ${station.country}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textsecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              /// LOTTIE ANIMATION
              Consumer<RadioProvider>(
                builder: (context, provider, _) {
                  final isCurrent = provider.currentStation?.id == station.id;
                  final isPlaying = isCurrent && provider.isPlaying;

                  return AnimatedOpacity(
                    opacity: isPlaying ? 1 : 0.3,
                    duration: const Duration(milliseconds: 300),
                    child: Lottie.asset(
                      'assets/images/audio_wave.json',
                      height: 80,
                      repeat: true,
                      animate: isPlaying,
                    ),
                  );
                },
              ),

              /// CONTROLS
              const SizedBox(height: 8),
              Consumer<RadioProvider>(
                builder: (context, provider, _) {
                  final isCurrent = provider.currentStation?.id == station.id;
                  final isPlaying = isCurrent && provider.isPlaying;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          isPlaying
                              ? Iconsax.pause_circle
                              : Iconsax.play_circle,
                          size: 45,
                          color: AppColors.accentColor,
                        ),
                        onPressed: () {
                          isCurrent
                              ? provider.togglePlayPause()
                              : provider.playStation(station);
                        },
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Iconsax.stop, size: 40),
                        color:
                            isCurrent ? Colors.redAccent : Colors.grey.shade400,
                        onPressed: isCurrent ? provider.stop : null,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(
                          provider.isFavorite(station)
                              ? Iconsax.heart
                              : Iconsax.heart_add,
                          size: 38,
                          color:
                              provider.isFavorite(station)
                                  ? Colors.red
                                  : AppColors.accentColor,
                        ),
                        onPressed: () => provider.toggleFavorite(station),
                      ),
                    ],
                  );
                },
              ),

              /// (OPTIONAL) SEEK BAR Placeholder
              const SizedBox(height: 24),

              const Spacer(),

              Consumer<RadioProvider>(
                builder: (context, provider, _) {
                  final isCurrent = provider.currentStation?.id == station.id;
                  return Text(
                    isCurrent && provider.isPlaying
                        ? 'Now Playing: ${station.name}'
                        : 'Tap Play to Start',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textsecondaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
