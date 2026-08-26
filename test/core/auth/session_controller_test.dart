import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/core/auth/app_role.dart';
import 'package:jobbridge_app/src/core/auth/session_controller.dart';
import 'package:jobbridge_app/src/core/auth/session_state.dart';
import 'package:jobbridge_app/src/core/auth/token_store.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/auth_events.dart';
import 'package:jobbridge_app/src/features/auth/data/auth_repository.dart';
import 'package:jobbridge_app/src/features/auth/domain/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cold-start restore is the whole reason a user does not sign in twice a day,
/// and its three outcomes are easy to collapse into two. The one that matters
/// is the middle case: **a refresh that could not be completed is not a refresh
/// that was refused**, and treating them alike signs people out for being
/// underground.
class _FakeTokenStore extends TokenStore {
  _FakeTokenStore() : super(const FlutterSecureStorage());

  String? refreshToken;
  String? accessToken;
  bool cleared = false;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<void> save(TokenPair tokens) async {
    accessToken = tokens.accessToken;
    refreshToken = tokens.refreshToken;
  }

  @override
  Future<void> clear() async {
    cleared = true;
    accessToken = null;
    refreshToken = null;
  }
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({this.onRefresh, this.onLogout}) : super(Dio());

  final AuthSession Function()? onRefresh;
  final void Function()? onLogout;

  int logoutCalls = 0;

  /// Every call this fake saw, in order, plus whatever a test appends. The
  /// *sequence* is the claim MT-021 turns on — see the group at the bottom.
  final events = <String>[];

  /// What `/auth/roles` answers with. Not the set it was sent: an administrator
  /// may have granted more (§10).
  Set<AppRole> grants = const {AppRole.employer};

  ApiException? selectFailure;

  @override
  Future<AuthSession> refresh(String refreshToken) async {
    final build = onRefresh;
    if (build == null) throw const ApiException('unexpected refresh');
    return build();
  }

  @override
  Future<Set<AppRole>> selectRoles(Set<AppRole> roles) async {
    events.add('roles');
    if (selectFailure case final failure?) throw failure;
    return grants;
  }

  /// Set to make publishing the active role fail — MT-022's unhappy path.
  ApiException? activeRoleFailure;

  @override
  Future<String> switchActiveRole(AppRole role) async {
    events.add('active-role:${role.wire}');

    final failure = activeRoleFailure;
    if (failure != null) throw failure;

    return 'access-naming-${role.wire}';
  }

  @override
  Future<void> logout(String refreshToken) async {
    logoutCalls++;
    onLogout?.call();
  }
}

AuthSession _session({
  List<String> roles = const ['candidate'],
  String? activeRole = 'candidate',
}) => AuthSession.fromJson({
  'accessToken': 'access-2',
  'refreshToken': 'refresh-2',
  'expiresInSeconds': 900,
  'roles': roles,
  'activeRole': activeRole,
  'isNewUser': false,
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeTokenStore tokens;
  late _FakeAuthRepository repo;

  ProviderContainer containerWith({Map<String, Object> prefs = const {}}) {
    SharedPreferences.setMockInitialValues(prefs);

    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        tokenStoreProvider.overrideWithValue(tokens),
        authRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Reads the session once `restore` has settled. `build` kicks it off
  /// fire-and-forget, so a test that reads immediately sees SessionUnknown.
  Future<SessionState> settled(ProviderContainer container) async {
    container.read(sessionControllerProvider);
    await container.read(sessionControllerProvider.notifier).restore();
    return container.read(sessionControllerProvider);
  }

  setUp(() {
    tokens = _FakeTokenStore();
    repo = _FakeAuthRepository();
  });

  group('restore', () {
    test('with no stored token, lands unauthenticated', () async {
      final state = await settled(containerWith());

      expect(state, isA<SessionUnauthenticated>());
      expect(tokens.cleared, isFalse);
    });

    test('exchanges a stored token for a real session', () async {
      // The token is not trusted on its own: the roles and the account status
      // come from the server, because a role could have been revoked or the
      // account blocked (BR-10) while the app was closed.
      tokens.refreshToken = 'refresh-1';
      repo = _FakeAuthRepository(onRefresh: _session);

      final state = await settled(containerWith());

      expect(state, isA<SessionActive>());
      expect((state as SessionActive).roles, {AppRole.candidate});
      expect(state.activeRole, AppRole.candidate);
      // The rotated pair replaced the old one.
      expect(tokens.refreshToken, 'refresh-2');
    });

    test('a refused refresh clears the tokens and explains itself', () async {
      tokens.refreshToken = 'refresh-1';
      repo = _FakeAuthRepository(
        onRefresh: () => throw const ApiException('Gone', statusCode: 401),
      );

      final state = await settled(containerWith());

      expect(state, isA<SessionUnauthenticated>());
      expect((state as SessionUnauthenticated).expired, isTrue);
      expect(tokens.cleared, isTrue);
    });

    test('a refresh that could not complete KEEPS the tokens', () async {
      // Offline, DNS, a 500 - none of it says the session is invalid. Clearing
      // here signs a user out for going through a tunnel, and they cannot get
      // back in until they have signal *and* their phone.
      tokens.refreshToken = 'refresh-1';
      repo = _FakeAuthRepository(
        onRefresh: () => throw const ApiException(
          "You're offline.",
          kind: ApiFailureKind.offline,
        ),
      );

      final state = await settled(containerWith());

      // **Not `SessionUnauthenticated`**, which is what this used to be and
      // what put a signed-in user on the sign-in screen (§12.4). The session
      // is unknown, not over.
      expect(state, isA<SessionUnreachable>());
      expect(tokens.cleared, isFalse);
      expect(tokens.refreshToken, 'refresh-1');
    });

    test('and carries what to say, in the user’s language', () async {
      tokens.refreshToken = 'refresh-1';
      repo = _FakeAuthRepository(
        onRefresh: () => throw const ApiException(
          "You're offline. Check your connection and try again.",
          kind: ApiFailureKind.offline,
        ),
      );

      final state = await settled(containerWith()) as SessionUnreachable;

      // Already localized — `ApiException` words transport failures from the
      // ARB — so the screen renders it as given.
      expect(state.message, contains('offline'));
      expect(state.offline, isTrue);
    });

    test('a server that answered badly is not the same as offline', () async {
      // Different problem, different sentence, different expectation: one is
      // fixed by moving, the other by waiting.
      tokens.refreshToken = 'refresh-1';
      repo = _FakeAuthRepository(
        onRefresh: () => throw const ApiException(
          'The server ran into a problem.',
          statusCode: 500,
          kind: ApiFailureKind.server,
        ),
      );

      final state = await settled(containerWith()) as SessionUnreachable;

      expect(state.offline, isFalse);
      expect(tokens.cleared, isFalse);
    });

    test('a retry after the network returns lands in the shell', () async {
      // The whole point of keeping the tokens. `restore` is re-run in full
      // rather than just the refresh call, so the stored role, the granted
      // roles and the account status all come back with it.
      tokens.refreshToken = 'refresh-1';
      var offline = true;
      repo = _FakeAuthRepository(
        onRefresh: () {
          if (offline) {
            throw const ApiException('no', kind: ApiFailureKind.offline);
          }
          return _session();
        },
      );

      final container = containerWith();
      expect(await settled(container), isA<SessionUnreachable>());

      offline = false;
      await container.read(sessionControllerProvider.notifier).restore();

      final state = container.read(sessionControllerProvider);
      expect(state, isA<SessionActive>());
      expect((state as SessionActive).roles, {AppRole.candidate});
    });

    test(
      'falls back to the remembered role when the server names none',
      () async {
        tokens.refreshToken = 'refresh-1';
        repo = _FakeAuthRepository(
          onRefresh: () => _session(
            roles: ['candidate', 'employer'],
            activeRole: null,
          ),
        );

        final state = await settled(
          containerWith(prefs: {'session.active_role': 'employer'}),
        );

        expect((state as SessionActive).activeRole, AppRole.employer);
      },
    );

    test('ignores a remembered role the account no longer holds', () async {
      // Revoked while the app was closed. Local storage must not resurrect it.
      tokens.refreshToken = 'refresh-1';
      repo = _FakeAuthRepository(
        onRefresh: () => _session(roles: ['candidate'], activeRole: null),
      );

      final state = await settled(
        containerWith(prefs: {'session.active_role': 'employer'}),
      );

      expect(state, isA<SessionActive>());
      expect((state as SessionActive).roles, {AppRole.candidate});
      // Falls through to what the account *does* hold rather than staying
      // null. Leaving it null is what MT-022 was: the shell would open on a
      // role invented at render time and 403 every call. `employer` is still
      // refused, which is the half this test was always about.
      expect(state.activeRole, AppRole.candidate);
      expect(repo.events, contains('active-role:candidate'));
    });
  });

  group('MT-022: a granted account always acts as something', () {
    test(
      'a fresh install on a multi-role account resolves and publishes',
      () async {
        // The reported case: two grants, no server active role, nothing stored
        // locally. `effectiveRole` would have named one when the router
        // asked, and the token would still have named none.
        tokens.refreshToken = 'refresh-1';
        repo = _FakeAuthRepository(
          onRefresh: () =>
              _session(roles: ['employer', 'admin'], activeRole: null),
        );

        final state = await settled(containerWith());

        expect(state, isA<SessionActive>());
        expect((state as SessionActive).activeRole, isNotNull);
        expect(state.hasUnresolvedRole, isFalse);
        // Told to the server, which is the whole point: role-scoped routes read
        // the role from the token, not from this object.
        expect(repo.events, contains('active-role:${state.activeRole!.wire}'));
      },
    );

    test(
      'the choice is deterministic, not whichever role arrived first',
      () async {
        // Same account, twice. A chooser is one acceptable answer and a stable
        // default is the other; this is the second, so it has to be stable.
        tokens.refreshToken = 'refresh-1';
        repo = _FakeAuthRepository(
          onRefresh: () =>
              _session(roles: ['admin', 'employer'], activeRole: null),
        );
        final first = await settled(containerWith());

        repo = _FakeAuthRepository(
          onRefresh: () =>
              _session(roles: ['employer', 'admin'], activeRole: null),
        );
        final second = await settled(containerWith());

        expect(
          (first as SessionActive).activeRole,
          (second as SessionActive).activeRole,
        );
      },
    );

    test('a remembered role is honoured and published', () async {
      tokens.refreshToken = 'refresh-1';
      repo = _FakeAuthRepository(
        onRefresh: () =>
            _session(roles: ['employer', 'admin'], activeRole: null),
      );

      final state = await settled(
        containerWith(prefs: {'session.active_role': 'admin'}),
      );

      expect((state as SessionActive).activeRole, AppRole.admin);
      expect(repo.events, contains('active-role:admin'));
    });

    test('a role the server already named costs no round trip', () async {
      // The token already names it, so publishing would be a request that
      // changes nothing — and sign-in is not a place to spend one.
      tokens.refreshToken = 'refresh-1';
      repo = _FakeAuthRepository(
        onRefresh: () => _session(roles: ['candidate']),
      );

      final state = await settled(containerWith());

      expect((state as SessionActive).activeRole, AppRole.candidate);
      expect(repo.events, isNot(contains('active-role:candidate')));
    });

    test('a failed publish does not enter a shell', () async {
      // The acceptance criterion, stated directly: no role shell renders with a
      // token whose active role is null. Offline is recoverable — the tokens
      // are saved and the offline screen re-runs the whole restore.
      tokens.refreshToken = 'refresh-1';
      repo =
          _FakeAuthRepository(
              onRefresh: () =>
                  _session(roles: ['employer', 'admin'], activeRole: null),
            )
            ..activeRoleFailure = const ApiException(
              'No connection',
              kind: ApiFailureKind.offline,
            );

      final state = await settled(containerWith());

      expect(state, isA<SessionUnreachable>());
      expect((state as SessionUnreachable).offline, isTrue);
    });
  });

  group('signOut', () {
    test('revokes server-side, then clears locally', () async {
      tokens.refreshToken = 'refresh-1';
      repo = _FakeAuthRepository(onRefresh: _session);

      final container = containerWith();
      await settled(container);
      await container.read(sessionControllerProvider.notifier).signOut();

      expect(repo.logoutCalls, 1);
      expect(tokens.cleared, isTrue);
      expect(
        container.read(sessionControllerProvider),
        isA<SessionUnauthenticated>(),
      );
    });

    test('still signs out locally when the server call fails', () async {
      // A user tapping "sign out" on a train has to end up signed out. Keeping
      // the tokens because a request timed out is the worse failure: the
      // session stays live *and* the app still looks signed in.
      tokens.refreshToken = 'refresh-1';
      repo = _FakeAuthRepository(
        onRefresh: _session,
        onLogout: () => throw const ApiException('offline'),
      );

      final container = containerWith();
      await settled(container);
      await container.read(sessionControllerProvider.notifier).signOut();

      expect(tokens.cleared, isTrue);
      expect(
        container.read(sessionControllerProvider),
        isA<SessionUnauthenticated>(),
      );
    });
  });

  test('a session lost by the interceptor expires the controller', () async {
    // The network layer cannot call the controller directly without closing a
    // provider cycle, so this arrives as an event. If the wiring breaks, a
    // revoked session leaves the user staring at a shell where every request
    // fails.
    tokens.refreshToken = 'refresh-1';
    repo = _FakeAuthRepository(onRefresh: _session);

    final container = containerWith();
    await settled(container);
    expect(container.read(sessionControllerProvider), isA<SessionActive>());

    await container.read(authEventsProvider).reportSessionLost();
    await Future<void>.delayed(Duration.zero);

    final state = container.read(sessionControllerProvider);
    expect(state, isA<SessionUnauthenticated>());
    expect((state as SessionUnauthenticated).expired, isTrue);
  });

  group('MT-021: finishing registration is one transition', () {
    /// A signed-in account that holds no role yet — which is every account
    /// between `POST /auth/otp/verify` and role selection, because verifying a
    /// code creates the account and a new account deliberately holds none.
    Future<ProviderContainer> registering() async {
      tokens.refreshToken = 'refresh-1';
      repo = _FakeAuthRepository(
        onRefresh: () => _session(roles: const [], activeRole: null),
      );

      final container = containerWith();
      final state = await settled(container);

      expect(state, isA<SessionActive>());
      expect((state as SessionActive).roles, isEmpty);

      // The restore itself is not part of the claim below.
      repo.events.clear();
      return container;
    }

    /// Appends `state` to the log the first time a session with granted roles
    /// is published. That is the exact moment the redirect chain is free to
    /// leave this screen for a role shell.
    void recordShellEntry(ProviderContainer container) {
      var entered = false;
      container.listen<SessionState>(sessionControllerProvider, (_, next) {
        if (entered) return;
        if (next is SessionActive && next.roles.isNotEmpty) {
          entered = true;
          repo.events.add('state');
        }
      });
    }

    test('the token names the role before the shell can be entered', () async {
      final container = await registering();
      recordShellEntry(container);

      await container.read(sessionControllerProvider.notifier).selectRoles({
        AppRole.employer,
      });

      // The whole finding in one assertion. `state` last is what stops the
      // shell rendering against a token that names no role — which the server
      // answers with 403 `role.none_active`, rendered as *"No active role is
      // selected. Choose a role first."* to somebody who had just chosen one.
      expect(repo.events, ['roles', 'active-role:employer', 'state']);
    });

    test('and the state that lands carries both halves at once', () async {
      final container = await registering();

      await container.read(sessionControllerProvider.notifier).selectRoles({
        AppRole.employer,
      });

      final state = container.read(sessionControllerProvider) as SessionActive;
      expect(state.roles, {AppRole.employer});
      // Not merely derivable through `effectiveRole` — actually set, and
      // therefore persisted, so a cold start agrees with what is on screen.
      expect(state.activeRole, AppRole.employer);
    });

    test('the choice survives a cold start', () async {
      // The audit noted a restart *healed* the broken state, which is the
      // clue that persistence was happening after the transition rather than
      // before it.
      final container = await registering();

      await container.read(sessionControllerProvider.notifier).selectRoles({
        AppRole.employer,
      });

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('session.active_role'), AppRole.employer.wire);
    });

    test('the server’s set wins over the one that was sent (§10)', () async {
      final container = await registering();
      repo.grants = const {AppRole.candidate, AppRole.employer};

      await container.read(sessionControllerProvider.notifier).selectRoles({
        AppRole.candidate,
      });

      final state = container.read(sessionControllerProvider) as SessionActive;
      expect(state.roles, {AppRole.candidate, AppRole.employer});
    });

    test('a refused grant moves nothing and stays retryable', () async {
      // The third acceptance criterion. Recording the roles locally on a
      // failed call would drop the user into a shell the server does not agree
      // they can use, and every request from it would 403.
      final container = await registering();
      repo.selectFailure = const ApiException('offline');

      await expectLater(
        container.read(sessionControllerProvider.notifier).selectRoles({
          AppRole.employer,
        }),
        throwsA(isA<ApiException>()),
      );

      final state = container.read(sessionControllerProvider) as SessionActive;
      expect(state.roles, isEmpty);
      expect(repo.events, ['roles']);
    });

    test('granting nothing publishes anyway rather than hanging', () async {
      // A server that answers with an empty set leaves nothing to be active.
      // The screen must not sit on a spinner: the redirect chain sends it
      // straight back to role selection, which is the honest outcome.
      final container = await registering();
      repo.grants = const {};
      recordShellEntry(container);

      await container.read(sessionControllerProvider.notifier).selectRoles({
        AppRole.employer,
      });

      final state = container.read(sessionControllerProvider) as SessionActive;
      expect(state.roles, isEmpty);
      expect(state.activeRole, isNull);
      // No token rotation, because there is no role to name.
      expect(repo.events, ['roles']);
    });
  });
}
