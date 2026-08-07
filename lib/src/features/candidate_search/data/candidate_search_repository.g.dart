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
