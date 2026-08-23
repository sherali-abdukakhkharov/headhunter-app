// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileRepository,
          ProfileRepository,
          ProfileRepository
        >
    with $Provider<ProfileRepository> {
  ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'4379d7128e304a20122a57ff9f8ae0d70de1cdbc';

/// The candidate's profile alone, without the form that describes it.
///
/// `ProfileEditor` fetches the profile **and** its category's schema, because
/// the editor cannot draw a field it has no description of. Home needs neither
/// the fields nor their descriptions — only how complete the profile is and
/// whether it can be found — so watching the editor there would spend a second
/// request on a form nobody opened.
///
/// The cost is that a candidate who opens Home and then their profile fetches
/// the profile twice. That is the cheaper half of the trade, and it is the
/// half that only happens when somebody navigates.

@ProviderFor(candidateProfile)
final candidateProfileProvider = CandidateProfileProvider._();

/// The candidate's profile alone, without the form that describes it.
///
/// `ProfileEditor` fetches the profile **and** its category's schema, because
/// the editor cannot draw a field it has no description of. Home needs neither
/// the fields nor their descriptions — only how complete the profile is and
/// whether it can be found — so watching the editor there would spend a second
/// request on a form nobody opened.
///
/// The cost is that a candidate who opens Home and then their profile fetches
/// the profile twice. That is the cheaper half of the trade, and it is the
/// half that only happens when somebody navigates.

final class CandidateProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<CandidateProfile>,
          CandidateProfile,
          FutureOr<CandidateProfile>
        >
    with $FutureModifier<CandidateProfile>, $FutureProvider<CandidateProfile> {
  /// The candidate's profile alone, without the form that describes it.
  ///
  /// `ProfileEditor` fetches the profile **and** its category's schema, because
  /// the editor cannot draw a field it has no description of. Home needs neither
  /// the fields nor their descriptions — only how complete the profile is and
  /// whether it can be found — so watching the editor there would spend a second
  /// request on a form nobody opened.
  ///
  /// The cost is that a candidate who opens Home and then their profile fetches
  /// the profile twice. That is the cheaper half of the trade, and it is the
  /// half that only happens when somebody navigates.
  CandidateProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'candidateProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$candidateProfileHash();

  @$internal
  @override
  $FutureProviderElement<CandidateProfile> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CandidateProfile> create(Ref ref) {
    return candidateProfile(ref);
  }
}

String _$candidateProfileHash() => r'3bd46b9fb567428aae89f5dd80a146ca4c429121';
