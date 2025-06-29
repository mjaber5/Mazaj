import 'package:go_router/go_router.dart';
import 'package:mazaj_radio/core/util/widget/fully_player_view.dart';
import 'package:mazaj_radio/feature/collections/presentation/view/collections_view.dart';
import 'package:mazaj_radio/feature/favorite/presentation/view/favorite_view.dart';
import 'package:mazaj_radio/feature/home/presentation/view/home_view.dart';
import 'package:mazaj_radio/feature/layout/presentation/view/layout_view.dart';
import 'package:mazaj_radio/feature/search/presentation/view/search_view.dart';
import 'package:mazaj_radio/feature/splash/presentation/view/splash_view.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';

abstract class AppRouter {
  static const String splashView = '/';
  static const String layoutView = '/layoutView';
  static const String homeView = '/homeView';
  static const String libraryView = '/libraryView';
  static const String collectionsView = '/collectionsView';
  static const String searchView = '/searchView';
  static const String fullyPlayer = '/fullyPlayerView';

  static final router = GoRouter(
    routes: [
      // Initial route
      GoRoute(path: splashView, builder: (context, state) => SplashView()),
      // Main application routes
      GoRoute(
        path: layoutView,
        builder: (context, state) => const LayoutView(),
      ),
      // Home route
      GoRoute(path: homeView, builder: (context, state) => const HomeView()),
      // Library route
      GoRoute(
        path: libraryView,
        builder: (context, state) => const FavoriteView(),
      ),
      // Collections route
      GoRoute(
        path: collectionsView,
        builder: (context, state) => const CollectionsView(),
      ),
      // Search route
      GoRoute(
        path: searchView,
        builder: (context, state) => const SearchView(),
      ),
      // Fully player route
      GoRoute(
        path: fullyPlayer,
        builder: (context, state) {
          final radio = state.extra as RadioItem?;
          if (radio == null) {
            // Fallback to prevent null radio
            return const LayoutView(); // Or redirect to another safe route
          }
          return FullPlayerView(radio: radio);
        },
      ),
    ],
  );
}
