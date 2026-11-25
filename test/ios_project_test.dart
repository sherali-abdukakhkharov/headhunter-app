// The iOS project, checked from Dart because nothing else here can check it.
//
// There is no Mac and no Xcode on the machine this project is developed on,
// and ios-build.yml compiles only when ios/ changes. A compiler would not catch
// most of what is below anyway: an iPhone build under the wrong bundle id, a
// channel whose name or error code drifted from MainActivity.kt, or an icon
// App Store Connect refuses all compile cleanly and fail on a phone, at upload
// or in review. `flutter test` runs on every push, so they are pinned here.
@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/files/attachment_opener.dart';
import 'package:jobbridge_app/src/core/links/link_opener.dart';
import 'package:jobbridge_app/src/features/notifications/data/push_platform.dart';

String _read(String path) => File(path).readAsStringSync();

/// The value of a `<key>` in an XML plist: a `<string>`, or `true`/`false`.
String? _plistValue(String plist, String key) {
  final match = RegExp(
    '<key>$key</key>\\s*<(?:string>([^<]*)</string|(true|false)/)>',
  ).firstMatch(plist);
  return match == null ? null : match.group(1) ?? match.group(2);
}

void main() {
  final pbxproj = _read('ios/Runner.xcodeproj/project.pbxproj');
  final infoPlist = _read('ios/Runner/Info.plist');
  final swift = _read('ios/Runner/AppDelegate.swift');
  final kotlin = _read(
    'android/app/src/main/kotlin/com/jobbridge/app/MainActivity.kt',
  );

  // Derived from Gradle rather than restated: the store identity is one
  // string, and Android had it first.
  final applicationId = RegExp(
    'applicationId = "([^"]+)"',
  ).firstMatch(_read('android/app/build.gradle.kts'))!.group(1)!;

  group('identity', () {
    test('the bundle id is the Android production application id', () {
      // `com.headhunter.app` until 2026-11-24 - the rename of 2026-08-19 never
      // reached ios/ while iOS was out of scope. A bundle id is fixed by the
      // first upload, so this is the last point it could still be corrected.
      final ids = RegExp(
        'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);',
      ).allMatches(pbxproj).map((m) => m.group(1)!).toList();

      expect(ids, hasLength(6), reason: 'three configs, two targets');
      expect(
        ids.where((id) => !id.endsWith('.RunnerTests')),
        everyElement(applicationId),
      );
      expect(
        ids.where((id) => id.endsWith('.RunnerTests')),
        everyElement('$applicationId.RunnerTests'),
      );
    });

    test('the release workflow uploads under the same id', () {
      expect(
        _read('.github/workflows/ios-release.yml'),
        contains('BUNDLE_ID: $applicationId'),
      );
    });

    test('the launcher name is the logotype', () {
      expect(
        _plistValue(infoPlist, 'CFBundleDisplayName'),
        HhBrandWordmark.text,
      );
    });

    test('iPhone only, iOS 15 or later', () {
      // iPad support would mean iPad screenshots and an iPad review for a
      // product designed as a phone app. iOS 15 is what Firebase's current SDK
      // requires; Swift Package Manager refuses to resolve it below that.
      final families = RegExp(
        'TARGETED_DEVICE_FAMILY = ([^;]+);',
      ).allMatches(pbxproj).map((m) => m.group(1));
      expect(families, isNotEmpty);
      expect(families, everyElement('1'));

      final targets = RegExp(
        'IPHONEOS_DEPLOYMENT_TARGET = ([0-9.]+);',
      ).allMatches(pbxproj).map((m) => double.parse(m.group(1)!));
      expect(targets, isNotEmpty);
      expect(targets, everyElement(greaterThanOrEqualTo(15)));
    });

    test('export compliance is answered once, in the bundle', () {
      expect(_plistValue(infoPlist, 'ITSAppUsesNonExemptEncryption'), 'false');
    });

    test('every interface language is declared to iOS', () {
      // Without it iOS reports only English to the app, whatever the phone is
      // set to, and the first launch picks the wrong variant.
      for (final language in ['uz', 'uz-Cyrl', 'ru', 'en']) {
        expect(infoPlist, contains('<string>$language</string>'));
      }
    });
  });

  group('the channels match MainActivity.kt', () {
    test('same three names as the Dart constants', () {
      for (final name in [
        AttachmentOpener.channelName,
        PushPlatform.channelName,
        LinkOpener.channelName,
      ]) {
        expect(swift, contains('"$name"'));
        expect(kotlin, contains('"$name"'));
      }
    });

    test('same methods', () {
      final android = RegExp(
        r'"(\w+)" ->',
      ).allMatches(kotlin).map((m) => m.group(1)).toSet();
      final ios = RegExp(
        r'case "(\w+)"',
      ).allMatches(swift).map((m) => m.group(1)).toSet();

      expect(android, isNotEmpty);
      expect(ios, android);
    });

    test('same error codes', () {
      // `AttachmentOpener` and `LinkOpener` branch on these strings. A code
      // that exists on one platform only turns a "nothing can open this"
      // message into an unhandled PlatformException on the other.
      final android = RegExp(
        r'result\.error\(\s*"(\w+)"',
      ).allMatches(kotlin).map((m) => m.group(1)).toSet();
      final ios = RegExp(
        r'code: "(\w+)"',
      ).allMatches(swift).map((m) => m.group(1)).toSet();

      expect(android, containsAll(<String>['no_viewer', 'no_browser']));
      expect(ios, android);
    });
  });

  group('push', () {
    test('the Push Notifications entitlement is signed in', () {
      final settings = RegExp(
        'CODE_SIGN_ENTITLEMENTS = ([^;]+);',
      ).allMatches(pbxproj).map((m) => m.group(1)).toList();

      expect(settings, hasLength(3), reason: 'Debug, Release and Profile');
      expect(settings, everyElement('Runner/Runner.entitlements'));
      expect(
        _plistValue(_read('ios/Runner/Runner.entitlements'), 'aps-environment'),
        isNotNull,
      );
    });

    test('GoogleService-Info.plist is supplied, never committed', () {
      // The iOS twin of google-services.json: GitHub's scanner flagged that
      // one on 2026-08-07, and this repository keeps credential-shaped files
      // out (CLAUDE.md).
      expect(
        _read('ios/.gitignore'),
        contains('Runner/GoogleService-Info.plist'),
      );
      expect(
        pbxproj,
        isNot(contains('GoogleService-Info.plist in Resources')),
      );
    });

    test('and the build phase that copies it runs in the app target', () {
      final phases = RegExp(
        r'buildPhases = \(([^)]*)\);',
      ).allMatches(pbxproj).map((m) => m.group(1)!).toList();

      expect(
        phases.where((p) => p.contains('Copy GoogleService-Info.plist')),
        hasLength(1),
      );
    });

    final plist = File('ios/Runner/GoogleService-Info.plist');
    test(
      'the Firebase plist is for this app',
      () {
        expect(
          _plistValue(plist.readAsStringSync(), 'BUNDLE_ID'),
          applicationId,
        );
      },
      skip: plist.existsSync()
          ? null
          : 'ios/Runner/GoogleService-Info.plist is not on this machine. It is '
                'gitignored and downloaded from the Firebase console - see '
                'docs/APP_STORE.md, section 6.3.',
    );

    test('every iOS release restores it before building', () {
      final release = _read('.github/workflows/ios-release.yml');
      final restore = release.indexOf('> ios/Runner/GoogleService-Info.plist');
      final build = release.indexOf('flutter build ipa');

      expect(restore, isNonNegative);
      expect(build, greaterThan(restore));
      expect(release, contains('--dart-define=FLAVOR=production'));
    });
  });

  group('the App Store icon', () {
    const iconSet = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';

    test('is one 1024 image, which Xcode derives every size from', () {
      final contents =
          jsonDecode(_read('$iconSet/Contents.json')) as Map<String, dynamic>;
      final images = (contents['images'] as List).cast<Map<String, dynamic>>();

      expect(images, hasLength(1));
      expect(images.single['size'], '1024x1024');
      expect(images.single['idiom'], 'universal');
      expect(images.single['filename'], 'Icon-App-1024x1024@1x.png');
    });

    test('is opaque RGB - App Store Connect refuses an alpha channel', () {
      // ITMS-90717. Flutter's PNG encoder always writes RGBA, which is why the
      // icon comes from tool/ios_app_icon.js rather than store_assets_test.
      final png = File('$iconSet/Icon-App-1024x1024@1x.png').readAsBytesSync();
      int u32(int at) =>
          png[at] << 24 | png[at + 1] << 16 | png[at + 2] << 8 | png[at + 3];

      expect(png.sublist(12, 16), ascii.encode('IHDR'));
      expect(u32(16), 1024, reason: 'width');
      expect(u32(20), 1024, reason: 'height');
      expect(png[24], 8, reason: 'bit depth');
      expect(png[25], 2, reason: 'colour type 2 is RGB with no alpha');
    });

    test("is not Flutter's placeholder any more", () {
      expect(
        Directory(iconSet).listSync().whereType<File>().map(
          (f) => f.uri.pathSegments.last,
        ),
        unorderedEquals(['Contents.json', 'Icon-App-1024x1024@1x.png']),
      );
    });
  });

  test('the launch screen draws nothing it cannot find', () {
    // The Flutter template's LaunchImage set was removed with the image view;
    // a storyboard naming a missing image shows a blank where it was.
    expect(
      _read('ios/Runner/Base.lproj/LaunchScreen.storyboard'),
      isNot(contains('LaunchImage')),
    );
  });
}
