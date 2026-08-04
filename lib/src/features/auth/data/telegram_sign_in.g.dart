// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telegram_sign_in.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(telegramSignIn)
final telegramSignInProvider = TelegramSignInProvider._();

final class TelegramSignInProvider
    extends $FunctionalProvider<TelegramSignIn, TelegramSignIn, TelegramSignIn>
    with $Provider<TelegramSignIn> {
  TelegramSignInProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'telegramSignInProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$telegramSignInHash();

  @$internal
  @override
  $ProviderElement<TelegramSignIn> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TelegramSignIn create(Ref ref) {
    return telegramSignIn(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TelegramSignIn value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TelegramSignIn>(value),
    );
  }
}

String _$telegramSignInHash() => r'571e211b4af93fd1525c04bd56e211f7d0b17575';
