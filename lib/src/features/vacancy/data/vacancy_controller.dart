import 'package:flutter/foundation.dart';
import 'package:headhunter_app/src/core/l10n/locale_controller.dart';
import 'package:headhunter_app/src/features/profile/data/profile_repository.dart';
import 'package:headhunter_app/src/features/profile/domain/field_schema.dart';
import 'package:headhunter_app/src/features/vacancy/data/vacancy_repository.dart';
import 'package:headhunter_app/src/features/vacancy/domain/vacancy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vacancy_controller.g.dart';

/// One vacancy, its form, and whatever has been typed but not saved.
@immutable
class VacancyEditorState {
  const VacancyEditorState({
    required this.vacancy,
    required this.schema,
    this.edits = const {},
    this.fieldErrors = const {},
    this.isSaving = false,
  });

  final Vacancy vacancy;
  final FieldSchema schema;

  /// Changed-but-unsaved values, held apart so the `PATCH` sends only what
  /// changed — the same reasoning as the candidate profile.
  final Map<String, Object?> edits;

  final Map<String, String> fieldErrors;
  final bool isSaving;

  bool get isDirty => edits.isNotEmpty;

  Object? valueOf(String code) =>
      edits.containsKey(code) ? edits[code] : vacancy.fields[code];

  VacancyEditorState copyWith({
    Vacancy? vacancy,
    FieldSchema? schema,
    Map<String, Object?>? edits,
    Map<String, String>? fieldErrors,
    bool? isSaving,
  }) => VacancyEditorState(
    vacancy: vacancy ?? this.vacancy,
    schema: schema ?? this.schema,
    edits: edits ?? this.edits,
    fieldErrors: fieldErrors ?? this.fieldErrors,
    isSaving: isSaving ?? this.isSaving,
  );
}

/// Loads one vacancy and the form that describes it (§6.3).
///
/// Two calls in order, because the second depends on the first: **the category
/// comes from the vacancy** and the form is per-category, exactly as the
/// candidate profile works. A vacancy with no occupation chosen yet has no
/// category, and the form still has to render — there is nowhere to choose the
/// occupation from otherwise.
@riverpod
class VacancyEditor extends _$VacancyEditor {
  /// Which form to fetch before an occupation has derived a category.
  ///
  /// Any will do: the sections that matter at that point are core and appear
  /// in all of them. The schema is refetched as soon as the server reports a
  /// real category.
  static const _categoryBeforeOccupation = 'professional';

  @override
  Future<VacancyEditorState> build(String id) async {
    // Watched: every label in the schema is locale-specific.
    ref.watch(activeLocaleProvider);

    final vacancy = await ref.watch(vacancyRepositoryProvider).read(id);
    final schema = await ref
        .watch(profileRepositoryProvider)
        .fetchVacancySchema(vacancy.category ?? _categoryBeforeOccupation);

    return VacancyEditorState(vacancy: vacancy, schema: schema);
  }

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

  /// Sends the pending edits.
  ///
  /// Refetches the form when the category changed, for the same reason the
  /// candidate profile does: choosing an occupation is what derives the
  /// category, and the category decides which fields exist.
  Future<bool> save() async {
    final current = state.value;
    if (current == null || !current.isDirty || current.isSaving) return false;

    state = AsyncData(current.copyWith(isSaving: true, fieldErrors: const {}));

    try {
      final saved = await ref
          .read(vacancyRepositoryProvider)
          .patch(current.vacancy.id, current.edits);

      final categoryChanged = saved.category != current.vacancy.category;

      state = AsyncData(
        current.copyWith(vacancy: saved, edits: const {}, isSaving: false),
      );

      // The list shows status and title, both of which a write can change.
      ref.invalidate(myVacanciesProvider);
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

  /// `POST /submit` (§6.4, BR-12).
  ///
  /// Its 422 lands on the fields exactly as a save's does — the server answers
  /// one `required` violation per unfilled field precisely so each can be
  /// focused rather than summarised.
  Future<void> submit() async {
    final current = state.value;
    if (current == null || current.isSaving) return;

    state = AsyncData(current.copyWith(isSaving: true, fieldErrors: const {}));

    try {
      final saved = await ref
          .read(vacancyRepositoryProvider)
          .submit(current.vacancy.id);

      state = AsyncData(current.copyWith(vacancy: saved, isSaving: false));
      ref.invalidate(myVacanciesProvider);
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

  /// Pause, resume or close (§6.4). Closing is terminal (BR-11).
  Future<void> changeStatus(String status, {String? reason}) async {
    final current = state.value;
    if (current == null) return;

    final saved = await ref
        .read(vacancyRepositoryProvider)
        .changeStatus(current.vacancy.id, status, reason: reason);

    state = AsyncData(current.copyWith(vacancy: saved));
    ref.invalidate(myVacanciesProvider);
  }
}
