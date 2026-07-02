import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF2BE76C);
  static const Color border = Color(0x3D2BE76C);
  static const Color background = Color(0xFF0E1115);
}

abstract final class AppTheme {
  // --- Dark palette (RetroReq green) ---
  static const Color darkPrimary = Color(0xFF2BE76C);
  static const Color darkGlow = Color(0x802BE76C);
  static const Color darkAccentSoft = Color(0x142BE76C);
  static const Color darkScaffold = Color(0xFF0E1115);
  static const Color darkPanel = Color(0xFF181C22);
  static const Color darkSurface = Color(0xFF181C22);
  static const Color darkElevated = Color(0xFF1E2329);
  static const Color darkBorder = Color(0x3D2BE76C);
  static const Color darkTermBg = Color(0xFF070A0C);
  static const Color darkHint = Color(0x8C96BEA5);
  static const Color darkSubtext = Color(0x8C96BEA5);
  static const Color darkMuted = Color(0x8C96BEA5);
  static const Color darkErr = Color(0xFFFF6B6B);
  static const Color darkStatus3 = Color(0xFF7AA2FF);
  static const Color darkStatus4 = Color(0xFFFFC24D);

  // --- Light palette ---
  static const Color lightPrimary = Color(0xFF00AA44);
  static const Color lightScaffold = Color(0xFFE8E8E8);
  static const Color lightPanel = Color(0xFFE8E8E8);
  static const Color lightSurface = Color(0xFFD0D0D0);
  static const Color lightElevated = Color(0xFFC0C0C0);
  static const Color lightBorder = Color(0xFF88CC99);
  static const Color lightHint = Color(0xFF777777);
  static const Color lightSubtext = Color(0xFF222222);
  static const Color lightMuted = Color(0xFF555555);
  static const Color lightTermBg = Color(0xFFD8D8D8);
  static const Color lightErr = Color(0xFFCC2200);
  static const Color lightStatus3 = Color(0xFF4466CC);
  static const Color lightStatus4 = Color(0xFFAA7700);

  static Color primary(final bool isLight) =>
      isLight ? lightPrimary : darkPrimary;
  static Color glow(final bool isLight) =>
      isLight ? const Color(0x3000AA44) : darkGlow;
  static Color accentSoft(final bool isLight) =>
      isLight ? const Color(0x1400AA44) : darkAccentSoft;
  static Color scaffold(final bool isLight) =>
      isLight ? lightScaffold : darkScaffold;
  static Color panel(final bool isLight) => isLight ? lightPanel : darkPanel;
  static Color surface(final bool isLight) =>
      isLight ? lightSurface : darkSurface;
  static Color elevated(final bool isLight) =>
      isLight ? lightElevated : darkElevated;
  static Color border(final bool isLight) => isLight ? lightBorder : darkBorder;
  static Color termBg(final bool isLight) => isLight ? lightTermBg : darkTermBg;
  static Color hint(final bool isLight) => isLight ? lightHint : darkHint;
  static Color subtext(final bool isLight) =>
      isLight ? lightSubtext : darkSubtext;
  static Color muted(final bool isLight) => isLight ? lightMuted : darkMuted;
  static Color err(final bool isLight) => isLight ? lightErr : darkErr;
  static Color status3(final bool isLight) =>
      isLight ? lightStatus3 : darkStatus3;
  static Color status4(final bool isLight) =>
      isLight ? lightStatus4 : darkStatus4;
}
