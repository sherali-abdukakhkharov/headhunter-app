// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interview_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(interviewRepository)
final interviewRepositoryProvider = InterviewRepositoryProvider._();

final class InterviewRepositoryProvider
    extends
        $FunctionalProvider<
          InterviewRepository,
          InterviewRepository,
          InterviewRepository
        >
    with $Provider<InterviewRepository> {
  InterviewRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'interviewRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$interviewRepositoryHash();

  @$internal
  @override
  $ProviderElement<InterviewRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InterviewRepository create(Ref ref) {
    return interviewRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InterviewRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InterviewRepository>(value),
    );
  }
}

String _$interviewRepositoryHash() =>
    r'3957031e686011b919c36b1192d482866d46b10b';

/// Every interview of the signed-in candidate (§8.3).

@ProviderFor(myInterviews)
final myInterviewsProvider = MyInterviewsProvider._();

/// Every interview of the signed-in candidate (§8.3).

final class MyInterviewsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Interview>>,
          List<Interview>,
          FutureOr<List<Interview>>
        >
    with $FutureModifier<List<Interview>>, $FutureProvider<List<Interview>> {
  /// Every interview of the signed-in candidate (§8.3).
  MyInterviewsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myInterviewsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myInterviewsHash();

  @$internal
  @override
  $FutureProviderElement<List<Interview>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Interview>> create(Ref ref) {
    return myInterviews(ref);
  }
}

String _$myInterviewsHash() => r'72d84ce6c04a48375daa976cf87bdb139d5aaf0c';

/// This candidate's interviews grouped by application.
///
/// Derived from [myInterviews] rather than fetched per application, so a list
/// of applications costs one request no matter how long it is. Keyed lookups
/// return an empty list rather than null, because "this application has no
/// interview" is the common case and not an absence worth a null check at every
/// call site.

@ProviderFor(myInterviewsByApplication)
final myInterviewsByApplicationProvider = MyInterviewsByApplicationProvider._();

/// This candidate's interviews grouped by application.
///
/// Derived from [myInterviews] rather than fetched per application, so a list
/// of applications costs one request no matter how long it is. Keyed lookups
/// return an empty list rather than null, because "this application has no
/// interview" is the common case and not an absence worth a null check at every
/// call site.

final class MyInterviewsByApplicationProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, List<Interview>>>,
          Map<String, List<Interview>>,
          FutureOr<Map<String, List<Interview>>>
        >
    with
        $FutureModifier<Map<String, List<Interview>>>,
        $FutureProvider<Map<String, List<Interview>>> {
  /// This candidate's interviews grouped by application.
  ///
  /// Derived from [myInterviews] rather than fetched per application, so a list
  /// of applications costs one request no matter how long it is. Keyed lookups
  /// return an empty list rather than null, because "this application has no
  /// interview" is the common case and not an absence worth a null check at every
  /// call site.
  MyInterviewsByApplicationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myInterviewsByApplicationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myInterviewsByApplicationHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, List<Interview>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, List<Interview>>> create(Ref ref) {
    return myInterviewsByApplication(ref);
  }
}

String _$myInterviewsByApplicationHash() =>
    r'a690b07ab0239000d29bc000a1541b6f632ecd79';

/// One application's interviews, for either side (§8.3).

@ProviderFor(applicationInterviews)
final applicationInterviewsProvider = ApplicationInterviewsFamily._();

/// One application's interviews, for either side (§8.3).

final class ApplicationInterviewsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Interview>>,
          List<Interview>,
          FutureOr<List<Interview>>
        >
    with $FutureModifier<List<Interview>>, $FutureProvider<List<Interview>> {
  /// One application's interviews, for either side (§8.3).
  ApplicationInterviewsProvider._({
    required ApplicationInterviewsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'applicationInterviewsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$applicationInterviewsHash();

  @override
  String toString() {
    return r'applicationInterviewsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Interview>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Interview>> create(Ref ref) {
    final argument = this.argument as String;
    return applicationInterviews(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ApplicationInterviewsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$applicationInterviewsHash() =>
    r'7f861257afd86eb036fa694abe397e41d3694efb';

/// One application's interviews, for either side (§8.3).

final class ApplicationInterviewsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Interview>>, String> {
  ApplicationInterviewsFamily._()
    : super(
        retry: null,
        name: r'applicationInterviewsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One application's interviews, for either side (§8.3).

  ApplicationInterviewsProvider call(String applicationId) =>
      ApplicationInterviewsProvider._(argument: applicationId, from: this);

  @override
  String toString() => r'applicationInterviewsProvider';
}

/// BR-08's trail for one interview, for whichever side is looking.

@ProviderFor(interviewHistory)
final interviewHistoryProvider = InterviewHistoryFamily._();

/// BR-08's trail for one interview, for whichever side is looking.

final class InterviewHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InterviewEvent>>,
          List<InterviewEvent>,
          FutureOr<List<InterviewEvent>>
        >
    with
        $FutureModifier<List<InterviewEvent>>,
        $FutureProvider<List<InterviewEvent>> {
  /// BR-08's trail for one interview, for whichever side is looking.
  InterviewHistoryProvider._({
    required InterviewHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'interviewHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$interviewHistoryHash();

  @override
  String toString() {
    return r'interviewHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<InterviewEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<InterviewEvent>> create(Ref ref) {
    final argument = this.argument as String;
    return interviewHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is InterviewHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$interviewHistoryHash() => r'891f2aebfff2dac71edf9d149c622f2f94c21107';

/// BR-08's trail for one interview, for whichever side is looking.

final class InterviewHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<InterviewEvent>>, String> {
  InterviewHistoryFamily._()
    : super(
        retry: null,
        name: r'interviewHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// BR-08's trail for one interview, for whichever side is looking.

  InterviewHistoryProvider call(String id) =>
      InterviewHistoryProvider._(argument: id, from: this);

  @override
  String toString() => r'interviewHistoryProvider';
}
