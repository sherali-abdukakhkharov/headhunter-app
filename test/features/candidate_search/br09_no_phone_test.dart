import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/features/candidate_search/domain/candidate_card.dart';
import 'package:headhunter_app/src/features/candidate_search/presentation/candidate_search_screen.dart';
import 'package:headhunter_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:headhunter_app/src/features/dictionaries/domain/dictionary_item.dart';

/// BR-09, §7.1, §11.1: **a candidate's phone number never appears on a search
/// card.**
///
/// A card is not a hiring interaction, so the rule never opens for one. The
/// guarantee is structural on both sides — the server's DTO has no phone field
/// and neither does [CandidateCard] — but "structural" is a claim, and this is
/// the test that makes it checkable.
///
/// `TODO.md` asks for this assertion by name, and it is the kind that has to
/// exist *before* someone adds a helpful "contact" line to the card.
void main() {
  const phone = '+998901234567';

  /// A card carrying every string field the model has, each set to something
  /// that could plausibly be mistaken for contact detail.
  CandidateCard card() => CandidateCard.fromJson(const {
    'candidateUserId': 'cand-1',
    'fullName': 'Aziza Karimova',
    'currentRoleTitle': 'Call-centre operator',
    'settlement': 'Chilonzor',
    'experienceYears': 4,
    'completenessPercent': 90,
    'salaryIsNegotiable': false,
    'isSaved': false,
    'isShortlisted': false,
    'matchScore': 82,
    'skills': <dynamic>[],
    'languages': <dynamic>[],
    'matchBreakdown': <dynamic>[],
    'note': 'Called her about the night shift',
  });

  Future<void> pump(WidgetTester tester, CandidateCard subject) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          dictionaryProvider(
            'region',
          ).overrideWith((ref) => const <DictionaryItem>[]),
        ],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: CandidateResultCard(card: subject),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Every string the card actually painted.
  List<String> renderedText(WidgetTester tester) => [
    for (final widget in tester.widgetList<Text>(find.byType(Text)))
      widget.data ?? '',
  ];

  test('the model has no phone field to render', () {
    // The first line of defence, and the reason the rest of this file can be
    // short: there is nowhere on the type to put one. If this ever compiles
    // with a phone, the tests below become the only thing standing between a
    // candidate and an unsolicited call.
    final json = <String, dynamic>{
      'candidateUserId': 'c',
      'experienceYears': 0,
      'completenessPercent': 0,
      'salaryIsNegotiable': false,
      'isSaved': false,
      'isShortlisted': false,
      'matchScore': 0,
      'skills': <dynamic>[],
      'languages': <dynamic>[],
      'matchBreakdown': <dynamic>[],
      // A server that started sending one would be ignored, not surfaced.
      'phone': phone,
    };

    final parsed = CandidateCard.fromJson(json);

    expect(parsed.toString(), isNot(contains(phone)));
  });

  testWidgets('a rendered card shows no phone number', (tester) async {
    await pump(tester, card());

    final text = renderedText(tester).join(' | ');

    expect(text, isNot(contains(phone)));
    // Nothing that looks like a nine-digit Uzbek subscriber number either —
    // the point is not the exact string but that no such thing is on screen.
    expect(
      RegExp(r'\+?998\s*\d').hasMatch(text),
      isFalse,
      reason: 'a phone-shaped string reached a candidate card: $text',
    );
    expect(
      RegExp(r'\d{7,}').hasMatch(text),
      isFalse,
      reason: 'a long digit run reached a candidate card: $text',
    );
  });

  testWidgets('even when the server sends one, it is never painted', (
    tester,
  ) async {
    // Defence in depth: if a future server version added the field, the card
    // must still not show it. The client is not the place that decides
    // BR-09 — but it must not undo it either.
    final withPhone = CandidateCard.fromJson(const {
      'candidateUserId': 'cand-1',
      'fullName': 'Aziza Karimova',
      'experienceYears': 4,
      'completenessPercent': 90,
      'salaryIsNegotiable': false,
      'isSaved': false,
      'isShortlisted': false,
      'matchScore': 82,
      'skills': <dynamic>[],
      'languages': <dynamic>[],
      'matchBreakdown': <dynamic>[],
      // Two spellings, because a future server could pick either.
      'phone': phone,
      'contactPhone': phone,
    });

    await pump(tester, withPhone);

    expect(renderedText(tester).join(' | '), isNot(contains(phone)));
  });

  testWidgets('the private note is not painted on the card either', (
    tester,
  ) async {
    // §7.3 says the note is the employer's and never visible to the
    // candidate. It is also not what a result card is for — and a note that
    // reads "called her about the night shift" on a shared screen is exactly
    // the sort of thing to keep off one.
    await pump(tester, card());

    expect(
      renderedText(tester).join(' | '),
      isNot(contains('Called her about the night shift')),
    );
  });
}
