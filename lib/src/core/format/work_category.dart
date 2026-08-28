import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';

/// §2.1's five work categories, from the wire to the design system.
///
/// ## Why a mapping rather than one name
///
/// The server sends a database enum — `physical_industrial`, not a dictionary
/// id — and the design system names the same five differently, because
/// `HhWorkCategory` is the *design's* vocabulary and knows nothing about a
/// wire format. Neither side should learn the other's spelling, so the
/// translation lives here, once.
///
/// It is **not** a dictionary lookup and must not become one. These five are a
/// column type, not editable content: an administrator adding a `work_category`
/// row is not a thing §10.3 allows, and a category without a band, a glyph and
/// a form schema would be a category the product cannot render.
HhWorkCategory? workCategoryFromWire(String? code) => switch (code) {
  'professional' => HhWorkCategory.professional,
  'service_operations' => HhWorkCategory.service,
  'physical_industrial' => HhWorkCategory.physical,
  'seasonal_agricultural' => HhWorkCategory.seasonal,
  'temporary_shift' => HhWorkCategory.temporary,
  // A sixth category from a newer server. Null means the card draws no band
  // rather than drawing the wrong one — the band is a *claim* about what kind
  // of work this is, and a wrong claim is worse than none.
  _ => null,
};

/// The category's name, in §2.1's words.
///
/// From the ARB rather than from a dictionary, for the reason above: there is
/// no `work_category` dictionary to read, and there is not meant to be.
String workCategoryLabel(HhWorkCategory category, AppL10n l10n) =>
    switch (category) {
      HhWorkCategory.professional => l10n.workCategoryProfessional,
      HhWorkCategory.service => l10n.workCategoryService,
      HhWorkCategory.physical => l10n.workCategoryPhysical,
      HhWorkCategory.seasonal => l10n.workCategorySeasonal,
      HhWorkCategory.temporary => l10n.workCategoryTemporary,
    };
