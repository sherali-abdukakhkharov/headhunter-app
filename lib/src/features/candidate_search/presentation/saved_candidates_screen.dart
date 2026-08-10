import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/features/candidate_search/data/candidate_search_repository.dart';
import 'package:headhunter_app/src/features/candidate_search/presentation/candidate_search_screen.dart';

/// Opens the saved list (§7.3).
Future<void> showSavedCandidates(BuildContext context) =>
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(builder: (_) => const SavedCandidatesScreen()),
    );

/// Candidates this employer bookmarked (§7.3).
///
/// ## The list is still behind BR-02's gate, and that is not a bug
///
/// A candidate who hides their profile leaves every employer's saved list —
/// the server enforces it, so a save can shrink this screen without anything
/// having been un-saved. The alternative would defeat "hide me from search"
/// for whoever bookmarked the candidate first. The save itself survives, so
/// they reappear if the candidate chooses to be findable again; the empty
/// state therefore says "nothing here" rather than "you have saved nobody".
class SavedCandidatesScreen extends ConsumerWidget {
  const SavedCandidatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final saved = ref.watch(savedCandidatesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.searchSaved)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(savedCandidatesProvider),
          child: switch (saved) {
            AsyncValue(hasError: true, :final error?) => _scrollable(
              Padding(
                padding: const EdgeInsets.all(HhSpace.gutter),
                child: HhErrorState(
                  title: l10n.stateErrorTitle,
                  message: error is ApiException
                      ? error.message
                      : l10n.stateErrorBody,
                  retryLabel: l10n.commonRetry,
                  onRetry: () => ref.invalidate(savedCandidatesProvider),
                ),
              ),
            ),
            AsyncData(:final value) when value.isEmpty => _scrollable(
              HhEmptyState(
                title: l10n.stateEmptyTitle,
                message: l10n.searchSavedEmpty,
              ),
            ),
            AsyncData(:final value) => ListView.builder(
              padding: const EdgeInsets.all(HhSpace.gutter),
              itemCount: value.length,
              itemBuilder: (context, index) =>
                  CandidateResultCard(card: value[index]),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }

  /// `RefreshIndicator` only fires on a scrollable child, and neither the empty
  /// nor the error state is one — so pull-to-refresh would be dead on exactly
  /// the two screens where a user most wants to retry.
  Widget _scrollable(Widget child) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: child,
      ),
    ),
  );
}
