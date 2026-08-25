/// MT-012: a machine value must not reach a screen.
///
/// Three different shapes of the same defect shipped together, and this file
/// covers the two that became shared code:
///
/// - **pay was three copies of six lines**, each rendering a bare
///   `150000 – 250000` — no separators, no currency, no period. A reader had to
///   count digits to tell a hundred and fifty thousand from a million and a
///   half.
/// - **two "moderation reasons" are written by the server, not by a person.**
///   §2.4 says a reason is shown verbatim, which is right for an
///   administrator's own words and wrong for a code like
///   `restriction_changed_requires_review`.
///
/// The third — a `file_purpose` code handed to an id resolver — is covered
/// where it renders, in `verification_queue_test` and `employer_profile_test`,
/// plus [humanizeCode] below.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/format/moderation_reason.dart';
import 'package:jobbridge_app/src/core/format/vacancy_pay.dart';
import 'package:jobbridge_app/src/core/l10n/app_locale.dart';
import 'package:jobbridge_app/src/features/dictionaries/presentation/dictionary_label.dart';

void main() {
  AppL10n copyFor(AppLocale locale) => lookupAppL10n(locale.locale);
  final en = copyFor(AppLocale.en);

  group('pay', () {
    test('a range carries both figures and the currency', () {
      final pay = formatPay(en, negotiable: false, from: 150000, to: 2500000);

      expect(pay, contains('UZS'));
      // The digits are grouped, whatever the separator for this variant is.
      // Asserted as the absence of the ungrouped run rather than against a
      // literal, because the grouping is intl's to choose and this test is
      // about the app not printing a raw integer (MT-012).
      expect(pay, isNot(contains('150000')));
      expect(pay, isNot(contains('2500000')));
    });

    test('a floor and a ceiling are different sentences', () {
      // "from 150 000" and "up to 150 000" are opposite facts, and a range
      // renderer that simply omitted the missing half would say neither.
      final floor = formatPay(en, negotiable: false, from: 150000);
      final ceiling = formatPay(en, negotiable: false, to: 150000);

      expect(floor, isNot(ceiling));
      expect(floor, en.vacancyPayFrom(150000));
      expect(ceiling, en.vacancyPayUpTo(150000));
    });

    test('negotiable wins over a range, which is the server’s precedence', () {
      // The vacancy form discards a typed range when negotiable is set, so a
      // record carrying both is one the server would read the same way.
      expect(
        formatPay(en, negotiable: true, from: 150000, to: 250000),
        en.vacancyNegotiablePay,
      );
    });

    test('no figures at all reads as negotiable rather than as blank', () {
      expect(formatPay(en, negotiable: false), en.vacancyNegotiablePay);
    });

    test('the period is appended when it is known', () {
      final pay = formatPay(
        en,
        negotiable: false,
        from: 150000,
        period: 'per month',
      );

      expect(pay, contains('per month'));
    });

    test('and omitted while it is not', () {
      // Null covers both "this vacancy states no period" and "the dictionary
      // has not answered yet". Neither is worth an ellipsis in the middle of a
      // figure, which reads as a rendering fault rather than as a pending
      // lookup.
      expect(
        formatPay(en, negotiable: false, from: 150000),
        isNot(contains('…')),
      );
    });

    test('every variant words it, and none of them leaks a raw integer', () {
      for (final locale in AppLocale.values) {
        final pay = formatPay(
          copyFor(locale),
          negotiable: false,
          from: 150000,
          to: 2500000,
        );

        expect(
          pay,
          isNot(contains('150000')),
          reason: '$locale prints an ungrouped figure',
        );
      }
    });
  });

  group('moderation reasons', () {
    test('the two the server writes are worded', () {
      expect(
        moderationReasonText(SystemModerationReason.restrictionChanged, en),
        en.vacancyReasonRestrictionChanged,
      );
      expect(
        moderationReasonText(SystemModerationReason.autoApproved, en),
        en.vacancyReasonAutoApproved,
      );
    });

    test('and they are not the code', () {
      // The literal that reached an employer's own vacancy card.
      expect(
        moderationReasonText('restriction_changed_requires_review', en),
        isNot(contains('_')),
      );
    });

    test("a moderator's own words pass through untouched (§2.4)", () {
      // The rule this function must not break. Whatever language it is in,
      // however it is punctuated, it is not ours to rewrite.
      const written = 'Yosh chegarasi asoslanmagan. Iltimos, tushuntiring.';

      expect(moderationReasonText(written, en), written);
    });

    test('a system reason added later degrades to today’s behaviour', () {
      // Not to a blank, and not to a wrong sentence: an unrecognised code is
      // still shown, which is exactly what happens now.
      expect(moderationReasonText('some_future_code', en), 'some_future_code');
    });
  });

  group('humanizeCode', () {
    test('turns a code into something a person can read', () {
      expect(humanizeCode('company_registration'), 'Company registration');
      expect(humanizeCode('cv'), 'Cv');
      expect(humanizeCode('tax-clearance'), 'Tax clearance');
    });

    test('collapses runs and trims, so nothing renders with gaps', () {
      expect(humanizeCode('a__b'), 'A b');
      expect(humanizeCode('_leading'), 'Leading');
    });

    test('an empty code is returned rather than becoming an empty string', () {
      // A blank where a label belongs reads as a layout bug; there is nothing
      // to show, and pretending otherwise helps nobody.
      expect(humanizeCode(''), '');
    });
  });
}
