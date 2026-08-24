// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The items of one dictionary type, in the active interface language.
///
/// ## Cache-first, then revalidate
///
/// 1. Serve what is cached for `(type, canonical locale)` immediately.
/// 2. Ask the server for anything newer, sending `If-None-Match` and `since`.
/// 3. On 304 — the common case — nothing else happens.
/// 4. On a delta, merge and emit again.
///
/// A cold cache waits for the network; a warm one never does. That matters
/// because these feed pickers: a form that cannot render its options until a
/// round trip completes is a form that looks broken on a slow connection.
///
/// **Keyed on the locale**, so switching language re-resolves every label while
/// the bound ids are untouched — which is the client half of UAT-13. The
/// dependency is `activeLocaleProvider`, watched rather than read, so the
/// provider rebuilds on a language change on its own.
///
/// ## What happens when the network fails
///
/// A cached copy wins: the error is swallowed and the stale-but-usable list is
/// served. Dictionaries change rarely, and refusing to render a picker because
/// a revalidation failed would break form editing offline for no benefit
/// (§12.4). With no cache there is nothing to serve, so the failure surfaces
/// and the UI shows it.

@ProviderFor(dictionary)
final dictionaryProvider = DictionaryFamily._();

/// The items of one dictionary type, in the active interface language.
///
/// ## Cache-first, then revalidate
///
/// 1. Serve what is cached for `(type, canonical locale)` immediately.
/// 2. Ask the server for anything newer, sending `If-None-Match` and `since`.
/// 3. On 304 — the common case — nothing else happens.
/// 4. On a delta, merge and emit again.
///
/// A cold cache waits for the network; a warm one never does. That matters
/// because these feed pickers: a form that cannot render its options until a
/// round trip completes is a form that looks broken on a slow connection.
///
/// **Keyed on the locale**, so switching language re-resolves every label while
/// the bound ids are untouched — which is the client half of UAT-13. The
/// dependency is `activeLocaleProvider`, watched rather than read, so the
/// provider rebuilds on a language change on its own.
///
/// ## What happens when the network fails
///
/// A cached copy wins: the error is swallowed and the stale-but-usable list is
/// served. Dictionaries change rarely, and refusing to render a picker because
/// a revalidation failed would break form editing offline for no benefit
/// (§12.4). With no cache there is nothing to serve, so the failure surfaces
/// and the UI shows it.

final class DictionaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DictionaryItem>>,
          List<DictionaryItem>,
          FutureOr<List<DictionaryItem>>
        >
    with
        $FutureModifier<List<DictionaryItem>>,
        $FutureProvider<List<DictionaryItem>> {
  /// The items of one dictionary type, in the active interface language.
  ///
  /// ## Cache-first, then revalidate
  ///
  /// 1. Serve what is cached for `(type, canonical locale)` immediately.
  /// 2. Ask the server for anything newer, sending `If-None-Match` and `since`.
  /// 3. On 304 — the common case — nothing else happens.
  /// 4. On a delta, merge and emit again.
  ///
  /// A cold cache waits for the network; a warm one never does. That matters
  /// because these feed pickers: a form that cannot render its options until a
  /// round trip completes is a form that looks broken on a slow connection.
  ///
  /// **Keyed on the locale**, so switching language re-resolves every label while
  /// the bound ids are untouched — which is the client half of UAT-13. The
  /// dependency is `activeLocaleProvider`, watched rather than read, so the
  /// provider rebuilds on a language change on its own.
  ///
  /// ## What happens when the network fails
  ///
  /// A cached copy wins: the error is swallowed and the stale-but-usable list is
  /// served. Dictionaries change rarely, and refusing to render a picker because
  /// a revalidation failed would break form editing offline for no benefit
  /// (§12.4). With no cache there is nothing to serve, so the failure surfaces
  /// and the UI shows it.
  DictionaryProvider._({
    required DictionaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'dictionaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dictionaryHash();

  @override
  String toString() {
    return r'dictionaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DictionaryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DictionaryItem>> create(Ref ref) {
    final argument = this.argument as String;
    return dictionary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DictionaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dictionaryHash() => r'f7d7e58d6829b86329d48404b723c1c72febcc23';

/// The items of one dictionary type, in the active interface language.
///
/// ## Cache-first, then revalidate
///
/// 1. Serve what is cached for `(type, canonical locale)` immediately.
/// 2. Ask the server for anything newer, sending `If-None-Match` and `since`.
/// 3. On 304 — the common case — nothing else happens.
/// 4. On a delta, merge and emit again.
///
/// A cold cache waits for the network; a warm one never does. That matters
/// because these feed pickers: a form that cannot render its options until a
/// round trip completes is a form that looks broken on a slow connection.
///
/// **Keyed on the locale**, so switching language re-resolves every label while
/// the bound ids are untouched — which is the client half of UAT-13. The
/// dependency is `activeLocaleProvider`, watched rather than read, so the
/// provider rebuilds on a language change on its own.
///
/// ## What happens when the network fails
///
/// A cached copy wins: the error is swallowed and the stale-but-usable list is
/// served. Dictionaries change rarely, and refusing to render a picker because
/// a revalidation failed would break form editing offline for no benefit
/// (§12.4). With no cache there is nothing to serve, so the failure surfaces
/// and the UI shows it.

final class DictionaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<DictionaryItem>>, String> {
  DictionaryFamily._()
    : super(
        retry: null,
        name: r'dictionaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The items of one dictionary type, in the active interface language.
  ///
  /// ## Cache-first, then revalidate
  ///
  /// 1. Serve what is cached for `(type, canonical locale)` immediately.
  /// 2. Ask the server for anything newer, sending `If-None-Match` and `since`.
  /// 3. On 304 — the common case — nothing else happens.
  /// 4. On a delta, merge and emit again.
  ///
  /// A cold cache waits for the network; a warm one never does. That matters
  /// because these feed pickers: a form that cannot render its options until a
  /// round trip completes is a form that looks broken on a slow connection.
  ///
  /// **Keyed on the locale**, so switching language re-resolves every label while
  /// the bound ids are untouched — which is the client half of UAT-13. The
  /// dependency is `activeLocaleProvider`, watched rather than read, so the
  /// provider rebuilds on a language change on its own.
  ///
  /// ## What happens when the network fails
  ///
  /// A cached copy wins: the error is swallowed and the stale-but-usable list is
  /// served. Dictionaries change rarely, and refusing to render a picker because
  /// a revalidation failed would break form editing offline for no benefit
  /// (§12.4). With no cache there is nothing to serve, so the failure surfaces
  /// and the UI shows it.

  DictionaryProvider call(String type) =>
      DictionaryProvider._(argument: type, from: this);

  @override
  String toString() => r'dictionaryProvider';
}

/// Only the items a picker should offer: active, not merged away (§10.3).
///
/// Separate from [dictionary] rather than filtered at each call site, because
/// the two audiences are genuinely different — a picker wants this, and label
/// resolution for a historical record wants the unfiltered set.

@ProviderFor(selectableDictionary)
final selectableDictionaryProvider = SelectableDictionaryFamily._();

/// Only the items a picker should offer: active, not merged away (§10.3).
///
/// Separate from [dictionary] rather than filtered at each call site, because
/// the two audiences are genuinely different — a picker wants this, and label
/// resolution for a historical record wants the unfiltered set.

final class SelectableDictionaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DictionaryItem>>,
          List<DictionaryItem>,
          FutureOr<List<DictionaryItem>>
        >
    with
        $FutureModifier<List<DictionaryItem>>,
        $FutureProvider<List<DictionaryItem>> {
  /// Only the items a picker should offer: active, not merged away (§10.3).
  ///
  /// Separate from [dictionary] rather than filtered at each call site, because
  /// the two audiences are genuinely different — a picker wants this, and label
  /// resolution for a historical record wants the unfiltered set.
  SelectableDictionaryProvider._({
    required SelectableDictionaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'selectableDictionaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$selectableDictionaryHash();

  @override
  String toString() {
    return r'selectableDictionaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DictionaryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DictionaryItem>> create(Ref ref) {
    final argument = this.argument as String;
    return selectableDictionary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SelectableDictionaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$selectableDictionaryHash() =>
    r'e7792ae311042689e5dd6d10de39c1686ca7b9b2';

/// Only the items a picker should offer: active, not merged away (§10.3).
///
/// Separate from [dictionary] rather than filtered at each call site, because
/// the two audiences are genuinely different — a picker wants this, and label
/// resolution for a historical record wants the unfiltered set.

final class SelectableDictionaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<DictionaryItem>>, String> {
  SelectableDictionaryFamily._()
    : super(
        retry: null,
        name: r'selectableDictionaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Only the items a picker should offer: active, not merged away (§10.3).
  ///
  /// Separate from [dictionary] rather than filtered at each call site, because
  /// the two audiences are genuinely different — a picker wants this, and label
  /// resolution for a historical record wants the unfiltered set.

  SelectableDictionaryProvider call(String type) =>
      SelectableDictionaryProvider._(argument: type, from: this);

  @override
  String toString() => r'selectableDictionaryProvider';
}

/// The children of [parentId] within [type] — districts of a region (§5.1).
///
/// Returns everything with no parent when [parentId] is null, which is the
/// top-level list a region picker shows.

@ProviderFor(dictionaryChildren)
final dictionaryChildrenProvider = DictionaryChildrenFamily._();

/// The children of [parentId] within [type] — districts of a region (§5.1).
///
/// Returns everything with no parent when [parentId] is null, which is the
/// top-level list a region picker shows.

final class DictionaryChildrenProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DictionaryItem>>,
          List<DictionaryItem>,
          FutureOr<List<DictionaryItem>>
        >
    with
        $FutureModifier<List<DictionaryItem>>,
        $FutureProvider<List<DictionaryItem>> {
  /// The children of [parentId] within [type] — districts of a region (§5.1).
  ///
  /// Returns everything with no parent when [parentId] is null, which is the
  /// top-level list a region picker shows.
  DictionaryChildrenProvider._({
    required DictionaryChildrenFamily super.from,
    required (String, String?) super.argument,
  }) : super(
         retry: null,
         name: r'dictionaryChildrenProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dictionaryChildrenHash();

  @override
  String toString() {
    return r'dictionaryChildrenProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<DictionaryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DictionaryItem>> create(Ref ref) {
    final argument = this.argument as (String, String?);
    return dictionaryChildren(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is DictionaryChildrenProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dictionaryChildrenHash() =>
    r'20f59197193c75f3aa0ccac21e430810c656d342';

/// The children of [parentId] within [type] — districts of a region (§5.1).
///
/// Returns everything with no parent when [parentId] is null, which is the
/// top-level list a region picker shows.

final class DictionaryChildrenFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<DictionaryItem>>,
          (String, String?)
        > {
  DictionaryChildrenFamily._()
    : super(
        retry: null,
        name: r'dictionaryChildrenProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The children of [parentId] within [type] — districts of a region (§5.1).
  ///
  /// Returns everything with no parent when [parentId] is null, which is the
  /// top-level list a region picker shows.

  DictionaryChildrenProvider call(String type, String? parentId) =>
      DictionaryChildrenProvider._(argument: (type, parentId), from: this);

  @override
  String toString() => r'dictionaryChildrenProvider';
}

/// Resolves ids to labels, **including ids no picker would offer**.
///
/// Looks in the cache first and asks the server only for what is missing. That
/// second step is the point: a record created last year can reference an
/// occupation an administrator has since retired, and it must render as words
/// rather than a UUID (§10.3).
///
/// Returns a map so a caller with several ids does one lookup. Ids the server
/// cannot resolve either are simply absent — the caller decides what to show,
/// because "deleted" reads differently in a profile than in an audit log.
///
/// **The key is a comma-joined string, not a `List`**, and that is
/// load-bearing.
///
/// Riverpod families compare their arguments with `==`, and a Dart `List` has
/// identity equality. A caller writing `resolvedLabelsProvider(type, [id])`
/// builds a *new* list on every rebuild, so every rebuild is a new family
/// member: a fresh fetch, a fresh cache entry, and neither is ever collected.
/// The screen still renders correctly, which is what makes it hard to spot.
///
/// Build the key with [labelKey], which also sorts — so the same set of ids in
/// a different order is the same provider.

@ProviderFor(resolvedLabels)
final resolvedLabelsProvider = ResolvedLabelsFamily._();

/// Resolves ids to labels, **including ids no picker would offer**.
///
/// Looks in the cache first and asks the server only for what is missing. That
/// second step is the point: a record created last year can reference an
/// occupation an administrator has since retired, and it must render as words
/// rather than a UUID (§10.3).
///
/// Returns a map so a caller with several ids does one lookup. Ids the server
/// cannot resolve either are simply absent — the caller decides what to show,
/// because "deleted" reads differently in a profile than in an audit log.
///
/// **The key is a comma-joined string, not a `List`**, and that is
/// load-bearing.
///
/// Riverpod families compare their arguments with `==`, and a Dart `List` has
/// identity equality. A caller writing `resolvedLabelsProvider(type, [id])`
/// builds a *new* list on every rebuild, so every rebuild is a new family
/// member: a fresh fetch, a fresh cache entry, and neither is ever collected.
/// The screen still renders correctly, which is what makes it hard to spot.
///
/// Build the key with [labelKey], which also sorts — so the same set of ids in
/// a different order is the same provider.

final class ResolvedLabelsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, DictionaryItem>>,
          Map<String, DictionaryItem>,
          FutureOr<Map<String, DictionaryItem>>
        >
    with
        $FutureModifier<Map<String, DictionaryItem>>,
        $FutureProvider<Map<String, DictionaryItem>> {
  /// Resolves ids to labels, **including ids no picker would offer**.
  ///
  /// Looks in the cache first and asks the server only for what is missing. That
  /// second step is the point: a record created last year can reference an
  /// occupation an administrator has since retired, and it must render as words
  /// rather than a UUID (§10.3).
  ///
  /// Returns a map so a caller with several ids does one lookup. Ids the server
  /// cannot resolve either are simply absent — the caller decides what to show,
  /// because "deleted" reads differently in a profile than in an audit log.
  ///
  /// **The key is a comma-joined string, not a `List`**, and that is
  /// load-bearing.
  ///
  /// Riverpod families compare their arguments with `==`, and a Dart `List` has
  /// identity equality. A caller writing `resolvedLabelsProvider(type, [id])`
  /// builds a *new* list on every rebuild, so every rebuild is a new family
  /// member: a fresh fetch, a fresh cache entry, and neither is ever collected.
  /// The screen still renders correctly, which is what makes it hard to spot.
  ///
  /// Build the key with [labelKey], which also sorts — so the same set of ids in
  /// a different order is the same provider.
  ResolvedLabelsProvider._({
    required ResolvedLabelsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'resolvedLabelsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$resolvedLabelsHash();

  @override
  String toString() {
    return r'resolvedLabelsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, DictionaryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, DictionaryItem>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return resolvedLabels(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ResolvedLabelsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$resolvedLabelsHash() => r'6353ea93cc45f4084d6b0792d6933eb9a1e4ecd3';

/// Resolves ids to labels, **including ids no picker would offer**.
///
/// Looks in the cache first and asks the server only for what is missing. That
/// second step is the point: a record created last year can reference an
/// occupation an administrator has since retired, and it must render as words
/// rather than a UUID (§10.3).
///
/// Returns a map so a caller with several ids does one lookup. Ids the server
/// cannot resolve either are simply absent — the caller decides what to show,
/// because "deleted" reads differently in a profile than in an audit log.
///
/// **The key is a comma-joined string, not a `List`**, and that is
/// load-bearing.
///
/// Riverpod families compare their arguments with `==`, and a Dart `List` has
/// identity equality. A caller writing `resolvedLabelsProvider(type, [id])`
/// builds a *new* list on every rebuild, so every rebuild is a new family
/// member: a fresh fetch, a fresh cache entry, and neither is ever collected.
/// The screen still renders correctly, which is what makes it hard to spot.
///
/// Build the key with [labelKey], which also sorts — so the same set of ids in
/// a different order is the same provider.

final class ResolvedLabelsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<String, DictionaryItem>>,
          (String, String)
        > {
  ResolvedLabelsFamily._()
    : super(
        retry: null,
        name: r'resolvedLabelsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Resolves ids to labels, **including ids no picker would offer**.
  ///
  /// Looks in the cache first and asks the server only for what is missing. That
  /// second step is the point: a record created last year can reference an
  /// occupation an administrator has since retired, and it must render as words
  /// rather than a UUID (§10.3).
  ///
  /// Returns a map so a caller with several ids does one lookup. Ids the server
  /// cannot resolve either are simply absent — the caller decides what to show,
  /// because "deleted" reads differently in a profile than in an audit log.
  ///
  /// **The key is a comma-joined string, not a `List`**, and that is
  /// load-bearing.
  ///
  /// Riverpod families compare their arguments with `==`, and a Dart `List` has
  /// identity equality. A caller writing `resolvedLabelsProvider(type, [id])`
  /// builds a *new* list on every rebuild, so every rebuild is a new family
  /// member: a fresh fetch, a fresh cache entry, and neither is ever collected.
  /// The screen still renders correctly, which is what makes it hard to spot.
  ///
  /// Build the key with [labelKey], which also sorts — so the same set of ids in
  /// a different order is the same provider.

  ResolvedLabelsProvider call(String type, String idKey) =>
      ResolvedLabelsProvider._(argument: (type, idKey), from: this);

  @override
  String toString() => r'resolvedLabelsProvider';
}

/// Warms every dictionary this app version knows about.
///
/// Called once after sign-in rather than lazily per picker: the first form a
/// candidate opens needs six of them at once, and six cold round trips in
/// sequence is the difference between a form that appears and one that
/// assembles itself while the user watches.
///
/// Failures are deliberately not propagated — this is a prefetch, and each
/// picker still resolves its own type on demand.

@ProviderFor(warmDictionaries)
final warmDictionariesProvider = WarmDictionariesFamily._();

/// Warms every dictionary this app version knows about.
///
/// Called once after sign-in rather than lazily per picker: the first form a
/// candidate opens needs six of them at once, and six cold round trips in
/// sequence is the difference between a form that appears and one that
/// assembles itself while the user watches.
///
/// Failures are deliberately not propagated — this is a prefetch, and each
/// picker still resolves its own type on demand.

final class WarmDictionariesProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Warms every dictionary this app version knows about.
  ///
  /// Called once after sign-in rather than lazily per picker: the first form a
  /// candidate opens needs six of them at once, and six cold round trips in
  /// sequence is the difference between a form that appears and one that
  /// assembles itself while the user watches.
  ///
  /// Failures are deliberately not propagated — this is a prefetch, and each
  /// picker still resolves its own type on demand.
  WarmDictionariesProvider._({
    required WarmDictionariesFamily super.from,
    required List<String> super.argument,
  }) : super(
         retry: null,
         name: r'warmDictionariesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$warmDictionariesHash();

  @override
  String toString() {
    return r'warmDictionariesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as List<String>;
    return warmDictionaries(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WarmDictionariesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$warmDictionariesHash() => r'82f121e5828db9ea471fe8a77046a316450632f5';

/// Warms every dictionary this app version knows about.
///
/// Called once after sign-in rather than lazily per picker: the first form a
/// candidate opens needs six of them at once, and six cold round trips in
/// sequence is the difference between a form that appears and one that
/// assembles itself while the user watches.
///
/// Failures are deliberately not propagated — this is a prefetch, and each
/// picker still resolves its own type on demand.

final class WarmDictionariesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, List<String>> {
  WarmDictionariesFamily._()
    : super(
        retry: null,
        name: r'warmDictionariesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Warms every dictionary this app version knows about.
  ///
  /// Called once after sign-in rather than lazily per picker: the first form a
  /// candidate opens needs six of them at once, and six cold round trips in
  /// sequence is the difference between a form that appears and one that
  /// assembles itself while the user watches.
  ///
  /// Failures are deliberately not propagated — this is a prefetch, and each
  /// picker still resolves its own type on demand.

  WarmDictionariesProvider call(List<String> types) =>
      WarmDictionariesProvider._(argument: types, from: this);

  @override
  String toString() => r'warmDictionariesProvider';
}

/// Every dictionary type the server has (§10.3).
///
/// Read from the manifest rather than from `DictionaryType.all`: that constant
/// is the client's prefetch list and says so — "not for validation: the server
/// remains the authority on what exists" — so an administrator's list built
/// from it would omit any type added after this build shipped.
///
/// Not cached with the item lists. The manifest is locale-independent and one
/// small request, and the screen that reads it is opened deliberately.

@ProviderFor(dictionaryManifest)
final dictionaryManifestProvider = DictionaryManifestProvider._();

/// Every dictionary type the server has (§10.3).
///
/// Read from the manifest rather than from `DictionaryType.all`: that constant
/// is the client's prefetch list and says so — "not for validation: the server
/// remains the authority on what exists" — so an administrator's list built
/// from it would omit any type added after this build shipped.
///
/// Not cached with the item lists. The manifest is locale-independent and one
/// small request, and the screen that reads it is opened deliberately.

final class DictionaryManifestProvider
    extends
        $FunctionalProvider<
          AsyncValue<DictionaryManifest>,
          DictionaryManifest,
          FutureOr<DictionaryManifest>
        >
    with
        $FutureModifier<DictionaryManifest>,
        $FutureProvider<DictionaryManifest> {
  /// Every dictionary type the server has (§10.3).
  ///
  /// Read from the manifest rather than from `DictionaryType.all`: that constant
  /// is the client's prefetch list and says so — "not for validation: the server
  /// remains the authority on what exists" — so an administrator's list built
  /// from it would omit any type added after this build shipped.
  ///
  /// Not cached with the item lists. The manifest is locale-independent and one
  /// small request, and the screen that reads it is opened deliberately.
  DictionaryManifestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dictionaryManifestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dictionaryManifestHash();

  @$internal
  @override
  $FutureProviderElement<DictionaryManifest> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DictionaryManifest> create(Ref ref) {
    return dictionaryManifest(ref);
  }
}

String _$dictionaryManifestHash() =>
    r'f2150ba77ce1d01bb36531584cd77f8cc87f20d9';
