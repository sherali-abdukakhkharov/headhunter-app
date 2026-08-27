import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/profile/domain/field_schema.dart';
import 'package:jobbridge_app/src/features/profile/presentation/schema_field_widget.dart';

/// BR-05, and every other bounded field in the schema.
///
/// `validation.min` and `.max` were parsed and never applied, so entering a
/// worker count of 0 — the value BR-05 exists to refuse — cost a round trip and
/// came back in the page's error state rather than on the field. That breaks
/// two rules at once: CLAUDE.md's "local validation belongs on the field", and
/// the page's error heading, which says "Something went wrong" and is a claim
/// about the system rather than about what the user is still typing (MT-013).
void main() {
  SchemaField numberField({double? min, double? max}) => SchemaField.fromJson({
    'code': 'worker_count',
    'kind': 'int',
    'label': 'Number of openings',
    'required': true,
    if (min != null || max != null)
      'validation': {'min': ?min, 'max': ?max},
  });

  Future<void> pump(
    WidgetTester tester, {
    required SchemaField field,
    required Object? value,
    String? serverError,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: HhTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: Scaffold(
          body: SchemaFieldWidget(
            field: field,
            value: value,
            errorText: serverError,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group("a field's declared bounds are checked where it is typed", () {
    testWidgets('BR-05: zero openings is refused without a round trip', (
      tester,
    ) async {
      await pump(tester, field: numberField(min: 1), value: 0);

      expect(find.text('Enter 1 or more.'), findsOneWidget);
    });

    testWidgets('the bound at its edge is accepted', (tester) async {
      await pump(tester, field: numberField(min: 1), value: 1);

      expect(find.textContaining('or more'), findsNothing);
    });

    testWidgets('an upper bound too', (tester) async {
      // `experience_years_min` is capped at 50 by the vacancy schema, and every
      // other bounded field had the same gap.
      await pump(tester, field: numberField(max: 50), value: 51);

      expect(find.text('Enter 50 or less.'), findsOneWidget);
    });

    testWidgets('a field with no declared bounds says nothing', (tester) async {
      await pump(tester, field: numberField(), value: 0);

      expect(find.textContaining('Enter'), findsNothing);
    });

    testWidgets('an empty field is not out of bounds', (tester) async {
      // Nothing typed is not a value below the minimum — that is what
      // `required` is for, and it is a different message in a different place.
      await pump(tester, field: numberField(min: 1), value: null);

      expect(find.textContaining('or more'), findsNothing);
    });

    testWidgets('a whole bound reads as a whole number', (tester) async {
      // The schema declares bounds as doubles because one type covers int and
      // decimal. "Enter 1.0 or more" is not a sentence about a worker count.
      await pump(tester, field: numberField(min: 1), value: 0);

      expect(find.text('Enter 1.0 or more.'), findsNothing);
    });

    testWidgets("the server's own refusal wins over the declaration", (
      tester,
    ) async {
      // It may know something the declaration does not, and two errors on one
      // field is one too many.
      await pump(
        tester,
        field: numberField(min: 1),
        value: 0,
        serverError: 'That is not allowed for this category.',
      );

      expect(
        find.text('That is not allowed for this category.'),
        findsOneWidget,
      );
      expect(find.textContaining('or more'), findsNothing);
    });
  });
}
