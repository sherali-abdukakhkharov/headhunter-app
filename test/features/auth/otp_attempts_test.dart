/// §4.2's attempt budget, on the screen that spends it.
///
/// The server locks a code out after `OTP_MAX_ATTEMPTS` and says so, and until
/// now the app could say nothing before that — a user was fine, fine, fine, and
/// then finished.
///
/// **The countdown is the client's own, and that is a security decision rather
/// than a shortcut.** `/auth/otp/verify` answers `auth.otp_invalid` identically
/// for "no code", "expired" and "wrong code", so probing a number cannot reveal
/// whether one is pending. A remaining-attempt count attached to that refusal
/// would be exactly that oracle: a number with a live code would answer with a
/// figure and a number without one would not. So the **limit** travels on the
/// send response, where it reveals nothing, and the client counts its own
/// attempts against it — which is accurate for the person actually typing, the
/// only party a countdown is for.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/auth/session_controller.dart';
import 'package:jobbridge_app/src/core/auth/session_state.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';
import 'package:jobbridge_app/src/features/auth/data/auth_repository.dart';
import 'package:jobbridge_app/src/features/auth/domain/otp_challenge.dart';
import 'package:jobbridge_app/src/features/auth/domain/uz_phone.dart';
import 'package:jobbridge_app/src/features/auth/presentation/otp_verification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Refuses every verification with whatever the test asked for.
class _RefusingSession extends SessionController {
  _RefusingSession(this.failure);

  ApiException failure;
  int attempts = 0;

  @override
  SessionState build() => const SessionUnauthenticated();

  @override
  Future<void> signInWithOtp({
    required String phone,
    required String code,
  }) async {
    attempts += 1;
    throw failure;
  }
}

/// Issues a fresh challenge on resend.
class _FakeAuth implements AuthRepository {
  int resends = 0;

  @override
  Future<OtpChallenge> resendOtp(String phone) async {
    resends += 1;
    return _challenge();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not under test');
}

OtpChallenge _challenge({int maxAttempts = 5, int codeLength = 6}) {
  final past = ZonedTimestamp.parse('2020-01-01T00:00:00+05:00');

  return OtpChallenge(
    expiresAt: past,
    resendAvailableAt: past,
    receivedAt: DateTime.utc(2020, 1, 1, 1),
    codeLength: codeLength,
    maxAttempts: maxAttempts,
  );
}

void main() {
  final en = lookupAppL10n(const Locale('en'));

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<({_RefusingSession session, _FakeAuth auth})> pump(
    WidgetTester tester, {
    ApiException failure = const ApiException(
      'That code is not valid.',
      statusCode: 401,
    ),
    int maxAttempts = 5,
    int codeLength = 6,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final session = _RefusingSession(failure);
    final auth = _FakeAuth();

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          sessionControllerProvider.overrideWith(() => session),
          authRepositoryProvider.overrideWithValue(auth),
        ],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: OtpVerificationScreen(
            args: OtpVerificationArgs(
              phone: UzPhone.parse('901234567'),
              challenge: _challenge(
                maxAttempts: maxAttempts,
                codeLength: codeLength,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    return (session: session, auth: auth);
  }

  /// One attempt.
  ///
  /// **Entering a complete code is what sends it.** The field submits itself
  /// the moment it is full, which is what makes an autofilled SMS a zero-tap
  /// sign-in; this used to enter the code *and* tap Confirm, which is now two
  /// attempts on one code and made every count in this group double.
  Future<void> guess(WidgetTester tester, String code) async {
    await tester.enterText(find.byType(HhTextField).first, code);
    await tester.pumpAndSettle();
  }

  group('the field sizes itself from the challenge', () {
    testWidgets('a four-digit code is complete at four', (tester) async {
      // The screen used to hard-code six. Changing OTP_LENGTH would have left
      // every installed app refusing to submit the code it had just been sent.
      await pump(tester, codeLength: 4);

      await tester.enterText(find.byType(HhTextField).first, '1234');
      await tester.pump();

      expect(
        tester
            .widget<HhButton>(
              find.widgetWithText(HhButton, en.authVerifyCode),
            )
            .onPressed,
        isNotNull,
      );
    });
  });

  group('the countdown', () {
    testWidgets('says nothing while there is plenty left', (tester) async {
      // "5 attempts left" on a first mistype is nagging, and a warning shown
      // every time is one that stops being read.
      await pump(tester);
      await guess(tester, '111111');

      expect(find.text(en.authAttemptsLeft(4)), findsNothing);
    });

    testWidgets('appears for the last two', (tester) async {
      await pump(tester);
      for (var i = 0; i < 3; i++) {
        await guess(tester, '11111$i');
      }

      expect(find.text(en.authAttemptsLeft(2)), findsOneWidget);
    });

    testWidgets('counts down to the last one', (tester) async {
      await pump(tester);
      for (var i = 0; i < 4; i++) {
        await guess(tester, '11111$i');
      }

      expect(find.text(en.authAttemptsLeft(1)), findsOneWidget);
    });

    testWidgets('counts only refusals, never a failure that never arrived', (
      tester,
    ) async {
      // Offline, a timeout, a 500 — none of them reached the code, so counting
      // them would burn attempts the server has not taken, and would tell
      // somebody on a bad connection they were one guess from lockout.
      await pump(
        tester,

        failure: const ApiException(
          "You're offline.",
          kind: ApiFailureKind.offline,
        ),
      );

      for (var i = 0; i < 4; i++) {
        await guess(tester, '11111$i');
      }

      expect(find.text(en.authAttemptsLeft(1)), findsNothing);
      expect(find.text(en.authAttemptsLeft(2)), findsNothing);
    });
  });

  group('lockout', () {
    Future<_RefusingSession> lockOut(WidgetTester tester) async {
      final harness = await pump(
        tester,
        failure: const ApiException(
          'Too many attempts.',
          statusCode: 429,
        ),
      );
      await guess(tester, '111111');
      return harness.session;
    }

    testWidgets('says what to do, which the refusal does not', (tester) async {
      // The server's message says this attempt failed. It does not say that
      // the code is finished and the only way on is a new one.
      await lockOut(tester);

      expect(find.textContaining(en.authAttemptsExhausted), findsOneWidget);
    });

    testWidgets('stops offering a verification that cannot succeed', (
      tester,
    ) async {
      final session = await lockOut(tester);
      final before = session.attempts;

      await tester.enterText(find.byType(HhTextField).first, '222222');
      await tester.pump();

      expect(
        tester
            .widget<HhButton>(
              find.widgetWithText(HhButton, en.authVerifyCode),
            )
            .onPressed,
        isNull,
      );
      expect(session.attempts, before);
    });

    testWidgets('and the countdown gives way to it', (tester) async {
      // Two sentences about the same fact is one too many.
      await lockOut(tester);

      expect(find.text(en.authAttemptsLeft(1)), findsNothing);
      expect(find.text(en.authAttemptsLeft(2)), findsNothing);
    });

    testWidgets('a new code lifts it and restarts the budget', (tester) async {
      // Carrying either across would leave somebody who did the one thing the
      // app told them to do still looking at a dead button.
      final session = await lockOut(tester);

      await tester.tap(find.widgetWithText(HhButton, en.authResendCode));
      await tester.pumpAndSettle();

      expect(find.textContaining(en.authAttemptsExhausted), findsNothing);

      session.failure = const ApiException('nope', statusCode: 401);
      await guess(tester, '333333');

      // Attempt one of a fresh five, so nothing is said yet.
      expect(find.text(en.authAttemptsLeft(4)), findsNothing);
      expect(find.text(en.authAttemptsLeft(1)), findsNothing);
    });
  });

  group('the code sends itself, so an SMS is a zero-tap sign-in', () {
    testWidgets('the field has focus on arrival', (tester) async {
      await pump(tester);

      // The only thing on the screen to do. Without this the user arrives at a
      // one-field page and has to tap it before the number pad appears — a step
      // between reading a code and entering it (1.29.0 audit, P1).
      final field = tester.widget<HhTextField>(find.byType(HhTextField).first);
      expect(field.autofocus, isTrue);
      expect(field.keyboardType, TextInputType.number);
    });

    testWidgets('it declares itself a one-time code to the platform', (
      tester,
    ) async {
      await pump(tester);

      final field = tester.widget<HhTextField>(find.byType(HhTextField).first);
      expect(field.autofillHints, [AutofillHints.oneTimeCode]);
      // The hint is only acted on inside a group.
      expect(
        find.ancestor(
          of: find.byType(HhTextField).first,
          matching: find.byType(AutofillGroup),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a complete code is sent without a tap', (tester) async {
      final harness = await pump(tester);

      await tester.enterText(find.byType(HhTextField).first, '123456');
      await tester.pumpAndSettle();

      expect(harness.session.attempts, 1);
    });

    testWidgets('a short code is not', (tester) async {
      final harness = await pump(tester);

      await tester.enterText(find.byType(HhTextField).first, '12345');
      await tester.pumpAndSettle();

      expect(harness.session.attempts, 0);
    });

    testWidgets('and it does not send the same refused code twice', (
      tester,
    ) async {
      // The refusal leaves those digits in the box. A listener that fired again
      // on the next rebuild would spend the whole attempt budget by itself,
      // which is a worse failure than the tap it replaced.
      final harness = await pump(tester);

      await tester.enterText(find.byType(HhTextField).first, '123456');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(harness.session.attempts, 1);
    });

    testWidgets('Confirm still works for a deliberate retry', (tester) async {
      // Automatic once, manual afterwards: a code refused by a *timeout* is one
      // the user is entitled to send again unchanged, and the button is what
      // says so. Removing it would make the retry impossible.
      final harness = await pump(tester);

      await tester.enterText(find.byType(HhTextField).first, '123456');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(HhButton, en.authVerifyCode));
      await tester.pumpAndSettle();

      expect(harness.session.attempts, 2);
    });

    testWidgets('a resent challenge may repeat the digits', (tester) async {
      // A new code can legitimately come out to the same six digits, and it
      // deserves the same automatic send as the first one did.
      final harness = await pump(tester);

      await tester.enterText(find.byType(HhTextField).first, '123456');
      await tester.pumpAndSettle();
      expect(harness.session.attempts, 1);

      await tester.tap(find.widgetWithText(HhButton, en.authResendCode));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(HhTextField).first, '123456');
      await tester.pumpAndSettle();

      expect(harness.session.attempts, 2);
    });
  });
}
