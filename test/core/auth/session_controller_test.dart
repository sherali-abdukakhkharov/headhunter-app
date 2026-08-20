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

  @override
  Future<AuthSession> refresh(String refreshToken) async {
    final build = onRefresh;
    if (build == null) throw const ApiException('unexpected refresh');
    return build();
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
        onRefresh: () => throw const ApiException('Cannot reach the server.'),
      );

      final state = await settled(containerWith());

      expect(state, isA<SessionUnauthenticated>());
      expect((state as SessionUnauthenticated).expired, isFalse);
      expect(tokens.cleared, isFalse);
      expect(tokens.refreshToken, 'refresh-1');
    });

    test('falls back to the remembered role when the server names none',
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
    });

    test('ignores a remembered role the account no longer holds', () async {
      // Revoked while the app was closed. Local storage must not resurrect it.
      tokens.refreshToken = 'refresh-1';
      repo = _FakeAuthRepository(
        onRefresh: () => _session(roles: ['candidate'], activeRole: null),
      );

      final state = await settled(
        containerWith(prefs: {'session.active_role': 'employer'}),
      );

      expect((state as SessionActive).activeRole, isNull);
      expect(state.roles, {AppRole.candidate});
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
}
