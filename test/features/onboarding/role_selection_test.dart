import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/auth/app_role.dart';
import 'package:jobbridge_app/src/core/auth/session_controller.dart';
import 'package:jobbridge_app/src/core/auth/session_state.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/onboarding/presentation/role_selection_screen.dart';

/// A session controller that records the role set it was handed.
///
/// The screen deliberately does not navigate — the granted roles change the
/// session and the redirect chain moves — so what it *sends* is the only
/// observable behaviour worth asserting.
class _RecordingSession extends SessionController {
  _RecordingSession({this.failure});

  final ApiException? failure;
  final calls = <Set<AppRole>>[];

  @override
  SessionState build() => const SessionUnauthenticated();

  @override
  Future<void> selectRoles(Set<AppRole> roles) async {
    calls.add(roles);
    if (failure case final error?) throw error;
  }
}

void main() {
  Future<_RecordingSession> pump(
    WidgetTester tester, {
    ApiException? failure,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final session = _RecordingSession(failure: failure);

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [sessionControllerProvider.overrideWith(() => session)],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const RoleSelectionScreen(),
        ),
      ),
    );
    await tester.pump();

    return session;
  }

  Finder role(String label) => find.widgetWithText(HhCheckboxRow, label);

  group('§2.3: the last step of registration explains itself', () {
    testWidgets('each role says what it can do, not just its name', (
      tester,
    ) async {
      // A first-time reader has no reason to know what "Employer" means in this
      // app. §2.2's capabilities are the explanation.
      await pump(tester);

      expect(find.text('Candidate'), findsOneWidget);
      expect(find.text('Employer'), findsOneWidget);
      expect(
        find.textContaining('Build a profile employers can find'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Publish vacancies, search candidates'),
        findsOneWidget,
      );
    });

    testWidgets('the employer line quotes no price', (tester) async {
      // Coins and unlocks are real (§6.6) and deliberately unmentioned here: a
      // price stated before anything has been offered reads as a paywall in
      // front of registration.
      await pump(tester);

      final painted = [
        for (final widget in tester.widgetList<Text>(find.byType(Text)))
          widget.data ?? '',
      ].join(' | ');

      expect(painted.toLowerCase(), isNot(contains('coin')));
      expect(painted, isNot(contains('unlock')));
      expect(RegExp(r'\d').hasMatch(painted), isFalse);
    });

    testWidgets('administrator is not offered at all (§10)', (tester) async {
      // Not disabled — absent. A self-service admin control is a privilege
      // escalation that happens to look like a button.
      await pump(tester);

      expect(find.text('Administrator'), findsNothing);
    });

    testWidgets('no scaffolding copy survives', (tester) async {
      // The screen shipped with an `HhNotice.pending` reading "Role selection
      // arrives in M1" — on the first screen a new account ever sees.
      await pump(tester);

      expect(find.textContaining('M1'), findsNothing);
      expect(find.byType(HhNotice), findsNothing);
    });
  });

  group('the both-roles note', () {
    testWidgets('appears only once both are chosen', (tester) async {
      // Said earlier it is advice nobody asked for; said here it answers the
      // question the second tick raises.
      await pump(tester);
      expect(find.textContaining('two separate spaces'), findsNothing);

      await tester.tap(role('Candidate'));
      await tester.pump();
      expect(find.textContaining('two separate spaces'), findsNothing);

      await tester.tap(role('Employer'));
      await tester.pump();
      expect(find.textContaining('two separate spaces'), findsOneWidget);
    });

    testWidgets('goes away again when one is unticked', (tester) async {
      await pump(tester);

      await tester.tap(role('Candidate'));
      await tester.pump();
      await tester.tap(role('Employer'));
      await tester.pump();
      await tester.tap(role('Employer'));
      await tester.pump();

      expect(find.textContaining('two separate spaces'), findsNothing);
    });
  });

  group('submitting', () {
    testWidgets('Next does nothing until a role is chosen', (tester) async {
      // An empty set would be sent, and the redirect chain would bounce
      // straight back here — a button that looks broken.
      final session = await pump(tester);

      await tester.tap(find.widgetWithText(HhButton, 'Next'));
      await tester.pump();

      expect(session.calls, isEmpty);
    });

    testWidgets('sends exactly what was ticked', (tester) async {
      final session = await pump(tester);

      await tester.tap(role('Employer'));
      await tester.pump();
      await tester.tap(find.widgetWithText(HhButton, 'Next'));
      await tester.pumpAndSettle();

      expect(session.calls, [
        {AppRole.employer},
      ]);
    });

    testWidgets('sends both when both are ticked', (tester) async {
      final session = await pump(tester);

      await tester.tap(role('Candidate'));
      await tester.pump();
      await tester.tap(role('Employer'));
      await tester.pump();
      await tester.tap(find.widgetWithText(HhButton, 'Next'));
      await tester.pumpAndSettle();

      expect(session.calls.single, {AppRole.candidate, AppRole.employer});
    });

    testWidgets('a refusal is shown in the server’s own words', (tester) async {
      // The message is already localized by the server (§3.2), so it is
      // rendered rather than mapped to a client string.
      await pump(tester, failure: const ApiException('Role not available.'));

      await tester.tap(role('Candidate'));
      await tester.pump();
      await tester.tap(find.widgetWithText(HhButton, 'Next'));
      await tester.pumpAndSettle();

      expect(find.text('Role not available.'), findsOneWidget);
      // And the choice survives the failure, so retrying does not start over.
      expect(find.widgetWithText(HhButton, 'Next'), findsOneWidget);
    });
  });

  group('HhCheckboxRow with a description', () {
    testWidgets('renders both lines and stays one tap target', (tester) async {
      var value = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: HhTheme.light,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => HhCheckboxRow(
                label: 'Employer',
                description: 'Publish vacancies and search candidates.',
                value: value,
                onChanged: (v) => setState(() => value = v),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Employer'), findsOneWidget);
      expect(
        find.text('Publish vacancies and search candidates.'),
        findsOneWidget,
      );

      // Tapping the *description* toggles it: the whole row is the target,
      // which is why this component exists rather than a bare Checkbox.
      await tester.tap(find.text('Publish vacancies and search candidates.'));
      await tester.pump();
      expect(value, isTrue);
    });
  });
}
