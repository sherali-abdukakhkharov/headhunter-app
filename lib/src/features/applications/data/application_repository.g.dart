// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(applicationRepository)
final applicationRepositoryProvider = ApplicationRepositoryProvider._();

final class ApplicationRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ApplicationRepository>,
          ApplicationRepository,
          FutureOr<ApplicationRepository>
        >
    with
        $FutureModifier<ApplicationRepository>,
        $FutureProvider<ApplicationRepository> {
  ApplicationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'applicationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$applicationRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ApplicationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ApplicationRepository> create(Ref ref) {
    return applicationRepository(ref);
  }
}

String _$applicationRepositoryHash() =>
    r'9b15448ea09a009cb599ee8aa9ebd0164cfa2cc5';

/// The candidate's own applications, every stage (§8.1).

@ProviderFor(myApplications)
final myApplicationsProvider = MyApplicationsProvider._();

/// The candidate's own applications, every stage (§8.1).

final class MyApplicationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Application>>,
          List<Application>,
          FutureOr<List<Application>>
        >
    with
        $FutureModifier<List<Application>>,
        $FutureProvider<List<Application>> {
  /// The candidate's own applications, every stage (§8.1).
  MyApplicationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myApplicationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myApplicationsHash();

  @$internal
  @override
  $FutureProviderElement<List<Application>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Application>> create(Ref ref) {
    return myApplications(ref);
  }
}

String _$myApplicationsHash() => r'6be226f854393a7820c565ecf8ea94fe22131d9f';
