/// §4.2, BR-14 and §3.2's language, from the screen a user is actually on.
///
/// Everything a person goes to settings *for* — the interface language,
/// sessions, the role switch, sign-out and account deletion — lives behind one
/// entry, and that entry used to sit under the whole editable profile. Reaching
/// it took five or six swipes past a form, which the 1.29.0 audit filed as a
/// P1: the controls somebody needs when something has gone wrong should not be
/// the ones furthest away.
///
/// So the entry is a header action now, and the property worth pinning is not
/// that it exists but **that it is on screen before anything is scrolled, in
/// every state the screen has**. A header inside the `AsyncData` arm would
/// disappear exactly when a user most needs the way out.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/account/presentation/account_entry_row.dart';
import 'package:jobbridge_app/src/features/employer/data/employer_controller.dart';
import 'package:jobbridge_app/src/features/employer/presentation/employer_profile_screen.dart';
import 'package:jobbridge_app/src/features/profile/data/profile_controller.dart';
import 'package:jobbridge_app/src/features/profile/presentation/candidate_profile_screen.dart';

/// A candidate editor held in whichever state the case needs.
class _Candidate extends ProfileEditor {
  _Candidate(this.failure);

  final ApiException? failure;

  @override
  Future<ProfileEditorState> build() {
    final f = failure;
    if (f != null) throw f;

    // Never completes: the loading arm, held open.
    return Completer<ProfileEditorState>().future;
  }
}

/// The same, for the employer's half.
class _Employer extends EmployerEditor {
  _Employer(this.failure);

  final ApiException? failure;

  @override
  Future<EmployerEditorState> build() {
    final f = failure;
    if (f != null) throw f;

    return Completer<EmployerEditorState>().future;
  }
}

/// Pumps [screen] with **both** editors stubbed.
///
/// Both rather than the one the screen needs, because `Override` is not
/// exported by `flutter_riverpod` — a helper cannot take a list of them — and
/// an override nothing reads costs nothing.
Future<void> _pump(
  WidgetTester tester,
  Widget screen, {
  ApiException? failure,
  Size size = const Size(1080, 2400),
  double scale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      retry: (retryCount, error) => null,
      overrides: [
        profileEditorProvider.overrideWith(() => _Candidate(failure)),
        employerEditorProvider.overrideWith(() => _Employer(failure)),
      ],
      child: MaterialApp(
        theme: HhTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: screen,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  const offline = ApiException(
    "You're offline.",
    kind: ApiFailureKind.offline,
  );

  group('the candidate profile', () {
    testWidgets('offers the account while it is still loading', (tester) async {
      await _pump(tester, const CandidateProfileScreen());

      // Hit-testable, not merely built: a control drawn under something still
      // measures as present, and this is what says a finger would land on it.
      expect(find.byType(AccountEntryAction).hitTestable(), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('and when the profile could not be loaded at all', (
      tester,
    ) async {
      await _pump(tester, const CandidateProfileScreen(), failure: offline);

      // The state in which somebody is most likely to want to sign out and
      // back in, and the one where the old placement offered nothing at all:
      // an error arm has no form to scroll to the bottom of.
      expect(find.byType(HhErrorState), findsOneWidget);
      expect(find.byType(AccountEntryAction).hitTestable(), findsOneWidget);
    });

    testWidgets('and it names the screen', (tester) async {
      await _pump(tester, const CandidateProfileScreen());

      final l10n = lookupAppL10n(const Locale('en'));
      expect(find.text(l10n.navProfile), findsOneWidget);
    });
  });

  group('the employer profile', () {
    testWidgets('offers the account while it is still loading', (tester) async {
      await _pump(tester, const EmployerProfileScreen());

      expect(find.byType(AccountEntryAction).hitTestable(), findsOneWidget);
    });

    testWidgets('and when it could not be loaded', (tester) async {
      await _pump(tester, const EmployerProfileScreen(), failure: offline);

      expect(find.byType(HhErrorState), findsOneWidget);
      expect(find.byType(AccountEntryAction).hitTestable(), findsOneWidget);
    });
  });

  testWidgets('the header survives 320pt at 2.0x text scale', (tester) async {
    // The design's own QA case. A title and an action on one row is the shape
    // that overflows first — and it did, by 9pt, the first time the action
    // carried the destination's full name instead of one word.
    await _pump(
      tester,
      const EmployerProfileScreen(),
      // 960 physical at dpr 3 is 320 logical.
      size: const Size(960, 2400),
      scale: 2,
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(AccountEntryAction), findsOneWidget);
  });
}
