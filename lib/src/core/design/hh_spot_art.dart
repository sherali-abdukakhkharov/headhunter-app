import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobbridge_app/src/core/design/hh_colors.dart';

/// The two-colour line drawings that sit in an empty or confirmed state.
///
/// ## Why these exist and why they are not icons
///
/// `HhEmptyState` reserves a 110 × 80 box, and until now a plain sand
/// rectangle filled it. The design brief (docs/design-feedback.md §B) asks
/// for three drawings plus a fourth for confirmations, in navy and turquoise
/// line work on a transparent ground — the same construction as `HhIcon`, at
/// four times the size and in two colours instead of one.
///
/// They are not `HhIconPath` entries because an icon is one colour and one
/// stroke weight by rule, and because a glyph shown at 110pt reads as a
/// magnified icon rather than as a drawing.
///
/// ## Why three and not one
///
/// **This is the whole point of the brief, and it is a content decision rather
/// than a decorative one.** A list that has never had anything in it is fixed
/// by *acting*; a list emptied by four filters is fixed by *undoing*. One
/// drawing for both would tell somebody who has just set four filters to go and
/// wait for employers to publish.
///
/// ## These are drawn, not briefed
///
/// The brief expected the designer to produce them. They are here because the
/// alternative was shipping the placeholder rectangle indefinitely. If drawings
/// arrive later they replace these path constants and nothing else changes —
/// which is also why every call site passes an [HhSpotArt] rather than an
/// asset.
enum HhSpotArt {
  /// A list that has never had anything in it: *this fills up when you do
  /// something.* A document with an add badge — the badge is the verb.
  first(
    // The badge sits **clear of the document**, not on it: a stroked circle
    // laid over a stroked outline crosses it, and two lines meeting at a
    // shallow angle read as a mistake rather than as a badge.
    navy:
        'M26 10h30l14 14v42a4 4 0 0 1-4 4H26a4 4 0 0 1-4-4V14a4 4 0 0 1 4-4z '
        'M56 10v14h14 '
        'M32 38h26M32 48h16',
    accent: 'M98 58a12 12 0 1 1-24 0 12 12 0 0 1 24 0zM86 51v14M79 58h14',
  ),

  /// A list the filters just emptied: *widen them — the work exists.* A funnel
  /// with nothing below it, and two marks pulling its mouth open.
  filter(
    navy: 'M26 18h58L61 45v23l-12-7V45z',
    accent: 'M18 18l-8-6M18 26l-8 6M92 18l8-6M92 26l8 6M46 74h20',
  ),

  /// The generic fallback, used where neither of the other two fits: an empty
  /// tray, saying nothing about why.
  neutral(
    navy:
        'M22 22h66a4 4 0 0 1 4 4v34a4 4 0 0 1-4 4H22a4 4 0 0 1-4-4V26a4 4 0 '
        '0 1 4-4z',
    accent: 'M34 43h42',
  ),

  /// A confirmation. The check is turquoise because the ring is the object and
  /// the mark is the answer.
  success(
    navy: 'M55 12a28 28 0 1 1 0 56 28 28 0 0 1 0-56z',
    accent: 'M42 40l9 9 21-21',
  );

  const HhSpotArt({required this.navy, required this.accent});

  /// The structure, in `brand900`.
  final String navy;

  /// The part that carries the meaning, in `accent500`.
  final String accent;
}

/// Renders one of the [HhSpotArt] drawings at the size the caller reserves.
///
/// Default 110 × 80, which is `HhEmptyState`'s box. The viewBox is the same
/// 110 × 80, so a caller asking for a different size scales the drawing rather
/// than cropping it.
class HhSpotIllustration extends StatelessWidget {
  const HhSpotIllustration(
    this.art, {
    super.key,
    this.width = 110,
    this.height = 80,
  });

  final HhSpotArt art;
  final double width;
  final double height;

  /// The stroke, chosen against `HhIcon`'s 1.75 at 24pt.
  ///
  /// Not scaled up proportionally: a 4.5× stroke at 4.5× the size would read as
  /// a magnified icon. Line art of this size wants a *finer* relative weight,
  /// which is what makes it read as a drawing rather than as a glyph.
  static const _stroke = 2.4;

  static String _rgb(Color color) =>
      (color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0');

  @override
  Widget build(BuildContext context) {
    final svg = StringBuffer()
      ..write('<svg xmlns="http://www.w3.org/2000/svg" ')
      ..write('width="$width" height="$height" viewBox="0 0 110 80" ')
      ..write('fill="none" stroke-width="$_stroke" ')
      ..write('stroke-linecap="round" stroke-linejoin="round">')
      ..write('<path stroke="#${_rgb(HhColors.brand900)}" d="${art.navy}"/>')
      ..write('<path stroke="#${_rgb(HhColors.accent500)}" d="${art.accent}"/>')
      ..write('</svg>');

    // Decorative without exception: every state that shows one of these also
    // shows a title and a message saying the same thing, and TalkBack reading
    // the picture as well would say it twice.
    return ExcludeSemantics(
      child: SvgPicture.string(svg.toString(), width: width, height: height),
    );
  }
}
