import 'package:flutter/material.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';

import 'package:mazaj_radio/core/util/widget/custom_appbar.dart';
import 'package:mazaj_radio/feature/favorite/data/model/favorite_sample_model.dart';

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
            FavoriteCardItemSection(
              favorites: [
                FavoriteItem(
                  title: 'AmroDiab',
                  subtitle: 'ya ana ya la',
                  icon: Icons.music_note,
                  color: AppColors.accentColor,
                ),
                FavoriteItem(
                  title: 'AmroDiab',
                  subtitle: 'ya ana ya la',
                  icon: Icons.music_note,
                  color: AppColors.buttonPrimary,
                ),
                FavoriteItem(
                  title: 'AmroDiab',
                  subtitle: 'ya ana ya la',
                  icon: Icons.music_note,
                  color: AppColors.buttonsecondaryColor,
                ),
                FavoriteItem(
                  title: 'AmroDiab',
                  subtitle: 'ya ana ya la',
                  icon: Icons.music_note,
                  color: AppColors.buttonOrange,
                ),
                FavoriteItem(
                  title: 'AmroDiab',
                  subtitle: 'ya ana ya la',
                  icon: Icons.music_note,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FavoriteCardItemSection extends StatelessWidget {
  final List<FavoriteItem> favorites;

  const FavoriteCardItemSection({super.key, required this.favorites});

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No favorites yet', style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      children:
          favorites.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: item.color,
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
                      child: Icon(item.icon, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 22,
                      child: Icon(Icons.play_arrow, color: Colors.black),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
