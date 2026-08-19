import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jobbridge_app/src/core/design/hh_colors.dart';
import 'package:jobbridge_app/src/core/design/hh_typography.dart';

/// The JobBridge mark, its lockups, and the rules that govern them.
///
/// Two people leaning toward each other; their limbs form the span. Both the
/// one who needs work and the one who needs workers are *in* the mark, and the
/// arc they make together is the bridge.
///
/// ## Geometry, and why the numbers look odd
///
/// The mark is drawn on the same **32-unit grid** as the icon set but is
/// **filled, not stroked** — the design puts it deliberately apart from a
/// stroke-based UI, which is why it is not an `HhIconPath`.
///
/// The exported artboard is **cropped to the ink** —
/// `viewBox="4.5 6.2 23 19.8"`, no padding baked in. So the aspect is
/// 23 : 19.8 and height is always
/// `0.861 × width`. Every rule below measures the arch itself rather than an
/// artboard margin, and that is why this widget takes a **width** — the design
/// states every size as a width, and a `size` parameter would have to guess
/// which dimension it meant.
///
/// ## Three colour arrangements, and no way to draw a fourth
///
/// The design bans turquoise on white, but a two-tone mark needs two colours to
/// separate the figures — so on white it had no legal version until the
/// separation was made *structural*: two heads and the 1.6-unit gap do the
/// work, and colour is an enhancement rather than the mechanism.
///
/// This widget therefore takes a **ground**, not colours. Passing colours
/// would leave "turquoise on white" and "both figures turquoise" expressible,
/// and both are in the design's misuse panel. Selecting by ground makes them
/// unwritable.
enum HhBrandGround {
  /// Two-tone on `brand900`: the left figure white, the right turquoise.
  navy,

  /// Mono `brand900` on white or any light surface. **Never turquoise here.**
  light,

  /// Mono `brand900` on `accent500` — the launch screen's inverted plate.
  turquoise,
}

/// The mark on its own (§ brand, "Brend belgisi").
///
/// ## Below 20px it becomes one figure, and the aspect changes with it
///
/// The pair has a hard floor of **20px**: under that the 1.6-unit gap closes
/// and the two figures fuse into a blob, which destroys the one idea the mark
/// carries. So a request for less than that is served with the **single
/// figure** — one head, one shoulder, still a person — rather than with an
/// illegible pair.
///
/// The switch is automatic on purpose. It is the same reasoning as selecting by
/// ground: a rule that a caller has to remember is a rule that gets broken at
/// the fourteenth call site. **The consequence to know about is that the solo
/// crop is 10.7 : 19.8 — taller than wide — so [height] changes shape at the
/// threshold.** Ask for the size you want the mark to occupy horizontally and
/// let the widget report its height.
class HhBrandMark extends StatelessWidget {
  const HhBrandMark({
    required this.width,
    super.key,
    this.ground = HhBrandGround.light,
    this.clearSpace = false,
    this.semanticLabel,
  });

  /// Width of the **arch**, not of an artboard: the crop is tight to the ink.
  final double width;

  final HhBrandGround ground;

  /// Wraps the mark in the design's clear space — half the arch height on all
  /// four sides.
  ///
  /// Off by default, because the commonest placements (inside the launch plate,
  /// inside an app-icon mask) get their space from the container and would
  /// otherwise be padded twice. It scales with the mark, so there is one rule
  /// rather than a table of pixel values.
  final bool clearSpace;

  /// Announce the brand to a screen reader. Leave null where a visible
  /// "JobBridge" sits beside it — [HhBrandLockup] labels the pair as a whole.
  final String? semanticLabel;

  /// Aspect of the pair crop: 23 : 19.8.
  static const double pairAspect = 19.8 / 23;

  /// Aspect of the solo crop: 10.7 : 19.8. Taller than wide.
  static const double soloAspect = 19.8 / 10.7;

  /// Under this width the pair fuses, so the solo figure is drawn instead.
  static const pairFloor = 20.0;

  /// The left figure — the candidate. Filled, on the 32-unit grid.
  static const _leftHead = '<circle cx="8.6" cy="9.8" r="3.6"/>';
  static const _leftBody =
      '<path d="M4.5 26C4.5 18.5 5.8 13.2 8.6 13.2C11.5 13.2 13.4 12.4 15.2 '
      '11.8L15.2 17.5C12.5 18.2 10.5 20.5 10.5 26Z"/>';

  /// The right figure — the employer, reaching toward the candidate. This is
  /// the one that goes turquoise, always; never the left, never both.
  static const _rightHead = '<circle cx="23.4" cy="9.8" r="3.6"/>';
  static const _rightBody =
      '<path d="M27.5 26C27.5 18.5 26.2 13.2 23.4 13.2C20.5 13.2 18.6 12.4 '
      '16.8 11.8L16.8 17.5C19.5 18.2 21.5 20.5 21.5 26Z"/>';

  /// Whether this width is drawn as one figure rather than two.
  bool get isSolo => width < pairFloor;

  /// The height this mark will occupy. Changes shape at [pairFloor].
  double get height => isSolo ? width * soloAspect : width * pairAspect;

  /// Clear space for a mark of [forWidth] — half the arch height, per side.
  static double clearSpaceFor(double forWidth) =>
      forWidth * pairAspect / 2;

  @override
  Widget build(BuildContext context) {
    final picture = SvgPicture.string(
      _document(),
      width: width,
      height: height,
    );

    final mark = clearSpace
        ? Padding(
            padding: EdgeInsets.all(clearSpaceFor(width)),
            child: picture,
          )
        : picture;

    if (semanticLabel == null) return ExcludeSemantics(child: mark);
    return Semantics(label: semanticLabel, image: true, child: mark);
  }

  String _document() {
    // The crop is an SVG viewBox with an origin, which is exactly what the
    // designer exported — so the path data below is byte-identical to the
    // design document and can be diffed against it.
    final viewBox = isSolo ? '4.5 6.2 10.7 19.8' : '4.5 6.2 23 19.8';

    final body = StringBuffer()
      ..write('<svg xmlns="http://www.w3.org/2000/svg" ')
      ..write('width="$width" height="$height" ')
      ..write('viewBox="$viewBox" fill="none">');

    if (isSolo) {
      // The solo figure is the **left** one, so on navy it takes the left
      // figure's colour — white. Turquoise belongs to the right figure and
      // there is no right figure here.
      body
        ..write('<g fill="${_hex(_leftColour)}">')
        ..write(_leftHead)
        ..write(_leftBody)
        ..write('</g>');
    } else {
      body
        ..write('<g fill="${_hex(_leftColour)}">')
        ..write(_leftHead)
        ..write(_leftBody)
        ..write('</g>')
        ..write('<g fill="${_hex(_rightColour)}">')
        ..write(_rightHead)
        ..write(_rightBody)
        ..write('</g>');
    }

    return (body..write('</svg>')).toString();
  }

  Color get _leftColour => switch (ground) {
    HhBrandGround.navy => HhColors.white,
    HhBrandGround.light || HhBrandGround.turquoise => HhColors.brand900,
  };

  Color get _rightColour => switch (ground) {
    HhBrandGround.navy => HhColors.accent500,
    HhBrandGround.light || HhBrandGround.turquoise => HhColors.brand900,
  };

  static String _hex(Color colour) =>
      '#${(colour.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}

/// The word "JobBridge", as a logotype.
///
/// ## It does not scale with the text scaler, and that is deliberate
///
/// Every other string in this app grows with the accessibility text scale, and
/// this one must not: the lockups' proportions are locked — "nisbat qulflangan"
/// is one of the four misuse specimens — and a word that grew while the mark
/// stayed put would break the lockup rather than help anybody read it. It is an
/// image of the brand's name, not readable content, so a screen reader gets the
/// semantic label and the glyphs stay fixed.
///
/// Golos Text 600 at -0.015em, one capital B, **never spaced and never
/// hyphenated**.
class HhBrandWordmark extends StatelessWidget {
  const HhBrandWordmark({
    required this.color,
    super.key,
    this.fontSize = 23,
  });

  final double fontSize;
  final Color color;

  /// The brand name. Deliberately **not** an ARB string: a logotype is not
  /// translated, and `appTitle` being a localizable key means it could one day
  /// come back in Cyrillic, which the mark's construction does not allow.
  static const text = 'JobBridge';

  @override
  Widget build(BuildContext context) => Text(
    text,
    textScaler: TextScaler.noScaling,
    style: TextStyle(
      fontFamily: HhTypography.family,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: 1,
      letterSpacing: fontSize * -0.015,
      color: color,
    ),
  );
}

/// How the mark and the wordmark sit together.
enum HhBrandLockupAxis {
  /// Mark then word, on one line. The mark's height equals the wordmark's cap
  /// height, so the two read as one object.
  horizontal,

  /// Mark above word. The mark leads and runs deliberately larger — splash and
  /// print.
  stacked,
}

/// The mark plus the wordmark (§ brand, "Lokaplar").
///
/// The mark's size is derived from [fontSize] and never set separately — that
/// is what keeps a lockup a lockup. See [HhBrandWordmark] for the type rules.
class HhBrandLockup extends StatelessWidget {
  const HhBrandLockup({
    super.key,
    this.axis = HhBrandLockupAxis.horizontal,
    this.ground = HhBrandGround.light,
    this.fontSize = 23,
  });

  final HhBrandLockupAxis axis;
  final HhBrandGround ground;

  /// Size of the wordmark. The mark is derived from it, never set separately —
  /// that is what keeps the lockup a lockup.
  final double fontSize;

  /// Golos Text's cap height as a fraction of em, matching the mark's height
  /// to the wordmark's caps in the horizontal lockup.
  ///
  /// Read off the design's own specimen rather than guessed: it draws a 21-wide
  /// mark beside a 23px wordmark, and 21 x 0.861 = 18.08 of height, so the cap
  /// height the designer measured is 18.08 / 23. A guess of 0.72 — a common
  /// value — produced a 19.2pt mark, which is **under the 20pt pair floor**, so
  /// the default horizontal lockup silently rendered as a single figure. The
  /// test that caught it asserts the mark is two-tone on navy, which a solo
  /// mark cannot be.
  static const double _capHeight = 18.08 / 23;

  @override
  Widget build(BuildContext context) {
    final markWidth = switch (axis) {
      // "the mark's height equals the wordmark's cap height" — so the width
      // follows from the aspect rather than being chosen.
      HhBrandLockupAxis.horizontal =>
        fontSize * _capHeight / HhBrandMark.pairAspect,
      // "the mark leads and runs deliberately larger."
      HhBrandLockupAxis.stacked => fontSize * 2,
    };

    // A lockup is defined with the pair — both specimens draw two figures — so
    // a size that would degrade to the solo mark is a caller error rather than
    // something to silently accept. Below about 22pt of wordmark, use
    // [HhBrandMark] on its own and set the words yourself.
    assert(
      markWidth >= HhBrandMark.pairFloor,
      'fontSize $fontSize derives a ${markWidth.toStringAsFixed(1)}pt mark, '
      'under the ${HhBrandMark.pairFloor}pt pair floor: the lockup would '
      'draw one figure. Use HhBrandMark directly at this size.',
    );

    final mark = HhBrandMark(width: markWidth, ground: ground);

    final word = HhBrandWordmark(fontSize: fontSize, color: _wordColour);

    // The design says the gap "equals the arch's overhang", which is not a
    // measurable quantity anywhere in the document — the arch's base overhangs
    // its heads by 0.5 of 23 units, which at any real size is under a pixel.
    // These two ratios are read off the specimens instead (11 of a 21-wide mark
    // horizontally, 7 of a 29-tall mark stacked) and the question is in
    // docs/design-feedback.md.
    final gap = switch (axis) {
      HhBrandLockupAxis.horizontal => markWidth / 2,
      HhBrandLockupAxis.stacked => markWidth * HhBrandMark.pairAspect / 4,
    };

    return Semantics(
      label: HhBrandWordmark.text,
      image: true,
      child: ExcludeSemantics(
        child: switch (axis) {
          HhBrandLockupAxis.horizontal => Row(
            mainAxisSize: MainAxisSize.min,
            children: [mark, SizedBox(width: gap), word],
          ),
          HhBrandLockupAxis.stacked => Column(
            mainAxisSize: MainAxisSize.min,
            children: [mark, SizedBox(height: gap), word],
          ),
        },
      ),
    );
  }

  /// On navy the mark goes turquoise and the word stays **white** — never both
  /// turquoise.
  Color get _wordColour => switch (ground) {
    HhBrandGround.navy => HhColors.white,
    HhBrandGround.light || HhBrandGround.turquoise => HhColors.brand900,
  };
}

/// The launch plate: a turquoise squircle holding the mark in navy.
///
/// The launch screen **inverts** the mark, and that is the whole point of it —
/// "so it never reads as the home-screen icon frozen mid-load". The icon is a
/// turquoise arch on navy; this is a navy arch on turquoise. Somebody looking
/// at a stalled launch can tell it apart from a stalled home screen.
///
/// ## "44% of the screen width" means the short edge
///
/// The design states the plate as 44% of the screen width, and it is drawn on a
/// portrait phone, where the width *is* the short edge. Taking the literal
/// width breaks the moment the surface is not that: at 800 x 600 the plate plus
/// its wordmark overflowed the screen by 36pt, because 44% of 800 is most of
/// 600. This product is portrait-only mobile, so that surface should never
/// happen — but a launch screen that overflows on a rotated or unusually shaped
/// display is a defect either way, and on every portrait phone the two readings
/// give the same number.
///
/// So the whole [Size] is taken rather than a width: the guard belongs where it
/// cannot be bypassed, not at the one call site that currently gets it right.
class HhBrandLaunchPlate extends StatelessWidget {
  const HhBrandLaunchPlate({required this.screenSize, super.key});

  final Size screenSize;

  /// Plate width as a fraction of the screen's.
  static const plateFraction = 0.44;

  /// Mark width as a fraction of the plate's. The square-and-squircle ratio —
  /// the plate is a squircle, so width binds.
  static const markFraction = 0.56;

  /// Corner radius as a fraction of the plate's width, matching the app icon's
  /// own specimens (22 of 96 on the master, 13 of 46 here).
  static const _radiusFraction = 0.283;

  double get plateWidth => screenSize.shortestSide * plateFraction;

  @override
  Widget build(BuildContext context) {
    final plate = plateWidth;

    return Container(
      width: plate,
      height: plate,
      decoration: BoxDecoration(
        color: HhColors.accent500,
        borderRadius: BorderRadius.circular(plate * _radiusFraction),
      ),
      alignment: Alignment.center,
      child: HhBrandMark(
        width: plate * markFraction,
        ground: HhBrandGround.turquoise,
      ),
    );
  }
}
