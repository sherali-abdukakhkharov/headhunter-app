/// §2.1's five categories, from the wire to the design system.
///
/// The band is **a claim about what kind of work a vacancy is**, and it is the
/// fastest signal on a scanned list — which is why the design draws five and
/// refuses a generic one. A wrong band is therefore worse than none, and that
/// is the property worth pinning: an unrecognised code maps to null and the
/// card draws no band at all.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/format/work_category.dart';

void main() {
  test('every code the server can send maps to a category', () {
    // The five values of the backend's `DictionaryCategory` enum, written out
    // rather than derived: this list *is* the contract, and generating it from
    // the mapping would only make it agree with itself.
    const wire = {
      'professional': HhWorkCategory.professional,
      'service_operations': HhWorkCategory.service,
      'physical_industrial': HhWorkCategory.physical,
      'seasonal_agricultural': HhWorkCategory.seasonal,
      'temporary_shift': HhWorkCategory.temporary,
    };

    for (final entry in wire.entries) {
      expect(workCategoryFromWire(entry.key), entry.value, reason: entry.key);
    }

    // And every category is reachable, so none of the five is unreferenced.
    expect(wire.values.toSet(), HhWorkCategory.values.toSet());
  });

  test('an unknown code draws no band rather than a wrong one', () {
    // A sixth category from a newer server, or a null on a vacancy that
    // predates the column. Either way the band would be a claim nobody made.
    expect(workCategoryFromWire('promotional'), isNull);
    expect(workCategoryFromWire(null), isNull);
    expect(workCategoryFromWire(''), isNull);
  });

  test('the code is not confused with the design system name', () {
    // `HhWorkCategory.service` is the design's word and `service_operations` is
    // the server's. Accepting the design's spelling off the wire would make the
    // mapping look right while silently accepting something no server sends.
    expect(workCategoryFromWire('service'), isNull);
    expect(workCategoryFromWire('physical'), isNull);
    expect(workCategoryFromWire('seasonal'), isNull);
    expect(workCategoryFromWire('temporary'), isNull);
  });

  testWidgets('every category has a name in §2.1 words', (tester) async {
    final l10n = await AppL10n.delegate.load(const Locale('en'));

    for (final category in HhWorkCategory.values) {
      expect(workCategoryLabel(category, l10n), isNotEmpty);
    }

    // The spec's own wording, so the band and the specification agree.
    expect(
      workCategoryLabel(HhWorkCategory.seasonal, l10n),
      'Seasonal and agricultural work',
    );
  });
}
