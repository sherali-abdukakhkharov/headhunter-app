// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employer_applications_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(employerApplicationsRepository)
final employerApplicationsRepositoryProvider =
    EmployerApplicationsRepositoryProvider._();

final class EmployerApplicationsRepositoryProvider
    extends
        $FunctionalProvider<
          EmployerApplicationsRepository,
          EmployerApplicationsRepository,
          EmployerApplicationsRepository
        >
    with $Provider<EmployerApplicationsRepository> {
  EmployerApplicationsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'employerApplicationsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$employerApplicationsRepositoryHash();

  @$internal
  @override
  $ProviderElement<EmployerApplicationsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EmployerApplicationsRepository create(Ref ref) {
    return employerApplicationsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmployerApplicationsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmployerApplicationsRepository>(
        value,
      ),
    );
  }
}

String _$employerApplicationsRepositoryHash() =>
    r'f87ed6faa12917788689b43cc832728ac9cd2909';

/// Applications on one vacancy, optionally narrowed server-side (§6.5).
///
/// `status` is a named argument rather than a second positional one so the
/// existing `vacancyApplicationsProvider(id)` call sites keep meaning "all of
/// them" — which is what they meant before the filter existed.

@ProviderFor(vacancyApplications)
final vacancyApplicationsProvider = VacancyApplicationsFamily._();

/// Applications on one vacancy, optionally narrowed server-side (§6.5).
///
/// `status` is a named argument rather than a second positional one so the
/// existing `vacancyApplicationsProvider(id)` call sites keep meaning "all of
/// them" — which is what they meant before the filter existed.

final class VacancyApplicationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Application>>,
          List<Application>,
          FutureOr<List<Application>>
        >
    with
        $FutureModifier<List<Application>>,
        $FutureProvider<List<Application>> {
  /// Applications on one vacancy, optionally narrowed server-side (§6.5).
  ///
  /// `status` is a named argument rather than a second positional one so the
  /// existing `vacancyApplicationsProvider(id)` call sites keep meaning "all of
  /// them" — which is what they meant before the filter existed.
  VacancyApplicationsProvider._({
    required VacancyApplicationsFamily super.from,
    required (String, {String? status}) super.argument,
  }) : super(
         retry: null,
         name: r'vacancyApplicationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vacancyApplicationsHash();

  @override
  String toString() {
    return r'vacancyApplicationsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Application>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Application>> create(Ref ref) {
    final argument = this.argument as (String, {String? status});
    return vacancyApplications(ref, argument.$1, status: argument.status);
  }

  @override
  bool operator ==(Object other) {
    return other is VacancyApplicationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vacancyApplicationsHash() =>
    r'2b985f689c27f948637726dcc7825b58eef1745a';

/// Applications on one vacancy, optionally narrowed server-side (§6.5).
///
/// `status` is a named argument rather than a second positional one so the
/// existing `vacancyApplicationsProvider(id)` call sites keep meaning "all of
/// them" — which is what they meant before the filter existed.

final class VacancyApplicationsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Application>>,
          (String, {String? status})
        > {
  VacancyApplicationsFamily._()
    : super(
        retry: null,
        name: r'vacancyApplicationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Applications on one vacancy, optionally narrowed server-side (§6.5).
  ///
  /// `status` is a named argument rather than a second positional one so the
  /// existing `vacancyApplicationsProvider(id)` call sites keep meaning "all of
  /// them" — which is what they meant before the filter existed.

  VacancyApplicationsProvider call(String vacancyId, {String? status}) =>
      VacancyApplicationsProvider._(
        argument: (vacancyId, status: status),
        from: this,
      );

  @override
  String toString() => r'vacancyApplicationsProvider';
}

/// The employer's own private notes on one application (§7.3).
///
/// Private to the employer: the candidate never sees these, which is why the
/// screen says so beside the field. A note is the one thing on the applicants
/// screen written *by* the employer rather than read from the candidate.

@ProviderFor(applicationNotes)
final applicationNotesProvider = ApplicationNotesFamily._();

/// The employer's own private notes on one application (§7.3).
///
/// Private to the employer: the candidate never sees these, which is why the
/// screen says so beside the field. A note is the one thing on the applicants
/// screen written *by* the employer rather than read from the candidate.

final class ApplicationNotesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ApplicationNote>>,
          List<ApplicationNote>,
          FutureOr<List<ApplicationNote>>
        >
    with
        $FutureModifier<List<ApplicationNote>>,
        $FutureProvider<List<ApplicationNote>> {
  /// The employer's own private notes on one application (§7.3).
  ///
  /// Private to the employer: the candidate never sees these, which is why the
  /// screen says so beside the field. A note is the one thing on the applicants
  /// screen written *by* the employer rather than read from the candidate.
  ApplicationNotesProvider._({
    required ApplicationNotesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'applicationNotesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$applicationNotesHash();

  @override
  String toString() {
    return r'applicationNotesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ApplicationNote>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ApplicationNote>> create(Ref ref) {
    final argument = this.argument as String;
    return applicationNotes(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ApplicationNotesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$applicationNotesHash() => r'3fe7c1616e8d8fc1642c9291c9e87b1d65db6b18';

/// The employer's own private notes on one application (§7.3).
///
/// Private to the employer: the candidate never sees these, which is why the
/// screen says so beside the field. A note is the one thing on the applicants
/// screen written *by* the employer rather than read from the candidate.

final class ApplicationNotesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ApplicationNote>>, String> {
  ApplicationNotesFamily._()
    : super(
        retry: null,
        name: r'applicationNotesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The employer's own private notes on one application (§7.3).
  ///
  /// Private to the employer: the candidate never sees these, which is why the
  /// screen says so beside the field. A note is the one thing on the applicants
  /// screen written *by* the employer rather than read from the candidate.

  ApplicationNotesProvider call(String applicationId) =>
      ApplicationNotesProvider._(argument: applicationId, from: this);

  @override
  String toString() => r'applicationNotesProvider';
}

/// §6.5's counts for one vacancy.

@ProviderFor(vacancyApplicationCounts)
final vacancyApplicationCountsProvider = VacancyApplicationCountsFamily._();

/// §6.5's counts for one vacancy.

final class VacancyApplicationCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ApplicationCounts>,
          ApplicationCounts,
          FutureOr<ApplicationCounts>
        >
    with
        $FutureModifier<ApplicationCounts>,
        $FutureProvider<ApplicationCounts> {
  /// §6.5's counts for one vacancy.
  VacancyApplicationCountsProvider._({
    required VacancyApplicationCountsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'vacancyApplicationCountsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vacancyApplicationCountsHash();

  @override
  String toString() {
    return r'vacancyApplicationCountsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ApplicationCounts> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ApplicationCounts> create(Ref ref) {
    final argument = this.argument as String;
    return vacancyApplicationCounts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is VacancyApplicationCountsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vacancyApplicationCountsHash() =>
    r'80ecc24857473817314c5e19018870882ca8151f';

/// §6.5's counts for one vacancy.

final class VacancyApplicationCountsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ApplicationCounts>, String> {
  VacancyApplicationCountsFamily._()
    : super(
        retry: null,
        name: r'vacancyApplicationCountsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// §6.5's counts for one vacancy.

  VacancyApplicationCountsProvider call(String vacancyId) =>
      VacancyApplicationCountsProvider._(argument: vacancyId, from: this);

  @override
  String toString() => r'vacancyApplicationCountsProvider';
}

/// One candidate, as BR-09 permits this employer to see them.

@ProviderFor(applicationCandidate)
final applicationCandidateProvider = ApplicationCandidateFamily._();

/// One candidate, as BR-09 permits this employer to see them.

final class ApplicationCandidateProvider
    extends
        $FunctionalProvider<
          AsyncValue<CandidateForEmployer>,
          CandidateForEmployer,
          FutureOr<CandidateForEmployer>
        >
    with
        $FutureModifier<CandidateForEmployer>,
        $FutureProvider<CandidateForEmployer> {
  /// One candidate, as BR-09 permits this employer to see them.
  ApplicationCandidateProvider._({
    required ApplicationCandidateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'applicationCandidateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$applicationCandidateHash();

  @override
  String toString() {
    return r'applicationCandidateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CandidateForEmployer> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CandidateForEmployer> create(Ref ref) {
    final argument = this.argument as String;
    return applicationCandidate(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ApplicationCandidateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$applicationCandidateHash() =>
    r'f04408c9c2a432c18a16610c2326a711b68d7092';

/// One candidate, as BR-09 permits this employer to see them.

final class ApplicationCandidateFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CandidateForEmployer>, String> {
  ApplicationCandidateFamily._()
    : super(
        retry: null,
        name: r'applicationCandidateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One candidate, as BR-09 permits this employer to see them.

  ApplicationCandidateProvider call(String applicationId) =>
      ApplicationCandidateProvider._(argument: applicationId, from: this);

  @override
  String toString() => r'applicationCandidateProvider';
}
