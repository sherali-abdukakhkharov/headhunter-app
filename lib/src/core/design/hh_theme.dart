import 'package:flutter/material.dart';

import 'package:jobbridge_app/src/core/design/hh_colors.dart';
import 'package:jobbridge_app/src/core/design/hh_metrics.dart';
import 'package:jobbridge_app/src/core/design/hh_typography.dart';

/// Builds the [ThemeData] from the design tokens.
///
/// Most of the product is built from the `Hh*` components rather than raw
/// Material widgets, so this theme mainly covers the surfaces Flutter draws
/// itself: scaffold background, app bar, dialogs, text selection, and the
/// fallback text theme.
///
/// The design is a **single light scheme**. There is no dark variant in the
/// specification, so exposing one here would invent visual decisions the client
/// has not approved — `MaterialApp.darkTheme` is deliberately left unset.
abstract final class HhTheme {
  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: HhColors.brand600,
      primaryContainer: HhColors.brand50,
      onPrimaryContainer: HhColors.brand800,
      secondary: HhColors.accent500,
      onSecondary: HhColors.brand900,
      secondaryContainer: HhColors.accent50,
      onSecondaryContainer: HhColors.accent700,
      onSurface: HhColors.ink,
      surfaceContainerLowest: HhColors.white,
      surfaceContainerLow: HhColors.sand50,
      surfaceContainer: HhColors.sand100,
      onSurfaceVariant: HhColors.inkMuted,
      outline: HhColors.border,
      outlineVariant: HhColors.borderSubtle,
      error: HhColors.error,
      errorContainer: HhColors.errorBg,
      onErrorContainer: HhColors.errorFg,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: HhTypography.family,
      // The colour every phone frame in the design document is drawn on.
      // Corrected 2026-08-19: the app had been painting sand100, which is both
      // a real palette colour and the canvas paper the artboards sit on - see
      // the note on HhColors.sand100.
      scaffoldBackgroundColor: HhColors.surfaceMuted,
      splashFactory: InkSparkle.splashFactory,

      textTheme: TextTheme(
        displaySmall: HhTypography.display,
        headlineSmall: HhTypography.display,
        titleLarge: HhTypography.title,
        titleMedium: HhTypography.subtitle,
        titleSmall: HhTypography.label,
        bodyLarge: HhTypography.body,
        bodyMedium: HhTypography.body,
        bodySmall: HhTypography.caption,
        labelLarge: HhTypography.bodyStrong,
        labelMedium: HhTypography.caption,
        labelSmall: HhTypography.overline,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: HhColors.white,
        foregroundColor: HhColors.brand900,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: HhTypography.title,
        shape: const Border(bottom: HhBorders.card),
      ),

      dividerTheme: const DividerThemeData(
        color: HhColors.borderFaint,
        thickness: 1,
        space: 1,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: HhColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: HhRadius.sheetTop),
        showDragHandle: true,
        dragHandleColor: HhColors.border,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: HhColors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: HhRadius.cardAll),
        titleTextStyle: HhTypography.subtitle,
        contentTextStyle: HhTypography.body,
      ),

      // Snackbars are only a fallback. The design's toast is `HhToast`:
      // dark-surfaced, with an action on the right.
      snackBarTheme: SnackBarThemeData(
        backgroundColor: HhColors.brand900,
        contentTextStyle: HhTypography.body.copyWith(color: HhColors.white),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(11)),
        ),
      ),

      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: HhColors.brand600,
        selectionColor: HhColors.brand200,
        selectionHandleColor: HhColors.brand600,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: HhColors.brand600,
        linearTrackColor: HhColors.borderSubtle,
        circularTrackColor: HhColors.brand200,
      ),

      // Minimum touch target, applied globally rather than per-widget.
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
    );
  }
}
