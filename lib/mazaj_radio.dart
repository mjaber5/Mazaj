import 'package:flutter/material.dart';
import 'package:mazaj_radio/core/util/app_router.dart';
import 'package:mazaj_radio/core/util/theme/theme.dart';
import 'package:mazaj_radio/core/util/widget/audio_player_cubit.dart';
import 'package:mazaj_radio/core/util/widget/my_audio_handler.dart';
import 'package:mazaj_radio/feature/home/presentation/view_model/radio_provider.dart';
import 'package:provider/provider.dart';

class MazajRadio extends StatelessWidget {
  final MyAudioHandler audioHandler;

  const MazajRadio({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MyAudioHandler>.value(value: audioHandler),
        ChangeNotifierProvider(create: (_) => RadioProvider()),
        // Use create to ensure cubit is properly disposed
        Provider<AudioPlayerCubit>(
          create: (_) => AudioPlayerCubit(audioHandler),
          dispose: (_, cubit) => cubit.close(),
        ),
      ],
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
