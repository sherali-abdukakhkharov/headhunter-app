import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobbridge_app/src/core/design/components/hh_category_band.dart';
import 'package:jobbridge_app/src/core/design/hh_colors.dart';

/// The five category bands, drawn rather than photographed.
///
/// ## Why these exist
///
/// §2.1 gives five kinds of work and the design gives each its own band at the
/// top of a vacancy card, because a picture is the fastest thing to read while
/// scrolling. The brief (docs/design-feedback.md §A) asked the designer for one
/// photograph per category and until they arrived the band filled with the
/// category tint, its glyph and its name.
///
/// **Photography has a problem here that illustration does not.** Five images
/// repeat across every card in a feed: twenty vacancies show the same five
/// photographs over and over, which reads as a template. A repeating *pattern*
/// does not — it reads as a category marker, which is what this is. That, and
/// not the wait, is why these are drawn.
///
/// ## One construction, five scenes
///
/// - a horizon at **y = 116**, identical in all five, so a scrolled list of
///   mixed categories keeps one line running through it;
/// - a repeating motif standing on that horizon — towers, awnings, saw teeth,
///   furrows, days — because repetition is what makes a band read as a texture
///   instead of as a picture;
/// - **exactly one turquoise element**, and it carries the meaning: the lit
///   windows, the awning, the crane's jib, the sun, the shift that is yours.
///
/// ## One master, two crops
///
/// The viewBox is 390 × 150, which is the detail hero exactly (2.6 : 1). The
/// card crop is 4.15 : 1 and keeps the middle 63 % of it, so nothing that
/// carries meaning sits above y = 30 or below y = 120.
///
/// **The photograph brief's "middle 60 %" is wrong for the card** and right
/// only for the hero: from a 3 : 2 master the card keeps 36 %. If photographs
/// are ever commissioned, that number has to be fixed first or every subject
/// loses its head on the feed.
///
/// ## Why filled shapes and not the spot art's line work
///
/// A 2.4pt stroke is invisible in an 86pt strip going past at scroll speed.
/// These are silhouettes in three tints of navy plus the accent, on the same
/// `brand50` ground the tinted band used, so the weight of a card does not
/// change now that the bands carry drawings.
enum HhCategoryArt {
  /// A skyline, with one tower's windows lit.
  professional([
    (_far, 0.28, 'M-12 78h36v38h-36zM72 86h34v30H72zM160 74h26v42h-26z'),
    (_far, 0.28, 'M238 82h24v34h-24zM316 78h26v38h-26zM352 56h42v60h-42z'),
    (_near, 0.42, 'M34 62h28v54H34zM196 60h32v56h-32zM272 66h34v50h-34z'),
    (_near, 0.42, 'M114 48h36v68h-36z'),
    (
      _accent,
      1,
      ' M122 58h9v9h-9zM137 58h9v9h-9zM122 74h9v9h-9zM137 74h9v9h-9z'
          ' M122 90h9v9h-9zM137 90h9v9h-9z',
    ),
    _ground,
  ]),

  /// A parade of shopfronts under scalloped awnings, one of them turquoise.
  service([
    (
      _far,
      0.26,
      ' M-40 76h84v40h-84zM54 76h84v40H54zM148 76h84v40h-84z'
          ' M242 76h84v40h-84zM336 76h84v40h-84z',
    ),
    (
      _near,
      0.34,
      ' M-10 94h24v22h-24zM84 94h24v22H84zM178 94h24v22h-24z'
          ' M272 94h24v22h-24zM366 94h24v22h-24z',
    ),
    (
      _near,
      0.46,
      ' M-40 76v-8h84v8a14 14 0 0 0-28 0 14 14 0 0 0-28 0 14 14 0 0 0-28 0z'
          ' M54 76v-8h84v8a14 14 0 0 0-28 0 14 14 0 0 0-28 0 14 14 0 0 0-28 0z'
          ' M242 76v-8h84v8a14 14 0 0 0-28 0 14 14 0 0 0-28 0 14 14 0 0 0-28 0z'
          ' M336 76v-8h84v8a14 14 0 0 0-28 0 14 14 0 0 0-28 0'
          ' a14 14 0 0 0-28 0z',
    ),
    (
      _accent,
      1,
      ' M148 76v-8h84v8a14 14 0 0 0-28 0 14 14 0 0 0-28 0 14 14 0 0 0-28 0z',
    ),
    _ground,
  ]),

  /// A sawtooth works, a container stack and a tower crane.
  physical([
    (
      _far,
      0.30,
      ' M-16 116V86l22-22v52zM6 116V86l22-22v52zM28 116V86l22-22v52z'
          ' M50 116V86l22-22v52zM72 116V86l22-22v52zM94 116V86l22-22v52z',
    ),
    (_far, 0.30, 'M126 116V52h13v64z'),
    (_near, 0.44, 'M168 90h42v26h-42zM214 72h42v44h-42z'),
    (_near, 0.26, 'M168 70h42v20h-42z'),
    (_ink, 0.50, 'M300 116V60h10v56zM250 52h16v17h-16z'),
    (_accent, 1, 'M256 56h110v9H256zM338 65h5v20h-5zM332 85h17v7h-17z'),
    _ground,
  ]),

  /// Furrows converging on a sun that sits on the horizon.
  seasonal([
    (_far, 0.24, 'M-20 116c70-52 150-52 220 0z'),
    (_far, 0.30, 'M150 116c80-58 170-58 270 0z'),
    (_accent, 1, 'M274 116a26 26 0 0 1 52 0z'),
    (
      _near,
      0.30,
      ' M177 116h4L68 150H42zM185 116h4L138 150H112zM193 116h4L208 150H182z'
          ' M201 116h4L278 150H252zM209 116h4L348 150H322z',
    ),
    _ground,
  ]),

  /// A week of days under an arc from sun to moon, one day raised and lit.
  temporary([
    (_far, 0.26, 'M68 80c62-40 192-40 254 0l-7 7c-58-34-182-34-240 0z'),
    (_far, 0.34, 'M26 76a14 14 0 1 1 28 0 14 14 0 1 1-28 0z'),
    (_near, 0.40, 'M364 60a15 15 0 1 0 0 32 19 19 0 0 1 0-32z'),
    (
      _near,
      0.40,
      ' M80 94h26v22H80zM114 94h26v22h-26zM148 94h26v22h-26z'
          ' M216 94h26v22h-26zM250 94h26v22h-26zM284 94h26v22h-26z',
    ),
    (_accent, 1, 'M182 86h26v30h-26z'),
    _ground,
  ]);

  const HhCategoryArt(this.shapes);

  /// `(fill, opacity, path)`, painted in order.
  final List<(String, double, String)> shapes;

  /// The drawing for a category. One per value, by construction.
  static HhCategoryArt of(HhWorkCategory category) => switch (category) {
    HhWorkCategory.professional => professional,
    HhWorkCategory.service => service,
    HhWorkCategory.physical => physical,
    HhWorkCategory.seasonal => seasonal,
    HhWorkCategory.temporary => temporary,
  };
}

const _sky = '#E9F1FA'; // brand50
const _far = '#5C8DC9'; // brand400
const _near = '#16569D'; // brand600
const _ink = '#0B2545'; // brand900
const _accent = '#12B0BE'; // accent500

/// The horizon and everything below it, shared by all five.
const (String, double, String) _ground = (
  _near,
  0.16,
  'M0 116h390v34H0z',
);

/// Paints one [HhCategoryArt] to fill whatever box the band gives it.
///
/// `BoxFit.cover` on a 390 × 150 viewBox: the hero shows all of it and the card
/// crops to the middle. The same treatment a photograph would get, which is
/// what keeps [HhCategoryBand.image] a drop-in replacement.
class HhCategoryArtwork extends StatelessWidget {
  const HhCategoryArtwork(this.art, {super.key});

  final HhCategoryArt art;

  @override
  Widget build(BuildContext context) {
    final svg = StringBuffer()
      ..write('<svg xmlns="http://www.w3.org/2000/svg" ')
      ..write('viewBox="0 0 390 150" width="390" height="150">')
      ..write('<rect width="390" height="150" fill="$_sky"/>');

    for (final (fill, opacity, path) in art.shapes) {
      svg.write('<path fill="$fill" fill-opacity="$opacity" d="$path"/>');
    }
    svg.write('</svg>');

    // Decorative: the band draws the category's name over it, so a screen
    // reader that described the picture as well would say it twice.
    return ExcludeSemantics(
      child: SvgPicture.string(
        svg.toString(),
        fit: BoxFit.cover,
        // Flutter's default while an SVG parses is a blank box; these are
        // strings, not files, so there is nothing to wait for — but a card
        // that flashed white before painting would be visible in a list.
        placeholderBuilder: (_) => const ColoredBox(color: HhColors.brand50),
      ),
    );
  }
}
