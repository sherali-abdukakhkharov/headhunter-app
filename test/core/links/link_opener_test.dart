/// The link hand-off, and the three things it has to agree with: the Kotlin
/// that receives it, and the backend that serves the page it names.
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/core/l10n/app_locale.dart';
import 'package:jobbridge_app/src/core/links/link_opener.dart';

const _kotlin = 'android/app/src/main/kotlin/com/jobbridge/app/MainActivity.kt';
const _backendLegal = '../headhunter-backend/src/modules/legal';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('the privacy policy URL', () {
    test('is the production page, in the reader’s language', () {
      expect(
        LegalLinks.privacyPolicy(AppLocale.uzLatn).toString(),
        'https://hh.qitmir.uz/privacy?lang=uz',
      );
      expect(
        LegalLinks.privacyPolicy(AppLocale.ru).toString(),
        'https://hh.qitmir.uz/privacy?lang=ru',
      );
      expect(
        LegalLinks.privacyPolicy(AppLocale.en).toString(),
        'https://hh.qitmir.uz/privacy?lang=en',
      );
    });

    test('gives Uzbek Cyrillic the Uzbek page, not the Russian one', () {
      // The pages exist in three languages and the app has four variants. The
      // Latin page is the same language; Russian would be a different one.
      expect(
        LegalLinks.privacyPolicy(AppLocale.uzCyrl).queryParameters['lang'],
        'uz',
      );
    });

    test('names a route and languages the backend actually serves', () {
      // Checked against the backend's source when it is checked out beside this
      // repository, the way the notification routes are: a renamed route or a
      // dropped language would otherwise surface as a 404 in a browser, on a
      // consent screen, with nothing red here.
      final controller = File('$_backendLegal/legal.controller.ts');
      final build = File('$_backendLegal/legal-pages.build.ts');
      if (!controller.existsSync() || !build.existsSync()) {
        markTestSkipped('headhunter-backend is not checked out beside this');
        return;
      }

      expect(controller.readAsStringSync(), contains("@Get('privacy')"));
      expect(
        build.readAsStringSync(),
        contains("LEGAL_LANGUAGES = ['uz', 'ru', 'en']"),
      );
    });
  });

  group('the channel', () {
    final calls = <MethodCall>[];
    String? failWith;

    setUp(() {
      calls.clear();
      failWith = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(LinkOpener.channelName),
            (call) async {
              calls.add(call);
              if (failWith case final code?) {
                throw PlatformException(code: code);
              }
              return null;
            },
          );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(LinkOpener.channelName),
            null,
          );
    });

    test('sends the URL as it was given', () async {
      await const LinkOpener().open(Uri.parse('https://hh.qitmir.uz/privacy'));

      expect(calls, hasLength(1));
      expect(calls.single.method, 'open');
      expect(calls.single.arguments, {'url': 'https://hh.qitmir.uz/privacy'});
    });

    test('turns "no browser" into its own exception', () async {
      failWith = 'no_browser';

      await expectLater(
        const LinkOpener().open(Uri.parse('https://hh.qitmir.uz/privacy')),
        throwsA(isA<NoBrowserException>()),
      );
    });

    test('keeps any other failure as the bug it is', () async {
      failWith = 'bad_argument';

      await expectLater(
        const LinkOpener().open(Uri.parse('https://hh.qitmir.uz/privacy')),
        throwsA(isA<PlatformException>()),
      );
    });
  });

  group('the Android side agrees with the Dart side', () {
    final kotlin = File(_kotlin).readAsStringSync();

    test('the channel name matches the one MainActivity registers', () {
      expect(
        kotlin.contains('"${LinkOpener.channelName}"'),
        isTrue,
        reason: 'a renamed channel fails only at runtime, on a tap',
      );
    });

    test('it opens https and nothing else', () {
      // An ACTION_VIEW intent opens whatever a URI names — tel:, intent:, a
      // file path, another app's deep link. The refusal is the whole guard.
      expect(kotlin, contains('uri.scheme != "https"'));
      expect(kotlin, contains('"no_browser"'));
    });
  });
}
