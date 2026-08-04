import 'package:flutter/widgets.dart';

/// Colour tokens, transcribed from the design document's Foundations section.
///
/// Two rules from the design that the type system cannot enforce, so they are
/// stated here and must be honoured by hand:
///
/// 1. **[accent500] is a surface/accent colour only — never a text colour
///    on white.** It does not meet contrast requirements as text.
/// 2. **Status is never colour alone.** Every semantic colour appears with an
///    icon and a word (see `HhBadge`), so colour-blind users read the state
///    from the glyph and the label, not the hue.
abstract final class HhColors {
  // --- Brand: Registan blue -------------------------------------------------
  // Borrowed from Uzbek tilework rather than the saturated purples of consumer
  // job apps: the product asks people for identity documents, so it should read
  // as institutional.

  /// Deepest brand tone. Headings, dark surfaces, toast background.
  static const brand900 = Color(0xFF0B2545);

  /// Gradient partner for [brand900]; badge text on [brand50].
  static const brand800 = Color(0xFF123B6B);

  /// **Primary action colour.** Buttons, focus rings, selected states.
  static const brand600 = Color(0xFF16569D);

  static const brand400 = Color(0xFF5C8DC9);
  static const brand200 = Color(0xFFC6D8EE);

  /// Tinted surface behind secondary buttons and info banners.
  static const brand50 = Color(0xFFE9F1FA);

  // --- Accent: turquoise ----------------------------------------------------

  static const accent700 = Color(0xFF0A6F7A);

  /// Surface/accent only. Never use as a text colour on white.
  static const accent500 = Color(0xFF12B0BE);

  static const accent50 = Color(0xFFDFF3F5);

  /// Ground for a conditional-field block — the rail's surface.
  ///
  /// Turquoise has exactly three jobs and this is the load-bearing one: any
  /// block that appeared *because of a choice*, and nothing else. See
  /// `HhConditionalField`.
  static const accentGround = Color(0xFFF2FAFB);

  /// Light turquoise used for text and icons *on* [brand900].
  static const accentOnDark = Color(0xFF8FD3DB);

  // --- Sand: page surfaces --------------------------------------------------

  static const sand300 = Color(0xFFE2D9C6);

  /// App background.
  static const sand100 = Color(0xFFEFEBE4);

  /// Subtle raised surface on white cards.
  static const sand50 = Color(0xFFF7F5F1);

  // --- Neutrals -------------------------------------------------------------

  static const white = Color(0xFFFFFFFF);

  /// Body text.
  static const ink = Color(0xFF2A333D);

  /// Secondary text, caption text, inactive icons.
  static const inkMuted = Color(0xFF5B6570);

  /// Tertiary text, metadata, inactive nav labels.
  static const inkSubtle = Color(0xFF8A939E);

  /// Placeholder text and disabled labels.
  static const inkDisabled = Color(0xFFA8B0B9);

  /// Default control border.
  static const border = Color(0xFFDDE3EA);

  /// Card and divider border.
  static const borderSubtle = Color(0xFFE2E6EB);

  /// Hairline rule inside cards.
  static const borderFaint = Color(0xFFEFF2F5);

  /// Unselected checkbox / radio outline.
  static const controlOutline = Color(0xFFC4CBD3);

  /// Neutral fill for meta chips and segmented-control track.
  static const fill = Color(0xFFF3F5F7);

  /// Disabled control background.
  static const fillDisabled = Color(0xFFEFF2F5);

  /// Skeleton placeholder blocks.
  static const skeleton = Color(0xFFE7EBEF);

  /// Lighter skeleton block, for secondary lines.
  static const skeletonLight = Color(0xFFEFF2F5);

  /// Avatar / image placeholder background.
  static const placeholder = Color(0xFFEEF1F4);

  // --- Semantic -------------------------------------------------------------
  // Base tones for solid fills. For badges use the `*Bg` / `*Fg` pairs below,
  // which are the contrast-checked combinations drawn in the design.

  static const success = Color(0xFF167A4B);
  static const warning = Color(0xFFB26A00);
  static const error = Color(0xFFC0362C);
  static const Color info = brand600;
  static const disabled = Color(0xFF8A939E);

  static const successBg = Color(0xFFE7F3EC);
  static const successFg = Color(0xFF0F5E3A);

  static const warningBg = Color(0xFFFBF0DC);
  static const warningFg = Color(0xFF8A5200);
  static const warningBorder = Color(0xFFEBD6AC);

  static const errorBg = Color(0xFFFBEAE8);
  static const errorFg = Color(0xFF96271E);

  /// Error text-field background and destructive-button border.
  static const errorSurface = Color(0xFFFDF4F3);
  static const errorBorder = Color(0xFFEFC9C6);

  static const Color infoBg = brand50;
  static const Color infoFg = brand800;

  static const neutralBg = Color(0xFFF0F2F4);
  static const Color neutralFg = inkMuted;

  /// Success glyph on the dark toast surface.
  static const successOnDark = Color(0xFF5BE0B0);

  /// Focus ring: 2px of this colour at 2px offset, on every interactive
  /// element.
  static const Color focusRing = brand600;
}
