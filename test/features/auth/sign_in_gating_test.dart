/// MT-013: an enabled control is a promise that pressing it will do something.
///
/// Both sign-in screens broke that promise. "Get a code" enabled as soon as the
/// terms box was ticked, so two digits were enough to make an impossible
/// request look available; "Confirm" enabled on an empty code field. Pressing
/// either produced the page-level error state — whose heading reads *"Something
/// went wrong"* — for a number or a code the user had simply not finished
/// typing. The app invited an action it could not perform and then blamed an
/// unspecified system failure for the result.
///
/// So there are two claims here, and they are separate: **what the button
/// does** (nothing, until the input could actually succeed) and **where the
/// sentence goes** (on the field, never in the error state).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/auth/session_controller.dart';
import 'package:jobbridge_app/src/core/auth/session_state.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';
import 'package:jobbridge_app/src/features/auth/domain/otp_challenge.dart';
import 'package:jobbridge_app/src/features/auth/domain/uz_phone.dart';
import 'package:jobbridge_app/src/features/auth/presentation/otp_verification_screen.dart';
import 'package:jobbridge_app/src/features/onboarding/presentation/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A session that records verification attempts and never completes one.
///
/// The screen does not navigate on success — the session change drives the
/// router — so the call itself is the only observable thing worth counting,
/// and what these cases assert is that it is **not** made.
class _RecordingSession extends SessionController {
  final codes = <String>[];

  @override
  SessionState build() => const SessionUnauthenticated();

  @override
  Future<void> signInWithOtp({
    required String phone,
    required String code,
  }) async {
    codes.add(code);
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// The English ARB, for asserting copy without restating it here.
  final en = lookupAppL10n(const Locale('en'));

  void sizeDevice(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  Widget app(Widget home) => MaterialApp(
    theme: HhTheme.light,
    locale: const Locale('en'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: home,
  );

  /// Whether the one button carrying [label] would do anything if tapped.
  bool enabled(WidgetTester tester, String label) {
    final button = tester.widget<HhButton>(
      find.widgetWithText(HhButton, label),
    );
    return button.onPressed != null;
  }

  group('phone entry', () {
    Future<void> pumpPhone(WidgetTester tester) async {
      sizeDevice(tester);
      await tester.pumpWidget(
        ProviderScope(
          retry: (retryCount, error) => null,
          child: app(const OnboardingScreen()),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> type(WidgetTester tester, String digits) async {
      await tester.enterText(find.byType(HhTextField).first, digits);
      await tester.pump();
    }

    Future<void> acceptTerms(WidgetTester tester) async {
      await tester.tap(find.byType(HhCheckboxRow));
      await tester.pump();
    }

    testWidgets('consent alone does not enable the send', (tester) async {
      // The exact reproduction: two digits and a tick.
      await pumpPhone(tester);
      final l10n = en;

      await type(tester, '94');
      await acceptTerms(tester);

      expect(
        enabled(tester, l10n.authSendCode),
        isFalse,
        reason: 'MT-013: 94 is not a number the API can be asked about',
      );
    });

    testWidgets('nine digits alone do not enable it either', (tester) async {
      // §4.1 step 2's consent is a precondition, not a formality.
      await pumpPhone(tester);

      await type(tester, '901234567');

      expect(enabled(tester, en.authSendCode), isFalse);
    });

    testWidgets('nine digits and consent enable it', (tester) async {
      await pumpPhone(tester);

      await type(tester, '901234567');
      await acceptTerms(tester);

      expect(enabled(tester, en.authSendCode), isTrue);
    });

    testWidgets('an incomplete number is answered on the field, not by the '
        'error state', (tester) async {
      await pumpPhone(tester);
      final l10n = en;

      await type(tester, '94');

      // The guidance is present...
      expect(find.text(l10n.authPhoneInvalid), findsOneWidget);
      // ...and it is not wearing the error state's heading, which announces a
      // system failure for something the user is in the middle of doing.
      expect(find.text(l10n.stateErrorTitle), findsNothing);
      expect(find.byType(HhErrorState), findsNothing);
    });

    testWidgets('an untouched field is not already scolding', (tester) async {
      // Arriving at a form that is red before it has been used tells the
      // reader nothing, and the hint underneath already shows the shape.
      await pumpPhone(tester);

      expect(find.text(en.authPhoneInvalid), findsNothing);
    });

    testWidgets('the guidance clears once the number is complete', (
      tester,
    ) async {
      await pumpPhone(tester);

      await type(tester, '9012');
      expect(find.text(en.authPhoneInvalid), findsOneWidget);

      await type(tester, '901234567');
      expect(find.text(en.authPhoneInvalid), findsNothing);
    });
  });

  group('code entry', () {
    Future<void> pumpCode(WidgetTester tester) async {
      sizeDevice(tester);

      // A challenge whose resend window has already passed, so no timer is
      // left running to keep pumpAndSettle spinning.
      final past = ZonedTimestamp.parse('2020-01-01T00:00:00+05:00');

      await tester.pumpWidget(
        ProviderScope(
          retry: (retryCount, error) => null,
          overrides: [
            sessionControllerProvider.overrideWith(_RecordingSession.new),
          ],
          child: app(
            OtpVerificationScreen(
              args: OtpVerificationArgs(
                phone: UzPhone.parse('901234567'),
                challenge: OtpChallenge(
                  expiresAt: past,
                  resendAvailableAt: past,
                  receivedAt: DateTime.utc(2020, 1, 1, 1),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('an empty code cannot be confirmed', (tester) async {
      await pumpCode(tester);

      expect(
        enabled(tester, en.authVerifyCode),
        isFalse,
        reason: 'MT-013: Confirm enabled on an empty field',
      );
    });

    testWidgets('a short code cannot be confirmed', (tester) async {
      await pumpCode(tester);

      await tester.enterText(find.byType(HhTextField).first, '66');
      await tester.pump();

      expect(enabled(tester, en.authVerifyCode), isFalse);
    });

    testWidgets('a complete code can', (tester) async {
      await pumpCode(tester);

      await tester.enterText(find.byType(HhTextField).first, '666666');
      await tester.pump();

      expect(enabled(tester, en.authVerifyCode), isTrue);
    });

    testWidgets('a short code is answered on the field, not by the error '
        'state', (tester) async {
      await pumpCode(tester);
      final l10n = en;

      await tester.enterText(find.byType(HhTextField).first, '66');
      await tester.pump();

      expect(
        find.text(l10n.authCodeInvalid(OtpVerificationScreen.codeLength)),
        findsOneWidget,
      );
      expect(find.text(l10n.stateErrorTitle), findsNothing);
      expect(find.byType(HhErrorState), findsNothing);
    });

    testWidgets('an untouched code field is not already scolding', (
      tester,
    ) async {
      await pumpCode(tester);

      expect(
        find.text(
          en.authCodeInvalid(OtpVerificationScreen.codeLength),
        ),
        findsNothing,
      );
    });
  });
}
