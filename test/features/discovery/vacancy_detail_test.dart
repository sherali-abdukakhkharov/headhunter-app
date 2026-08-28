import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_item.dart';
import 'package:jobbridge_app/src/features/discovery/data/discovery_repository.dart';
import 'package:jobbridge_app/src/features/discovery/domain/vacancy_detail.dart';
import 'package:jobbridge_app/src/features/discovery/presentation/vacancy_detail_screen.dart';
import 'package:jobbridge_app/src/features/profile/domain/field_schema.dart';

/// §5.6's vacancy detail, and the two things about it that are easy to get
/// wrong: what a disappeared vacancy looks like (UAT-15), and the difference
/// between a requirement and a preference (§6.3).
void main() {
  DictionaryItem item(String id, String code, String label, {int? rank}) =>
      DictionaryItem(
        id: id,
        code: code,
        label: label,
        sortOrder: 0,
        isActive: true,
        rank: rank,
      );

  final languages = [item('lang-ru', 'russian', 'Ruscha')];
  final levels = [item('lvl-c1', 'c1', 'C1', rank: 50)];
  final attributes = [item('attr-car', 'own_car', 'Shaxsiy avtomobil')];

  VacancyDetail detail({
    List<Map<String, dynamic>> requirements = const [],
    String? description,
    String? startsOn,
    String? endsOn,
    String? applicationStatus,
    bool isSaved = false,
    // The **wire** value, not the design systems word for the same thing:
    // `service` is what `HhWorkCategory` calls it and no server sends it.
    String category = 'service_operations',
  }) => VacancyDetail.fromJson({
    'item': {
      'id': 'vac-1',
      'title': 'Call-centre operator',
      'salaryIsNegotiable': false,
      'salaryFrom': 4000000,
      'workerCount': 20,
      'category': category,
      'isSaved': isSaved,
      'employer': const {'name': 'Uniconsoft', 'isVerified': true},
      'applicationStatus': ?applicationStatus,
    },
    'requirements': requirements,
    'description': ?description,
    'startsOn': ?startsOn,
    'endsOn': ?endsOn,
  });

  /// A vacancy schema naming one of the field codes used below, so the heading
  /// has something to resolve — and deliberately **not** naming the other, so
  /// the fallback is exercised in the same render.
  final schema = FieldSchema.fromJson(const {
    'category': 'service',
    'schemaVersion': 2,
    'locale': 'en',
    'sections': [
      {
        'code': 'requirements',
        'label': 'Requirements',
        'editor': 'engine',
        'fields': [
          {
            'code': 'languages',
            'label': 'Languages',
            'kind': 'dictionary_leveled',
            'required': false,
          },
        ],
      },
    ],
  });

  Future<void> pump(
    WidgetTester tester, {
    VacancyDetail? subject,
    Exception? error,
    bool withSchema = true,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        // Mirrors main.dart. Load-bearing here: the 404 arm below is only
        // reachable because a thrown provider settles into AsyncError.
        retry: (retryCount, error) => null,
        overrides: [
          vacancyDetailProvider('vac-1').overrideWith(
            (ref) => error != null ? throw error : subject!,
          ),
          // Keyed on the category the subject actually carries, which is a
          // **wire** value — the same string the screen looks the schema up
          // with.
          vacancyFieldSchemaProvider(
            subject?.item.category ?? 'service_operations',
          ).overrideWith(
            (ref) => withSchema
                ? schema
                : throw Exception('schema unavailable'),
          ),
          dictionaryProvider('language').overrideWith((ref) => languages),
          dictionaryProvider('language_level').overrideWith((ref) => levels),
          dictionaryProvider('attribute').overrideWith((ref) => attributes),
          dictionaryProvider(
            'region',
          ).overrideWith((ref) => const <DictionaryItem>[]),
        ],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const VacancyDetailScreen(id: 'vac-1', feed: Feed.recommended),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('UAT-15: a vacancy that is gone', () {
    testWidgets('a 404 reads as gone, not as a fault', (tester) async {
      // The candidate tapped something that was on screen a second ago.
      // "Something went wrong" would tell them the app is broken rather than
      // that the job is filled.
      await pump(
        tester,
        error: const ApiException('vacancy.not_found', statusCode: 404),
      );

      expect(
        find.text('This vacancy is no longer available'),
        findsOneWidget,
      );
      expect(find.text('Something went wrong'), findsNothing);
    });

    testWidgets('gone offers no retry — there is nothing to retry', (
      tester,
    ) async {
      await pump(
        tester,
        error: const ApiException('vacancy.not_found', statusCode: 404),
      );

      expect(find.text('Try again'), findsNothing);
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('a network failure still reads as a failure', (tester) async {
      // The other half of the same rule: everything that is *not* a 404 keeps
      // the ordinary error state, because retrying it is worth offering.
      await pump(
        tester,
        error: const ApiException('Cannot reach the server.'),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(
        find.text('This vacancy is no longer available'),
        findsNothing,
      );
    });

    testWidgets('a refusal never shows a spinner', (tester) async {
      // Retry is off app-wide, so a failing provider sits in a state that
      // still reports loading unless hasError is matched first.
      await pump(
        tester,
        error: const ApiException('vacancy.not_found', statusCode: 404),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('§6.3: required is not the same as preferred', () {
    testWidgets('both are badged, and differently', (tester) async {
      // A preference that looked like a requirement would stop people
      // applying, which is the opposite of what a preference is for.
      await pump(
        tester,
        subject: detail(
          requirements: const [
            {
              'fieldCode': 'languages',
              'isMandatory': true,
              'itemId': 'lang-ru',
              'levelId': 'lvl-c1',
            },
            {
              'fieldCode': 'attributes',
              'isMandatory': false,
              'itemId': 'attr-car',
            },
          ],
        ),
      );

      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Preferred'), findsOneWidget);
    });

    testWidgets('a levelled requirement shows both halves', (tester) async {
      // The row carries an item *and* a level, so testing the item slot first
      // and stopping would silently drop "C1" — which is the whole
      // requirement.
      await pump(
        tester,
        subject: detail(
          requirements: const [
            {
              'fieldCode': 'languages',
              'isMandatory': true,
              'itemId': 'lang-ru',
              'levelId': 'lvl-c1',
            },
          ],
        ),
      );

      expect(find.text('Ruscha'), findsOneWidget);
      expect(find.text('C1'), findsOneWidget);
    });

    testWidgets('mandatory rows sort above preferred within a group', (
      tester,
    ) async {
      final subject = detail(
        requirements: const [
          {'fieldCode': 'attributes', 'isMandatory': false, 'valueText': 'B'},
          {'fieldCode': 'attributes', 'isMandatory': true, 'valueText': 'A'},
        ],
      );

      expect(
        subject.byField['attributes']!.map((r) => r.valueText),
        ['A', 'B'],
      );
    });

    testWidgets('a group is named by the schema, not by its field code', (
      tester,
    ) async {
      // `employment_type_ids` on screen reads as a bug. The wording lives in
      // the vacancy schema, already localized by the server — and a
      // code-to-string table in Dart would go stale the moment an
      // administrator adds a field (§10.3).
      await pump(
        tester,
        subject: detail(
          requirements: const [
            {
              'fieldCode': 'languages',
              'isMandatory': true,
              'itemId': 'lang-ru',
            },
          ],
        ),
      );

      expect(find.text('Languages'), findsOneWidget);
      expect(find.text('languages'), findsNothing);
    });

    testWidgets('a code the schema does not name falls back to the code', (
      tester,
    ) async {
      // Honest rather than blank: an unknown field is a server that grew one,
      // and hiding the group would hide a requirement.
      await pump(
        tester,
        subject: detail(
          requirements: const [
            {
              'fieldCode': 'some_new_field',
              'isMandatory': true,
              'valueText': 'Own tools',
            },
          ],
        ),
      );

      expect(find.text('some_new_field'), findsOneWidget);
      expect(find.text('Own tools'), findsOneWidget);
    });

    testWidgets('a schema that will not load never hides the requirement', (
      tester,
    ) async {
      // The requirement is what the candidate came for. A heading that
      // arrives late — or not at all — must not hold it up.
      await pump(
        tester,
        withSchema: false,
        subject: detail(
          requirements: const [
            {
              'fieldCode': 'languages',
              'isMandatory': true,
              'itemId': 'lang-ru',
            },
          ],
        ),
      );

      expect(find.text('Ruscha'), findsOneWidget);
      expect(find.text('languages'), findsOneWidget);
    });

    testWidgets('a boolean requirement reads as a word', (tester) async {
      await pump(
        tester,
        subject: detail(
          requirements: const [
            {
              'fieldCode': 'attributes',
              'isMandatory': true,
              'valueBool': true,
            },
          ],
        ),
      );

      expect(find.text('Yes'), findsOneWidget);
    });
  });

  group('what the screen shows', () {
    testWidgets('the description is rendered exactly as entered', (
      tester,
    ) async {
      // §2.4: user-entered content is never translated, and must not look as
      // though it might be.
      const written = 'Ish vaqti 9:00 dan 18:00 gacha. Обед оплачивается.';

      await pump(tester, subject: detail(description: written));

      expect(find.text(written), findsOneWidget);
    });

    testWidgets('a work window with no end reads as an open range', (
      tester,
    ) async {
      // A real combination — day work advertised as "from the 3rd" — and the
      // one a two-branch reading of start/end gets wrong.
      await pump(tester, subject: detail(startsOn: '2026-09-01'));

      expect(find.text('From 2026-09-01'), findsOneWidget);
    });

    testWidgets('a work window with both dates reads as a range', (
      tester,
    ) async {
      await pump(
        tester,
        subject: detail(startsOn: '2026-09-01', endsOn: '2026-10-15'),
      );

      expect(find.text('2026-09-01 – 2026-10-15'), findsOneWidget);
    });

    testWidgets('BR-07: an existing application replaces Apply', (
      tester,
    ) async {
      await pump(tester, subject: detail(applicationStatus: 'viewed'));

      expect(find.text('Apply'), findsNothing);
      expect(find.text('Applied'), findsOneWidget);
    });

    testWidgets('BR-07: a withdrawn application still offers Apply', (
      tester,
    ) async {
      // Withdrawing is what frees the candidate to apply again; treating it as
      // "already applied" would strand them.
      await pump(tester, subject: detail(applicationStatus: 'withdrawn'));

      expect(find.text('Apply'), findsOneWidget);
    });
  });

  group('§2.1: the band on the detail', () {
    testWidgets('names the category', (tester) async {
      await pump(tester, subject: detail());

      final band = tester.widget<HhCategoryBand>(find.byType(HhCategoryBand));
      expect(band.category, HhWorkCategory.service);
      expect(band.categoryLabel, 'Service and operations');
    });

    testWidgets('keeps the compact crop while there is no photograph', (
      tester,
    ) async {
      await pump(tester, subject: detail());

      final band = tester.widget<HhCategoryBand>(find.byType(HhCategoryBand));

      // The hero crop is 2.6:1 and exists to hold a picture. Spent on flat
      // tint it is a large pale block across the top of the first screen, for
      // one word — which is what the 1.29.0 audit's designer note said. The
      // rule that fixes the *card's* height across both cases is about list
      // rhythm, and a detail page has one band and no rhythm to protect.
      expect(band.image, isNull);
      expect(band.height, HhCategoryBand.cardHeight);
    });

    testWidgets('draws no band for a category this build does not know', (
      tester,
    ) async {
      await pump(tester, subject: detail(category: 'promotional_2027'));

      // A band is a claim about what kind of work this is, and a wrong one is
      // worse than none.
      expect(find.byType(HhCategoryBand), findsNothing);
      expect(find.text('Call-centre operator'), findsOneWidget);
    });
  });
}
