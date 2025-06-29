import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/core/util/widget/audio_player_cubit.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';
import 'package:mazaj_radio/feature/home/data/model/radio_station.dart';
import 'package:mazaj_radio/feature/home/presentation/view_model/radio_provider.dart';
import 'package:provider/provider.dart';

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
    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, state) {
        final cubit = context.read<AudioPlayerCubit>();
        final isPlaying =
            state.currentRadio?.id == radioItem.id && state.isPlaying;
        final isLoading =
            state.currentRadio?.id == radioItem.id && state.isLoading;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Color(
                int.parse(radio.color.replaceFirst('#', '0xFF')),
              ).withOpacity(0.87),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: radio.logo,
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(
                          color: AppColors.greyMedium.withOpacity(0.3),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          color: AppColors.greyMedium.withOpacity(0.3),
                          child: Icon(
                            Icons.radio,
                            size: 30,
                            color: AppColors.white,
                          ),
                        ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        radio.name,
                        style: const TextStyle(
                          color: AppColors.white,
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
                          color: AppColors.white,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Provider.of<RadioProvider>(context).isFavorite(radio)
                            ? CupertinoIcons.heart_solid
                            : CupertinoIcons.heart,
                        color:
                            Provider.of<RadioProvider>(
                                  context,
                                ).isFavorite(radio)
                                ? AppColors.accentColor
                                : AppColors.white,
                      ),
                      onPressed: () {
                        Provider.of<RadioProvider>(
                          context,
                          listen: false,
                        ).toggleFavorite(radio);
                      },
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
                                    AppColors.black,
                                  ),
                                ),
                              )
                              : IconButton(
                                icon: Icon(
                                  isPlaying
                                      ? CupertinoIcons.pause
                                      : CupertinoIcons.play_fill,
                                  color: AppColors.black,
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
              ],
            ),
          ),
        );
      },
    );
  }
}
