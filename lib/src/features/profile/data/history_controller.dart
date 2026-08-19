import 'package:jobbridge_app/src/features/profile/data/history_repository.dart';
import 'package:jobbridge_app/src/features/profile/data/profile_controller.dart';
import 'package:jobbridge_app/src/features/profile/domain/history_record.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history_controller.g.dart';

/// Work experience records for the section at [path] (§5.1).
///
/// Keyed on the path rather than on nothing, because the schema publishes it —
/// see [HistoryRepository]. Two sections could not collide today, but a
/// provider keyed on the thing it fetches is the shape that stays correct if a
/// third arrives.
///
/// ## Invalidations, per the standing rule
///
/// Every mutation here refreshes **two** things:
///
/// 1. This list, because the server owns the ids and the ordering.
/// 2. The profile, because completeness is computed server-side (§5.3) and a
///    new work record can change it — so the ring is stale the instant a record
///    is added.
///
/// The second one is [ProfileEditor.refreshProfile] and **not**
/// `ref.invalidate(profileEditorProvider)`. Invalidating would refetch the
/// schema as well and, worse, discard whatever the user has typed into the main
/// form and not yet saved: adding a job would silently eat a half-filled name.
@riverpod
class ExperienceList extends _$ExperienceList {
  @override
  Future<List<ExperienceRecord>> build(String path) =>
      ref.watch(historyRepositoryProvider).listExperience(path);

  Future<void> add(ExperienceDraft draft) =>
      _write(() => ref.read(historyRepositoryProvider).add(path, draft));

  Future<void> replace(String id, ExperienceDraft draft) => _write(
    () => ref.read(historyRepositoryProvider).replace(path, id, draft),
  );

  Future<void> remove(String id) =>
      _write(() => ref.read(historyRepositoryProvider).remove(path, id));

  /// Runs a write, then re-reads both the list and the profile.
  ///
  /// The write is deliberately **not** wrapped in `AsyncValue.guard`: a failed
  /// save has to reach the editor that called it, so it can stay open with the
  /// user's input intact and show why. Turning it into an error state here
  /// would close the sheet and lose the entry.
  Future<void> _write(Future<void> Function() write) async {
    await write();
    state = await AsyncValue.guard(
      () => ref.read(historyRepositoryProvider).listExperience(path),
    );
    await ref.read(profileEditorProvider.notifier).refreshProfile();
  }
}

/// Education records for the section at [path] (§5.1).
///
/// Same two invalidations as [ExperienceList], for the same reasons.
@riverpod
class EducationList extends _$EducationList {
  @override
  Future<List<EducationRecord>> build(String path) =>
      ref.watch(historyRepositoryProvider).listEducation(path);

  Future<void> add(EducationDraft draft) =>
      _write(() => ref.read(historyRepositoryProvider).add(path, draft));

  Future<void> replace(String id, EducationDraft draft) => _write(
    () => ref.read(historyRepositoryProvider).replace(path, id, draft),
  );

  Future<void> remove(String id) =>
      _write(() => ref.read(historyRepositoryProvider).remove(path, id));

  Future<void> _write(Future<void> Function() write) async {
    await write();
    state = await AsyncValue.guard(
      () => ref.read(historyRepositoryProvider).listEducation(path),
    );
    await ref.read(profileEditorProvider.notifier).refreshProfile();
  }
}
