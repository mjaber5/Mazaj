// layout_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/core/util/constant/sizes.dart';
import 'package:mazaj_radio/core/util/widget/audio_player_cubit.dart';
import 'package:mazaj_radio/feature/collections/presentation/view/collections_view.dart';
import 'package:mazaj_radio/feature/favorite/presentation/view/favorite_view.dart';
import 'package:mazaj_radio/feature/home/presentation/view/home_view.dart';
import 'package:mazaj_radio/feature/search/presentation/view/search_view.dart';

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
      create: (_) => AudioPlayerCubit(),
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        extendBody: true,
        body: _buildLayoutPageView(),
        bottomNavigationBar: _buildNavigationBar(isDark),
      ),
    );
  }

  NavigationBar _buildNavigationBar(bool isDark) {
    return NavigationBar(
      height: 70,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      onDestinationSelected: (value) {
        setState(() {
          currentIndex = value;
          pageController.jumpToPage(value);
        });
      },
      selectedIndex: currentIndex,
      indicatorColor: Colors.transparent,
      animationDuration: const Duration(milliseconds: 200),
      labelTextStyle: WidgetStateProperty.all(
        TextStyle(
          fontSize: AppTextSizes.fontSizeXs,
          fontWeight: FontWeight.w400,
          color: isDark ? AppColors.greyLight : AppColors.greyDark,
        ),
      ),
      destinations: [
        NavigationDestination(
          icon: Icon(
            Iconsax.home,
            color:
                isDark
                    ? AppColors.greyLight.withOpacity(0.5)
                    : AppColors.greyDark.withOpacity(0.5),
            size: AppTextSizes.iconMd,
          ),
          label: 'Home',
          selectedIcon: Icon(
            Iconsax.home,
            color: AppColors.accentColor,
            size: AppTextSizes.iconMd,
          ),
        ),
        NavigationDestination(
          icon: Icon(
            Ionicons.heart,
            size: AppTextSizes.iconMd,
            color:
                isDark
                    ? AppColors.greyLight.withOpacity(0.5)
                    : AppColors.greyDark.withOpacity(0.5),
          ),
          label: 'Favorite',
          selectedIcon: Icon(
            Ionicons.heart,
            size: AppTextSizes.iconMd,
            color: AppColors.accentColor,
          ),
        ),
        NavigationDestination(
          icon: Icon(
            Ionicons.search,
            size: AppTextSizes.iconMd,
            color:
                isDark
                    ? AppColors.greyLight.withOpacity(0.5)
                    : AppColors.greyDark.withOpacity(0.5),
          ),
          label: 'Search',
          selectedIcon: Icon(
            Ionicons.search,
            color: AppColors.accentColor,
            size: AppTextSizes.iconMd,
          ),
        ),
        NavigationDestination(
          icon: Icon(
            Icons.collections_outlined,
            color:
                isDark
                    ? AppColors.greyLight.withOpacity(0.5)
                    : AppColors.greyDark.withOpacity(0.5),
            size: AppTextSizes.iconMd,
          ),
          label: 'Collections',
          selectedIcon: Icon(
            Icons.collections_outlined,
            color: AppColors.accentColor,
            size: AppTextSizes.iconMd,
          ),
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
