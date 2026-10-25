import 'package:flutter/material.dart';

import 'app_palette.dart';

abstract final class AppTextStyles {
  static const String bodyFamily = 'Manrope';
  static const String displayFamily = 'InstrumentSerif';

  static TextTheme textTheme(AppPalette palette) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: displayFamily,
        fontSize: 54,
        height: 0.98,
        letterSpacing: -1.1,
        fontWeight: FontWeight.w400,
        color: palette.ink,
      ),
      displayMedium: TextStyle(
        fontFamily: displayFamily,
        fontSize: 42,
        height: 1,
        letterSpacing: -0.7,
        fontWeight: FontWeight.w400,
        color: palette.ink,
      ),
      displaySmall: TextStyle(
        fontFamily: displayFamily,
        fontSize: 34,
        height: 1.05,
        letterSpacing: -0.3,
        fontWeight: FontWeight.w400,
        color: palette.ink,
      ),
      headlineLarge: TextStyle(
        fontFamily: bodyFamily,
        fontSize: 30,
        height: 1.15,
        letterSpacing: -0.8,
        fontWeight: FontWeight.w700,
        color: palette.ink,
      ),
      headlineMedium: TextStyle(
        fontFamily: bodyFamily,
        fontSize: 25,
        height: 1.2,
        letterSpacing: -0.5,
        fontWeight: FontWeight.w700,
        color: palette.ink,
      ),
      headlineSmall: TextStyle(
        fontFamily: bodyFamily,
        fontSize: 21,
        height: 1.25,
        letterSpacing: -0.25,
        fontWeight: FontWeight.w700,
        color: palette.ink,
      ),
      titleLarge: TextStyle(
        fontFamily: bodyFamily,
        fontSize: 18,
        height: 1.3,
        letterSpacing: -0.15,
        fontWeight: FontWeight.w700,
        color: palette.ink,
      ),
      titleMedium: TextStyle(
        fontFamily: bodyFamily,
        fontSize: 15,
        height: 1.35,
        fontWeight: FontWeight.w700,
        color: palette.ink,
      ),
      titleSmall: TextStyle(
        fontFamily: bodyFamily,
        fontSize: 13,
        height: 1.35,
        fontWeight: FontWeight.w700,
        color: palette.ink,
      ),
      bodyLarge: TextStyle(
        fontFamily: bodyFamily,
        fontSize: 16,
        height: 1.55,
        fontWeight: FontWeight.w400,
        color: palette.ink,
      ),
      bodyMedium: TextStyle(
        fontFamily: bodyFamily,
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: palette.ink,
      ),
      bodySmall: TextStyle(
        fontFamily: bodyFamily,
        fontSize: 12,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: palette.inkMuted,
      ),
      labelLarge: TextStyle(
        fontFamily: bodyFamily,
        fontSize: 14,
        height: 1.2,
        letterSpacing: 0.1,
        fontWeight: FontWeight.w700,
        color: palette.ink,
      ),
      labelMedium: TextStyle(
        fontFamily: bodyFamily,
        fontSize: 12,
        height: 1.2,
        letterSpacing: 0.3,
        fontWeight: FontWeight.w700,
        color: palette.inkMuted,
      ),
      labelSmall: TextStyle(
        fontFamily: bodyFamily,
        fontSize: 10,
        height: 1.2,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w700,
        color: palette.inkMuted,
      ),
    );
  }
}
