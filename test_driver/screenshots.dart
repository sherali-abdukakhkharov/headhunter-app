// Takes the App Store screenshots: drives test_driver/app.dart on an iOS
// simulator and photographs the simulator's screen with `simctl`, so the
// status bar is the real one — the workflow overrides it to 9:41, full bars.
//
// The scenes and the accounts are docs/STORE_SCREENSHOTS_BRIEF.md's, the same
// eight the Google Play set has. Run by .github/workflows/ios-screenshots.yml;
// it needs SIMULATOR_UDID and SCREENSHOT_DIR, and SCREENSHOT_LOCALES picks the
// interface variants.
//
// One account per role for every language rather than the brief's Russian
// candidate: each set then shows the same data, and the run signs in twice
// instead of six times. The language is switched on the device only, so the
// accounts' own languages are untouched (test_driver/app.dart).
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';

/// A seeded account and its fixed code (headhunter-backend
/// docs/TEST_ACCOUNTS.md). No SMS is sent for these numbers.
typedef _Account = ({String phone, String code});

/// Aziza Karimova, candidate.
const _Account _candidate = (phone: '011000001', code: '111111');

/// Chinor Technologies, employer.
const _Account _employer = (phone: '012000001', code: '222221');

/// Seeded content, written by its author and so the same in every language
/// (§2.4): which is what makes these safe to find by.
const _vacancy = 'Backend Developer (Node.js)';
const _company = 'Chinor Technologies';

Future<void> main() async {
  final shots = _Shots(
    driver: await FlutterDriver.connect(),
    udid: _env('SIMULATOR_UDID'),
    directory: _env('SCREENSHOT_DIR'),
  );
  final locales = (Platform.environment['SCREENSHOT_LOCALES'] ?? '')
      .split(',')
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toList();
  if (locales.isEmpty) locales.addAll(['en', 'ru', 'uz-Latn']);

  try {
    await shots.driver.waitUntilFirstFrameRasterized();

    await shots.signIn(_candidate);
    for (final locale in locales) {
      await shots.candidate(locale);
    }
    await shots.signOut();

    await shots.signIn(_employer);
    for (final locale in locales) {
      await shots.employer(locale);
    }
    await shots.signOut();
  } finally {
    await shots.driver.close();
  }
}

String _env(String name) {
  final value = Platform.environment[name];
  if (value == null || value.isEmpty) {
    throw StateError('$name is not set - see ios-screenshots.yml');
  }

  return value;
}

class _Shots {
  _Shots({required this.driver, required this.udid, required this.directory});

  final FlutterDriver driver;
  final String udid;
  final String directory;

  /// Where the last shot was being taken, for the picture of a failure.
  String _scene = 'start';

  Future<void> signIn(_Account account) async {
    final adopted = await driver.requestData(
      'signIn ${account.phone} ${account.code}',
      timeout: const Duration(minutes: 1),
    );
    stdout.writeln('Signed in as ${account.phone}; account language $adopted');
    await _settle();
  }

  Future<void> signOut() async {
    await driver.requestData('signOut');
    await _settle();
  }

  /// Shots 1-5.
  Future<void> candidate(String locale) => _guard(locale, () async {
    await _locale(locale);

    await _go('/candidate/vacancies');
    await _see(find.text(_vacancy), required: true);
    await _shot(locale, '01-vacancies');

    await driver.tap(find.text(_vacancy));
    await _shot(locale, '02-vacancy');

    await _go('/candidate/profile');
    await _shot(locale, '03-profile');

    await _go('/candidate/applications');
    await _see(find.text(_vacancy));
    await _shot(locale, '04-applications');

    await _go('/candidate/messages');
    await _see(find.text(_company), required: true);
    await driver.tap(find.text(_company));
    await _shot(locale, '05-chat');
  });

  /// Shots 6-8.
  Future<void> employer(String locale) => _guard(locale, () async {
    await _locale(locale);

    await _go('/employer/home');
    await _shot(locale, '06-employer-home');

    await _go('/employer/candidates');
    await _shot(locale, '07-candidates');

    // The pipeline is reached through the vacancy, as an employer would, and
    // the vacancy's id is read from where that tap landed.
    await _go('/employer/vacancies');
    await _see(find.text(_vacancy), required: true);
    await driver.tap(find.text(_vacancy));
    await _settle();
    final vacancy = Uri.parse(await driver.requestData('location')).path;
    await _go('$vacancy/applicants');
    await _shot(locale, '08-pipeline');
  });

  Future<void> _locale(String tag) async {
    _scene = '$tag-locale';
    await driver.requestData('locale $tag');
    await _settle();
  }

  Future<void> _go(String path) async {
    _scene = path;
    await driver.requestData('go $path');
    await _settle();
  }

  /// Waits for [finder]. A required one fails the run; any other only says it
  /// was not there, and the picture is taken anyway for a person to judge.
  Future<void> _see(SerializableFinder finder, {bool required = false}) async {
    try {
      await driver.waitFor(finder, timeout: const Duration(seconds: 30));
      // DriverError is an Error, but it is what flutter_driver throws for a
      // timeout, and a timeout is the answer being asked for here.
      // ignore: avoid_catching_errors
    } on DriverError catch (error) {
      if (required) rethrow;
      stderr.writeln('Not seen on $_scene: $error');
    }
  }

  /// Until nothing is animating — a spinner animates, so this is also "until
  /// it has loaded" — then a moment more for images and scroll indicators.
  Future<void> _settle() async {
    try {
      await driver.waitUntilNoTransientCallbacks(
        timeout: const Duration(seconds: 30),
      );
      // As in [_see].
      // ignore: avoid_catching_errors
    } on DriverError catch (error) {
      stderr.writeln('Still animating on $_scene: $error');
    }
    await Future<void>.delayed(const Duration(seconds: 2));
  }

  Future<void> _shot(String locale, String name) async {
    _scene = '$locale/$name';
    await _settle();
    await _capture('$directory/$locale', '$name.png');
    stdout.writeln('Took $locale/$name');
  }

  Future<void> _capture(String folder, String file) async {
    await Directory(folder).create(recursive: true);
    final result = await Process.run('xcrun', [
      'simctl',
      'io',
      udid,
      'screenshot',
      '--type=png',
      // Square corners: App Store Connect wants the full rectangle.
      '--mask=ignored',
      '$folder/$file',
    ]);
    if (result.exitCode != 0) {
      throw StateError('simctl screenshot failed: ${result.stderr}');
    }
  }

  /// Runs one language's scenes, and on a failure photographs the screen it
  /// failed on before failing — CI is the only place this runs, and a
  /// timeout's message says nothing about what was in front of it.
  Future<void> _guard(String locale, Future<void> Function() scenes) async {
    try {
      await scenes();
    } on Object {
      final name = 'failed-${_scene.replaceAll(RegExp('[^A-Za-z0-9-]+'), '_')}';
      await _capture('$directory/failures', '$name.png');
      rethrow;
    }
  }
}
