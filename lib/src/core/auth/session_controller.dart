import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:jobbridge_app/src/core/auth/app_role.dart';
import 'package:jobbridge_app/src/core/auth/session_state.dart';
import 'package:jobbridge_app/src/core/auth/token_store.dart';
import 'package:jobbridge_app/src/core/config/app_flavor.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/auth_events.dart';
import 'package:jobbridge_app/src/core/storage/preferences_provider.dart';
import 'package:jobbridge_app/src/features/auth/data/auth_repository.dart';
import 'package:jobbridge_app/src/features/auth/domain/auth_session.dart';
import 'package:jobbridge_app/src/features/notifications/data/push_registration.dart';
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
/// Telegram login was the deprecated predecessor. Its client code was removed
/// on 2026-08-19 — see docs/TELEGRAM_LOGIN.md.
///
/// Still a seam: [restore] cannot rebuild a session from a stored refresh token
/// until the refresh call is wired through the repository, so a cold start with
/// valid tokens currently lands on onboarding rather than the shell.
/// [signInAsDevelopmentRole] also stays, gated on the flavor - it is how the
/// redirect chain is exercised without a network or a real bot.
///
/// ## Why this drives push registration rather than being observed by it
///
/// `PushRegistration` is told when a session starts and ends; it does not watch
/// for it. The obvious shape - a listener on this state - is wrong twice.
/// **Ordering**: unregistering a device needs the credentials [signOut] is
/// about to discard, and a listener would only ever see the sign-out
/// afterwards. **Cycles**: this would then be read by a provider it watched,
/// which Riverpod refuses. So the call sites are [_adopt] and [signOut], and
/// both are best-effort - a notification token is never a reason for a sign-in
/// or a sign-out to fail.
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

    // The network layer cannot call this controller directly without closing a
    // provider cycle, so a refused refresh arrives as an event. See AuthEvents.
    final lost = ref
        .read(authEventsProvider)
        .sessionLost
        .listen((_) => expire());
    ref.onDispose(lost.cancel);

    // Deliberately fire-and-forget. Returning SessionUnknown synchronously lets
    // the router hold navigation for one frame instead of the whole tree
    // awaiting a keychain read - and SessionUnknown is precisely the state that
    // prevents the cold-start onboarding flash.
    unawaited(restore());
    return const SessionUnknown();
  }

  /// Re-establishes the session at cold start. Leaves [SessionUnknown] only
  /// once it has an answer.
  ///
  /// **The refresh token is exchanged for a real session, not trusted on its
  /// own.** Its presence says nothing about which roles the account holds or
  /// whether an administrator has blocked it since (BR-10) — guessing
  /// `{candidate}` would put a blocked employer into a working candidate shell.
  /// So the server answers, and the answer includes roles and status.
  ///
  /// Three outcomes, and the middle one is the one worth being careful about:
  ///
  /// - **Refresh succeeds** → straight into the shell, no sign-in.
  /// - **Refresh is refused** (401/403 → [ApiException] with that status) → the
  ///   session is genuinely over. Clear the tokens and show onboarding.
  /// - **Refresh fails to complete** (offline, DNS, a 500) → **keep the
  ///   tokens.** The session is probably fine and the next launch on a network
  ///   will restore it. The user sees onboarding this launch, which is honest:
  ///   the app cannot know their roles, so it cannot show them a shell.
  Future<void> restore() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final storedRole = AppRole.fromWire(prefs.getString(_activeRoleKey));

    final tokens = ref.read(tokenStoreProvider);
    final refreshToken = await tokens.readRefreshToken();

    if (refreshToken != null) {
      try {
        final session = await ref
            .read(authRepositoryProvider)
            .refresh(refreshToken);

        await _adopt(session, fallbackRole: storedRole);
        return;
      } on ApiException catch (e) {
        if (e.statusCode == 401 || e.statusCode == 403) {
          await tokens.clear();
          _set(const SessionUnauthenticated(expired: true));
          return;
        }

        // Could not *complete*, as opposed to refused. The tokens stay — they
        // are probably fine — and the state says so rather than falling
        // through to "signed out", which is what put a signed-in user on the
        // sign-in screen with no way to retry (§12.4).
        _set(
          SessionUnreachable(
            message: e.message,
            offline: e.kind == ApiFailureKind.offline,
          ),
        );
        return;
      }
    }

    final developmentRoles = AppFlavor.current.allowsDevelopmentTools
        ? (prefs.getStringList(_developmentRolesKey) ?? const [])
              .map(AppRole.fromWire)
              .nonNulls
              .toSet()
        : const <AppRole>{};

    _set(
      developmentRoles.isEmpty
          ? const SessionUnauthenticated()
          : SessionActive(roles: developmentRoles, activeRole: storedRole),
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

  /// Takes ownership of a freshly issued session, whichever call produced it.
  ///
  /// Order matters: the tokens are persisted **before** the state moves to
  /// [SessionActive]. The router redirects on that change and the shell it
  /// lands on may fetch immediately, so flipping state ahead of the write would
  /// race the first authenticated request against its own credentials.
  /// [fallbackRole] is used when the server names no active role — the choice
  /// remembered from the last run, honoured only if the account still holds it.
  /// A role revoked while the app was closed must not come back from local
  /// storage.
  Future<void> _adopt(AuthSession session, {AppRole? fallbackRole}) async {
    await ref.read(tokenStoreProvider).save(session.tokens);

    final roles = session.grantedRoles;
    final active =
        session.active ??
        (fallbackRole != null && roles.contains(fallbackRole)
            ? fallbackRole
            : null);

    final prefs = await ref.read(sharedPreferencesProvider.future);
    if (active != null) {
      await prefs.setString(_activeRoleKey, active.wire);
    }

    _set(SessionActive(roles: roles, activeRole: active));

    // Push (§9.2). After the tokens are stored, because registering the device
    // is an authenticated call; and deliberately not awaited, because a
    // notification token is not something a sign-in may fail on — the in-app
    // centre is the record whether or not a push is ever delivered.
    //
    // This runs at every cold start that restores a session too, which is
    // intentional: FCM may have rotated the token while the app was closed and
    // nothing announces that, and the route is idempotent.
    unawaited(ref.read(pushRegistrationProvider.notifier).register());
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

    await _publishActiveRole(role);
  }

  /// Tells the server which role is being acted as, and stores the access token
  /// it returns.
  ///
  /// **Role-scoped endpoints read the role from the token**, so a switch that
  /// stays local produces `role.none_active` — a 403 from every one of them, on
  /// an account that genuinely holds the role. Nothing noticed until the first
  /// such endpoint existed - exactly the kind of gap found in a feature rather
  /// than in auth.
  ///
  /// Best-effort and deliberately non-fatal: the local switch has already
  /// happened and the shell has already moved. A failure here leaves the token
  /// naming the previous role, and the next call that needs it gets a 403 whose
  /// message says so. Blocking the switch on a network round trip would make
  /// changing tabs fail offline.
  ///
  /// Only the access token rotates — [TokenPair] is rebuilt with the existing
  /// refresh token, because this is not a new session and the refresh chain
  /// must not be disturbed.
  Future<void> _publishActiveRole(AppRole role) async {
    final store = ref.read(tokenStoreProvider);

    try {
      final accessToken = await ref
          .read(authRepositoryProvider)
          .switchActiveRole(role);

      final refreshToken = await store.readRefreshToken();
      if (refreshToken == null) return;

      await store.save(
        TokenPair(accessToken: accessToken, refreshToken: refreshToken),
      );
    } on ApiException catch (e) {
      debugPrint('[session] active role not published: ${e.message}');
    }
  }

  /// Submits the roles chosen at the end of registration (§2.3) and adopts the
  /// set the **server** returns.
  ///
  /// Not the set that was sent: an administrator may already have granted
  /// something (§10), and echoing the request back would silently drop it.
  ///
  /// Throws [ApiException] so the screen can keep the user on it and let them
  /// retry. Recording the roles locally on a failed call would move them into a
  /// shell the server does not agree they can use, and every request from it
  /// would 403.
  Future<void> selectRoles(Set<AppRole> roles) async {
    final granted = await ref.read(authRepositoryProvider).selectRoles(roles);

    // Built, not published. Publishing the granted roles is what lets the
    // redirect chain into the shell, so everything the shell needs has to be
    // true *before* the state moves — see below.
    final current = state;
    final next = current is SessionActive
        ? current.copyWith(roles: granted)
        : SessionActive(roles: granted);

    final active = next.effectiveRole;
    if (active == null) {
      // The server granted nothing at all. Publish anyway rather than leaving
      // the screen spinning: the redirect chain sends it straight back here,
      // which is the honest outcome.
      _set(next);
      return;
    }

    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_activeRoleKey, active.wire);

    // The token minted at sign-in names no role, and `/auth/roles` does not
    // reissue it — the backend says so explicitly ("the new roles reach the
    // token on the next refresh or role switch").
    //
    // **Awaited before the state moves, and that ordering is the whole fix for
    // MT-021.** This used to publish the roles first and rotate the token
    // three awaits later, so the router entered the shell while the token
    // still named no role, and the shell's first role-scoped request came back
    // 403 `role.none_active` — rendered as *"No active role is selected.
    // Choose a role first."* on the screen of somebody who had just chosen
    // one. A cold restart healed it, because `restore` reads the role that had
    // been persisted by then, which is what made it look intermittent.
    //
    // [switchRole] deliberately does the opposite and publishes state first.
    // The two are not inconsistent: **registration is already a network
    // operation** and the user is already waiting on `/auth/roles`, so one
    // more round trip costs nothing they can perceive. Changing tabs is not —
    // blocking a role switch on the network would make it fail offline, for a
    // token rotation that is only needed by the next request.
    await _publishActiveRole(active);

    // One transition, with the roles and the active role together. Anything
    // watching the session sees a session that can act, never a half of one.
    _set(next.copyWith(activeRole: active));
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
  ///
  /// Revokes the session server-side first, then clears locally. **The server
  /// call is best-effort and never blocks the sign-out**: a user tapping "sign
  /// out" on a train has to end up signed out, and a device that keeps its
  /// tokens because a request timed out is the worse failure — the session
  /// stays live on the server *and* the app still looks signed in.
  ///
  /// The consequence is a refresh token that stays valid until it expires when
  /// the call does not land. That is the accepted trade; `logout-all` on the
  /// sessions screen (§4.2) is the remedy for a device genuinely out of the
  /// user's hands.
  Future<void> signOut() async {
    final tokens = ref.read(tokenStoreProvider);
    final refreshToken = await tokens.readRefreshToken();

    // Push, first (§9.2). `DELETE /notifications/devices/:token` needs the
    // credentials this method is about to throw away, and revoking the session
    // below may invalidate them too — so this is the one window in which the
    // device can say "not here any more". It is awaited, unlike the
    // registration, because there is no later chance; it swallows its own
    // failures, so awaiting cannot hold up a sign-out.
    //
    // A session that ends any other way — expiry, a refused refresh — cannot
    // reach the endpoint at all, and leaves the row for the next sign-in on
    // this device to move.
    await ref.read(pushRegistrationProvider.notifier).unregister();

    if (refreshToken != null) {
      try {
        await ref.read(authRepositoryProvider).logout(refreshToken);
      } on ApiException {
        // Deliberately swallowed - see above.
      }
    }

    await tokens.clear();

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
