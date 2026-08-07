// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads the candidate profile and the form that describes it (§5).
///
/// Two calls, in this order, because the second depends on the first: the
/// **category comes from the profile** and the schema is per-category (§5.2).

@ProviderFor(ProfileEditor)
final profileEditorProvider = ProfileEditorProvider._();

/// Loads the candidate profile and the form that describes it (§5).
///
/// Two calls, in this order, because the second depends on the first: the
/// **category comes from the profile** and the schema is per-category (§5.2).
final class ProfileEditorProvider
    extends $AsyncNotifierProvider<ProfileEditor, ProfileEditorState> {
  /// Loads the candidate profile and the form that describes it (§5).
  ///
  /// Two calls, in this order, because the second depends on the first: the
  /// **category comes from the profile** and the schema is per-category (§5.2).
  ProfileEditorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileEditorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileEditorHash();

  @$internal
  @override
  ProfileEditor create() => ProfileEditor();
}

String _$profileEditorHash() => r'3a95b4d2b65f12fcd692256cb3ee4c48e7ef61f4';

/// Loads the candidate profile and the form that describes it (§5).
///
/// Two calls, in this order, because the second depends on the first: the
/// **category comes from the profile** and the schema is per-category (§5.2).

abstract class _$ProfileEditor extends $AsyncNotifier<ProfileEditorState> {
  FutureOr<ProfileEditorState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ProfileEditorState>, ProfileEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ProfileEditorState>, ProfileEditorState>,
              AsyncValue<ProfileEditorState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
