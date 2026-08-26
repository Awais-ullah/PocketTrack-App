import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized typography system for PocketTrack.
///
/// Uses the platform's built-in system font instead of downloading
/// "Inter" over the network — Google Fonts fetches its font file at
/// runtime, and if that fetch is slow, blocked, or fails on a given
/// device, text using it can render inconsistently (some text fine,
/// some faint/missing) until the download completes. The system font
/// always renders immediately and identically everywhere. Tabular
/// figures are still enabled so currency values line up in lists.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    required Color color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle display({Color color = AppColors.textPrimary}) =>
      _base(size: 32, weight: FontWeight.bold, color: color);

  static TextStyle h1({Color color = AppColors.textPrimary}) =>
      _base(size: 24, weight: FontWeight.w700, color: color);

  static TextStyle h2({Color color = AppColors.textPrimary}) =>
      _base(size: 18, weight: FontWeight.w700, color: color);

  static TextStyle body({Color color = AppColors.textPrimary}) =>
      _base(size: 15, weight: FontWeight.normal, color: color);

  static TextStyle bodyStrong({Color color = AppColors.textPrimary}) =>
      _base(size: 15, weight: FontWeight.w700, color: color);

  static TextStyle caption({Color color = AppColors.textSecondary}) =>
      _base(size: 13, weight: FontWeight.normal, color: color);

  static TextStyle label({Color color = AppColors.textSecondary}) =>
      _base(size: 12, weight: FontWeight.w600, color: color, letterSpacing: 0.6);
}