import 'package:flutter/foundation.dart';
import 'package:headhunter_app/src/core/l10n/locale_controller.dart';
import 'package:headhunter_app/src/features/profile/data/profile_repository.dart';
import 'package:headhunter_app/src/features/profile/domain/candidate_profile.dart';
import 'package:headhunter_app/src/features/profile/domain/field_schema.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_controller.g.dart';

/// The profile, its form, and whatever the user has typed but not yet saved.
@immutable
class ProfileEditorState {
  const ProfileEditorState({
    required this.profile,
    required this.schema,
    this.edits = const {},
    this.fieldErrors = const {},
    this.isSaving = false,
  });

  final CandidateProfile profile;
  final FieldSchema schema;

  /// Changed-but-unsaved values, keyed by field code.
  ///
  /// Held apart from [CandidateProfile.fields] rather than merged into it, so
  /// the `PATCH` can send **only what changed**. A full-document write would
  /// clobber whatever another device edited since this screen loaded, and the
  /// endpoint is partial precisely so that need not happen.
  final Map<String, Object?> edits;

  /// Server-side rejections from a 422, by field code.
  final Map<String, String> fieldErrors;

  final bool isSaving;

  bool get isDirty => edits.isNotEmpty;

  /// The value a widget should show: the pending edit if there is one, and
  /// otherwise what the server last said.
  ///
  /// `containsKey`, not a null check — an edit whose value *is* null means
  /// "clear this field", and treating that as "no edit" makes clearing a field
  /// impossible.
  Object? valueOf(String code) =>
      edits.containsKey(code) ? edits[code] : profile.fields[code];

  ProfileEditorState copyWith({
    CandidateProfile? profile,
    FieldSchema? schema,
    Map<String, Object?>? edits,
    Map<String, String>? fieldErrors,
    bool? isSaving,
  }) => ProfileEditorState(
    profile: profile ?? this.profile,
    schema: schema ?? this.schema,
    edits: edits ?? this.edits,
    fieldErrors: fieldErrors ?? this.fieldErrors,
    isSaving: isSaving ?? this.isSaving,
  );
}

/// Loads the candidate profile and the form that describes it (§5).
///
/// Two calls, in this order, because the second depends on the first: the
/// **category comes from the profile** and the schema is per-category (§5.2).
@riverpod
class ProfileEditor extends _$ProfileEditor {
  /// Which form to fetch before the server has derived a category.
  ///
  /// A category is derived from the primary occupation, so a profile that has
  /// not chosen one yet has none — but the form has to render anyway, or there
  /// is nowhere to choose the occupation *from*. Any category serves: the
  /// sections that matter here (personal, location, target work) are core and
  /// appear in all five. As soon as the server reports a real category the
  /// schema is refetched and any category-specific fields appear.
  static const _categoryBeforeOccupation = 'professional';

  @override
  Future<ProfileEditorState> build() async {
    // Watched: every label in the schema and every dictionary label under it is
    // locale-specific, so a language change has to refetch the form.
    ref.watch(activeLocaleProvider);

    final repository = ref.watch(profileRepositoryProvider);

    final profile = await repository.fetchProfile();
    final schema = await repository.fetchSchema(
      profile.category ?? _categoryBeforeOccupation,
    );

    for (final section in schema.sections) {
      if (section.unknownFieldCodes.isNotEmpty) {
        // Logged rather than swallowed: this is the server having added a field
        // type this app version cannot draw, and it explains a completeness
        // percentage the user cannot otherwise reach.
        debugPrint(
          '[schema] ${section.code}: unsupported field kinds for '
          '${section.unknownFieldCodes.join(', ')}',
        );
      }
    }

    return ProfileEditorState(profile: profile, schema: schema);
  }

  /// Records a local edit. Nothing is sent until [save].
  void edit(String code, Object? value) {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        edits: {...current.edits, code: value},
        // The old rejection described the old value.
        fieldErrors: {...current.fieldErrors}..remove(code),
      ),
    );
  }

  /// Sends the pending edits and adopts the recomputed profile.
  ///
  /// Completeness and the derived category are calculated server-side in the
  /// same transaction as the write, so the response — not any local guess — is
  /// what the screen then shows.
  ///
  /// Returns true when the write landed.
  Future<bool> save() async {
    final current = state.value;
    if (current == null || !current.isDirty || current.isSaving) return false;

    state = AsyncData(current.copyWith(isSaving: true, fieldErrors: const {}));

    try {
      final saved = await ref
          .read(profileRepositoryProvider)
          .patchProfile(current.edits);

      final categoryChanged = saved.category != current.profile.category;

      state = AsyncData(
        current.copyWith(
          profile: saved,
          // Cleared only on success. Keeping them after a failure is what lets
          // the user fix one field and retry without retyping the rest.
          edits: const {},
          isSaving: false,
        ),
      );

      // Choosing a primary occupation is what derives the category, and the
      // category decides which fields exist (§5.2). So the form itself has to
      // be refetched - the alternative is a saved profile whose category
      // fields are simply absent until the next cold start.
      if (categoryChanged) ref.invalidateSelf();

      return true;
    } on FieldValidationException catch (e) {
      state = AsyncData(
        current.copyWith(isSaving: false, fieldErrors: e.byCode),
      );
      rethrow;
    } on Object {
      state = AsyncData(current.copyWith(isSaving: false));
      rethrow;
    }
  }

  /// Sets search visibility (UAT-12). Applies immediately — it is a toggle, not
  /// part of the form's dirty set, and it deliberately does not refresh
  /// `lastMeaningfulUpdateAt`.
  Future<void> setVisibility(String visibility) async {
    final current = state.value;
    if (current == null) return;

    final saved = await ref
        .read(profileRepositoryProvider)
        .setVisibility(visibility);

    state = AsyncData(current.copyWith(profile: saved));
  }
}
