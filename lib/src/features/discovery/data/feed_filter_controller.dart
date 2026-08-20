import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/storage/preferences_provider.dart';
import 'package:jobbridge_app/src/features/discovery/domain/feed_filters.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feed_filter_controller.g.dart';

/// The candidate's vacancy filters, kept between sessions (§5.5).
///
/// Persisted for the same reason the employer's search config is: somebody who
/// narrows a feed to their occupation and region has done work, and losing it
/// on every cold start is why people stop using filters and go back to
/// scrolling. Plain preferences rather than secure storage — a filter set is
/// dictionary ids, a number and a date, and names nobody.
///
/// ## The feed watches this rather than taking it as an argument
///
/// `vacancyFeedProvider` is keyed on `Feed` alone and reads the filters through
/// `ref.watch`, so a filter change re-runs the query without changing the
/// provider's identity. That keeps all eight existing `invalidate` call sites
/// working: every one of them names a feed, and none of them would know which
/// filter set to name if the filters were part of the key.
///
/// It also means [FeedFilters] needs a **deep `==`** — without it `ref.watch`
/// cannot tell a changed set from the same one and the feed either never
/// refreshes or refreshes on every rebuild.
@riverpod
class FeedFilterController extends _$FeedFilterController {
  static const _key = 'discovery.filters';

  @override
  Future<FeedFilters> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    final raw = prefs.getString(_key);
    if (raw == null) return const FeedFilters();

    try {
      return FeedFilters.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object catch (error) {
      // Written by another build, or half-written. A convenience rather than
      // data anyone can lose: start clean and log it instead of failing the
      // screen it belongs to.
      debugPrint('[discovery] discarding unreadable saved filters — $error');
      return const FeedFilters();
    }
  }

  /// Applies a filter set and writes it back.
  ///
  /// State first, storage second: the feed re-queries on the new value, and
  /// making a filter change wait for a disk write buys latency for nothing. A
  /// failed write costs the *next* session's restore, which is why it is logged
  /// rather than surfaced.
  Future<void> set(FeedFilters filters) async {
    state = AsyncData(filters);

    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setString(_key, jsonEncode(filters.toJson()));
    } on Object catch (error) {
      debugPrint('[discovery] could not save filters — $error');
    }
  }

  /// Back to an unfiltered feed.
  Future<void> clear() => set(const FeedFilters());
}
