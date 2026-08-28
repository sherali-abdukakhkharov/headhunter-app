/// M11's crash reporting and structured logging, and the half that matters
/// most: **no sensitive data**.
///
/// Two kinds of failure used to reach nobody. A framework error is printed in
/// debug and handed, in a release build, to a default handler that says
/// nothing; an uncaught asynchronous error went to the platform and vanished
/// the same way. A tester on a release APK had nothing to report but "it
/// broke".
library;

import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/core/logging/app_log.dart';
import 'package:jobbridge_app/src/core/logging/crash_handlers.dart';

class _Recording implements LogSink {
  final records = <LogRecord>[];

  @override
  void record(LogRecord record) => records.add(record);
}

class _Exploding implements LogSink {
  @override
  void record(LogRecord record) => throw StateError('the sink is broken');
}

void main() {
  late _Recording sink;

  setUp(() {
    AppLog.clearSinks();
    sink = _Recording();
    AppLog.addSink(sink);
  });

  tearDown(AppLog.clearSinks);

  group('the record', () {
    test('a phone number never reaches the line', () {
      AppLog.info('auth.otp_sent', fields: {'phone': '+998901234567'});

      final line = sink.records.single.format();

      // Masked rather than removed: the last two digits tell two test accounts
      // apart, and it matches how the backend logs them.
      expect(line, contains('***67'));
      expect(line, isNot(contains('901234567')));
    });

    test('a token never reaches the line', () {
      AppLog.error(
        'auth.refresh_failed',
        fields: {'body': '{"accessToken":"eyJhbGciOi.secret.value"}'},
      );

      final line = sink.records.single.format();

      expect(line, contains('<redacted>'));
      expect(line, isNot(contains('eyJhbGciOi')));
    });

    test('the event name is greppable and the level is on the line', () {
      AppLog.warn('vacancy.publish_refused', fields: {'reason': 'br03'});

      expect(
        sink.records.single.format(),
        '[warn] vacancy.publish_refused reason=br03',
      );
    });

    test('the stack is carried but kept off the line', () {
      final stack = StackTrace.current;
      AppLog.error('x', error: StateError('boom'), stackTrace: stack);

      final record = sink.records.single;

      // The sink gets it; logcat does not. A stack is long enough to bury
      // every other line in the buffer.
      expect(record.stackTrace, same(stack));
      expect(record.format(), isNot(contains('#0')));
    });
  });

  group('the handlers', () {
    testWidgets('a framework error is recorded and still shown', (
      tester,
    ) async {
      final seen = <FlutterErrorDetails>[];
      final previousFlutter = FlutterError.onError;
      final previousPlatform = PlatformDispatcher.instance.onError;
      FlutterError.onError = seen.add;

      resetCrashHandlers();
      installCrashHandlers();
      addTearDown(() {
        FlutterError.onError = previousFlutter;
        PlatformDispatcher.instance.onError = previousPlatform;
        resetCrashHandlers();
      });

      FlutterError.reportError(
        FlutterErrorDetails(
          exception: StateError('bad build'),
          library: 'widgets library',
        ),
      );

      expect(sink.records.single.event, 'app.flutter_error');
      expect(sink.records.single.fields['library'], 'widgets library');

      // **The previous handler still runs.** Returning without calling it would
      // delete the red screen in debug — the loudest signal there is — to add a
      // log line, which is worse than the silence this replaces.
      expect(seen, hasLength(1));
    });

    test('an uncaught asynchronous error is recorded', () async {
      final previousFlutter = FlutterError.onError;
      final previousPlatform = PlatformDispatcher.instance.onError;

      resetCrashHandlers();
      installCrashHandlers();
      addTearDown(() {
        FlutterError.onError = previousFlutter;
        PlatformDispatcher.instance.onError = previousPlatform;
        resetCrashHandlers();
      });

      PlatformDispatcher.instance.onError!(
        StateError('nobody awaited this'),
        StackTrace.current,
      );

      expect(sink.records.single.event, 'app.uncaught_error');
      expect(sink.records.single.error, isA<StateError>());
    });

    test('a sink that throws does not take the app with it', () {
      AppLog.addSink(_Exploding());

      // This runs *from* the error handlers, so a throw here would be an error
      // raised while reporting an error — the shape of an infinite loop.
      expect(() => AppLog.info('x'), returnsNormally);

      // And the working sink still received it.
      expect(sink.records, hasLength(1));
    });

    test('installing twice does not report twice', () {
      final previousFlutter = FlutterError.onError;
      final previousPlatform = PlatformDispatcher.instance.onError;

      resetCrashHandlers();
      installCrashHandlers();
      installCrashHandlers();
      addTearDown(() {
        FlutterError.onError = previousFlutter;
        PlatformDispatcher.instance.onError = previousPlatform;
        resetCrashHandlers();
      });

      PlatformDispatcher.instance.onError!(
        StateError('once'),
        StackTrace.current,
      );

      // The second install would chain onto the first, so one error would
      // produce two records - noise in production, and a confusing failure in
      // a test. Which is how this was found.
      expect(sink.records, hasLength(1));
    });

    test('adding the same sink twice records once', () {
      AppLog.addSink(sink);
      AppLog.info('x');

      expect(sink.records, hasLength(1));
    });
  });
}
