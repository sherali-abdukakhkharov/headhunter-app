// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evidence_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(evidenceRepository)
final evidenceRepositoryProvider = EvidenceRepositoryProvider._();

final class EvidenceRepositoryProvider
    extends
        $FunctionalProvider<
          EvidenceRepository,
          EvidenceRepository,
          EvidenceRepository
        >
    with $Provider<EvidenceRepository> {
  EvidenceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'evidenceRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$evidenceRepositoryHash();

  @$internal
  @override
  $ProviderElement<EvidenceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EvidenceRepository create(Ref ref) {
    return evidenceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EvidenceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EvidenceRepository>(value),
    );
  }
}

String _$evidenceRepositoryHash() =>
    r'bcced38c7ee9c2c9563ad51efe680dc985912bb9';

/// Every file the employer has uploaded, newest first.
///
/// One request for all purposes rather than one per row: the endpoint returns
/// them together and the card draws every row at once, so filtering per purpose
/// would be several round trips to paint one card.

@ProviderFor(evidenceFiles)
final evidenceFilesProvider = EvidenceFilesProvider._();

/// Every file the employer has uploaded, newest first.
///
/// One request for all purposes rather than one per row: the endpoint returns
/// them together and the card draws every row at once, so filtering per purpose
/// would be several round trips to paint one card.

final class EvidenceFilesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Attachment>>,
          List<Attachment>,
          FutureOr<List<Attachment>>
        >
    with $FutureModifier<List<Attachment>>, $FutureProvider<List<Attachment>> {
  /// Every file the employer has uploaded, newest first.
  ///
  /// One request for all purposes rather than one per row: the endpoint returns
  /// them together and the card draws every row at once, so filtering per purpose
  /// would be several round trips to paint one card.
  EvidenceFilesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'evidenceFilesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$evidenceFilesHash();

  @$internal
  @override
  $FutureProviderElement<List<Attachment>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Attachment>> create(Ref ref) {
    return evidenceFiles(ref);
  }
}

String _$evidenceFilesHash() => r'982a164bcea7850b9e7f79c0c0b61740c2bb5cca';
