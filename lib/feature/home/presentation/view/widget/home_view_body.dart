import 'package:flutter/material.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:provider/provider.dart';
import 'package:mazaj_radio/core/util/widget/custom_appbar.dart';
import 'package:mazaj_radio/feature/home/presentation/view/widget/greeting_header.dart';
import 'package:mazaj_radio/feature/home/presentation/view/widget/hot_recommended_card_item.dart';
import 'package:mazaj_radio/feature/home/presentation/view/widget/hot_recommended_section_title.dart';
import 'package:mazaj_radio/feature/home/presentation/view/widget/recently_played_section.dart';
import 'package:mazaj_radio/feature/home/presentation/view/widget/recently_played_section_item.dart';
import 'package:mazaj_radio/feature/home/presentation/view_model/radio_provider.dart';
import 'package:mazaj_radio/feature/collections/presentation/view/widget/mini_player.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsetsDirectional.only(
                start: 16,
                end: 16,
                top: 16,
              ),
              children: [
                CustomAppBar(isDark: isDark, title: 'Home'),
                buildGreetingHeader(context),
                const SizedBox(height: 20),
                const TitleSection(),
                const HotRecommendedCardItem(),
                const SizedBox(height: 20),
                const RecentlyPlayedSection(),
                Consumer<RadioProvider>(
                  builder: (context, provider, child) {
                    final radios = provider.recentlyPlayed;
                    if (radios.isEmpty) {
                      return Center(
                        child: Text(
                          'No recent radios available',
                          style: TextStyle(
                            color:
                                isDark
                                    ? AppColors.textOnPrimary
                                    : AppColors.textPrimary,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children:
                          radios
                              .asMap()
                              .entries
                              .map(
                                (entry) => RecentlyPlayedSectionItem(
                                  radio: entry.value,
                                ),
                              )
                              .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          const MiniPlayer(),
        ],
      ),
    );
  }
}
