// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate_search_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(candidateSearchRepository)
final candidateSearchRepositoryProvider = CandidateSearchRepositoryProvider._();

final class CandidateSearchRepositoryProvider
    extends
        $FunctionalProvider<
          CandidateSearchRepository,
          CandidateSearchRepository,
          CandidateSearchRepository
        >
    with $Provider<CandidateSearchRepository> {
  CandidateSearchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'candidateSearchRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$candidateSearchRepositoryHash();

  @$internal
  @override
  $ProviderElement<CandidateSearchRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CandidateSearchRepository create(Ref ref) {
    return candidateSearchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CandidateSearchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CandidateSearchRepository>(value),
    );
  }
}

String _$candidateSearchRepositoryHash() =>
    r'f25676d75163ba9f658eef03db686f7f3698f799';

/// Candidates this employer saved (§7.3).

@ProviderFor(savedCandidates)
final savedCandidatesProvider = SavedCandidatesProvider._();

/// Candidates this employer saved (§7.3).

final class SavedCandidatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CandidateCard>>,
          List<CandidateCard>,
          FutureOr<List<CandidateCard>>
        >
    with
        $FutureModifier<List<CandidateCard>>,
        $FutureProvider<List<CandidateCard>> {
  /// Candidates this employer saved (§7.3).
  SavedCandidatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedCandidatesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedCandidatesHash();

  @$internal
  @override
  $FutureProviderElement<List<CandidateCard>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CandidateCard>> create(Ref ref) {
    return savedCandidates(ref);
  }
}

String _$savedCandidatesHash() => r'12905c9a0a98c4de1c27b23b6fdeb25d201e9220';

/// One candidate, as BR-09 permits this employer to see them (§7.3).
///
/// Deliberately **not** `keepAlive`. Reading a candidate is a logged access to
/// protected data (§11.1), and a cache that outlives the screen would keep
/// answering with an exposure decision that was made under an interaction the
/// candidate may since have withdrawn.

@ProviderFor(searchCandidate)
final searchCandidateProvider = SearchCandidateFamily._();

/// One candidate, as BR-09 permits this employer to see them (§7.3).
///
/// Deliberately **not** `keepAlive`. Reading a candidate is a logged access to
/// protected data (§11.1), and a cache that outlives the screen would keep
/// answering with an exposure decision that was made under an interaction the
/// candidate may since have withdrawn.

final class SearchCandidateProvider
    extends
        $FunctionalProvider<
          AsyncValue<CandidateForEmployer>,
          CandidateForEmployer,
          FutureOr<CandidateForEmployer>
        >
    with
        $FutureModifier<CandidateForEmployer>,
        $FutureProvider<CandidateForEmployer> {
  /// One candidate, as BR-09 permits this employer to see them (§7.3).
  ///
  /// Deliberately **not** `keepAlive`. Reading a candidate is a logged access to
  /// protected data (§11.1), and a cache that outlives the screen would keep
  /// answering with an exposure decision that was made under an interaction the
  /// candidate may since have withdrawn.
  SearchCandidateProvider._({
    required SearchCandidateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchCandidateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchCandidateHash();

  @override
  String toString() {
    return r'searchCandidateProvider'
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
    return searchCandidate(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchCandidateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchCandidateHash() => r'137438d37580951096ab8b08e44999a3bd4849f7';

/// One candidate, as BR-09 permits this employer to see them (§7.3).
///
/// Deliberately **not** `keepAlive`. Reading a candidate is a logged access to
/// protected data (§11.1), and a cache that outlives the screen would keep
/// answering with an exposure decision that was made under an interaction the
/// candidate may since have withdrawn.

final class SearchCandidateFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CandidateForEmployer>, String> {
  SearchCandidateFamily._()
    : super(
        retry: null,
        name: r'searchCandidateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One candidate, as BR-09 permits this employer to see them (§7.3).
  ///
  /// Deliberately **not** `keepAlive`. Reading a candidate is a logged access to
  /// protected data (§11.1), and a cache that outlives the screen would keep
  /// answering with an exposure decision that was made under an interaction the
  /// candidate may since have withdrawn.

  SearchCandidateProvider call(String candidateUserId) =>
      SearchCandidateProvider._(argument: candidateUserId, from: this);

  @override
  String toString() => r'searchCandidateProvider';
}
