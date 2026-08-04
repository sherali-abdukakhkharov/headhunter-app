import 'package:flutter/painting.dart';

import 'package:headhunter_app/src/core/design/hh_colors.dart';

/// The type scale, transcribed from the design document's Foundations section.
///
/// Six roles only. If a screen seems to need a seventh, it almost certainly
/// wants an existing role in a different colour.
abstract final class HhTypography {
  /// Bundled family. Covers latin, latin-ext, cyrillic and cyrillic-ext, so all
  /// four interface variants render from one font.
  static const family = 'Golos Text';

  /// Golos Text is a **variable** font (`wght` axis 400-900).
  ///
  /// `fontWeight` alone is not reliably applied to a variable font across
  /// platforms, so every style also carries an explicit `wght` variation. Build
  /// styles through [_style] rather than constructing `TextStyle` directly, or
  /// weights silently collapse to Regular.
  static TextStyle _style({
    required double size,
    required int weight,
    required double height,
    Color color = HhColors.ink,
    double? letterSpacing,
  }) => TextStyle(
    fontFamily: family,
    fontSize: size,
    height: height,
    color: color,
    fontWeight: _weightOf(weight),
    fontVariations: [FontVariation('wght', weight.toDouble())],
    letterSpacing: letterSpacing,
  );

  static FontWeight _weightOf(int weight) => switch (weight) {
    <= 400 => FontWeight.w400,
    <= 500 => FontWeight.w500,
    <= 600 => FontWeight.w600,
    <= 700 => FontWeight.w700,
    <= 800 => FontWeight.w800,
    _ => FontWeight.w900,
  };

  /// Screen-level headline. 26 / 700, tightened tracking.
  static final TextStyle display = _style(
    size: 26,
    weight: 700,
    height: 1.15,
    color: HhColors.brand900,
    letterSpacing: -0.52, // -.02em
  );

  /// Screen name in an app bar. 20 / 700.
  static final TextStyle title = _style(
    size: 20,
    weight: 700,
    height: 1.25,
    color: HhColors.brand900,
  );

  /// Card heading. 16 / 600.
  static final TextStyle subtitle = _style(
    size: 16,
    weight: 600,
    height: 1.35,
    color: HhColors.brand900,
  );

  /// Default body copy. 15 / 400.
  static final TextStyle body = _style(size: 15, weight: 400, height: 1.5);

  /// Emphasised body, and the label inside a button. 15 / 600.
  static final TextStyle bodyStrong = _style(
    size: 15,
    weight: 600,
    height: 1.4,
    color: HhColors.brand900,
  );

  /// Secondary/helper text. 13 / 500.
  static final TextStyle caption = _style(
    size: 13,
    weight: 500,
    height: 1.45,
    color: HhColors.inkMuted,
  );

  /// Persistent field label — sits above the input, never inside it.
  static final TextStyle label = _style(
    size: 13,
    weight: 600,
    height: 1.3,
    color: HhColors.inkMuted,
  );

  /// Section eyebrow. 11 / 600, uppercase, wide tracking.
  ///
  /// Apply `.toUpperCase()` to the string yourself; the style cannot.
  static final TextStyle overline = _style(
    size: 11,
    weight: 600,
    height: 1.3,
    color: HhColors.inkMuted,
    letterSpacing: 0.99, // .09em
  );

  /// Metadata chip text and badge text. 12.5 / 600.
  static final TextStyle badge = _style(size: 12.5, weight: 600, height: 1.2);

  /// Small metadata inside cards. 12 / 500.
  static final TextStyle meta = _style(
    size: 12,
    weight: 500,
    height: 1.3,
    color: HhColors.inkMuted,
  );

  /// Bottom-navigation label. 10.5, weight shifts with selection.
  static TextStyle navLabel({required bool selected}) => _style(
    size: 10.5,
    weight: selected ? 600 : 500,
    height: 1.2,
    color: selected ? HhColors.brand600 : HhColors.inkSubtle,
  );

  /// Chip label. Weight shifts with selection, matching the design.
  static TextStyle chipLabel({required bool selected}) => _style(
    size: 13.5,
    weight: selected ? 600 : 500,
    height: 1.2,
    color: selected ? HhColors.white : HhColors.ink,
  );
}
