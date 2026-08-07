import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/features/applications/data/application_repository.dart';
import 'package:headhunter_app/src/features/dictionaries/domain/dictionary_type.dart';
import 'package:headhunter_app/src/features/dictionaries/presentation/dictionary_label.dart';
import 'package:headhunter_app/src/features/discovery/data/discovery_repository.dart';
import 'package:headhunter_app/src/features/discovery/domain/vacancy_card.dart';

/// The candidate's vacancy feeds (§5.6).
///
/// Three tabs over one list widget, because they differ only in which endpoint
/// fills them — recommended is ranked server-side, and ARCHITECTURE.md is
/// explicit that ranking stays there.
class VacancyFeedScreen extends ConsumerStatefulWidget {
  const VacancyFeedScreen({super.key});

  @override
  ConsumerState<VacancyFeedScreen> createState() => _VacancyFeedScreenState();
}

class _VacancyFeedScreenState extends ConsumerState<VacancyFeedScreen> {
  Feed _feed = Feed.recommended;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final items = ref.watch(vacancyFeedProvider(_feed));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(HhSpace.gutter),
              // Index-based, which is the component's contract. The order
              // here is `Feed.values`, so the two cannot drift.
              child: HhSegmented(
                labels: [
                  l10n.feedRecommended,
                  l10n.feedRecent,
                  l10n.feedSaved,
                ],
                selectedIndex: Feed.values.indexOf(_feed),
                onChanged: (index) =>
                    setState(() => _feed = Feed.values[index]),
              ),
            ),

            Expanded(
              child: switch (items) {
                // hasError first: retry is disabled app-wide, so a failure is
                // terminal and matching loading first spins over it forever.
                AsyncValue(hasError: true, :final error?) => Padding(
                  padding: const EdgeInsets.all(HhSpace.gutter),
                  child: HhErrorState(
                    title: l10n.stateErrorTitle,
                    message: error is ApiException
                        ? error.message
                        : l10n.stateErrorBody,
                    retryLabel: l10n.commonRetry,
                    onRetry: () =>
                        ref.invalidate(vacancyFeedProvider(_feed)),
                  ),
                ),
                AsyncData(:final value) when value.isEmpty => HhEmptyState(
                  title: l10n.stateEmptyTitle,
                  message: l10n.feedEmpty,
                ),
                AsyncData(:final value) => ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HhSpace.gutter,
                  ),
                  itemCount: value.length,
                  itemBuilder: (context, index) =>
                      VacancyFeedCard(card: value[index], feed: _feed),
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// One vacancy, with the actions §5.6 asks for.
class VacancyFeedCard extends ConsumerStatefulWidget {
  const VacancyFeedCard({required this.card, required this.feed, super.key});

  final VacancyCard card;
  final Feed feed;

  @override
  ConsumerState<VacancyFeedCard> createState() => _VacancyFeedCardState();
}

class _VacancyFeedCardState extends ConsumerState<VacancyFeedCard> {
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
            Text(
              card.title ?? l10n.vacancyUntitled,
              style: HhTypography.body.copyWith(fontWeight: FontWeight.w500),
            ),

            if (card.employer.name case final name? when name.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                name,
                style: HhTypography.caption.copyWith(
                  color: HhColors.inkMuted,
                ),
              ),
            ],

            // §5.6 puts verification on the vacancy itself, so a candidate can
            // weigh it without opening the employer.
            if (card.employer.isVerified) ...[
              const SizedBox(height: HhSpace.sm),
              HhBadge.verificationVerified(
                label: l10n.vacancyVerifiedEmployer,
              ),
            ],

            const SizedBox(height: HhSpace.sm),
            Text(_pay(card, l10n), style: HhTypography.caption),

            if (card.regionId case final regionId?) ...[
              const SizedBox(height: 2),
              DictionaryLabel(
                type: DictionaryType.region,
                id: regionId,
                style: HhTypography.caption.copyWith(
                  color: HhColors.inkMuted,
                ),
              ),
            ],

            if (card.deadlineOn case final deadline?) ...[
              const SizedBox(height: 2),
              Text(
                l10n.vacancyDeadline(deadline),
                style: HhTypography.caption.copyWith(
                  color: HhColors.inkMuted,
                ),
              ),
            ],

            const SizedBox(height: HhSpace.md),
            Row(
              children: [
                // BR-07 straight from the card: the server tells us the
                // caller's own stage, so Apply is offered exactly when there
                // is no live application — no cross-referencing a second list.
                if (card.hasApplied)
                  Expanded(
                    child: Text(
                      l10n.vacancyApplied,
                      style: HhTypography.caption.copyWith(
                        color: HhColors.success,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: HhButton.secondary(
                      label: l10n.vacancyApply,
                      compact: true,
                      expand: false,
                      loading: _busy,
                      onPressed: _busy ? null : _apply,
                    ),
                  ),

                HhButton.text(
                  label: card.isSaved ? l10n.vacancySaved : l10n.vacancySave,
                  onPressed: _busy ? null : _toggleSaved,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// A pay line, or the negotiable note.
  ///
  /// Digits are not localized: §8.3's display policy is still open, and a
  /// thousands separator invented here would have to be undone.
  String _pay(VacancyCard card, AppL10n l10n) {
    if (card.salaryIsNegotiable) return l10n.vacancyNegotiablePay;

    final from = card.salaryFrom;
    final to = card.salaryTo;
    if (from == null && to == null) return l10n.vacancyNegotiablePay;
    if (from != null && to != null) return '$from – $to';

    return '${from ?? to}';
  }

  Future<void> _apply() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    try {
      final repository = await ref.read(applicationRepositoryProvider.future);
      await repository.apply(widget.card.id);

      // Both: the feed carries applicationStatus on every card, and the
      // application list has a new row.
      ref
        ..invalidate(vacancyFeedProvider(widget.feed))
        ..invalidate(myApplicationsProvider);
    } on ApiException catch (e) {
      // BR-07's refusal arrives here when an application already exists —
      // the server's words, which name the reason.
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleSaved() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    try {
      await ref
          .read(discoveryRepositoryProvider)
          .setSaved(widget.card.id, saved: !widget.card.isSaved);

      // The saved feed is a different list from the one being looked at, and
      // both are now wrong.
      ref
        ..invalidate(vacancyFeedProvider(widget.feed))
        ..invalidate(vacancyFeedProvider(Feed.saved));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
