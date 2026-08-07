import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/features/candidate_search/data/candidate_search_repository.dart';
import 'package:headhunter_app/src/features/candidate_search/domain/candidate_card.dart';
import 'package:headhunter_app/src/features/dictionaries/domain/dictionary_type.dart';
import 'package:headhunter_app/src/features/dictionaries/presentation/dictionary_label.dart';

/// Employer candidate search (§7.1–§7.3).
///
/// ## Count before results (§7.2)
///
/// The count is asked for first and the results only on request. That is the
/// whole ergonomics of a filter builder: an employer narrowing a search wants
/// to know how many match before paying for a page of them.
///
/// **"200+" comes from `isExact`, never from comparing the number.** Reading
/// `count == 200` as capped would be wrong the day the server raises the cap,
/// and wrong today for a search that genuinely returns exactly two hundred.
class CandidateSearchScreen extends ConsumerStatefulWidget {
  const CandidateSearchScreen({super.key});

  @override
  ConsumerState<CandidateSearchScreen> createState() =>
      _CandidateSearchScreenState();
}

class _CandidateSearchScreenState extends ConsumerState<CandidateSearchScreen> {
  /// §7.1's filter set. Empty here — the builder UI is the next slice, and the
  /// endpoint treats an absent filter as "no constraint".
  final Map<String, dynamic> _filters = {};

  CandidateCount? _count;
  List<CandidateCard>? _results;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // The count is cheap and answers the first question, so it is asked
    // immediately; the results wait for a decision.
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshCount());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(HhSpace.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_count case final count?)
                    Text(
                      count.isExact
                          ? l10n.searchCountExact(count.count)
                          : l10n.searchCountCapped(count.count),
                      style: HhTypography.subtitle,
                    ),
                  const SizedBox(height: HhSpace.md),
                  HhButton(
                    label: l10n.searchRun,
                    iconPath: HhIconPath.search,
                    loading: _busy,
                    onPressed: _busy ? null : _run,
                  ),
                ],
              ),
            ),

            Expanded(child: _body(l10n)),
          ],
        ),
      ),
    );
  }

  Widget _body(AppL10n l10n) {
    if (_error case final message?) {
      return Padding(
        padding: const EdgeInsets.all(HhSpace.gutter),
        child: HhErrorState(
          title: l10n.stateErrorTitle,
          message: message,
          retryLabel: l10n.commonRetry,
          onRetry: _run,
        ),
      );
    }

    final results = _results;
    if (results == null) return const SizedBox.shrink();
    if (results.isEmpty) {
      return HhEmptyState(
        title: l10n.stateEmptyTitle,
        message: l10n.searchNoResults,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: HhSpace.gutter),
      itemCount: results.length,
      itemBuilder: (context, index) =>
          CandidateResultCard(card: results[index]),
    );
  }

  Future<void> _refreshCount() async {
    try {
      final count = await ref
          .read(candidateSearchRepositoryProvider)
          .count({'filters': _filters});
      if (mounted) setState(() => _count = count);
    } on ApiException catch (e) {
      // A count that cannot be fetched is not worth an error screen on its
      // own — the search button still works and will report properly.
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _run() async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final results = await ref
          .read(candidateSearchRepositoryProvider)
          .search({'filters': _filters});
      if (mounted) setState(() => _results = results);
      await _refreshCount();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// One candidate in the results (§7.3).
///
/// **There is deliberately no phone number here, and no way to add one.**
/// BR-09 and §11.1: a card is not a hiring interaction, so the rule never
/// opens for one. The model this renders has no phone field at all, which is
/// what makes the guarantee structural instead of a habit — and a test asserts
/// the rendered card contains no digits from a candidate's number.
class CandidateResultCard extends ConsumerStatefulWidget {
  const CandidateResultCard({required this.card, super.key});

  final CandidateCard card;

  @override
  ConsumerState<CandidateResultCard> createState() =>
      _CandidateResultCardState();
}

class _CandidateResultCardState extends ConsumerState<CandidateResultCard> {
  bool _busy = false;

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

            const SizedBox(height: HhSpace.sm),
            HhBadge(
              label: l10n.searchMatch(card.matchScore),
              tone: card.matchScore >= 70 ? HhTone.success : HhTone.neutral,
              iconPath: HhIconPath.checkCircle,
            ),

            const SizedBox(height: HhSpace.sm),
            HhButton.text(
              label: card.isSaved ? l10n.vacancySaved : l10n.vacancySave,
              onPressed: _busy ? null : _toggleSaved,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleSaved() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    try {
      await ref
          .read(candidateSearchRepositoryProvider)
          .setSaved(
            widget.card.candidateUserId,
            saved: !widget.card.isSaved,
          );

      ref.invalidate(savedCandidatesProvider);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
