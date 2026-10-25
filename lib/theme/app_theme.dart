import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_palette.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(AppPalette.light, Brightness.light);

  static ThemeData dark() => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette palette, Brightness brightness) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: palette.ink,
      brightness: brightness,
    ).copyWith(
      primary: palette.ink,
      onPrimary: palette.inverseInk,
      secondary: palette.ink,
      onSecondary: palette.inverseInk,
      surface: palette.surface,
      onSurface: palette.ink,
      error: palette.error,
      onError: palette.inverseInk,
      outline: palette.line,
      outlineVariant: palette.line,
    );

    final TextTheme textTheme = AppTextStyles.textTheme(palette);
    final RoundedRectangleBorder cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.canvas,
      canvasColor: palette.canvas,
      fontFamily: AppTextStyles.bodyFamily,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[palette],
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: palette.ink,
        systemOverlayStyle:
            brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: cardShape,
      ),
      dividerTheme: DividerThemeData(
        color: palette.line,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: palette.ink, size: 22),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceMuted,
        hintStyle: textTheme.bodyMedium?.copyWith(color: palette.inkMuted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: palette.inkMuted),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(
          color: palette.ink,
          fontWeight: FontWeight.w700,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.ink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.error, width: 1.5),
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: palette.error),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.ink,
          foregroundColor: palette.inverseInk,
          disabledBackgroundColor: palette.ink.withValues(alpha: 0.35),
          disabledForegroundColor: palette.inverseInk.withValues(alpha: 0.7),
          minimumSize: const Size(0, 54),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.ink,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: BorderSide(color: palette.line),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.ink,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(48, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: palette.ink,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: palette.surface,
        modalBarrierColor: Colors.black.withValues(alpha: 0.42),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: false,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.inverse,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: palette.inverseInk,
        ),
        actionTextColor: palette.inverseInk,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        insetPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceMuted,
        selectedColor: palette.ink,
        disabledColor: palette.surfaceMuted,
        side: BorderSide(color: palette.line),
        labelStyle: textTheme.bodySmall?.copyWith(color: palette.ink),
        secondaryLabelStyle: textTheme.bodySmall?.copyWith(
          color: palette.inverseInk,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.ink,
        linearTrackColor: palette.surfaceMuted,
        circularTrackColor: palette.surfaceMuted,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: palette.inverse,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: palette.inverseInk),
      ),
    );
  }
}
