import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/candidate_search/data/candidate_search_repository.dart';
import 'package:jobbridge_app/src/features/candidate_search/presentation/candidate_search_screen.dart';
import 'package:jobbridge_app/src/features/candidate_search/presentation/find_candidates_action.dart';
import 'package:jobbridge_app/src/shared/widgets/refreshable_fill.dart';

/// One vacancy's shortlist (§7.3).
///
/// ## Why this is not just the saved list with a filter
///
/// Saving is about a person; shortlisting is about a person **for a role**. An
/// employer filling two vacancies keeps two shortlists and the same candidate
/// can be on both, on one, or on neither — so the vacancy is part of the
/// identity of the list rather than a filter over one.
///
/// ## It is behind BR-02's gate, like every other list of cards
///
/// The server re-runs its card query with "is on this vacancy's shortlist" as
/// the only condition, which means a candidate who hides their profile leaves
/// this screen **without having been removed from the shortlist**. They come
/// back if they choose to be findable again. That is why the empty state says
/// nobody is shortlisted rather than that the employer has shortlisted nobody:
/// the second would be a claim about what they did, and it can be false.
///
/// ## No match score
///
/// The cards carry one — the server scores every card in an unfiltered list
/// 100, because there was nothing to have matched — and painting it would
/// announce a perfect match for everyone on the shortlist. `showMatch: false`
/// for the same reason the saved list sets it.
class VacancyShortlistScreen extends ConsumerWidget {
  const VacancyShortlistScreen({required this.vacancyId, super.key});

  final String vacancyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final provider = vacancyShortlistProvider(vacancyId);
    final shortlist = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shortlistTitle)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(provider),
          child: switch (shortlist) {
            // hasError before loading: Riverpod's retry is off app-wide, so a
            // failure is terminal and matching loading first spins forever.
            AsyncValue(hasError: true, :final error?) => RefreshableFill(
              child: Padding(
                padding: const EdgeInsets.all(HhSpace.gutter),
                child: HhErrorState(
                  title: l10n.stateErrorTitle,
                  message: error is ApiException
                      ? error.message
                      : l10n.stateErrorBody,
                  retryLabel: l10n.commonRetry,
                  onRetry: () => ref.invalidate(provider),
                ),
              ),
            ),
            AsyncData(:final value) when value.isEmpty => RefreshableFill(
              child: HhEmptyState(
                title: l10n.stateEmptyTitle,
                message: l10n.shortlistEmpty,
                // The only thing that fills a shortlist is a search, and it is
                // two screens away otherwise. UAT-06's prefill means the search
                // it opens is already this vacancy's requirements.
                actionLabel: l10n.searchFromVacancy,
                onAction: () =>
                    findCandidatesForVacancy(context, ref, vacancyId),
              ),
            ),
            AsyncData(:final value) => ListView.builder(
              padding: const EdgeInsets.all(HhSpace.gutter),
              itemCount: value.length,
              itemBuilder: (context, index) => CandidateResultCard(
                card: value[index],
                // Which makes every card's toggle read "Shortlisted" and
                // remove on tap — this list is the one place where that is the
                // action an employer wants.
                vacancyId: vacancyId,
                showMatch: false,
              ),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }
}
