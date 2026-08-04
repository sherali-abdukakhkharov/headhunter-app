// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The active interface language.
///
/// Ownership follows §3.2: the language is selectable **before** registration,
/// so local storage is the source of truth pre-auth. After sign-in the server
/// value wins on a fresh install, and a local change is pushed to the server.
/// Only the local half exists today - [select] is where the server push lands
/// when the profile endpoint arrives in M1, and the seam is marked below rather
/// than left to be rediscovered.
///
/// Kept alive: this is read by the `x-lang` interceptor on every request and by
/// `MaterialApp.locale`, so it must not be rebuilt when a screen is disposed.

@ProviderFor(LocaleController)
final localeControllerProvider = LocaleControllerProvider._();

/// The active interface language.
///
/// Ownership follows §3.2: the language is selectable **before** registration,
/// so local storage is the source of truth pre-auth. After sign-in the server
/// value wins on a fresh install, and a local change is pushed to the server.
/// Only the local half exists today - [select] is where the server push lands
/// when the profile endpoint arrives in M1, and the seam is marked below rather
/// than left to be rediscovered.
///
/// Kept alive: this is read by the `x-lang` interceptor on every request and by
/// `MaterialApp.locale`, so it must not be rebuilt when a screen is disposed.
final class LocaleControllerProvider
    extends $AsyncNotifierProvider<LocaleController, AppLocale> {
  /// The active interface language.
  ///
  /// Ownership follows §3.2: the language is selectable **before** registration,
  /// so local storage is the source of truth pre-auth. After sign-in the server
  /// value wins on a fresh install, and a local change is pushed to the server.
  /// Only the local half exists today - [select] is where the server push lands
  /// when the profile endpoint arrives in M1, and the seam is marked below rather
  /// than left to be rediscovered.
  ///
  /// Kept alive: this is read by the `x-lang` interceptor on every request and by
  /// `MaterialApp.locale`, so it must not be rebuilt when a screen is disposed.
  LocaleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeControllerHash();

  @$internal
  @override
  LocaleController create() => LocaleController();
}

String _$localeControllerHash() => r'f0074d22d044cdb459257ca0f1749f893bb607f3';

/// The active interface language.
///
/// Ownership follows §3.2: the language is selectable **before** registration,
/// so local storage is the source of truth pre-auth. After sign-in the server
/// value wins on a fresh install, and a local change is pushed to the server.
/// Only the local half exists today - [select] is where the server push lands
/// when the profile endpoint arrives in M1, and the seam is marked below rather
/// than left to be rediscovered.
///
/// Kept alive: this is read by the `x-lang` interceptor on every request and by
/// `MaterialApp.locale`, so it must not be rebuilt when a screen is disposed.

abstract class _$LocaleController extends $AsyncNotifier<AppLocale> {
  FutureOr<AppLocale> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppLocale>, AppLocale>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppLocale>, AppLocale>,
              AsyncValue<AppLocale>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The active locale as a plain value, for callers that cannot await.
///
/// Falls back to [AppLocale.fallback] while preferences are still loading and on
/// error. The `x-lang` interceptor uses this: a request must always carry a
/// language, and blocking every request on a disk read to avoid one wrong header
/// during the first frames is the worse trade.

@ProviderFor(activeLocale)
final activeLocaleProvider = ActiveLocaleProvider._();

/// The active locale as a plain value, for callers that cannot await.
///
/// Falls back to [AppLocale.fallback] while preferences are still loading and on
/// error. The `x-lang` interceptor uses this: a request must always carry a
/// language, and blocking every request on a disk read to avoid one wrong header
/// during the first frames is the worse trade.

final class ActiveLocaleProvider
    extends $FunctionalProvider<AppLocale, AppLocale, AppLocale>
    with $Provider<AppLocale> {
  /// The active locale as a plain value, for callers that cannot await.
  ///
  /// Falls back to [AppLocale.fallback] while preferences are still loading and on
  /// error. The `x-lang` interceptor uses this: a request must always carry a
  /// language, and blocking every request on a disk read to avoid one wrong header
  /// during the first frames is the worse trade.
  ActiveLocaleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeLocaleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeLocaleHash();

  @$internal
  @override
  $ProviderElement<AppLocale> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppLocale create(Ref ref) {
    return activeLocale(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLocale value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLocale>(value),
    );
  }
}

String _$activeLocaleHash() => r'1523d225080ceb65df107f911d9403bd76a0689e';
