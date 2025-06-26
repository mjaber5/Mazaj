import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

        final radio = state.currentRadio!;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.greyDark : AppColors.greyLight,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: radio.logo,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(Icons.radio),
              ),
            ),
            title: Text(
              radio.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              radio.genres,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.pause, color: AppColors.textPrimary),
              onPressed: () => context.read<AudioPlayerCubit>().pauseRadio(),
            ),
            onTap: () {
              // Navigate to a detailed player screen if needed
            },
          ),
        );
      },
    );
  }
}
