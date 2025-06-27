// favorite_view_body.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mazaj_radio/core/util/widget/audio_player_cubit.dart';
import 'package:mazaj_radio/core/util/widget/custom_appbar.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';
import 'package:mazaj_radio/feature/home/data/model/radio_station.dart';
import 'package:mazaj_radio/feature/home/presentation/view_model/radio_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../core/util/widget/mini_player.dart';

class FavoriteViewBody extends StatelessWidget {
  const FavoriteViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomAppBar(isDark: isDark, title: 'Favorite'),
            SizedBox(height: MediaQuery.of(context).size.height * 0.045),
            Expanded(
              child: Consumer<RadioProvider>(
                builder: (context, provider, child) {
                  final favorites = provider.favorites;
                  if (favorites.isEmpty) {
                    return const Center(
                      child: Text(
                        'No favorites yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final radio = favorites[index];
                      final radioItem = RadioItem(
                        id: radio.id,
                        name: radio.name,
                        logo: radio.logo,
                        genres: radio.genres,
                        streamUrl: radio.streamUrl,
                        country: radio.country,
                        featured: radio.featured,
                        color: radio.color,
                      );
                      return FavoriteCardItem(
                        radio: radio,
                        radioItem: radioItem,
                      );
                    },
                  );
                },
              ),
            ),
            const MiniPlayer(),
          ],
        ),
      ),
    );
  }
}

class FavoriteCardItem extends StatelessWidget {
  final RadioStation radio;
  final RadioItem radioItem;

  const FavoriteCardItem({
    super.key,
    required this.radio,
    required this.radioItem,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AudioPlayerCubit>();
    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, state) {
        final isPlaying =
            state.currentRadio?.id == radioItem.id && state.isPlaying;
        final isLoading =
            state.currentRadio?.id == radioItem.id && state.isLoading;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Color(
                int.parse(radio.color.replaceFirst('#', '0xFF')),
              ).withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.radio, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        radio.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${radio.genres} • ${radio.country}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 22,
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          )
                          : IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              if (isPlaying) {
                                cubit.pauseRadio(context);
                              } else {
                                cubit.playRadio(radioItem, context);
                                Provider.of<RadioProvider>(
                                  context,
                                  listen: false,
                                ).addRecentlyPlayed(radio);
                              }
                            },
                          ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
