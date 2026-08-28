import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/candidate_search/data/candidate_search_repository.dart';
import 'package:jobbridge_app/src/features/candidate_search/data/search_config_controller.dart';
import 'package:jobbridge_app/src/features/candidate_search/domain/candidate_card.dart';
import 'package:jobbridge_app/src/features/candidate_search/domain/search_filters.dart';
import 'package:jobbridge_app/src/features/candidate_search/presentation/applied_filter_chips.dart';
import 'package:jobbridge_app/src/features/candidate_search/presentation/candidate_detail_screen.dart';
import 'package:jobbridge_app/src/features/candidate_search/presentation/filter_builder_screen.dart';
import 'package:jobbridge_app/src/features/candidate_search/presentation/saved_candidates_screen.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_type.dart';
import 'package:jobbridge_app/src/features/dictionaries/presentation/dictionary_label.dart';
import 'package:jobbridge_app/src/features/invitations/presentation/sent_invitations_screen.dart';

/// Employer candidate search (§7.1–§7.3).
///
/// ## Count before results (§7.2)
///
/// The count is asked for on every filter change; the results are asked for
/// when the employer says so. That is the whole ergonomics of a filter builder:
/// someone narrowing a search wants to know how many match before paying for a
/// page of them, and "212 candidates" is the signal that the filters are still
/// too loose.
///
/// **"200+" comes from `isExact`, never from comparing the number.** Reading
/// `count == 200` as capped would be wrong the day the server raises the cap,
/// and wrong today for a search that genuinely returns exactly two hundred.
///
/// ## Changing a filter invalidates the results, and says so
///
/// Editing the filters clears the result list rather than leaving it under a
/// new count. A list of candidates that no longer matches the filters above it
/// is the one state a search screen must never be in — every card in it is an
/// answer to a question that is no longer on screen.
class CandidateSearchScreen extends ConsumerStatefulWidget {
  const CandidateSearchScreen({super.key});

  @override
  ConsumerState<CandidateSearchScreen> createState() =>
      _CandidateSearchScreenState();
}

class _CandidateSearchScreenState extends ConsumerState<CandidateSearchScreen> {
  /// One page. The server caps a request at 50 and the count at 200, so this is
  /// about scroll length rather than about the size of the answer.
  static const _pageSize = 20;

  CandidateCount? _count;
  List<CandidateCard>? _results;
  ApiException? _error;
  bool _busy = false;
  bool _hasMore = false;

  /// The configuration the visible [_count] and [_results] were produced from.
  ///
  /// Not the same thing as the current configuration: the point of the whole
  /// screen is that those two can differ while the employer is deciding.
  SearchConfig? _shown;

  @override
  void initState() {
    super.initState();
    // §7.2's count is cheap and answers the first question, so the saved
    // filters are counted as soon as they are readable. Post-frame because the
    // stored set arrives asynchronously and the first build must not wait for
    // a disk read to paint the filters it already knows.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final config = await ref.read(searchConfigControllerProvider.future);
      if (mounted) await _refreshCount(config);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final config = ref.watch(searchConfigControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: switch (config) {
          // hasError before loading — Riverpod's retry is off app-wide, so a
          // failed read of the saved filters is terminal, not a slow one.
          AsyncValue(hasError: true, :final error) => Padding(
            padding: const EdgeInsets.all(HhSpace.gutter),
            child: HhErrorState(
              title: l10n.stateErrorTitle,
              message: l10n.stateErrorBody,
              retryLabel: l10n.commonRetry,
              onRetry: () {
                debugPrint('[search] saved filters unreadable — $error');
                ref.invalidate(searchConfigControllerProvider);
              },
            ),
          ),
          AsyncData(:final value) => _loaded(l10n, value),
          _ => const HhSkeletonList(item: HhCandidateCardSkeleton()),
        },
      ),
    );
  }

  Widget _loaded(AppL10n l10n, SearchConfig config) {
    // The count belongs to whatever was last asked for. Showing the previous
    // filter set's count above a new one would be a wrong answer, not a stale
    // one, so it is simply absent until the new count arrives.
    final countIsCurrent = _shown != null && _sameFilters(_shown!, config);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(HhSpace.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title on its own line, actions beneath it.
              //
              // They shared a row until the sent-invitation list needed a third
              // place in it: title, saved, filters was already tight, and at
              // 2.0x text scale a fourth child left the title about twelve
              // points to lay "Search candidates" out in. Nothing overflowed —
              // an `Expanded` `Text` wraps — it simply became one word per
              // line, which is the failure mode a layout test does not catch.
              Text(l10n.searchCandidates, style: HhTypography.title),
              const SizedBox(height: HhSpace.sm),
              Row(
                children: [
                  IconButton(
                    onPressed: () => showSavedCandidates(context),
                    tooltip: l10n.searchSaved,
                    icon: const HhIcon(
                      HhIconPath.bookmark,
                      size: 22,
                      color: HhColors.brand600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => showSentInvitations(context),
                    tooltip: l10n.invitationsSentTitle,
                    // The same glyph `HhBadge.invitationSent` carries: within
                    // this product a paper plane means an invitation, and the
                    // badge rule that no glyph means two things holds outside
                    // the badges too.
                    icon: const HhIcon(
                      HhIconPath.send,
                      size: 22,
                      color: HhColors.brand600,
                    ),
                  ),
                  const Spacer(),
                  HhButton.secondary(
                    label: l10n.filtersEdit,
                    iconPath: HhIconPath.filters,
                    compact: true,
                    expand: false,
                    onPressed: () => _editFilters(config),
                  ),
                ],
              ),

              // UAT-06: a prefilled search must say it was prefilled. The
              // filters below it are the vacancy's, and an employer who did not
              // set them has to be able to tell.
              if (config.vacancyId != null) ...[
                const SizedBox(height: HhSpace.md),
                HhMetaChip(
                  label: l10n.searchScopedToVacancy,
                  iconPath: HhIconPath.briefcase,
                ),
              ],

              const SizedBox(height: HhSpace.md),
              AppliedFilterChips(
                filters: config.filters,
                onChanged: (next) => _apply(config.withFilters(next)),
              ),

              const SizedBox(height: HhSpace.md),
              if (countIsCurrent && _count != null)
                Text(
                  _count!.isExact
                      ? l10n.searchCountExact(_count!.count)
                      : l10n.searchCountCapped(_count!.count),
                  style: HhTypography.subtitle,
                ),

              const SizedBox(height: HhSpace.md),
              HhButton(
                label: l10n.searchRun,
                iconPath: HhIconPath.search,
                loading: _busy,
                onPressed: _busy ? null : () => _run(config),
              ),
            ],
          ),
        ),

        Expanded(child: _body(l10n, config)),
      ],
    );
  }

  Widget _body(AppL10n l10n, SearchConfig config) {
    if (_error case final message?) {
      return Padding(
        padding: const EdgeInsets.all(HhSpace.gutter),
        child: HhErrorState(
          title: failureTitle(message, l10n),
          message: message.message,
          retryLabel: l10n.commonRetry,
          onRetry: () => _run(config),
        ),
      );
    }

    final results = _results;
    final shown = _shown;

    // The class doc promises a result list never sits under filters it does not
    // answer, and clearing on edit is not enough on its own: a prefill arrives
    // from the vacancy editor (UAT-06), which writes the configuration and
    // navigates here without going through `_apply`. This screen keeps its
    // state across tab switches, so the previous search's cards would otherwise
    // still be on screen under somebody else's requirements.
    if (results == null || shown == null || !_answers(shown, config)) {
      return const SizedBox.shrink();
    }

    if (results.isEmpty) {
      return HhEmptyState(
        title: l10n.stateEmptyTitle,
        message: l10n.searchNoResults,
        art: HhSpotArt.filter,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: HhSpace.gutter),
      itemCount: results.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == results.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: HhSpace.md),
            child: HhButton.secondary(
              label: l10n.commonLoadMore,
              loading: _busy,
              onPressed: _busy ? null : () => _run(config, more: true),
            ),
          );
        }

        return CandidateResultCard(
          card: results[index],
          // The vacancy the *results* were fetched under, not the one currently
          // configured. They are the same here — a difference is what
          // `_answers` refuses to paint — and taking it from `shown` is what
          // keeps `isShortlisted` on each card and the vacancy the toggle
          // writes to the same vacancy.
          vacancyId: shown.vacancyId,
        );
      },
    );
  }

  /// Whether [shown]'s results are an answer to [current].
  ///
  /// The vacancy matters as well as the filters: it decides `isShortlisted` on
  /// every card, so results fetched for one vacancy would mislabel the
  /// shortlist of another.
  static bool _answers(SearchConfig shown, SearchConfig current) =>
      _sameFilters(shown, current) && shown.vacancyId == current.vacancyId;

  Future<void> _editFilters(SearchConfig config) async {
    final edited = await showFilterBuilder(context, initial: config);
    if (edited != null) await _apply(edited);
  }

  /// Applies a new configuration: persist it, drop results that no longer
  /// answer it, and ask for the new count.
  Future<void> _apply(SearchConfig config) async {
    setState(() {
      _results = null;
      _hasMore = false;
      _error = null;
    });

    await ref.read(searchConfigControllerProvider.notifier).set(config);
    await _refreshCount(config);
  }

  Future<void> _refreshCount(SearchConfig config) async {
    try {
      final count = await ref
          .read(candidateSearchRepositoryProvider)
          .count(config.toJson());

      if (!mounted) return;
      setState(() {
        _count = count;
        _shown = config;
      });
    } on ApiException catch (e) {
      // A count that will not load is not worth replacing the screen over: the
      // search button still works and reports properly. It does have to stop
      // claiming a number, though.
      if (!mounted) return;
      setState(() {
        _count = null;
        _shown = null;
        _error = e;
      });
    }
  }

  Future<void> _run(SearchConfig config, {bool more = false}) async {
    setState(() {
      _busy = true;
      _error = null;
    });

    final offset = more ? _results?.length ?? 0 : 0;

    try {
      final page = await ref
          .read(candidateSearchRepositoryProvider)
          .search({...config.toJson(), 'limit': _pageSize, 'offset': offset});

      if (mounted) {
        setState(() {
          _results = more ? [...?_results, ...page] : page;
          // A short page is the last page. Asking the server for a total would
          // cost a second query to learn something the page already implies.
          _hasMore = page.length == _pageSize;
        });
      }

      await _refreshCount(config);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Whether two configurations would produce the same count.
  ///
  /// The sort is excluded on purpose: it reorders the same set, so a count
  /// computed under one sort is exactly right under another.
  static bool _sameFilters(SearchConfig a, SearchConfig b) =>
      a.filters.toJson().toString() == b.filters.toJson().toString();
}

/// One candidate in the results (§7.3).
///
/// **There is deliberately no phone number here, and no way to add one.**
/// BR-09 and §11.1: a card is not a hiring interaction, so the rule never
/// opens for one. The model this renders has no phone field at all, which is
/// what makes the guarantee structural instead of a habit — and a test asserts
/// the rendered card contains no digits from a candidate's number.
///
/// ## Two of the actions depend on where the card is
///
/// **Shortlisting needs a vacancy**, so [vacancyId] decides whether the action
/// exists at all rather than whether it is enabled. A shortlist is per-vacancy
/// (§7.3) and `isShortlisted` is only meaningful when the request that produced
/// the card named one — in the saved list it is false for everybody, including
/// people who *are* shortlisted somewhere.
///
/// **The match score is only a number where a filter set produced it.** With no
/// filters the server has nothing to have matched and scores every card 100, so
/// the saved list and a shortlist would each claim a perfect match for everyone
/// on them. That reads as a computed result and is not one, which is why
/// [showMatch] is false in both.
class CandidateResultCard extends ConsumerStatefulWidget {
  const CandidateResultCard({
    required this.card,
    this.vacancyId,
    this.showMatch = true,
    super.key,
  });

  final CandidateCard card;

  /// The vacancy this card is being looked at for, if any. Enables §7.3's
  /// shortlist toggle.
  final String? vacancyId;

  /// Whether [CandidateCard.matchScore] answers a question somebody asked.
  final bool showMatch;

  @override
  ConsumerState<CandidateResultCard> createState() =>
      _CandidateResultCardState();
}

class _CandidateResultCardState extends ConsumerState<CandidateResultCard> {
  bool _busy = false;

  /// Local overrides for the two flags this card can change.
  ///
  /// The card is handed a value from a list its parent loaded, and the toggles
  /// below write to the server rather than to that list — so without these the
  /// button says "Save" again the moment the request succeeds, which reads as
  /// the save having failed. Re-fetching the whole list to move one label would
  /// also reorder the rows under the finger that tapped.
  bool? _saved;
  bool? _shortlisted;

  bool get _isSaved => _saved ?? widget.card.isSaved;
  bool get _isShortlisted => _shortlisted ?? widget.card.isShortlisted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final card = widget.card;

    return Padding(
      padding: const EdgeInsets.only(bottom: HhSpace.sm),
      child: HhCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (card.fullName case final name? when name.isNotEmpty)
              Text(
                name,
                style: HhTypography.body.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),

            if (card.currentRoleTitle case final role? when role.isNotEmpty)
              Text(
                role,
                style: HhTypography.caption.copyWith(
                  color: HhColors.inkMuted,
                ),
              ),

            if (card.regionId case final regionId?)
              DictionaryLabel(
                type: DictionaryType.region,
                id: regionId,
                style: HhTypography.caption.copyWith(
                  color: HhColors.inkMuted,
                ),
              ),

            const SizedBox(height: 2),
            Text(
              l10n.searchExperienceYears(card.experienceYears),
              style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
            ),

            // And only where the server actually matched something. With no
            // filters it has nothing to have matched and scores every card
            // 100, which reads as a computed judgement about a person and is
            // not one. `matchBreakdown` is the server's own evidence that a
            // requirement was weighed, so it is the gate rather than the
            // client's idea of which list this is.
            if (widget.showMatch && card.matchBreakdown.isNotEmpty) ...[
              const SizedBox(height: HhSpace.sm),
              HhBadge(
                label: l10n.searchMatch(card.matchScore),
                tone: card.matchScore >= 70 ? HhTone.success : HhTone.neutral,
                iconPath: HhIconPath.checkCircle,
              ),
            ],

            const SizedBox(height: HhSpace.sm),
            // A Wrap rather than a Row: three text actions fit at 360pt, and at
            // 2.0x text scale they do not. Wrapping to a second line is the one
            // failure mode here that still leaves every action reachable.
            Wrap(
              spacing: HhSpace.md,
              children: [
                // §7.3's "View profile" — and the *only* place on this screen
                // where BR-09 can open at all. The card carries nothing that
                // opening the profile would reveal; the server re-decides, and
                // logs the read (§11.1).
                HhButton.text(
                  label: l10n.candidateViewProfile,
                  onPressed: () => showCandidateDetail(
                    context,
                    candidateUserId: card.candidateUserId,
                  ),
                ),
                HhButton.text(
                  label: _isSaved ? l10n.vacancySaved : l10n.vacancySave,
                  onPressed: _busy ? null : _toggleSaved,
                ),
                // Only with a vacancy to shortlist *to* — see the class doc.
                if (widget.vacancyId != null)
                  HhButton.text(
                    label: _isShortlisted
                        ? l10n.searchShortlisted
                        : l10n.searchShortlist,
                    onPressed: _busy ? null : _toggleShortlisted,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleSaved() async {
    final messenger = ScaffoldMessenger.of(context);
    final next = !_isSaved;
    setState(() => _busy = true);

    try {
      await ref
          .read(candidateSearchRepositoryProvider)
          .setSaved(widget.card.candidateUserId, saved: next);

      ref.invalidate(savedCandidatesProvider);
      if (mounted) setState(() => _saved = next);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// §7.3's shortlist, which is per-vacancy.
  ///
  /// The vacancy's own list is invalidated by name rather than every shortlist:
  /// un-shortlisting somebody while looking at that vacancy's shortlist has to
  /// remove the row, and no other vacancy's list changed.
  Future<void> _toggleShortlisted() async {
    final vacancyId = widget.vacancyId;
    if (vacancyId == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final next = !_isShortlisted;
    setState(() => _busy = true);

    try {
      await ref
          .read(candidateSearchRepositoryProvider)
          .setShortlisted(
            vacancyId,
            widget.card.candidateUserId,
            shortlisted: next,
          );

      ref.invalidate(vacancyShortlistProvider(vacancyId));
      if (mounted) setState(() => _shortlisted = next);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
