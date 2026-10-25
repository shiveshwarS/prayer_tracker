import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.canvas,
    required this.surface,
    required this.surfaceMuted,
    required this.ink,
    required this.inkMuted,
    required this.line,
    required this.inverse,
    required this.inverseInk,
    required this.inverseMuted,
    required this.error,
    required this.shadow,
    required this.contributionLevels,
  });

  final Color canvas;
  final Color surface;
  final Color surfaceMuted;
  final Color ink;
  final Color inkMuted;
  final Color line;
  final Color inverse;
  final Color inverseInk;
  final Color inverseMuted;
  final Color error;
  final Color shadow;

  /// Six levels, from zero completed prayers to all five.
  final List<Color> contributionLevels;

  static const AppPalette light = AppPalette(
    canvas: Color(0xFFF7F6F2),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEFEEE9),
    ink: Color(0xFF11110F),
    inkMuted: Color(0xFF686862),
    line: Color(0xFFE3E1D9),
    inverse: Color(0xFF0E0E0C),
    inverseInk: Color(0xFFFAF9F5),
    inverseMuted: Color(0xFFB8B7B0),
    error: Color(0xFF9B2C2C),
    shadow: Color(0x14000000),
    contributionLevels: <Color>[
      Color(0xFFE8E7E1),
      Color(0xFFCFCDC5),
      Color(0xFFA8A69D),
      Color(0xFF77756E),
      Color(0xFF3F3E3A),
      Color(0xFF11110F),
    ],
  );

  static const AppPalette dark = AppPalette(
    canvas: Color(0xFF0A0A09),
    surface: Color(0xFF141412),
    surfaceMuted: Color(0xFF1D1D1A),
    ink: Color(0xFFF4F3EE),
    inkMuted: Color(0xFFA3A29A),
    line: Color(0xFF2A2A26),
    inverse: Color(0xFFF4F3EE),
    inverseInk: Color(0xFF0B0B09),
    inverseMuted: Color(0xFF5C5B55),
    error: Color(0xFFFFB4AB),
    shadow: Color(0x3D000000),
    contributionLevels: <Color>[
      Color(0xFF20201D),
      Color(0xFF34342F),
      Color(0xFF5A5952),
      Color(0xFF94928A),
      Color(0xFFC9C7BF),
      Color(0xFFF4F3EE),
    ],
  );

  Color contributionColor(int completed) =>
      contributionLevels[completed.clamp(0, 5)];

  @override
  AppPalette copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceMuted,
    Color? ink,
    Color? inkMuted,
    Color? line,
    Color? inverse,
    Color? inverseInk,
    Color? inverseMuted,
    Color? error,
    Color? shadow,
    List<Color>? contributionLevels,
  }) {
    return AppPalette(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      line: line ?? this.line,
      inverse: inverse ?? this.inverse,
      inverseInk: inverseInk ?? this.inverseInk,
      inverseMuted: inverseMuted ?? this.inverseMuted,
      error: error ?? this.error,
      shadow: shadow ?? this.shadow,
      contributionLevels: contributionLevels ?? this.contributionLevels,
    );
  }

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) {
      return this;
    }
    return AppPalette(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      line: Color.lerp(line, other.line, t)!,
      inverse: Color.lerp(inverse, other.inverse, t)!,
      inverseInk: Color.lerp(inverseInk, other.inverseInk, t)!,
      inverseMuted: Color.lerp(inverseMuted, other.inverseMuted, t)!,
      error: Color.lerp(error, other.error, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      contributionLevels: List<Color>.generate(
        6,
        (int index) =>
            Color.lerp(
              contributionLevels[index],
              other.contributionLevels[index],
              t,
            )!,
      ),
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
