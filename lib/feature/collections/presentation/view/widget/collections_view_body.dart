import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mazaj_radio/core/services/radio_service.dart';
import 'package:mazaj_radio/core/util/widget/audio_player_cubit.dart';
import 'package:mazaj_radio/core/util/widget/custom_appbar.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';
import 'package:mazaj_radio/feature/collections/presentation/view/widget/collections_radio_list.dart';
import 'package:mazaj_radio/feature/collections/presentation/view/widget/mini_player.dart';

class CollectionsViewBody extends StatelessWidget {
  const CollectionsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radioService = RadioService();

    return BlocProvider(
      create: (_) => AudioPlayerCubit(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomAppBar(isDark: isDark, title: 'Collections'),
              const SizedBox(height: 24),
              Expanded(
                child: FutureBuilder<List<RadioItem>>(
                  future: radioService.getRadioList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No radios available.'));
                    } else {
                      return CollectionsRadioList(radios: snapshot.data!);
                    }
                  },
                ),
              ),
              const MiniPlayer(),
            ],
          ),
        ),
      ),
    );
  }
}
