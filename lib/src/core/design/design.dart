/// The JobBridge design system.
///
/// Implemented from the client's shipped design document. The three decisions
/// the design says drive everything downstream, restated because they are easy
/// to erode one screen at a time:
///
/// 1. **Institutional trust, not startup energy.** Deep Registan blue with one
///    turquoise accent, flat surfaces, a single elevation level. It should read
///    as a service a person can trust with their identity documents.
/// 2. **One control size for everyone.** Every control is 52px tall with a
///    persistent label. There is no "simple mode" for manual workers and dense
///    mode for professionals — a welder and a frontend developer use the same
///    components, and only the *fields* differ.
/// 3. **Status is never colour alone.** Every badge carries an icon plus a
///    word, and moderation, verification and application stages share one
///    badge with the same five tones, so the vocabulary is learned once.
///
/// Import this barrel rather than the individual files.
library;

export 'components/hh_badge.dart';
export 'components/hh_bottom_nav.dart';
export 'components/hh_button.dart';
export 'components/hh_card.dart';
export 'components/hh_category_band.dart';
export 'components/hh_chip.dart';
export 'components/hh_conditional_field.dart';
export 'components/hh_progress.dart';
export 'components/hh_selection.dart';
export 'components/hh_states.dart';
export 'components/hh_text_field.dart';
export 'hh_colors.dart';
export 'hh_icons.dart';
export 'hh_metrics.dart';
export 'hh_theme.dart';
export 'hh_typography.dart';
