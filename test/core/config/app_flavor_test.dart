import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:headhunter_app/src/core/config/app_config.dart';
import 'package:headhunter_app/src/core/config/app_flavor.dart';

void main() {
  group('AppFlavor', () {
    test('defaults to development when FLAVOR is not passed', () {
      // The safe direction, and worth pinning: forgetting the flag can only
      // produce a less privileged build pointed at a local backend. If this
      // ever defaults to production, a stray `flutter build` ships a store
      // identity by accident.
      expect(AppFlavor.current, AppFlavor.development);
      expect(AppFlavor.current.isProduction, isFalse);
      expect(AppFlavor.current.allowsDevelopmentTools, isTrue);
    });

    test('only production ships without an app id suffix', () {
      for (final flavor in AppFlavor.values) {
        expect(
          flavor.appIdSuffix.isEmpty,
          flavor == AppFlavor.production,
          reason: flavor.name,
        );
      }
    });

    test('app id suffixes are unique, so builds install side by side', () {
      final suffixes = AppFlavor.values.map((f) => f.appIdSuffix).toSet();
      expect(suffixes, hasLength(AppFlavor.values.length));
    });

    test('only production has no environment marker in its display name', () {
      expect(AppFlavor.production.displayName, 'HeadHunter');
      for (final flavor in AppFlavor.values) {
        if (flavor == AppFlavor.production) continue;
        expect(
          flavor.displayName,
          isNot('HeadHunter'),
          reason: '${flavor.name} must be distinguishable on the home screen',
        );
      }
    });

    test('production and testing are https; only development may be plain', () {
      // §12.5. A plaintext base URL for a shared or store environment is a
      // credential leak, and it is the kind of thing that gets pasted in from a
      // local config and never noticed.
      expect(AppFlavor.production.apiBaseUrl, startsWith('https://'));
      expect(AppFlavor.staging.apiBaseUrl, startsWith('https://'));
    });

    test('no flavor is named in a way AGP rejects', () {
      // AGP refuses any product flavor whose name starts with `test`: it
      // collides with the `test`/`androidTest` source sets. §12.1's "testing"
      // environment is therefore `staging` on both sides. Found by a failed
      // build, so it is asserted here rather than left to be rediscovered.
      for (final flavor in AppFlavor.values) {
        expect(
          flavor.name.startsWith('test'),
          isFalse,
          reason: 'AGP rejects the product flavor name "${flavor.name}"',
        );
      }
    });

    test('logging is off in production regardless of build mode', () {
      // Asserted through the flavor rather than AppConfig, which reads the
      // *current* flavor: a profile build of production is still production, so
      // `kDebugMode` alone is the wrong gate.
      expect(AppFlavor.production.isProduction, isTrue);
      expect(AppFlavor.production.allowsDevelopmentTools, isFalse);
    });
  });

  group('AppConfig', () {
    test('falls back to the flavor base URL with no override', () {
      expect(AppConfig.apiBaseUrl, AppFlavor.development.apiBaseUrl);
      expect(AppConfig.isApiBaseUrlOverridden, isFalse);
    });

    test('development points at the emulator host alias, not localhost', () {
      // `localhost` inside the Android emulator is the emulator itself, so it
      // can never find a server on the development machine. This has cost time
      // before; the test states which one is correct.
      expect(AppConfig.apiBaseUrl, contains('10.0.2.2'));
      expect(AppConfig.apiBaseUrl, contains(':3001'));
    });
  });

  group('Gradle agrees with Dart', () {
    // Gradle owns the application id and the launcher label; AppFlavor states
    // the same suffixes so they can be read in one place. Nothing but this test
    // connects them, and a mismatch stays invisible until a device ends up with
    // two builds claiming one id - at which point installing one uninstalls the
    // other and takes its data.
    late final String gradle;

    setUpAll(() {
      gradle = File('android/app/build.gradle.kts').readAsStringSync();
    });

    test('declares a product flavor per AppFlavor value', () {
      for (final flavor in AppFlavor.values) {
        expect(
          gradle,
          contains('create("${flavor.name}")'),
          reason: 'no Gradle product flavor for ${flavor.name}',
        );
      }
    });

    test('applies the same app id suffix as AppFlavor', () {
      for (final flavor in AppFlavor.values) {
        if (flavor.appIdSuffix.isEmpty) continue;
        expect(
          gradle,
          contains('applicationIdSuffix = "${flavor.appIdSuffix}"'),
          reason: '${flavor.name} suffix differs between Gradle and Dart',
        );
      }
    });

    test('applies the same display name as AppFlavor', () {
      for (final flavor in AppFlavor.values) {
        expect(
          gradle,
          contains('manifestPlaceholders["appName"] = "${flavor.displayName}"'),
          reason: '${flavor.name} display name differs from Dart',
        );
      }
    });

    test('the manifest takes its label from the per-flavor placeholder', () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();
      // A hardcoded label here would make all three flavors identical on the
      // home screen, silently undoing the whole point of the suffixes.
      expect(manifest, contains(r'android:label="${appName}"'));
    });
  });
}
