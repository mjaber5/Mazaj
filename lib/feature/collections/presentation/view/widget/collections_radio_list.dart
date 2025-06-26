import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animations/animations.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/core/util/widget/audio_player_cubit.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';

class CollectionsRadioList extends StatelessWidget {
  final List<RadioItem> radios;
  const CollectionsRadioList({super.key, required this.radios});

  String safeImageUrl(String url) {
    if (url.contains('placehold.co')) {
      return '$url&format=png';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AudioPlayerCubit, AudioPlayerState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      child: ListView.builder(
        itemCount: radios.length,
        itemBuilder: (context, index) {
          final radio = radios[index];
          return OpenContainer(
            closedElevation: 0,
            closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            closedBuilder: (context, openContainer) {
              return _RadioListItem(radio: radio, safeImageUrl: safeImageUrl);
            },
            openBuilder: (context, _) {
              return _RadioDetailScreen(radio: radio);
            },
          );
        },
      ),
    );
  }
}

class _RadioListItem extends StatelessWidget {
  final RadioItem radio;
  final String Function(String) safeImageUrl;

  const _RadioListItem({required this.radio, required this.safeImageUrl});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, state) {
        final isPlaying = state.currentRadio?.id == radio.id && state.isPlaying;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.accentColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: safeImageUrl(radio.logo),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => const CircularProgressIndicator(),
                  errorWidget:
                      (context, url, error) =>
                          const Icon(Icons.radio, size: 60),
                ),
              ),
              title: Text(
                radio.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                radio.genres,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              trailing: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 22,
                child: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    final cubit = context.read<AudioPlayerCubit>();
                    if (isPlaying) {
                      cubit.pauseRadio();
                    } else {
                      cubit.playRadio(radio);
                    }
                  },
                ),
              ),
              onTap: () => context.read<AudioPlayerCubit>().playRadio(radio),
            ),
          ),
        );
      },
    );
  }
}

class _RadioDetailScreen extends StatelessWidget {
  final RadioItem radio;

  const _RadioDetailScreen({required this.radio});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(radio.name)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: radio.logo,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Text(radio.name, style: Theme.of(context).textTheme.headlineSmall),
            Text(radio.genres, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
