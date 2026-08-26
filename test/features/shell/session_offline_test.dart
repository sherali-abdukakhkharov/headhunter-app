/// §12.4's explicit offline state, for the one launch that used to lie.
///
/// A cold start whose refresh could not *complete* kept the tokens — correct,
/// the session is probably fine — and then published `SessionUnauthenticated`,
/// so the redirect chain put a signed-in user on the sign-in screen. Two things
/// were wrong with that: it says the session is gone when nothing indicates it,
/// and the only action it offers needs an SMS over the network that is missing.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/auth/session_controller.dart';
import 'package:jobbridge_app/src/core/auth/session_state.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/shell/presentation/session_offline_screen.dart';

/// A session the test moves by hand, recording what the screen asked for.
class _FakeSession extends SessionController {
  _FakeSession(this._initial);

  final SessionState _initial;

  /// Every call, in order — the screen must re-run the **whole** restore
  /// rather than a bare refresh, and it must not conflate the two buttons.
  final calls = <String>[];

  /// What `restore` should leave behind. Null keeps the current state, which
  /// is what a second failure looks like.
  SessionState? onRestore;

  @override
  SessionState build() => _initial;

  @override
  Future<void> restore() async {
    calls.add('restore');
    if (onRestore case final next?) state = next;
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    state = const SessionUnauthenticated();
  }
}

void main() {
  final en = lookupAppL10n(const Locale('en'));

  Future<_FakeSession> pump(
    WidgetTester tester, {
    SessionState session = const SessionUnreachable(
      message: "You're offline. Check your connection and try again.",
      offline: true,
    ),
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _FakeSession(session);

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [sessionControllerProvider.overrideWith(() => fake)],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const SessionOfflineScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    return fake;
  }

  group('what it says', () {
    testWidgets('that the account is still there', (tester) async {
      // The sentence the sign-in screen could never say, and the reason this
      // screen exists at all.
      await pump(tester);

      expect(find.text(en.sessionUnreachableBody), findsOneWidget);
    });

    testWidgets('the failure in the user’s own language', (tester) async {
      // Already localized by `ApiException`, which words transport failures
      // from the ARB — so it is rendered as given rather than re-derived.
      await pump(tester);

      expect(
        find.text("You're offline. Check your connection and try again."),
        findsOneWidget,
      );
    });

    testWidgets('“no connection” when the request never left the device', (
      tester,
    ) async {
      await pump(tester);

      expect(find.text(en.stateOfflineTitle), findsOneWidget);
      expect(find.text(en.sessionUnreachableTitle), findsNothing);
    });

    testWidgets('and something else when the server answered badly', (
      tester,
    ) async {
      // Different problem, different expectation: one is fixed by moving, the
      // other by waiting. A single "no connection" heading would send somebody
      // hunting for signal they already have.
      await pump(
        tester,
        session: const SessionUnreachable(
          message: 'The server ran into a problem.',
          offline: false,
        ),
      );

      expect(find.text(en.sessionUnreachableTitle), findsOneWidget);
      expect(find.text(en.stateOfflineTitle), findsNothing);
    });
  });

  group('what it does', () {
    testWidgets('retry re-runs the whole restore, not a bare refresh', (
      tester,
    ) async {
      // `restore` reads the stored role, exchanges the token, adopts the roles
      // and status the server returns, and falls back to development roles
      // where there is no token. A retry that did only the middle step would
      // leave the other four to be found as bugs later.
      final fake = await pump(tester);

      await tester.tap(find.text(en.commonRetry));
      await tester.pumpAndSettle();

      expect(fake.calls, ['restore']);
    });

    testWidgets('a successful retry leaves the screen to the router', (
      tester,
    ) async {
      // Deliberately no navigation here: the session change moves the redirect
      // chain, which is the rule the whole chain depends on.
      final fake = await pump(tester);
      fake.onRestore = const SessionActive(roles: {});

      await tester.tap(find.text(en.commonRetry));
      await tester.pumpAndSettle();

      // The screen is still mounted — there is no router in this harness — and
      // the point is that it did not try to navigate itself.
      expect(fake.calls, ['restore']);
    });

    testWidgets('a failed retry leaves the screen usable', (tester) async {
      // No state change: the second attempt failed the same way. The button
      // has to come back, or one bad tap ends the session for good.
      final fake = await pump(tester);

      await tester.tap(find.text(en.commonRetry));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.commonRetry));
      await tester.pumpAndSettle();

      expect(fake.calls, ['restore', 'restore']);
    });

    testWidgets('there is a way out for a token that will never work', (
      tester,
    ) async {
      // A revoked token, or a server that stays down, would otherwise trap
      // somebody on a screen whose only button does nothing. Sign-out is
      // best-effort and clears locally, so it works without the network this
      // screen is about.
      final fake = await pump(tester);

      await tester.tap(find.text(en.sessionUnreachableSignOut));
      await tester.pumpAndSettle();

      expect(fake.calls, ['signOut']);
    });
  });
}
