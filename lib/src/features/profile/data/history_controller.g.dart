// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Work experience records for the section at [path] (§5.1).
///
/// Keyed on the path rather than on nothing, because the schema publishes it —
/// see [HistoryRepository]. Two sections could not collide today, but a
/// provider keyed on the thing it fetches is the shape that stays correct if a
/// third arrives.
///
/// ## Invalidations, per the standing rule
///
/// Every mutation here refreshes **two** things:
///
/// 1. This list, because the server owns the ids and the ordering.
/// 2. The profile, because completeness is computed server-side (§5.3) and a
///    new work record can change it — so the ring is stale the instant a record
///    is added.
///
/// The second one is [ProfileEditor.refreshProfile] and **not**
/// `ref.invalidate(profileEditorProvider)`. Invalidating would refetch the
/// schema as well and, worse, discard whatever the user has typed into the main
/// form and not yet saved: adding a job would silently eat a half-filled name.

@ProviderFor(ExperienceList)
final experienceListProvider = ExperienceListFamily._();

/// Work experience records for the section at [path] (§5.1).
///
/// Keyed on the path rather than on nothing, because the schema publishes it —
/// see [HistoryRepository]. Two sections could not collide today, but a
/// provider keyed on the thing it fetches is the shape that stays correct if a
/// third arrives.
///
/// ## Invalidations, per the standing rule
///
/// Every mutation here refreshes **two** things:
///
/// 1. This list, because the server owns the ids and the ordering.
/// 2. The profile, because completeness is computed server-side (§5.3) and a
///    new work record can change it — so the ring is stale the instant a record
///    is added.
///
/// The second one is [ProfileEditor.refreshProfile] and **not**
/// `ref.invalidate(profileEditorProvider)`. Invalidating would refetch the
/// schema as well and, worse, discard whatever the user has typed into the main
/// form and not yet saved: adding a job would silently eat a half-filled name.
final class ExperienceListProvider
    extends $AsyncNotifierProvider<ExperienceList, List<ExperienceRecord>> {
  /// Work experience records for the section at [path] (§5.1).
  ///
  /// Keyed on the path rather than on nothing, because the schema publishes it —
  /// see [HistoryRepository]. Two sections could not collide today, but a
  /// provider keyed on the thing it fetches is the shape that stays correct if a
  /// third arrives.
  ///
  /// ## Invalidations, per the standing rule
  ///
  /// Every mutation here refreshes **two** things:
  ///
  /// 1. This list, because the server owns the ids and the ordering.
  /// 2. The profile, because completeness is computed server-side (§5.3) and a
  ///    new work record can change it — so the ring is stale the instant a record
  ///    is added.
  ///
  /// The second one is [ProfileEditor.refreshProfile] and **not**
  /// `ref.invalidate(profileEditorProvider)`. Invalidating would refetch the
  /// schema as well and, worse, discard whatever the user has typed into the main
  /// form and not yet saved: adding a job would silently eat a half-filled name.
  ExperienceListProvider._({
    required ExperienceListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'experienceListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$experienceListHash();

  @override
  String toString() {
    return r'experienceListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ExperienceList create() => ExperienceList();

  @override
  bool operator ==(Object other) {
    return other is ExperienceListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$experienceListHash() => r'ec675f3a25cee145d92c5dca257d8b43a5a28eab';

/// Work experience records for the section at [path] (§5.1).
///
/// Keyed on the path rather than on nothing, because the schema publishes it —
/// see [HistoryRepository]. Two sections could not collide today, but a
/// provider keyed on the thing it fetches is the shape that stays correct if a
/// third arrives.
///
/// ## Invalidations, per the standing rule
///
/// Every mutation here refreshes **two** things:
///
/// 1. This list, because the server owns the ids and the ordering.
/// 2. The profile, because completeness is computed server-side (§5.3) and a
///    new work record can change it — so the ring is stale the instant a record
///    is added.
///
/// The second one is [ProfileEditor.refreshProfile] and **not**
/// `ref.invalidate(profileEditorProvider)`. Invalidating would refetch the
/// schema as well and, worse, discard whatever the user has typed into the main
/// form and not yet saved: adding a job would silently eat a half-filled name.

final class ExperienceListFamily extends $Family
    with
        $ClassFamilyOverride<
          ExperienceList,
          AsyncValue<List<ExperienceRecord>>,
          List<ExperienceRecord>,
          FutureOr<List<ExperienceRecord>>,
          String
        > {
  ExperienceListFamily._()
    : super(
        retry: null,
        name: r'experienceListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Work experience records for the section at [path] (§5.1).
  ///
  /// Keyed on the path rather than on nothing, because the schema publishes it —
  /// see [HistoryRepository]. Two sections could not collide today, but a
  /// provider keyed on the thing it fetches is the shape that stays correct if a
  /// third arrives.
  ///
  /// ## Invalidations, per the standing rule
  ///
  /// Every mutation here refreshes **two** things:
  ///
  /// 1. This list, because the server owns the ids and the ordering.
  /// 2. The profile, because completeness is computed server-side (§5.3) and a
  ///    new work record can change it — so the ring is stale the instant a record
  ///    is added.
  ///
  /// The second one is [ProfileEditor.refreshProfile] and **not**
  /// `ref.invalidate(profileEditorProvider)`. Invalidating would refetch the
  /// schema as well and, worse, discard whatever the user has typed into the main
  /// form and not yet saved: adding a job would silently eat a half-filled name.

  ExperienceListProvider call(String path) =>
      ExperienceListProvider._(argument: path, from: this);

  @override
  String toString() => r'experienceListProvider';
}

/// Work experience records for the section at [path] (§5.1).
///
/// Keyed on the path rather than on nothing, because the schema publishes it —
/// see [HistoryRepository]. Two sections could not collide today, but a
/// provider keyed on the thing it fetches is the shape that stays correct if a
/// third arrives.
///
/// ## Invalidations, per the standing rule
///
/// Every mutation here refreshes **two** things:
///
/// 1. This list, because the server owns the ids and the ordering.
/// 2. The profile, because completeness is computed server-side (§5.3) and a
///    new work record can change it — so the ring is stale the instant a record
///    is added.
///
/// The second one is [ProfileEditor.refreshProfile] and **not**
/// `ref.invalidate(profileEditorProvider)`. Invalidating would refetch the
/// schema as well and, worse, discard whatever the user has typed into the main
/// form and not yet saved: adding a job would silently eat a half-filled name.

abstract class _$ExperienceList extends $AsyncNotifier<List<ExperienceRecord>> {
  late final _$args = ref.$arg as String;
  String get path => _$args;

  FutureOr<List<ExperienceRecord>> build(String path);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<ExperienceRecord>>, List<ExperienceRecord>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ExperienceRecord>>,
                List<ExperienceRecord>
              >,
              AsyncValue<List<ExperienceRecord>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Education records for the section at [path] (§5.1).
///
/// Same two invalidations as [ExperienceList], for the same reasons.

@ProviderFor(EducationList)
final educationListProvider = EducationListFamily._();

/// Education records for the section at [path] (§5.1).
///
/// Same two invalidations as [ExperienceList], for the same reasons.
final class EducationListProvider
    extends $AsyncNotifierProvider<EducationList, List<EducationRecord>> {
  /// Education records for the section at [path] (§5.1).
  ///
  /// Same two invalidations as [ExperienceList], for the same reasons.
  EducationListProvider._({
    required EducationListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'educationListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$educationListHash();

  @override
  String toString() {
    return r'educationListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EducationList create() => EducationList();

  @override
  bool operator ==(Object other) {
    return other is EducationListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$educationListHash() => r'e406f0051ba0619ee64331c684f58b73634ed7e8';

/// Education records for the section at [path] (§5.1).
///
/// Same two invalidations as [ExperienceList], for the same reasons.

final class EducationListFamily extends $Family
    with
        $ClassFamilyOverride<
          EducationList,
          AsyncValue<List<EducationRecord>>,
          List<EducationRecord>,
          FutureOr<List<EducationRecord>>,
          String
        > {
  EducationListFamily._()
    : super(
        retry: null,
        name: r'educationListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Education records for the section at [path] (§5.1).
  ///
  /// Same two invalidations as [ExperienceList], for the same reasons.

  EducationListProvider call(String path) =>
      EducationListProvider._(argument: path, from: this);

  @override
  String toString() => r'educationListProvider';
}

/// Education records for the section at [path] (§5.1).
///
/// Same two invalidations as [ExperienceList], for the same reasons.

abstract class _$EducationList extends $AsyncNotifier<List<EducationRecord>> {
  late final _$args = ref.$arg as String;
  String get path => _$args;

  FutureOr<List<EducationRecord>> build(String path);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<EducationRecord>>, List<EducationRecord>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<EducationRecord>>,
                List<EducationRecord>
              >,
              AsyncValue<List<EducationRecord>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
