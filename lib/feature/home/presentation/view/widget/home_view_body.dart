import 'package:flutter/material.dart';

import 'package:mazaj_radio/core/util/widget/custom_appbar.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsetsDirectional.only(start: 16, end: 16, top: 16),
        children: [CustomAppBar(isDark: isDark, title: 'Home')],
      ),
    );
  }
}
