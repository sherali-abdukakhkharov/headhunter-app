import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/l10n/app_locale.dart';

void main() {
  group('AppLocale wire tags', () {
    // Frozen contract with the backend: BCP-47, lowercase language, title-case
    // script. This exact casing appears in the x-lang header, in the response
    // body's `locale`, and inside dictionary ETags. A casing slip is not an
    // error - it is a permanent silent cache miss.
    test('are exactly the canonical forms', () {
      expect(AppLocale.uzLatn.tag, 'uz-Latn');
      expect(AppLocale.uzCyrl.tag, 'uz-Cyrl');
      expect(AppLocale.ru.tag, 'ru');
      expect(AppLocale.en.tag, 'en');
    });

    test('are unique', () {
      final tags = AppLocale.values.map((l) => l.tag).toSet();
      expect(tags, hasLength(AppLocale.values.length));
    });
  });

  group('AppLocale.fromTag', () {
    test('round-trips every canonical tag', () {
      for (final locale in AppLocale.values) {
        expect(AppLocale.fromTag(locale.tag), locale);
      }
    });

    test('accepts the aliases the backend accepts', () {
      expect(AppLocale.fromTag('uz'), AppLocale.uzLatn);
      expect(AppLocale.fromTag('oz'), AppLocale.uzCyrl);
    });

    test('tolerates separator and case variation on input', () {
      expect(AppLocale.fromTag('uz_Latn'), AppLocale.uzLatn);
      expect(AppLocale.fromTag('UZ-LATN'), AppLocale.uzLatn);
      expect(AppLocale.fromTag('uz-cyrl'), AppLocale.uzCyrl);
    });

    test('returns null rather than guessing', () {
      expect(AppLocale.fromTag(null), isNull);
      expect(AppLocale.fromTag(''), isNull);
      expect(AppLocale.fromTag('klingon'), isNull);
      expect(AppLocale.fromTag('uz-Arab'), isNull);
    });
  });

  group('AppLocale.fromDeviceLocale', () {
    test('keeps the script when the device supplies one', () {
      expect(
        AppLocale.fromDeviceLocale(
          const Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl'),
        ),
        AppLocale.uzCyrl,
      );
    });

    test('defaults bare uz to Latin explicitly', () {
      expect(AppLocale.fromDeviceLocale(const Locale('uz')), AppLocale.uzLatn);
    });

    test('falls back for unsupported languages', () {
      expect(
        AppLocale.fromDeviceLocale(const Locale('de')),
        AppLocale.fallback,
      );
    });
  });

  group('supportedLocales', () {
    // The regression this guards: gen-l10n emits supportedLocales without
    // script codes. Handing that list to MaterialApp lets locale resolution
    // collapse uz-Cyrl onto plain uz, which resolves to Latin - Cyrillic
    // becomes unreachable and nothing fails loudly.
    test('carries the script code for both Uzbek variants', () {
      final uzbek = AppLocale.supportedLocales
          .where((l) => l.languageCode == 'uz')
          .toList();

      expect(uzbek, hasLength(2));
      expect(uzbek.map((l) => l.scriptCode), containsAll(['Latn', 'Cyrl']));
    });

    test('matches the enum, one entry each', () {
      expect(
        AppLocale.supportedLocales,
        AppLocale.values.map((l) => l.locale).toList(),
      );
    });

    test('every supported locale resolves to a generated bundle', () {
      // Guards the other half: the delegate must actually accept the
      // script-coded locales we hand MaterialApp.
      for (final locale in AppLocale.supportedLocales) {
        expect(
          AppL10n.delegate.isSupported(locale),
          isTrue,
          reason: '$locale is advertised but the delegate rejects it',
        );
      }
    });

    test('the two Uzbek scripts load different strings', () {
      // If the script code were being dropped anywhere in the chain, these
      // would be identical.
      final latn = lookupAppL10n(AppLocale.uzLatn.locale);
      final cyrl = lookupAppL10n(AppLocale.uzCyrl.locale);

      expect(latn.commonRetry, isNot(cyrl.commonRetry));
      expect(latn.commonRetry, 'Qayta urinish');
      expect(cyrl.commonRetry, 'Қайта уриниш');
    });
  });

  group('fallback chain', () {
    test('follows uz-Cyrl -> uz-Latn -> en as §3.2 requires', () {
      expect(AppLocale.uzCyrl.fallbackChain, [
        AppLocale.uzCyrl,
        AppLocale.uzLatn,
        AppLocale.en,
      ]);
    });

    test('every chain starts with itself and ends at English', () {
      for (final locale in AppLocale.values) {
        expect(locale.fallbackChain.first, locale);
        expect(locale.fallbackChain.last, AppLocale.en);
      }
    });
  });
}
