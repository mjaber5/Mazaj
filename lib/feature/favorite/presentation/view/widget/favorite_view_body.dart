// favorite_view_body.dart
import 'package:flutter/material.dart';
import 'package:mazaj_radio/core/util/widget/custom_appbar.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';
import 'package:mazaj_radio/feature/favorite/presentation/view/widget/favorite_card_item.dart';
import 'package:mazaj_radio/feature/home/presentation/view_model/radio_provider.dart';
import 'package:provider/provider.dart';

class FavoriteViewBody extends StatelessWidget {
  const FavoriteViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 12, end: 12, top: 16),
        child: Column(
          children: [
            CustomAppBar(isDark: isDark, title: 'Favorite'),
            SizedBox(height: MediaQuery.of(context).size.height * 0.029),
            Expanded(
              child: Consumer<RadioProvider>(
                builder: (context, provider, child) {
                  final favorites = provider.favorites;
                  if (favorites.isEmpty) {
                    return const Center(
                      child: Text(
                        'No favorites yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final radio = favorites[index];
                      final radioItem = RadioItem(
                        id: radio.id,
                        name: radio.name,
                        logo: radio.logo,
                        genres: radio.genres,
                        streamUrl: radio.streamUrl,
                        country: radio.country,
                        featured: radio.featured,
                        color: radio.color,
                        textColor: radio.textColor,
                      );
                      return FavoriteCardItem(
                        radio: radio,
                        radioItem: radioItem,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
