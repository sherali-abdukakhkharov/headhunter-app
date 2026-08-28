// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_primer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the in-app explanation has been shown on this install.
///
/// ## Why the system dialog is not the first thing a new user sees
///
/// Registration used to open with `requestPermission()`, so Android's dialog
/// appeared the instant a code was verified — **before a new user had even
/// chosen a role**. The 1.29.0 audit's designer note is exact about what is
/// wrong with that: the interruption has no rationale a user can see, it is
/// worded by the OS in whatever language the *phone* is set to rather than the
/// one they just picked, and Android asks **once**. A "no" given to a question
/// nobody explained is a permanent no, repairable only in system settings.
///
/// So the app explains first, in its own four languages, and asks only when
/// somebody says yes. Declining here costs nothing: the device is registered
/// either way (§9.2's in-app centre is the record), and the settings sheet
/// offers the same button afterwards.
///
/// ## Stored locally, and that is the right scope
///
/// This is a fact about *this install* — whether this phone has been asked —
/// not about the account. Putting it on the account would mean a second device
/// never sees the explanation, and it is that device's permission that is being
/// asked for.

@ProviderFor(NotificationPrimer)
final notificationPrimerProvider = NotificationPrimerProvider._();

/// Whether the in-app explanation has been shown on this install.
///
/// ## Why the system dialog is not the first thing a new user sees
///
/// Registration used to open with `requestPermission()`, so Android's dialog
/// appeared the instant a code was verified — **before a new user had even
/// chosen a role**. The 1.29.0 audit's designer note is exact about what is
/// wrong with that: the interruption has no rationale a user can see, it is
/// worded by the OS in whatever language the *phone* is set to rather than the
/// one they just picked, and Android asks **once**. A "no" given to a question
/// nobody explained is a permanent no, repairable only in system settings.
///
/// So the app explains first, in its own four languages, and asks only when
/// somebody says yes. Declining here costs nothing: the device is registered
/// either way (§9.2's in-app centre is the record), and the settings sheet
/// offers the same button afterwards.
///
/// ## Stored locally, and that is the right scope
///
/// This is a fact about *this install* — whether this phone has been asked —
/// not about the account. Putting it on the account would mean a second device
/// never sees the explanation, and it is that device's permission that is being
/// asked for.
final class NotificationPrimerProvider
    extends $AsyncNotifierProvider<NotificationPrimer, bool> {
  /// Whether the in-app explanation has been shown on this install.
  ///
  /// ## Why the system dialog is not the first thing a new user sees
  ///
  /// Registration used to open with `requestPermission()`, so Android's dialog
  /// appeared the instant a code was verified — **before a new user had even
  /// chosen a role**. The 1.29.0 audit's designer note is exact about what is
  /// wrong with that: the interruption has no rationale a user can see, it is
  /// worded by the OS in whatever language the *phone* is set to rather than the
  /// one they just picked, and Android asks **once**. A "no" given to a question
  /// nobody explained is a permanent no, repairable only in system settings.
  ///
  /// So the app explains first, in its own four languages, and asks only when
  /// somebody says yes. Declining here costs nothing: the device is registered
  /// either way (§9.2's in-app centre is the record), and the settings sheet
  /// offers the same button afterwards.
  ///
  /// ## Stored locally, and that is the right scope
  ///
  /// This is a fact about *this install* — whether this phone has been asked —
  /// not about the account. Putting it on the account would mean a second device
  /// never sees the explanation, and it is that device's permission that is being
  /// asked for.
  NotificationPrimerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPrimerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPrimerHash();

  @$internal
  @override
  NotificationPrimer create() => NotificationPrimer();
}

String _$notificationPrimerHash() =>
    r'13c2118ceef4733901178184693ce8cc529ebd3f';

/// Whether the in-app explanation has been shown on this install.
///
/// ## Why the system dialog is not the first thing a new user sees
///
/// Registration used to open with `requestPermission()`, so Android's dialog
/// appeared the instant a code was verified — **before a new user had even
/// chosen a role**. The 1.29.0 audit's designer note is exact about what is
/// wrong with that: the interruption has no rationale a user can see, it is
/// worded by the OS in whatever language the *phone* is set to rather than the
/// one they just picked, and Android asks **once**. A "no" given to a question
/// nobody explained is a permanent no, repairable only in system settings.
///
/// So the app explains first, in its own four languages, and asks only when
/// somebody says yes. Declining here costs nothing: the device is registered
/// either way (§9.2's in-app centre is the record), and the settings sheet
/// offers the same button afterwards.
///
/// ## Stored locally, and that is the right scope
///
/// This is a fact about *this install* — whether this phone has been asked —
/// not about the account. Putting it on the account would mean a second device
/// never sees the explanation, and it is that device's permission that is being
/// asked for.

abstract class _$NotificationPrimer extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
