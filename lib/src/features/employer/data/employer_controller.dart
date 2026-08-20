import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/l10n/locale_controller.dart';
import 'package:jobbridge_app/src/features/employer/data/employer_repository.dart';
import 'package:jobbridge_app/src/features/employer/domain/employer_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'employer_controller.g.dart';

/// The employer profile, plus whatever has been typed and not yet saved.
///
/// [profile] is **null before the first save** — the state §6.1 calls "no
/// employer yet", where the only question is which kind this is.
@immutable
class EmployerEditorState {
  const EmployerEditorState({
    required this.type,
    this.profile,
    this.edits = const {},
    this.isSaving = false,
  });

  final EmployerProfile? profile;

  /// The chosen employer type. Comes from [profile] once one exists, and is
  /// **fixed from then on** — the server refuses a change with
  /// `employer.type_immutable`, so the UI must not offer one.
  final String type;

  /// Changed-but-unsaved values, keyed by the response field name.
  final Map<String, Object?> edits;

  final bool isSaving;

  bool get isDirty => edits.isNotEmpty;
  bool get isNew => profile == null;

  /// True once the type can no longer change.
  bool get typeLocked => profile != null;

  /// The value a widget should show: the pending edit if there is one, else
  /// what the server last said.
  ///
  /// `containsKey`, not a null check — an edit whose value *is* null means
  /// "clear this", and treating that as "no edit" makes clearing impossible.
  Object? valueOf(String field) {
    if (edits.containsKey(field)) return edits[field];
    return switch (field) {
      'contactPhone' => profile?.contactPhone,
      'regionId' => profile?.regionId,
      'districtId' => profile?.districtId,
      'address' => profile?.address,
      'description' => profile?.description,
      'fullName' => profile?.fullName,
      'legalName' => profile?.legalName,
      'publicName' => profile?.publicName,
      'industryId' => profile?.industryId,
      'contactPersonName' => profile?.contactPersonName,
      'logoFileId' => profile?.logoFileId,
      _ => null,
    };
  }

  EmployerEditorState copyWith({
    EmployerProfile? profile,
    String? type,
    Map<String, Object?>? edits,
    bool? isSaving,
  }) => EmployerEditorState(
    profile: profile ?? this.profile,
    type: type ?? this.type,
    edits: edits ?? this.edits,
    isSaving: isSaving ?? this.isSaving,
  );
}

/// Loads and writes the employer profile (§6.1).
@riverpod
class EmployerEditor extends _$EmployerEditor {
  @override
  Future<EmployerEditorState> build() async {
    // Watched: the profile's dictionary-backed fields resolve labels per
    // locale, and BR-03's reason text arrives translated.
    ref.watch(activeLocaleProvider);

    final profile = await ref.watch(employerRepositoryProvider).fetchProfile();

    return EmployerEditorState(
      profile: profile,
      // A company by default only until the first save; `type` then comes from
      // the server and stops being a choice.
      type: profile?.type ?? 'company',
    );
  }

  /// Chooses the employer type, before there is a profile.
  ///
  /// Refused once one exists: the server calls that `employer.type_immutable`,
  /// and offering a control that always fails is worse than not offering it.
  void chooseType(String type) {
    final current = state.value;
    if (current == null || current.typeLocked) return;

    // The other type's answers are dropped rather than carried across. They
    // would not be sent anyway — the server reads only the fields its type
    // declares — and keeping them makes the form show values that will vanish.
    state = AsyncData(current.copyWith(type: type, edits: const {}));
  }

  void edit(String field, Object? value) {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(edits: {...current.edits, field: value}),
    );
  }

  /// `PUT /employers/me` with the whole form.
  ///
  /// Returns true when the write landed.
  Future<bool> save() async {
    final current = state.value;
    if (current == null || current.isSaving) return false;

    state = AsyncData(current.copyWith(isSaving: true));

    try {
      final saved = await ref
          .read(employerRepositoryProvider)
          .save(_body(current));

      state = AsyncData(
        current.copyWith(
          profile: saved,
          type: saved.type,
          // Cleared only on success: keeping them after a failure is what lets
          // the user fix one field and retry without retyping the rest.
          edits: const {},
          isSaving: false,
        ),
      );

      return true;
    } on Object {
      state = AsyncData(current.copyWith(isSaving: false));
      rethrow;
    }
  }

  /// Everything the current type declares, because `PUT` replaces the whole
  /// record — a field left out is a field cleared.
  ///
  /// The other type's fields are **not** sent. They are meaningless to the
  /// server for this type, and sending them would be the client asserting a
  /// shape the contract does not have.
  Map<String, dynamic> _body(EmployerEditorState state) => {
    'type': state.type,
    for (final field in _sharedFields) field: state.valueOf(field),
    for (final field in state.type == 'company'
        ? _companyFields
        : _individualFields)
      field: state.valueOf(field),
  };

  static const _sharedFields = [
    'contactPhone',
    'regionId',
    'districtId',
    'address',
    'description',
  ];

  static const _companyFields = [
    'legalName',
    'publicName',
    'industryId',
    'contactPersonName',
    'logoFileId',
  ];

  static const _individualFields = ['fullName'];
}

/// Verification state and history (§6.1).
///
/// Separate from [EmployerEditor] because it is read far more often than the
/// profile is written, and because submitting must refresh it without
/// disturbing a form the user may be halfway through.
@riverpod
class Verification extends _$Verification {
  @override
  Future<VerificationState> build() =>
      ref.watch(employerRepositoryProvider).verification();

  /// Submits the collected evidence and re-reads both this and the profile.
  ///
  /// The profile too, because `verificationStatus` and `canPublish` live on it
  /// and BR-03 reads them — leaving it stale would show "you may not publish"
  /// beside a submission that just went under review.
  Future<void> submit(List<String> fileIds) async {
    await ref.read(employerRepositoryProvider).submitVerification(fileIds);

    ref
      ..invalidateSelf()
      ..invalidate(employerEditorProvider);
    await future;
  }
}
