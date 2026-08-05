import 'dart:async';

import 'package:headhunter_app/src/core/auth/app_role.dart';
import 'package:headhunter_app/src/core/auth/session_state.dart';
import 'package:headhunter_app/src/core/auth/token_store.dart';
import 'package:headhunter_app/src/core/config/app_flavor.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/core/storage/preferences_provider.dart';
import 'package:headhunter_app/src/features/auth/data/auth_repository.dart';
import 'package:headhunter_app/src/features/auth/data/telegram_sign_in.dart';
import 'package:headhunter_app/src/features/auth/domain/auth_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_controller.g.dart';

/// App-wide session and active-role state.
///
/// Kept alive: the router redirects on it and every shell reads it, so it must
/// survive a screen being disposed.
///
/// ## What is real here and what is still a seam
///
/// The **role model** is real - the granted set, the active choice, the
/// fallback when a role is revoked, and the persistence of the active choice.
/// Those are decided by §2.3 and do not depend on the auth wire format.
///
/// **Acquiring** a session is now real too: [signInWithOtp] posts a phone
/// number and the code sent to it, and takes the roles and tokens from the
/// response.
/// [signInWithTelegram] is the deprecated predecessor, kept but uncalled.
///
/// Still a seam: [restore] cannot rebuild a session from a stored refresh token
/// until the refresh call is wired through the repository, so a cold start with
/// valid tokens currently lands on onboarding rather than the shell.
/// [signInAsDevelopmentRole] also stays, gated on the flavor - it is how the
/// redirect chain is exercised without a network or a real bot.
@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  /// Active role, as a wire tag. A tag rather than an enum index: reordering
  /// [AppRole] must not silently move a user into a different shell.
  static const _activeRoleKey = 'session.active_role';

  /// Development-only: the roles a hardcoded session was granted, so a hot
  /// restart lands back in the shell being worked on. Removed with the rest of
  /// [signInAsDevelopmentRole] when M1 lands real auth.
  static const _developmentRolesKey = 'session.dev_roles';

  /// True once the provider has been torn down, so a slow [restore] cannot
  /// assign to `state` afterwards. Only observable in tests, where the scope is
  /// disposed between cases - but that failure is an unrelated test blowing up
  /// with a Riverpod error, which is a bad afternoon to debug.
  var _disposed = false;

  @override
  SessionState build() {
    ref.onDispose(() => _disposed = true);
    // Deliberately fire-and-forget. Returning SessionUnknown synchronously lets
    // the router hold navigation for one frame instead of the whole tree
    // awaiting a keychain read - and SessionUnknown is precisely the state that
    // prevents the cold-start onboarding flash.
    unawaited(restore());
    return const SessionUnknown();
  }

  /// Re-establishes the session from local storage. Leaves [SessionUnknown]
  /// only once it has an answer.
  Future<void> restore() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final activeRole = AppRole.fromWire(prefs.getString(_activeRoleKey));

    // M1 seam. The real sequence is: read the refresh token, exchange it for a
    // session, and take the granted roles and account status from the response.
    // Presence of a refresh token alone cannot stand in for that - it says
    // nothing about which roles the account holds or whether it has been
    // blocked since (BR-10), and guessing `{candidate}` would put a blocked
    // employer into a working candidate shell.
    await ref.read(tokenStoreProvider).readRefreshToken();

    final developmentRoles = AppFlavor.current.allowsDevelopmentTools
        ? (prefs.getStringList(_developmentRolesKey) ?? const [])
              .map(AppRole.fromWire)
              .nonNulls
              .toSet()
        : const <AppRole>{};

    _set(
      developmentRoles.isEmpty
          ? const SessionUnauthenticated()
          : SessionActive(roles: developmentRoles, activeRole: activeRole),
    );
  }

  /// Signs in with a phone number and the one-time code sent to it (§4.1,
  /// UAT-01).
  ///
  /// Registration and login are one call: with a phone-only identity they are
  /// the same act, and the response's `isNewUser` is what routes a new account
  /// into role selection. Verifying the code is also what makes the number
  /// verified, so **BR-01 is satisfied by arriving here** — unlike the Telegram
  /// path, which could produce an authenticated account with no usable phone.
  ///
  /// [phone] must be in wire form; build it with `UzPhone.wire`.
  ///
  /// Throws [ApiException] and nothing else. A 401 is a wrong, expired or
  /// already-used code; the server will not say which, and its message is
  /// already localized.
  Future<void> signInWithOtp({
    required String phone,
    required String code,
  }) async {
    final session = await ref
        .read(authRepositoryProvider)
        .verifyOtp(phone: phone, code: code);

    await _adopt(session);
  }

  /// Signs in with Telegram.
  ///
  /// **Deprecated 2026-08-05** in favour of [signInWithOtp] (§4.1, UAT-01).
  /// Nothing calls this; it is kept with its tests because the flow is correct
  /// and re-enabling it is cheaper than rebuilding it. See
  /// docs/TELEGRAM_LOGIN.md.
  ///
  /// Obtains a signed ID token from Telegram, exchanges it for a session, and
  /// stores the token pair. **The app decides nothing about identity** — it
  /// forwards Telegram's assertion, and the backend decides who this is after
  /// verifying the signature against Telegram's JWKS.
  ///
  /// Rethrows so the calling screen can render the failure:
  /// - [TelegramSignInCancelled] — the user backed out; show nothing.
  /// - [TelegramSignInFailure] — Telegram or the SDK failed; the screen maps
  ///   `kind` to localized copy.
  /// - [ApiException] — the server refused, and its `message` is already
  ///   localized. This is the path a login with no Telegram-verified phone
  ///   number takes, because BR-01 admits no account without one.
  Future<void> signInWithTelegram() async {
    final idToken = await ref.read(telegramSignInProvider).obtainIdToken();
    final session = await ref
        .read(authRepositoryProvider)
        .signInWithTelegram(idToken);

    await _adopt(session);
  }

  /// Takes ownership of a freshly issued session, whichever call produced it.
  ///
  /// Order matters: the tokens are persisted **before** the state moves to
  /// [SessionActive]. The router redirects on that change and the shell it
  /// lands on may fetch immediately, so flipping state ahead of the write would
  /// race the first authenticated request against its own credentials.
  Future<void> _adopt(AuthSession session) async {
    await ref.read(tokenStoreProvider).save(session.tokens);

    final prefs = await ref.read(sharedPreferencesProvider.future);
    final active = session.active;
    if (active != null) {
      await prefs.setString(_activeRoleKey, active.wire);
    }

    _set(
      SessionActive(roles: session.grantedRoles, activeRole: active),
    );
  }

  /// Switches the active role (§2.3).
  ///
  /// **State only - this does not navigate, and calling it alone is a bug.**
  /// Use `switchRoleAndGo` in `core/router/role_navigation.dart`, the one place
  /// that pairs the two.
  ///
  /// The reason it cannot navigate on its own: after this returns, the location
  /// is still the *old* role's shell, and the router's deep-link rule reads the
  /// location and re-activates the role that owns it - undoing the switch. See
  /// `switchRoleAndGo` for the full explanation.
  ///
  /// A role the account does not hold is ignored rather than asserted: the
  /// caller may be a deep link, and a link to a revoked role is a thing that
  /// happens in normal use, not a programming error.
  Future<void> switchRole(AppRole role) async {
    final current = state;
    if (current is! SessionActive || !current.can(role)) return;
    if (current.activeRole == role) return;

    _set(current.copyWith(activeRole: role));

    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_activeRoleKey, role.wire);
  }

  /// Records the roles the server granted, preserving the active choice where
  /// it is still valid. Called after role selection and after a profile
  /// refresh.
  void setGrantedRoles(Set<AppRole> roles) {
    final current = state;
    _set(
      current is SessionActive
          ? current.copyWith(roles: roles)
          : SessionActive(roles: roles),
    );
  }

  /// Applies an administrator action's outcome (§10.4, UAT-14).
  void applyAccountStatus(AccountStatus status, {String? reason}) {
    final current = state;
    if (current is! SessionActive) return;
    _set(current.copyWith(status: status, restrictionReason: reason));
  }

  /// The session is definitively gone - refresh failed or the server rejected
  /// the refresh token.
  ///
  /// This is the destination for `AuthInterceptor.onAuthFailure`; the
  /// interceptor already clears the tokens, so this only moves the state and
  /// records that the user is owed an explanation.
  void expire() => _set(const SessionUnauthenticated(expired: true));

  /// Signs out at the user's request. Unlike [expire] this owes no explanation.
  Future<void> signOut() async {
    await ref.read(tokenStoreProvider).clear();

    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.remove(_activeRoleKey);
    await prefs.remove(_developmentRolesKey);

    _set(const SessionUnauthenticated());
  }

  /// **Development only.** Establishes a session with hardcoded roles so the
  /// role shells and the redirect chain can be exercised before M1 ships auth.
  ///
  /// Gated on [AppFlavor.allowsDevelopmentTools] rather than `kDebugMode`: a
  /// release build of the development flavor is what gets demonstrated, so this
  /// has to work there. In the production flavor the call is a no-op, so a
  /// stray invocation cannot mint a session in a store build.
  Future<void> signInAsDevelopmentRole(
    Set<AppRole> roles, {
    AppRole? activeRole,
    AccountStatus status = AccountStatus.active,
    String? restrictionReason,
  }) async {
    if (!AppFlavor.current.allowsDevelopmentTools) return;

    _set(
      SessionActive(
        roles: roles,
        activeRole: activeRole ?? roles.firstOrNull,
        status: status,
        restrictionReason: restrictionReason,
      ),
    );

    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setStringList(
      _developmentRolesKey,
      roles.map((r) => r.wire).toList(),
    );
    final resolved = activeRole ?? roles.firstOrNull;
    if (resolved != null) {
      await prefs.setString(_activeRoleKey, resolved.wire);
    }
  }

  void _set(SessionState next) {
    if (_disposed) return;
    state = next;
  }
}
