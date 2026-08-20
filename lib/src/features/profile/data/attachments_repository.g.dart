// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachments_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(attachmentsRepository)
final attachmentsRepositoryProvider = AttachmentsRepositoryProvider._();

final class AttachmentsRepositoryProvider
    extends
        $FunctionalProvider<
          AttachmentsRepository,
          AttachmentsRepository,
          AttachmentsRepository
        >
    with $Provider<AttachmentsRepository> {
  AttachmentsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attachmentsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attachmentsRepositoryHash();

  @$internal
  @override
  $ProviderElement<AttachmentsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AttachmentsRepository create(Ref ref) {
    return attachmentsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttachmentsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttachmentsRepository>(value),
    );
  }
}

String _$attachmentsRepositoryHash() =>
    r'9433d58e8cbd81b1e33576fcb8d8b362e8af4329';

/// Every file on the profile, newest first, as the server orders them.
///
/// One provider for all purposes rather than one per slot: the endpoint returns
/// them together, and splitting the fetch would mean four round trips to draw
/// one screen.

@ProviderFor(attachments)
final attachmentsProvider = AttachmentsProvider._();

/// Every file on the profile, newest first, as the server orders them.
///
/// One provider for all purposes rather than one per slot: the endpoint returns
/// them together, and splitting the fetch would mean four round trips to draw
/// one screen.

final class AttachmentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Attachment>>,
          List<Attachment>,
          FutureOr<List<Attachment>>
        >
    with $FutureModifier<List<Attachment>>, $FutureProvider<List<Attachment>> {
  /// Every file on the profile, newest first, as the server orders them.
  ///
  /// One provider for all purposes rather than one per slot: the endpoint returns
  /// them together, and splitting the fetch would mean four round trips to draw
  /// one screen.
  AttachmentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attachmentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attachmentsHash();

  @$internal
  @override
  $FutureProviderElement<List<Attachment>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Attachment>> create(Ref ref) {
    return attachments(ref);
  }
}

String _$attachmentsHash() => r'64730d6919ce58cb56ff26f6e659e4d6e65b6a61';
