// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminRepository)
final adminRepositoryProvider = AdminRepositoryProvider._();

final class AdminRepositoryProvider
    extends
        $FunctionalProvider<AdminRepository, AdminRepository, AdminRepository>
    with $Provider<AdminRepository> {
  AdminRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdminRepository create(Ref ref) {
    return adminRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminRepository>(value),
    );
  }
}

String _$adminRepositoryHash() => r'e369349b36a30b5bfe413df6ec69f6dad14f8c00';

/// The period the §10.1 dashboard is showing, or null for the server's default.
///
/// A provider of its own rather than a field on the dashboard notifier, so that
/// refreshing the figures keeps the period. Folding the two together would make
/// a pull-to-refresh silently reset the range an administrator had chosen —
/// same numbers, different question, and nothing on screen to say so.

@ProviderFor(DashboardRangeController)
final dashboardRangeControllerProvider = DashboardRangeControllerProvider._();

/// The period the §10.1 dashboard is showing, or null for the server's default.
///
/// A provider of its own rather than a field on the dashboard notifier, so that
/// refreshing the figures keeps the period. Folding the two together would make
/// a pull-to-refresh silently reset the range an administrator had chosen —
/// same numbers, different question, and nothing on screen to say so.
final class DashboardRangeControllerProvider
    extends $NotifierProvider<DashboardRangeController, DashboardRange?> {
  /// The period the §10.1 dashboard is showing, or null for the server's default.
  ///
  /// A provider of its own rather than a field on the dashboard notifier, so that
  /// refreshing the figures keeps the period. Folding the two together would make
  /// a pull-to-refresh silently reset the range an administrator had chosen —
  /// same numbers, different question, and nothing on screen to say so.
  DashboardRangeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardRangeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardRangeControllerHash();

  @$internal
  @override
  DashboardRangeController create() => DashboardRangeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardRange? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardRange?>(value),
    );
  }
}

String _$dashboardRangeControllerHash() =>
    r'ffea0c834677b387cbec697a2e2cc859de99cdd3';

/// The period the §10.1 dashboard is showing, or null for the server's default.
///
/// A provider of its own rather than a field on the dashboard notifier, so that
/// refreshing the figures keeps the period. Folding the two together would make
/// a pull-to-refresh silently reset the range an administrator had chosen —
/// same numbers, different question, and nothing on screen to say so.

abstract class _$DashboardRangeController extends $Notifier<DashboardRange?> {
  DashboardRange? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DashboardRange?, DashboardRange?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DashboardRange?, DashboardRange?>,
              DashboardRange?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// §10.1's counters for the selected period.

@ProviderFor(adminDashboard)
final adminDashboardProvider = AdminDashboardProvider._();

/// §10.1's counters for the selected period.

final class AdminDashboardProvider
    extends
        $FunctionalProvider<
          AsyncValue<AdminDashboard>,
          AdminDashboard,
          FutureOr<AdminDashboard>
        >
    with $FutureModifier<AdminDashboard>, $FutureProvider<AdminDashboard> {
  /// §10.1's counters for the selected period.
  AdminDashboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminDashboardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminDashboardHash();

  @$internal
  @override
  $FutureProviderElement<AdminDashboard> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AdminDashboard> create(Ref ref) {
    return adminDashboard(ref);
  }
}

String _$adminDashboardHash() => r'5c11edb05ad9248cc6955cea9dadb11e78c71683';

/// §10.2's verification queue, oldest first.

@ProviderFor(VerificationQueue)
final verificationQueueProvider = VerificationQueueProvider._();

/// §10.2's verification queue, oldest first.
final class VerificationQueueProvider
    extends $AsyncNotifierProvider<VerificationQueue, VerificationQueuePage> {
  /// §10.2's verification queue, oldest first.
  VerificationQueueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verificationQueueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verificationQueueHash();

  @$internal
  @override
  VerificationQueue create() => VerificationQueue();
}

String _$verificationQueueHash() => r'8a6ae86b3751a977392fc43046a38682930ca983';

/// §10.2's verification queue, oldest first.

abstract class _$VerificationQueue
    extends $AsyncNotifier<VerificationQueuePage> {
  FutureOr<VerificationQueuePage> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<VerificationQueuePage>, VerificationQueuePage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<VerificationQueuePage>,
                VerificationQueuePage
              >,
              AsyncValue<VerificationQueuePage>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
