import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The CI check TODO.md M0.5 asks for: every ARB file shares exactly one key
/// set.
///
/// §3.2 requires that a missing translation never reaches a user as a raw key.
/// `gen-l10n` would quietly fall back to the template instead, which shows
/// English to an Uzbek user - visible only if someone happens to open that
/// screen in that language. This turns it into a build failure.
void main() {
  const arbDir = 'lib/l10n';

  Map<String, dynamic> readArb(String name) =>
      jsonDecode(File('$arbDir/$name').readAsStringSync())
          as Map<String, dynamic>;

  /// Message keys only: drops `@@locale` and the `@key` metadata blocks.
  Set<String> messageKeys(Map<String, dynamic> arb) =>
      arb.keys.where((k) => !k.startsWith('@')).toSet();

  const files = [
    'app_en.arb',
    'app_ru.arb',
    'app_uz.arb',
    'app_uz_Latn.arb',
    'app_uz_Cyrl.arb',
  ];

  test('every ARB file exists', () {
    for (final f in files) {
      expect(
        File('$arbDir/$f').existsSync(),
        isTrue,
        reason: '$f is missing',
      );
    }
  });

  test('all ARB files share exactly one key set', () {
    final template = messageKeys(readArb('app_en.arb'));
    expect(template, isNotEmpty);

    for (final f in files.where((f) => f != 'app_en.arb')) {
      final keys = messageKeys(readArb(f));

      expect(
        keys.difference(template),
        isEmpty,
        reason: '$f defines keys the template does not have',
      );
      expect(
        template.difference(keys),
        isEmpty,
        reason:
            '$f is missing keys from the template - they would silently render '
            'in English',
      );
    }
  });

  test('no message value is left empty', () {
    for (final f in files) {
      final arb = readArb(f);
      for (final key in messageKeys(arb)) {
        expect(
          (arb[key] as String).trim(),
          isNotEmpty,
          reason: '$f:$key is blank',
        );
      }
    }
  });

  // `gen-l10n` refuses to build unless a base `app_uz.arb` exists alongside the
  // script-coded files, so the Latin content is necessarily duplicated. That
  // duplication is a drift hazard - two files that must say the same thing and
  // nothing forcing them to. This is the thing that forces them to.
  test('app_uz.arb and app_uz_Latn.arb agree on every value', () {
    final base = readArb('app_uz.arb');
    final latn = readArb('app_uz_Latn.arb');

    for (final key in messageKeys(latn)) {
      expect(
        base[key],
        latn[key],
        reason:
            'app_uz.arb:$key has drifted from app_uz_Latn.arb. The base '
            'file is the Latin fallback and must mirror it exactly.',
      );
    }
  });

  test('each ARB declares the locale its filename claims', () {
    const expected = {
      'app_en.arb': 'en',
      'app_ru.arb': 'ru',
      'app_uz.arb': 'uz',
      'app_uz_Latn.arb': 'uz_Latn',
      'app_uz_Cyrl.arb': 'uz_Cyrl',
    };

    for (final entry in expected.entries) {
      expect(readArb(entry.key)['@@locale'], entry.value, reason: entry.key);
    }
  });
}
