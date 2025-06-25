import 'package:flutter/material.dart';

import 'package:mazaj_radio/core/util/app_router.dart';
import 'package:mazaj_radio/core/util/theme/theme.dart';

class MazajRadio extends StatelessWidget {
  const MazajRadio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
