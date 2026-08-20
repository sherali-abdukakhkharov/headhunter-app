import 'package:flutter/widgets.dart';

import 'package:jobbridge_app/src/core/design/hh_colors.dart';

/// Spacing scale — 4pt base.
abstract final class HhSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Horizontal screen gutter.
  static const gutter = 16.0;

  /// Padding inside a card.
  static const cardPadding = 16.0;

  /// Vertical gap between sections on a screen.
  static const sectionGap = 24.0;
}

/// Corner radii. Each value has one job — do not invent intermediate radii.
abstract final class HhRadius {
  /// Text fields, selects, meta chips.
  static const input = 8.0;

  /// Buttons. Slightly softer than an input so a button never looks like a
  /// field.
  static const button = 10.0;

  /// Cards, banners.
  static const card = 12.0;

  /// Top corners of a bottom sheet.
  static const sheet = 18.0;

  /// Pill chips and toggles.
  static const pill = 999.0;

  static const BorderRadius inputAll = BorderRadius.all(
    Radius.circular(input),
  );
  static const BorderRadius buttonAll = BorderRadius.all(
    Radius.circular(button),
  );
  static const BorderRadius cardAll = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius pillAll = BorderRadius.all(
    Radius.circular(pill),
  );
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
}

/// Control and target sizes.
abstract final class HhSize {
  /// Minimum touch target in either axis. Never ship an interactive element
  /// smaller than this, even when the visual glyph is smaller.
  static const minTarget = 44.0;

  /// **The** control height — a *minimum*, not a fixed height.
  ///
  /// The design makes the single size a deliberate, load-bearing choice: rather
  /// than a "simple mode" for manual workers and a dense mode for
  /// professionals, every control is the same size for everyone and only the
  /// *fields* differ. Introducing a second control height re-opens that
  /// decision.
  ///
  /// Design round 1, §08.2 resolved the tension with system font scaling
  /// (§12.1) explicitly: **"control height min 52 — the box grows with the
  /// label, it never clips it."** So always apply this as
  /// `BoxConstraints(minHeight:)`, never as a fixed `height:`. At large
  /// accessibility text scales the control grows; the label is never truncated
  /// to preserve the 52.
  static const control = 52.0;

  /// Compact control height, for in-card actions only — never for a primary
  /// form control.
  static const controlCompact = 44.0;

  /// Icon on the 24px design grid.
  static const icon = 24.0;

  /// Bottom-navigation icon.
  static const iconNav = 23.0;

  /// Icon inside a badge or meta chip.
  static const iconSmall = 14.0;

  /// Reference frame width the design was drawn at; layouts are verified
  /// 320-430.
  static const designWidth = 390.0;
}

/// The design permits exactly one elevation level. Two shadows, each with one
/// purpose.
abstract final class HhElevation {
  /// Cards.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F0B2545), // rgba(11,37,69,.06)
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Bottom sheets and sticky bars — shadow is cast upward.
  static const List<BoxShadow> sheet = [
    BoxShadow(
      color: Color(0x1A0B2545), // rgba(11,37,69,.10)
      blurRadius: 24,
      offset: Offset(0, -4),
    ),
  ];

  /// Bottom navigation bar.
  static const List<BoxShadow> nav = [
    BoxShadow(
      color: Color(0x0D0B2545),
      blurRadius: 10,
      offset: Offset(0, -2),
    ),
  ];
}

/// Motion. Short and unobtrusive — this is a utility product, not a showcase.
abstract final class HhDuration {
  static const fast = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 200);
  static const slow = Duration(milliseconds: 320);
}

/// Standard borders, so a one-off `Border.all` never drifts from the system.
abstract final class HhBorders {
  static const control = BorderSide(color: HhColors.border, width: 1.5);
  static const controlFocused = BorderSide(color: HhColors.brand600, width: 2);
  static const controlError = BorderSide(color: HhColors.error, width: 1.5);
  static const controlDisabled = BorderSide(
    color: HhColors.borderFaint,
    width: 1.5,
  );
  static const card = BorderSide(color: HhColors.borderSubtle);
  static const faint = BorderSide(color: HhColors.borderFaint);

  /// Glow drawn around a focused text field, in addition to the 2px border.
  static const List<BoxShadow> focusGlow = [
    BoxShadow(color: Color(0x2116569D), spreadRadius: 3),
  ];
}
