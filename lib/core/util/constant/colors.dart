import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core App Colors
  static const Color primaryColor = Color.fromARGB(
    255,
    247,
    247,
    247,
  ); // Deeper, professional blue
  static const Color secondaryColor = Color.fromARGB(
    255,
    98,
    0,
    225,
  ); // Vibrant blue for accents
  static const Color accentColor = Color.fromARGB(
    255,
    224,
    0,
    164,
  ); // Softer blue for highlights

  // Text Colors
  static const Color textPrimary = Color(
    0xFF212121,
  ); // Darker for better contrast
  static const Color textsecondaryColor = Color(
    0xFF757575,
  ); // Muted grey for readability
  static const Color textOnPrimary = Color(
    0xFFFFFFFF,
  ); // White for text on blue
  static const Color textOnsecondaryColor = Color(
    0xFF000000,
  ); // Black for lighter blues

  // Background Colors
  static const Color backgroundLight = Color(
    0xFFF8FAFC,
  ); // Subtle off-white for light theme
  static const Color backgroundDark = Color(0xFF121212); // AMOLED-friendly dark
  static const Color surfaceLight = Color(0xFFFFFFFF); // Clean white for cards
  static const Color surfaceDark = Color(0xFF1E1E1E); // Dark surface for depth

  // Container Colors
  static const Color containerLight = Color(
    0xFFF1F5F9,
  ); // Light blue-grey for containers
  static const Color containerDark = Color(0xFF2D2D2D); // Darker for contrast
  static const Color containerHighlight = Color(
    0xFFE3F2FD,
  ); // Light blue for task highlights

  // Button Colors
  static const Color buttonPrimary = Color(0xFF0D47A1); // Matches primary
  static const Color buttonsecondaryColor = Color(
    0xFF1976D2,
  ); // Matches secondaryColor
  static const Color buttonDisabled = Color(0xFFB0BEC5); // Neutral grey
  static const Color buttonText = Color(0xFFFFFFFF); // White for button text
  static const Color buttonOrange = Color.fromARGB(
    255,
    255,
    162,
    0,
  ); // Amber for action buttons,
  static const Color buttonGreen = Color.fromARGB(
    255,
    76,
    175,
    80,
  ); // Green for success actions
  // Border Colors
  static const Color borderPrimary = Color(
    0xFFE0E0E0,
  ); // Light grey for borders
  static const Color borderDark = Color(0xFF424242); // Dark grey for dark theme
  static const Color borderFocus = Color(
    0xFF1976D2,
  ); // secondaryColor blue for focus

  // Status Colors
  static const Color error = Color(0xFFB00020); // Red for errors (accessible)
  static const Color success = Color(
    0xFF1976D2,
  ); // secondaryColor blue for success
  static const Color warning = Color(0xFFFFA000); // Amber for warnings
  static const Color info = Color(0xFF64B5F6); // Light blue for info

  // Neutral Shades
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color greyDark = Color(0xFF424242);
  static const Color greyMedium = Color(0xFFB0BEC5);
  static const Color greyLight = Color(0xFFECEFF1);

  // Gradient (for Focus Mode or subtle transitions)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
