import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/core/util/widget/audio_player_cubit.dart';
import 'package:mazaj_radio/core/util/widget/my_audio_handler.dart';
import 'package:mazaj_radio/feature/collections/presentation/view/collections_view.dart';
import 'package:mazaj_radio/feature/favorite/presentation/view/favorite_view.dart';
import 'package:mazaj_radio/feature/home/presentation/view/home_view.dart';
import 'package:mazaj_radio/feature/search/presentation/view/search_view.dart';
import 'package:provider/provider.dart';

class LayoutView extends StatefulWidget {
  const LayoutView({super.key});

  @override
  State<LayoutView> createState() => _LayoutViewState();
}

class _LayoutViewState extends State<LayoutView> {
  int currentIndex = 0;
  PageController pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocProvider(
      create:
          (context) => AudioPlayerCubit(
            Provider.of<MyAudioHandler>(context, listen: false),
          ),
      child: Scaffold(
        extendBody: true,
        body: Stack(children: [_buildLayoutPageView()]),
        bottomNavigationBar: _buildNavigationBar(isDark),
      ),
    );
  }

  CrystalNavigationBar _buildNavigationBar(bool isDark) {
    return CrystalNavigationBar(
      outlineBorderColor: Colors.transparent,
      itemPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      borderRadius: 30, // Ensure inner content respects rounded corners
      backgroundColor: AppColors.accentColor.withOpacity(
        0.1,
      ), // Let the Container handle the background
      currentIndex: currentIndex,
      onTap: (index) {
        setState(() {
          currentIndex = index;
          pageController.jumpToPage(index);
        });
      },
      items: [
        CrystalNavigationBarItem(
          icon: currentIndex == 0 ? Ionicons.home : Ionicons.home_outline,
          selectedColor: AppColors.accentColor,
          unselectedColor: AppColors.greyDark,
        ),
        CrystalNavigationBarItem(
          icon: currentIndex == 1 ? Iconsax.heart5 : Iconsax.heart,
          selectedColor: AppColors.accentColor,
          unselectedColor: AppColors.greyDark,
        ),
        CrystalNavigationBarItem(
          icon: currentIndex == 2 ? Ionicons.search : Ionicons.search_outline,
          selectedColor: AppColors.accentColor,
          unselectedColor: AppColors.greyDark,
        ),
        CrystalNavigationBarItem(
          icon: currentIndex == 3 ? Ionicons.grid : Ionicons.grid_outline,
          selectedColor: AppColors.accentColor,
          unselectedColor: AppColors.greyDark,
        ),
      ],
    );
  }

  PageView _buildLayoutPageView() {
    return PageView(
      controller: pageController,
      children: const [
        HomeView(),
        FavoriteView(),
        SearchView(),
        CollectionsView(),
      ],
      onPageChanged: (value) {
        setState(() {
          currentIndex = value;
        });
      },
    );
  }
}
