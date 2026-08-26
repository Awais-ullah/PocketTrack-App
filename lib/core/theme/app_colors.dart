import 'package:flutter/material.dart';

/// Centralized color palette for PocketTrack.
///
/// No widget should ever hardcode a Color literal — every color used
/// in the UI must come from this class so the whole app can be
/// re-themed (including dark mode) from one place.
class AppColors {
  AppColors._();

  // ---- Brand ----
  static const Color primary = Color(0xFF1B5E4F);
  static const Color primaryDark = Color(0xFF0F3D33);
  static const Color primaryLight = Color(0xFFDCEEE8);

  // ---- Semantic (transaction types) ----
  static const Color income = Color(0xFF2E9E5B);
  static const Color incomeSurface = Color(0xFFE3F5EA);
  static const Color expense = Color(0xFFD9534F);
  static const Color expenseSurface = Color(0xFFFBE7E6);

  // ---- Light theme neutrals ----
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1D1F);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);

  // ---- Dark theme neutrals ----
  static const Color backgroundDark = Color(0xFF121416);
  static const Color surfaceDark = Color(0xFF1C1F22);
  static const Color textPrimaryDark = Color(0xFFF2F3F5);
  static const Color textSecondaryDark = Color(0xFF9AA0A6);
  static const Color dividerDark = Color(0xFF2C2F33);

  // ---- Status ----
  static const Color warning = Color(0xFFE8A93D);
  static const Color error = Color(0xFFD9534F);

  /// Category accent colors — cycled through for category icons
  /// that don't have an explicit color assigned.
  static const List<Color> categoryPalette = [
    Color(0xFF1B5E4F),
    Color(0xFF2E9E5B),
    Color(0xFFE8A93D),
    Color(0xFF3D7AB3),
    Color(0xFF8B5CF6),
    Color(0xFFD9534F),
    Color(0xFF0F9B8E),
    Color(0xFF6B7280),
  ];
}
