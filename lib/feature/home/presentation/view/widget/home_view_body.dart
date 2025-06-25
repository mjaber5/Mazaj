import 'package:flutter/material.dart';
import 'package:mazaj_radio/core/util/widget/custom_appbar.dart';
import 'package:mazaj_radio/feature/home/presentation/view/widget/greeting_header.dart';
import 'package:mazaj_radio/feature/home/presentation/view/widget/hot_recommended_card_item.dart';
import 'package:mazaj_radio/feature/home/presentation/view/widget/hot_recommended_section_title.dart';
import 'package:mazaj_radio/feature/home/presentation/view/widget/recently_played_section.dart';
import 'package:mazaj_radio/feature/home/presentation/view/widget/recently_played_section_item.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsetsDirectional.only(start: 16, end: 16, top: 16),
        children: [
          CustomAppBar(isDark: isDark, title: 'Home'),
          buildGreetingHeader(context),
          const SizedBox(height: 20),
          TitleSection(),
          HotRecommendedCardItem(),
          const SizedBox(height: 20),
          RecentlyPlayedSection(),
          RecentlyPlayedSectionItem(
            radioName: 'Rotanna',
            radioGenre: 'Pop',
            logoUrl: 'uvyefr',
            lastPlayed: '!jd',
            onPlay: () {},
          ),
          RecentlyPlayedSectionItem(
            radioName: 'Rotanna',
            radioGenre: 'Pop',
            logoUrl: 'uvyefr',
            lastPlayed: '!jd',
            onPlay: () {},
          ),
          RecentlyPlayedSectionItem(
            radioName: 'Rotanna',
            radioGenre: 'Pop',
            logoUrl: 'uvyefr',
            lastPlayed: '!jd',
            onPlay: () {},
          ),
          RecentlyPlayedSectionItem(
            radioName: 'Rotanna',
            radioGenre: 'Pop',
            logoUrl: 'uvyefr',
            lastPlayed: '!jd',
            onPlay: () {},
          ),
        ],
      ),
    );
  }
}
