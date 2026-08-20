// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vacancy_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(vacancyRepository)
final vacancyRepositoryProvider = VacancyRepositoryProvider._();

final class VacancyRepositoryProvider
    extends
        $FunctionalProvider<
          VacancyRepository,
          VacancyRepository,
          VacancyRepository
        >
    with $Provider<VacancyRepository> {
  VacancyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vacancyRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vacancyRepositoryHash();

  @$internal
  @override
  $ProviderElement<VacancyRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VacancyRepository create(Ref ref) {
    return vacancyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VacancyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VacancyRepository>(value),
    );
  }
}

String _$vacancyRepositoryHash() => r'a1ed3f9324aa87c0ba35c420da77f86dd1bf9dd8';

/// The employer's own vacancies, every status.

@ProviderFor(myVacancies)
final myVacanciesProvider = MyVacanciesProvider._();

/// The employer's own vacancies, every status.

final class MyVacanciesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Vacancy>>,
          List<Vacancy>,
          FutureOr<List<Vacancy>>
        >
    with $FutureModifier<List<Vacancy>>, $FutureProvider<List<Vacancy>> {
  /// The employer's own vacancies, every status.
  MyVacanciesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myVacanciesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myVacanciesHash();

  @$internal
  @override
  $FutureProviderElement<List<Vacancy>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Vacancy>> create(Ref ref) {
    return myVacancies(ref);
  }
}

String _$myVacanciesHash() => r'36b58cfefc5319b076caac1aec2f198c25a769a8';
