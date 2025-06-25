import 'package:flutter/material.dart';

class FavoriteItem {
  final String title;
  final String subtitle;
  final IconData icon; // or image URL
  final Color color;

  FavoriteItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
