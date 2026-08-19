// SVG path data is opaque data, not code: wrapping every `d` attribute at an
// arbitrary column makes the paths harder to compare against the design source,
// so the line-length rule is relaxed for this file only.
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:headhunter_app/src/core/design/hh_colors.dart';
import 'package:headhunter_app/src/core/design/hh_metrics.dart';

/// SVG path data for the design's icon set.
///
/// The design ships a bespoke family — 24px grid, 1.75 stroke, round caps and
/// joins — which the Material icon font cannot express, so the paths are
/// transcribed here verbatim and rendered as stroked SVG by [HhIcon].
///
/// Adding an icon means adding a path here, not reaching for `Icons.*`. Mixing
/// Material icons in is immediately visible: they are filled, sit on a
/// different optical grid, and have square joins.
abstract final class HhIconPath {
  // Navigation
  static const home =
      'M3 10.8 12 3.5l9 7.3M5.6 9.6V20.5h4.6v-5.4h3.6v5.4h4.6V9.6';
  static const briefcase =
      'M3.5 8.5h17v11h-17zM9 8.5V6.5A1.5 1.5 0 0 1 10.5 5h3A1.5 1.5 0 0 1 15 '
      '6.5v2M3.5 13h17';
  static const document = 'M6 3.5h7l5 5v12H6zM13 3.5v5h5M9 13.5h6M9 17h4';
  static const chat =
      'M20 12.4c0 3.6-3.6 6.4-8 6.4-1 0-1.9-.14-2.8-.4L4 20.5l1.6-3.5C4.6 15.8 '
      '4 14.2 4 12.4 4 8.9 7.6 6 12 6s8 2.9 8 6.4z';
  static const person =
      'M12 12.5a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM4.5 20.5c1-3.6 4-5.5 7.5-5.5s6.5 '
      '1.9 7.5 5.5';
  static const people =
      'M9 12a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7zM2.5 20c.9-3.2 3.4-5 '
      '6.5-5s5.6 1.8 6.5 5M16 5.4a3.5 3.5 0 0 1 0 6.9M17.5 15.4c2 .6 3.4 2.2 4 '
      '4.6';
  static const building =
      'M5 20.5V4.5h10v16M15 10.5h4v10M8 8h4M8 11.5h4M8 15h4M3.5 20.5h17';
  static const String dictionary = document;

  // Actions
  static const search = 'M11 18a7 7 0 1 0 0-14 7 7 0 0 0 0 14zM16.2 16.2 21 21';
  static const filters =
      'M4 7h9M17 7h3M4 12h3M11 12h9M4 17h9M17 17h3M13 5v4M7 10v4M13 15v4';
  static const bookmark = 'M6.5 4.5h11v16l-5.5-4-5.5 4z';
  static const upload =
      'M12 16V4.5M7.5 9 12 4.5 16.5 9M4.5 15.5v3a2 2 0 0 0 2 2h11a2 2 0 0 0 '
      '2-2v-3';
  static const edit =
      'M4.5 19.5h4L19 9a2.1 2.1 0 0 0-3-3L4.5 17.5zM14.5 6.5l3 3';
  static const trash = 'M5 7h14M9.5 7V4.5h5V7M7 7l1 13.5h8L17 7';
  static const send = 'M21 3 10.5 13.5M21 3l-7 18-3.5-7.5L3 10z';
  static const refresh =
      'M20 5.5v5h-5M4 18.5v-5h5M19.3 14a7.5 7.5 0 0 1-12.6 3.1M4.7 10A7.5 7.5 0 '
      '0 1 17.3 6.9';
  static const plus = 'M12 5v14M5 12h14';
  static const close = 'M6 6l12 12M18 6 6 18';
  static const check = 'M5 12.5 10 17.5 19 7';
  static const more = 'M6 12h.1M12 12h.1M18 12h.1';
  static const pause = 'M9 5v14M15 5v14';

  /// Withdrawal — "the candidate pulled out". Under the glyph rule this is what
  /// separates a withdrawn application from a paused or closed one; all three
  /// are neutral-toned, so the glyph carries the whole distinction.
  static const arrowLeft = 'M19.5 12H5M11.5 18.5 5 12l6.5-6.5';

  /// Disclosure on a field that opens a picker. Distinct from [arrowLeft],
  /// which means withdrawal — this one is pure "there is a list behind this".
  static const chevronDown = 'M6 9.5 12 15.5 18 9.5';

  /// Disclosure on a row that opens a *screen*, where [chevronDown] means a
  /// list opens in place. The same glyph turned, because it is the same promise
  /// — "there is more behind this" — pointed at where the more actually is.
  static const chevronRight = 'M9.5 6 15.5 12 9.5 18';

  // Attributes and metadata
  static const location =
      'M12 21s7-5.6 7-11a7 7 0 1 0-14 0c0 5.4 7 11 7 11zM12 12.5a2.5 2.5 0 1 0 '
      '0-5 2.5 2.5 0 0 0 0 5z';
  static const clock = 'M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18zM12 7v5.2l3.4 2';
  static const wallet =
      'M3.5 7.5h13.5a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5.5a2 2 0 0 1-2-2zM3.5 '
      '7.5V6A1.5 1.5 0 0 1 5 4.5h10M15.5 13.5h3';

  /// One Coin — a disc with a C struck into it (§6.6).
  ///
  /// Distinct from [wallet], and the pair is the distinction the design draws:
  /// the wallet glyph means *the place the balance lives*, this one means *the
  /// unit itself*. So the app bar's balance chip and a priced button carry the
  /// coin, while the Wallet screen and its Top up action carry the wallet.
  static const coin =
      'M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18zM14.8 9.6a3.5 3.5 0 1 0 0 4.8';

  /// A handset. **Contact data, not a dial action** — placing a call needs a
  /// package this project has not taken on, so this labels the row rather than
  /// promising to ring it.
  static const phone =
      'M6.5 3.5h4l1.5 4-2.2 1.6a12 12 0 0 0 5.1 5.1L16.5 12l4 1.5v4a2 2 0 0 '
      '1-2.2 2C10.4 18.8 5.2 13.6 4.5 5.7a2 2 0 0 1 2-2.2z';

  /// An envelope. E-mail as a contact *value*; [chat] is the in-product
  /// conversation, and the two must never share a glyph.
  static const mail = 'M3.5 6.5h17v11h-17zM3.5 7l8.5 6 8.5-6';

  static const calendar = 'M4.5 6.5h15v14h-15zM4.5 11h15M8.5 4v4M15.5 4v4';
  static const car =
      'M4 16.5h16M5.5 16.5v2h-2v-2M20.5 16.5v2h-2v-2M4 16.5v-4l2-5h12l2 '
      '5v4zM4.2 12.5h15.6M7.5 14.5h.1M16.5 14.5h.1';
  static const tool =
      'M15 3.5a5 5 0 0 0-4.3 7.5L3.5 18.2l2.3 2.3 7.2-7.2A5 5 0 1 0 15 3.5z';
  static const globe =
      'M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18zM3.5 12h17M12 3a14 14 0 0 1 0 18 14 '
      '14 0 0 1 0-18z';
  static const eye =
      'M12 5.5c5 0 8.5 6.5 8.5 6.5S17 18.5 12 18.5 3.5 12 3.5 12 7 5.5 12 '
      '5.5zM12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z';
  static const lock = 'M6.5 10.5h11v10h-11zM8.5 10.5V7.5a3.5 3.5 0 0 1 7 0v3';
  static const bell =
      'M12 3.5A5.5 5.5 0 0 0 6.5 9c0 5-2 6.5-2 6.5h15s-2-1.5-2-6.5A5.5 5.5 0 0 '
      '0 12 3.5zM10.2 19a2 2 0 0 0 3.6 0';

  // Status — each of these is half of a badge; the other half is the word.
  static const shieldCheck =
      'M12 3.5 19.5 6v6c0 4.4-3 7.6-7.5 9.5C7.5 19.6 4.5 16.4 4.5 12V6zM8.8 '
      '12.2l2.4 2.4 4-4.4';
  static const checkCircle =
      'M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18zM8 12.2l2.8 2.8L16 9.5';
  static const xCircle =
      'M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18zM9.2 9.2l5.6 5.6M14.8 9.2l-5.6 5.6';
  static const infoCircle =
      'M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18zM12 11v5.5M12 7.6v.1';
  static const alertTriangle = 'M12 4.5 21 20H3zM12 10.5v4M12 17.3v.1';
  static const wifiOff =
      'M3 3l18 18M8.6 15.6a5 5 0 0 1 5.2-1.1M5.4 12.2a10 10 0 0 1 2.8-2M2 8.6A15 '
      '15 0 0 1 7 5.7M22 8.6a15 15 0 0 0-9.6-3.5M18.8 12.2a10 10 0 0 0-2.2-1.6M12 '
      '19.3v.1';
}

/// Renders one of the [HhIconPath] glyphs.
///
/// The design's rule: **outline (1.75 stroke) = inactive, 2.2 stroke =
/// active.** Pass `active: true` rather than hand-tuning [strokeWidth], so the
/// distinction stays consistent everywhere.
class HhIcon extends StatelessWidget {
  const HhIcon(
    this.path, {
    super.key,
    this.size = HhSize.icon,
    this.color = HhColors.ink,
    this.active = false,
    this.strokeWidth,
    this.semanticLabel,
  });

  /// One of the constants on [HhIconPath].
  final String path;

  final double size;
  final Color color;

  /// Selected/current state — thickens the stroke per the design.
  final bool active;

  /// Overrides the stroke derived from [active]. Use sparingly: badge and chip
  /// glyphs are drawn at 2.2 because they are small, not because they are
  /// active.
  final double? strokeWidth;

  /// Accessible label. The design requires every *interactive* icon to ship
  /// one; decorative icons beside a text label should stay null so screen
  /// readers do not read the same thing twice.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final stroke = strokeWidth ?? (active ? 2.2 : 1.75);
    final rgb = (color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0');

    // flutter_svg needs a complete document; building it here keeps the icon
    // set as pure path data with no per-icon asset files to keep in sync. The
    // stroke colour is baked in, so no ColorFilter is needed at paint time.
    final svg = StringBuffer()
      ..write('<svg xmlns="http://www.w3.org/2000/svg" ')
      ..write('width="$size" height="$size" viewBox="0 0 24 24" fill="none" ')
      ..write('stroke="#$rgb" stroke-opacity="${color.a}" ')
      ..write('stroke-width="$stroke" ')
      ..write('stroke-linecap="round" stroke-linejoin="round">')
      ..write('<path d="$path"/></svg>');

    final picture = SvgPicture.string(
      svg.toString(),
      width: size,
      height: size,
    );

    if (semanticLabel == null) {
      return ExcludeSemantics(child: picture);
    }
    return Semantics(label: semanticLabel, image: true, child: picture);
  }
}
