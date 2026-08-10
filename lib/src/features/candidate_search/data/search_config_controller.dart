import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:headhunter_app/src/core/storage/preferences_provider.dart';
import 'package:headhunter_app/src/features/candidate_search/domain/search_filters.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_config_controller.g.dart';

/// The employer's current search configuration, kept between sessions.
///
/// ## Why it is persisted
///
/// §7.1's filter set has thirty-four fields. An employer who narrows a search
/// to eight of them and closes the app has done real work, and losing it is the
/// reason people stop using a filter builder and go back to scrolling.
///
/// ## The restrictions are persisted too, deliberately
///
/// A restored set includes any BR-12 age or gender filter **and the
/// justification it was declared with** — the two are stored together and
/// neither survives without the other ([CandidateSearchFilters.removing]). The
/// alternative, quietly dropping them on restore, trades one surprise for a
/// worse one: filters the employer set and can no longer see. What makes this
/// safe is that a restriction is never invisible — it is always one of the
/// applied-filter chips, and the server logs every search that uses one.
///
/// Stored in plain preferences rather than secure storage: a filter set is the
/// employer's own search, not anyone's personal data. No candidate appears in
/// it — only dictionary ids, numbers and dates.
@riverpod
class SearchConfigController extends _$SearchConfigController {
  static const _key = 'candidate_search.config';

  @override
  Future<SearchConfig> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    final raw = prefs.getString(_key);
    if (raw == null) return const SearchConfig();

    try {
      return SearchConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object catch (error) {
      // A stored config written by another build, or half-written. It is a
      // convenience, not data anyone can lose — start clean and say so in the
      // log rather than failing the screen it belongs to.
      debugPrint('[search] discarding unreadable saved filters — $error');
      return const SearchConfig();
    }
  }

  /// Applies a configuration and writes it back.
  ///
  /// State first, storage second: the screen re-queries on the new value, and
  /// making it wait for a disk write to render a filter change would be
  /// latency bought for nothing. A failed write costs the *next* session's
  /// restore, which is why it is logged rather than surfaced.
  Future<void> set(SearchConfig config) async {
    state = AsyncData(config);

    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setString(_key, jsonEncode(config.toJson()));
    } on Object catch (error) {
      debugPrint('[search] could not save filters — $error');
    }
  }

  /// UAT-06: replaces the configuration with one derived from a vacancy's
  /// requirements.
  ///
  /// The server turns the **mandatory** requirements into filters and
  /// deliberately leaves the preferred ones out — a preference that excluded
  /// candidates would not be a preference, and the match score rewards them
  /// instead. Mandatory skills arrive as match-all, which may match nobody:
  /// that is exactly what §7.2's count is for.
  ///
  /// It is a starting point, not a lock. Everything it sets is editable in the
  /// builder before anything is searched.
  Future<void> prefillFrom(
    String vacancyId,
    Map<String, dynamic> filters,
  ) => set(
    SearchConfig(
      filters: CandidateSearchFilters.fromJson(filters),
      // Carried so each card can say whether the candidate is already on this
      // vacancy's shortlist (§7.3).
      vacancyId: vacancyId,
    ),
  );
}
