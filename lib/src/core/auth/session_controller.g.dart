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
/// ## What is real here and what is a seam
///
/// The **role model** is real - the granted set, the active choice, the
/// fallback when a role is revoked, and the persistence of the active choice.
/// Those are decided by §2.3 and do not depend on the auth wire format.
///
/// **Acquiring** a session is a seam. The backend's `docs/API_CONTRACTS.md`
/// does not yet specify the auth endpoints, so [restore] cannot exchange a
/// stored refresh token for a profile, and inventing that shape now would mean
/// rewriting it in M1. Until then a session is established by
/// [signInAsDevelopmentRole], which is gated on the flavor.

@ProviderFor(SessionController)
final sessionControllerProvider = SessionControllerProvider._();

/// App-wide session and active-role state.
///
/// Kept alive: the router redirects on it and every shell reads it, so it must
/// survive a screen being disposed.
///
/// ## What is real here and what is a seam
///
/// The **role model** is real - the granted set, the active choice, the
/// fallback when a role is revoked, and the persistence of the active choice.
/// Those are decided by §2.3 and do not depend on the auth wire format.
///
/// **Acquiring** a session is a seam. The backend's `docs/API_CONTRACTS.md`
/// does not yet specify the auth endpoints, so [restore] cannot exchange a
/// stored refresh token for a profile, and inventing that shape now would mean
/// rewriting it in M1. Until then a session is established by
/// [signInAsDevelopmentRole], which is gated on the flavor.
final class SessionControllerProvider
    extends $NotifierProvider<SessionController, SessionState> {
  /// App-wide session and active-role state.
  ///
  /// Kept alive: the router redirects on it and every shell reads it, so it must
  /// survive a screen being disposed.
  ///
  /// ## What is real here and what is a seam
  ///
  /// The **role model** is real - the granted set, the active choice, the
  /// fallback when a role is revoked, and the persistence of the active choice.
  /// Those are decided by §2.3 and do not depend on the auth wire format.
  ///
  /// **Acquiring** a session is a seam. The backend's `docs/API_CONTRACTS.md`
  /// does not yet specify the auth endpoints, so [restore] cannot exchange a
  /// stored refresh token for a profile, and inventing that shape now would mean
  /// rewriting it in M1. Until then a session is established by
  /// [signInAsDevelopmentRole], which is gated on the flavor.
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

String _$sessionControllerHash() => r'4ae562ca6042775db2d7bf00b101c9dd5a236f86';

/// App-wide session and active-role state.
///
/// Kept alive: the router redirects on it and every shell reads it, so it must
/// survive a screen being disposed.
///
/// ## What is real here and what is a seam
///
/// The **role model** is real - the granted set, the active choice, the
/// fallback when a role is revoked, and the persistence of the active choice.
/// Those are decided by §2.3 and do not depend on the auth wire format.
///
/// **Acquiring** a session is a seam. The backend's `docs/API_CONTRACTS.md`
/// does not yet specify the auth endpoints, so [restore] cannot exchange a
/// stored refresh token for a profile, and inventing that shape now would mean
/// rewriting it in M1. Until then a session is established by
/// [signInAsDevelopmentRole], which is gated on the flavor.

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
