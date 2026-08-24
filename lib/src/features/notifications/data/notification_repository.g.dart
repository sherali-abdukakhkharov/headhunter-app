// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationRepository)
final notificationRepositoryProvider = NotificationRepositoryProvider._();

final class NotificationRepositoryProvider
    extends
        $FunctionalProvider<
          NotificationRepository,
          NotificationRepository,
          NotificationRepository
        >
    with $Provider<NotificationRepository> {
  NotificationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotificationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationRepository create(Ref ref) {
    return notificationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationRepository>(value),
    );
  }
}

String _$notificationRepositoryHash() =>
    r'91a87c2d6d8991d74ac3a3e52628138398130ecc';

/// §9.2's list, newest first.
///
/// Keyed by [unreadOnly] so switching the filter is a different question
/// rather than a refetch of the same one — and switching back costs nothing.

@ProviderFor(Notifications)
final notificationsProvider = NotificationsFamily._();

/// §9.2's list, newest first.
///
/// Keyed by [unreadOnly] so switching the filter is a different question
/// rather than a refetch of the same one — and switching back costs nothing.
final class NotificationsProvider
    extends $AsyncNotifierProvider<Notifications, NotificationPage> {
  /// §9.2's list, newest first.
  ///
  /// Keyed by [unreadOnly] so switching the filter is a different question
  /// rather than a refetch of the same one — and switching back costs nothing.
  NotificationsProvider._({
    required NotificationsFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'notificationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$notificationsHash();

  @override
  String toString() {
    return r'notificationsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Notifications create() => Notifications();

  @override
  bool operator ==(Object other) {
    return other is NotificationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$notificationsHash() => r'd5c74461fdaa251be2b07bb4f23730c2fa222ea7';

/// §9.2's list, newest first.
///
/// Keyed by [unreadOnly] so switching the filter is a different question
/// rather than a refetch of the same one — and switching back costs nothing.

final class NotificationsFamily extends $Family
    with
        $ClassFamilyOverride<
          Notifications,
          AsyncValue<NotificationPage>,
          NotificationPage,
          FutureOr<NotificationPage>,
          bool
        > {
  NotificationsFamily._()
    : super(
        retry: null,
        name: r'notificationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// §9.2's list, newest first.
  ///
  /// Keyed by [unreadOnly] so switching the filter is a different question
  /// rather than a refetch of the same one — and switching back costs nothing.

  NotificationsProvider call({bool unreadOnly = false}) =>
      NotificationsProvider._(argument: unreadOnly, from: this);

  @override
  String toString() => r'notificationsProvider';
}

/// §9.2's list, newest first.
///
/// Keyed by [unreadOnly] so switching the filter is a different question
/// rather than a refetch of the same one — and switching back costs nothing.

abstract class _$Notifications extends $AsyncNotifier<NotificationPage> {
  late final _$args = ref.$arg as bool;
  bool get unreadOnly => _$args;

  FutureOr<NotificationPage> build({bool unreadOnly = false});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<NotificationPage>, NotificationPage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<NotificationPage>, NotificationPage>,
              AsyncValue<NotificationPage>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(unreadOnly: _$args));
  }
}

/// The badge (§9.2).
///
/// Deliberately its own provider rather than a count over the list: the list
/// is one page and the count is all of them, so counting the page would
/// under-report the moment there are more than twenty.

@ProviderFor(unreadNotificationCount)
final unreadNotificationCountProvider = UnreadNotificationCountProvider._();

/// The badge (§9.2).
///
/// Deliberately its own provider rather than a count over the list: the list
/// is one page and the count is all of them, so counting the page would
/// under-report the moment there are more than twenty.

final class UnreadNotificationCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// The badge (§9.2).
  ///
  /// Deliberately its own provider rather than a count over the list: the list
  /// is one page and the count is all of them, so counting the page would
  /// under-report the moment there are more than twenty.
  UnreadNotificationCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadNotificationCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadNotificationCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return unreadNotificationCount(ref);
  }
}

String _$unreadNotificationCountHash() =>
    r'773d5a7205f4c630a112a6faa79515fffb48d9f4';

/// §9.2's five per-category switches.

@ProviderFor(NotificationPreferences)
final notificationPreferencesProvider = NotificationPreferencesProvider._();

/// §9.2's five per-category switches.
final class NotificationPreferencesProvider
    extends
        $AsyncNotifierProvider<
          NotificationPreferences,
          List<NotificationPreference>
        > {
  /// §9.2's five per-category switches.
  NotificationPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPreferencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPreferencesHash();

  @$internal
  @override
  NotificationPreferences create() => NotificationPreferences();
}

String _$notificationPreferencesHash() =>
    r'a82286a107fbf9e6d3f409f0ac19666b386b833b';

/// §9.2's five per-category switches.

abstract class _$NotificationPreferences
    extends $AsyncNotifier<List<NotificationPreference>> {
  FutureOr<List<NotificationPreference>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<NotificationPreference>>,
              List<NotificationPreference>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<NotificationPreference>>,
                List<NotificationPreference>
              >,
              AsyncValue<List<NotificationPreference>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
