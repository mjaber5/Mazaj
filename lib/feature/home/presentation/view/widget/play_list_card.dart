import 'package:flutter/material.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/feature/home/data/model/play_list.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;

  const PlaylistCard({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: playlist.color,
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                playlist.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                playlist.subtitle,
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                '${playlist.songCount} Songs',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        // Play Button with White Background Circle
        Positioned(
          bottom: -20,
          right: 16,
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(
              4,
            ), // space between outer and inner circle
            child: Container(
              decoration: BoxDecoration(
                color: playlist.color,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.play_arrow, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
