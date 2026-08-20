// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovery_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(discoveryRepository)
final discoveryRepositoryProvider = DiscoveryRepositoryProvider._();

final class DiscoveryRepositoryProvider
    extends
        $FunctionalProvider<
          DiscoveryRepository,
          DiscoveryRepository,
          DiscoveryRepository
        >
    with $Provider<DiscoveryRepository> {
  DiscoveryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoveryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoveryRepositoryHash();

  @$internal
  @override
  $ProviderElement<DiscoveryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DiscoveryRepository create(Ref ref) {
    return discoveryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiscoveryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiscoveryRepository>(value),
    );
  }
}

String _$discoveryRepositoryHash() =>
    r'4efd0cfdf65e95e7ecc27233081dd410d9bcb366';

/// One feed's contents.

@ProviderFor(vacancyFeed)
final vacancyFeedProvider = VacancyFeedFamily._();

/// One feed's contents.

final class VacancyFeedProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VacancyCard>>,
          List<VacancyCard>,
          FutureOr<List<VacancyCard>>
        >
    with
        $FutureModifier<List<VacancyCard>>,
        $FutureProvider<List<VacancyCard>> {
  /// One feed's contents.
  VacancyFeedProvider._({
    required VacancyFeedFamily super.from,
    required Feed super.argument,
  }) : super(
         retry: null,
         name: r'vacancyFeedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vacancyFeedHash();

  @override
  String toString() {
    return r'vacancyFeedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<VacancyCard>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<VacancyCard>> create(Ref ref) {
    final argument = this.argument as Feed;
    return vacancyFeed(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is VacancyFeedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vacancyFeedHash() => r'ff02685e577256f788b11ba99fc62040b84ec517';

/// One feed's contents.

final class VacancyFeedFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<VacancyCard>>, Feed> {
  VacancyFeedFamily._()
    : super(
        retry: null,
        name: r'vacancyFeedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One feed's contents.

  VacancyFeedProvider call(Feed feed) =>
      VacancyFeedProvider._(argument: feed, from: this);

  @override
  String toString() => r'vacancyFeedProvider';
}

/// One vacancy in full (§5.6).

@ProviderFor(vacancyDetail)
final vacancyDetailProvider = VacancyDetailFamily._();

/// One vacancy in full (§5.6).

final class VacancyDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<VacancyDetail>,
          VacancyDetail,
          FutureOr<VacancyDetail>
        >
    with $FutureModifier<VacancyDetail>, $FutureProvider<VacancyDetail> {
  /// One vacancy in full (§5.6).
  VacancyDetailProvider._({
    required VacancyDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'vacancyDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vacancyDetailHash();

  @override
  String toString() {
    return r'vacancyDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<VacancyDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<VacancyDetail> create(Ref ref) {
    final argument = this.argument as String;
    return vacancyDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is VacancyDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vacancyDetailHash() => r'854e310e4cb8229da9885b214ea8053f20dadc0f';

/// One vacancy in full (§5.6).

final class VacancyDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<VacancyDetail>, String> {
  VacancyDetailFamily._()
    : super(
        retry: null,
        name: r'vacancyDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One vacancy in full (§5.6).

  VacancyDetailProvider call(String id) =>
      VacancyDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'vacancyDetailProvider';
}

/// The vacancy form declaration for one work category, used **read-only** here
/// to name a requirement's field (§6.3, §10.3).
///
/// A requirement arrives as `fieldCode` — `employment_type_ids` — and the human
/// wording for that code lives in the schema, already localized by the server.
/// Rendering the code instead was the first version of this screen and it read
/// as a bug on a device; mapping codes to strings in Dart would be worse, since
/// administrators add fields at runtime and a client-side table would go stale
/// silently.
///
/// One request per category, cached by the family key, so a candidate scrolling
/// ten call-centre vacancies fetches it once.

@ProviderFor(vacancyFieldSchema)
final vacancyFieldSchemaProvider = VacancyFieldSchemaFamily._();

/// The vacancy form declaration for one work category, used **read-only** here
/// to name a requirement's field (§6.3, §10.3).
///
/// A requirement arrives as `fieldCode` — `employment_type_ids` — and the human
/// wording for that code lives in the schema, already localized by the server.
/// Rendering the code instead was the first version of this screen and it read
/// as a bug on a device; mapping codes to strings in Dart would be worse, since
/// administrators add fields at runtime and a client-side table would go stale
/// silently.
///
/// One request per category, cached by the family key, so a candidate scrolling
/// ten call-centre vacancies fetches it once.

final class VacancyFieldSchemaProvider
    extends
        $FunctionalProvider<
          AsyncValue<FieldSchema>,
          FieldSchema,
          FutureOr<FieldSchema>
        >
    with $FutureModifier<FieldSchema>, $FutureProvider<FieldSchema> {
  /// The vacancy form declaration for one work category, used **read-only** here
  /// to name a requirement's field (§6.3, §10.3).
  ///
  /// A requirement arrives as `fieldCode` — `employment_type_ids` — and the human
  /// wording for that code lives in the schema, already localized by the server.
  /// Rendering the code instead was the first version of this screen and it read
  /// as a bug on a device; mapping codes to strings in Dart would be worse, since
  /// administrators add fields at runtime and a client-side table would go stale
  /// silently.
  ///
  /// One request per category, cached by the family key, so a candidate scrolling
  /// ten call-centre vacancies fetches it once.
  VacancyFieldSchemaProvider._({
    required VacancyFieldSchemaFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'vacancyFieldSchemaProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vacancyFieldSchemaHash();

  @override
  String toString() {
    return r'vacancyFieldSchemaProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<FieldSchema> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FieldSchema> create(Ref ref) {
    final argument = this.argument as String;
    return vacancyFieldSchema(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is VacancyFieldSchemaProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vacancyFieldSchemaHash() =>
    r'5f62fede88397ddb70e5eba981b7e16bbfe8784d';

/// The vacancy form declaration for one work category, used **read-only** here
/// to name a requirement's field (§6.3, §10.3).
///
/// A requirement arrives as `fieldCode` — `employment_type_ids` — and the human
/// wording for that code lives in the schema, already localized by the server.
/// Rendering the code instead was the first version of this screen and it read
/// as a bug on a device; mapping codes to strings in Dart would be worse, since
/// administrators add fields at runtime and a client-side table would go stale
/// silently.
///
/// One request per category, cached by the family key, so a candidate scrolling
/// ten call-centre vacancies fetches it once.

final class VacancyFieldSchemaFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<FieldSchema>, String> {
  VacancyFieldSchemaFamily._()
    : super(
        retry: null,
        name: r'vacancyFieldSchemaProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The vacancy form declaration for one work category, used **read-only** here
  /// to name a requirement's field (§6.3, §10.3).
  ///
  /// A requirement arrives as `fieldCode` — `employment_type_ids` — and the human
  /// wording for that code lives in the schema, already localized by the server.
  /// Rendering the code instead was the first version of this screen and it read
  /// as a bug on a device; mapping codes to strings in Dart would be worse, since
  /// administrators add fields at runtime and a client-side table would go stale
  /// silently.
  ///
  /// One request per category, cached by the family key, so a candidate scrolling
  /// ten call-centre vacancies fetches it once.

  VacancyFieldSchemaProvider call(String category) =>
      VacancyFieldSchemaProvider._(argument: category, from: this);

  @override
  String toString() => r'vacancyFieldSchemaProvider';
}
