// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_registration.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Which device token the server currently knows about, or null.
///
/// ## The session drives this, and not the other way round
///
/// `SessionController` calls [register] once a session is adopted and
/// [unregister] before it clears the tokens. It reads like an inversion — a
/// listener on the session state would be the obvious shape — and there are
/// two reasons it is not one:
///
/// - **Ordering.** `DELETE /notifications/devices/:token` needs the access
///   token that is about to be thrown away. A listener would observe the
///   sign-out *after* the credentials were gone and get a 401 every time.
/// - **Cycles.** `SessionController` would then read this while this watched
///   `SessionController`, which Riverpod refuses outright.
///
/// So this provider knows nothing about sessions. It is told.
///
/// ## Nothing here is allowed to fail loudly
///
/// Every path swallows its failure and logs. A device that cannot register is
/// a device that does not receive push, and §9.2's in-app centre is the record
/// either way — a sign-in that failed because a notification token could not be
/// stored would be trading the product for a copy of it.

@ProviderFor(PushRegistration)
final pushRegistrationProvider = PushRegistrationProvider._();

/// Which device token the server currently knows about, or null.
///
/// ## The session drives this, and not the other way round
///
/// `SessionController` calls [register] once a session is adopted and
/// [unregister] before it clears the tokens. It reads like an inversion — a
/// listener on the session state would be the obvious shape — and there are
/// two reasons it is not one:
///
/// - **Ordering.** `DELETE /notifications/devices/:token` needs the access
///   token that is about to be thrown away. A listener would observe the
///   sign-out *after* the credentials were gone and get a 401 every time.
/// - **Cycles.** `SessionController` would then read this while this watched
///   `SessionController`, which Riverpod refuses outright.
///
/// So this provider knows nothing about sessions. It is told.
///
/// ## Nothing here is allowed to fail loudly
///
/// Every path swallows its failure and logs. A device that cannot register is
/// a device that does not receive push, and §9.2's in-app centre is the record
/// either way — a sign-in that failed because a notification token could not be
/// stored would be trading the product for a copy of it.
final class PushRegistrationProvider
    extends $NotifierProvider<PushRegistration, String?> {
  /// Which device token the server currently knows about, or null.
  ///
  /// ## The session drives this, and not the other way round
  ///
  /// `SessionController` calls [register] once a session is adopted and
  /// [unregister] before it clears the tokens. It reads like an inversion — a
  /// listener on the session state would be the obvious shape — and there are
  /// two reasons it is not one:
  ///
  /// - **Ordering.** `DELETE /notifications/devices/:token` needs the access
  ///   token that is about to be thrown away. A listener would observe the
  ///   sign-out *after* the credentials were gone and get a 401 every time.
  /// - **Cycles.** `SessionController` would then read this while this watched
  ///   `SessionController`, which Riverpod refuses outright.
  ///
  /// So this provider knows nothing about sessions. It is told.
  ///
  /// ## Nothing here is allowed to fail loudly
  ///
  /// Every path swallows its failure and logs. A device that cannot register is
  /// a device that does not receive push, and §9.2's in-app centre is the record
  /// either way — a sign-in that failed because a notification token could not be
  /// stored would be trading the product for a copy of it.
  PushRegistrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushRegistrationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushRegistrationHash();

  @$internal
  @override
  PushRegistration create() => PushRegistration();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$pushRegistrationHash() => r'adef400b8b72e5eec9560792892e6733e33ce28d';

/// Which device token the server currently knows about, or null.
///
/// ## The session drives this, and not the other way round
///
/// `SessionController` calls [register] once a session is adopted and
/// [unregister] before it clears the tokens. It reads like an inversion — a
/// listener on the session state would be the obvious shape — and there are
/// two reasons it is not one:
///
/// - **Ordering.** `DELETE /notifications/devices/:token` needs the access
///   token that is about to be thrown away. A listener would observe the
///   sign-out *after* the credentials were gone and get a 401 every time.
/// - **Cycles.** `SessionController` would then read this while this watched
///   `SessionController`, which Riverpod refuses outright.
///
/// So this provider knows nothing about sessions. It is told.
///
/// ## Nothing here is allowed to fail loudly
///
/// Every path swallows its failure and logs. A device that cannot register is
/// a device that does not receive push, and §9.2's in-app centre is the record
/// either way — a sign-in that failed because a notification token could not be
/// stored would be trading the product for a copy of it.

abstract class _$PushRegistration extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
