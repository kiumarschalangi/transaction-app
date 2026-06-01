import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF00FF00);
  static const Color border = Color(0xFF444444);
  static const Color background = Color(0xFF333333);
}

abstract final class AppTheme {
  // --- Dark palette ---
  static const Color darkPrimary = Color(0xFF00FF00);
  static const Color darkScaffold = Color(0xFF000000);
  static const Color darkPanel = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF333333);
  static const Color darkElevated = Color(0xFF222222);
  static const Color darkBorder = Color(0xFF444444);
  static const Color darkHint = Color(0xFF666666);
  static const Color darkSubtext = Color(0xFFCCCCCC);
  static const Color darkMuted = Color(0xFF888888);

  // --- Light palette ---
  static const Color lightPrimary = Color(0xFF00BB00);
  static const Color lightScaffold = Color(0xFFE8E8E8);
  static const Color lightPanel = Color(0xFFE8E8E8);
  static const Color lightSurface = Color(0xFFD0D0D0);
  static const Color lightElevated = Color(0xFFC0C0C0);
  static const Color lightBorder = Color(0xFFAAAAAA);
  static const Color lightHint = Color(0xFF777777);
  static const Color lightSubtext = Color(0xFF222222);
  static const Color lightMuted = Color(0xFF555555);

  static Color primary(final bool isLight) =>
      isLight ? lightPrimary : darkPrimary;
  static Color scaffold(final bool isLight) =>
      isLight ? lightScaffold : darkScaffold;
  static Color panel(final bool isLight) => isLight ? lightPanel : darkPanel;
  static Color surface(final bool isLight) =>
      isLight ? lightSurface : darkSurface;
  static Color elevated(final bool isLight) =>
      isLight ? lightElevated : darkElevated;
  static Color border(final bool isLight) => isLight ? lightBorder : darkBorder;
  static Color hint(final bool isLight) => isLight ? lightHint : darkHint;
  static Color subtext(final bool isLight) =>
      isLight ? lightSubtext : darkSubtext;
  static Color muted(final bool isLight) => isLight ? lightMuted : darkMuted;
}
