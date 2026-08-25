// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(SessionController)
final sessionControllerProvider = SessionControllerProvider._();

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
final class SessionControllerProvider
    extends $NotifierProvider<SessionController, SessionState> {
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
  SessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionControllerHash();

  @$internal
  @override
  SessionController create() => SessionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionState>(value),
    );
  }
}

String _$sessionControllerHash() => r'd1928fab0968a580b3e19ef0d5ac0117ba38c813';

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

abstract class _$SessionController extends $Notifier<SessionState> {
  SessionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SessionState, SessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SessionState, SessionState>,
              SessionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
