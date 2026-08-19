// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_opener.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(attachmentOpener)
final attachmentOpenerProvider = AttachmentOpenerProvider._();

final class AttachmentOpenerProvider
    extends
        $FunctionalProvider<
          AttachmentOpener,
          AttachmentOpener,
          AttachmentOpener
        >
    with $Provider<AttachmentOpener> {
  AttachmentOpenerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attachmentOpenerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attachmentOpenerHash();

  @$internal
  @override
  $ProviderElement<AttachmentOpener> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AttachmentOpener create(Ref ref) {
    return attachmentOpener(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttachmentOpener value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttachmentOpener>(value),
    );
  }
}

String _$attachmentOpenerHash() => r'7ff6bdb04ecd7361f22cbb5c4b07322017203959';
