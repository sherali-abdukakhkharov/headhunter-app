import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/format/moderation_reason.dart';
import 'package:jobbridge_app/src/core/format/vacancy_pay.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_decision.dart';
import 'package:jobbridge_app/src/features/admin/domain/moderation_decision.dart';
import 'package:jobbridge_app/src/features/admin/domain/moderation_queue_item.dart';
import 'package:jobbridge_app/src/features/admin/domain/vacancy_review.dart';
import 'package:jobbridge_app/src/features/admin/presentation/admin_decision_sheet.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_type.dart';
import 'package:jobbridge_app/src/features/dictionaries/presentation/dictionary_label.dart';
import 'package:jobbridge_app/src/features/discovery/presentation/vacancy_requirement_groups.dart';

/// One vacancy, read in full before §10.2's decision (BR-04, BR-12).
///
/// ## The restriction comes first, when there is one
///
/// §10.2 asks a moderator to review "conditional age/gender restrictions", and
/// BR-12 makes this queue the **only** route to publication for a vacancy that
/// carries one. So a restricted vacancy opens with the restriction, its
/// justification and the employer's own words — above the title, because it is
/// the reason the vacancy is on this screen rather than published already.
///
/// Everything else is in reading order: what the job is, what it pays, where
/// and when, then the description as written (§2.4) and the structured
/// requirements. The requirements use the same widget §5.6 renders for a
/// candidate, which is deliberate — a moderator who saw a *preference* drawn as
/// a requirement would reject a vacancy for a condition it never imposed.
///
/// ## Gone is a normal answer
///
/// A vacancy leaves moderation the moment anyone decides it, so a 404 here is
/// most often a colleague having got there first. It gets the same treatment
/// UAT-15 gives the candidate's detail screen: its own notice, a way back, and
/// **no retry** — retrying would fail identically.
///
/// ## The employer card was written before the server sent it
///
/// §10.2 lists the employer's contact information among what a moderator
/// reviews, and `VacancyReviewDto` carried neither a name nor a way to reach
/// them — only `employer_user_id`. The card was written against the fields
/// anyway and simply did not render while they were absent.
///
/// That was the whole bet, and it paid the next day: the join landed on
/// 2026-08-22 and the card lit up **on the next fetch, with no client
/// release**. The alternative — a second request per review to fetch the
/// employer — would have cost a round trip on every open and written an audit
/// entry (§11.1) for a contact nobody asked to see.
///
/// What did need a release is the shape being slightly different from the
/// guess: there is no e-mail anywhere in this product (login is phone + OTP,
/// §4.1), and there is a *third* field — the published company number beside
/// the account one. Which is the honest cost of the idiom, and a small one.
class VacancyReviewScreen extends ConsumerWidget {
  const VacancyReviewScreen({required this.vacancyId, super.key});

  final String vacancyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final review = ref.watch(vacancyForReviewProvider(vacancyId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminReviewTitle)),
      body: switch (review) {
        // 404 first, and separately: "somebody decided it" is an outcome and
        // everything else is a fault, and the two want different words and a
        // different set of actions.
        AsyncValue(hasError: true, error: final ApiException e)
            when e.statusCode == 404 =>
          ListView(
            padding: const EdgeInsets.all(HhSpace.gutter),
            children: [
              HhNotice(
                title: l10n.adminVacancyGoneTitle,
                message: l10n.adminVacancyGoneBody,
                iconPath: HhIconPath.infoCircle,
              ),
              const SizedBox(height: HhSpace.lg),
              HhButton.secondary(
                label: l10n.commonBack,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        AsyncValue(hasError: true, :final error?) => ListView(
          padding: const EdgeInsets.all(HhSpace.gutter),
          children: [
            HhErrorState(
              title: l10n.stateErrorTitle,
              message: error is ApiException
                  ? error.message
                  : l10n.stateErrorBody,
              retryLabel: l10n.commonRetry,
              onRetry: () =>
                  ref.invalidate(vacancyForReviewProvider(vacancyId)),
            ),
          ],
        ),
        AsyncData(:final value) => _Review(
          vacancyId: vacancyId,
          review: value,
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Review extends ConsumerWidget {
  const _Review({required this.vacancyId, required this.review});

  final String vacancyId;
  final VacancyReview review;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    return ListView(
      padding: const EdgeInsets.all(HhSpace.gutter),
      children: [
        if (review.restriction case final restriction?) ...[
          _Restriction(restriction: restriction),
          const SizedBox(height: HhSpace.sectionGap),
        ],

        if (review.moderationReason case final reason?) ...[
          // A vacancy round the loop a second time. Worth showing: a second
          // rejection for the same thing means the first reason did not land,
          // and that is the moderator's problem to fix rather than repeat.
          HhNotice.restricted(
            title: l10n.adminPreviousReason,
            // Verbatim when a moderator wrote it, worded when the server did
            // — this queue is where `restriction_changed_requires_review`
            // appears most often, since BR-12 is what puts a vacancy back in
            // it (MT-012).
            message: moderationReasonText(reason, l10n),
          ),
          const SizedBox(height: HhSpace.sectionGap),
        ],

        Text(
          review.title ?? l10n.vacancyUntitled,
          style: HhTypography.title,
        ),
        if (review.occupationId case final occupationId?) ...[
          const SizedBox(height: HhSpace.xs),
          DictionaryLabel(
            type: DictionaryType.occupation,
            id: occupationId,
            style: HhTypography.caption,
          ),
        ],

        const SizedBox(height: HhSpace.md),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: HhSpace.sm,
            runSpacing: HhSpace.xs,
            children: [
              HhMetaChip(label: _pay(ref, l10n), iconPath: HhIconPath.wallet),
              if (review.workerCount case final count?)
                HhMetaChip(
                  label: l10n.vacancyOpenings(count),
                  iconPath: HhIconPath.people,
                ),
              if (review.deadlineOn case final deadline?)
                HhMetaChip(
                  label: l10n.vacancyDeadline(deadline),
                  iconPath: HhIconPath.calendar,
                ),
              if (_window(l10n) case final window?)
                HhMetaChip(label: window, iconPath: HhIconPath.clock),
            ],
          ),
        ),

        if (review.hasEmployerContact) ...[
          const SizedBox(height: HhSpace.sectionGap),
          Text(l10n.adminVacancyEmployer, style: HhTypography.label),
          const SizedBox(height: HhSpace.sm),
          _Employer(review: review),
        ],

        const SizedBox(height: HhSpace.sectionGap),
        Text(l10n.adminVacancyWhere, style: HhTypography.label),
        const SizedBox(height: HhSpace.sm),
        HhCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dictionary ids resolved to labels (BR-13), and **both** are
              // `region`: districts are rows in the region dictionary under a
              // parent, which is what makes §5.1's cascade one dictionary
              // rather than two. District under region rather than instead of
              // it — the candidate's detail screen shows only the narrower one,
              // and a moderator judging where the work is wants the pair.
              if (review.regionId case final regionId?)
                DictionaryLabel(
                  type: DictionaryType.region,
                  id: regionId,
                  style: HhTypography.body,
                ),
              if (review.districtId case final districtId?)
                DictionaryLabel(
                  type: DictionaryType.region,
                  id: districtId,
                  style: HhTypography.caption,
                ),
              if (review.address case final address?) ...[
                const SizedBox(height: HhSpace.xs),
                // Written by the employer, shown as written (§2.4).
                Text(address, style: HhTypography.caption),
              ],
            ],
          ),
        ),

        if (review.description case final description?) ...[
          const SizedBox(height: HhSpace.sectionGap),
          Text(l10n.vacancyDescription, style: HhTypography.label),
          const SizedBox(height: HhSpace.sm),
          HhCard(child: Text(description, style: HhTypography.body)),
        ],

        if (review.requirements.isNotEmpty) ...[
          const SizedBox(height: HhSpace.sectionGap),
          Text(l10n.vacancyRequirements, style: HhTypography.label),
          const SizedBox(height: HhSpace.sm),
          VacancyRequirementGroups(
            requirements: review.requirements,
            category: review.category,
          ),
        ],

        const SizedBox(height: HhSpace.sectionGap),
        // Approve first: the common case in a moderation queue is a posting
        // that is fine, and BR-04 makes approving the act that publishes it.
        HhButton(
          label: l10n.adminPublish,
          onPressed: () => _decide(context, ref, ModerationDecision.approve),
        ),
        const SizedBox(height: HhSpace.sm),
        HhButton.secondary(
          label: l10n.adminSendBack,
          onPressed: () => _decide(context, ref, ModerationDecision.reject),
        ),
      ],
    );
  }

  /// Pay as the employer set it, or the negotiable line.
  ///
  /// Nothing is computed: §12.3.1 puts amounts on the server, and these two
  /// integers are rendered rather than combined into a monthly equivalent or
  /// converted. `salaryIsNegotiable` wins over a range, because that is the
  /// server's own precedence — the vacancy form discards a typed range when
  /// negotiable is set.
  String _pay(WidgetRef ref, AppL10n l10n) => formatPay(
    l10n,
    negotiable: review.salaryIsNegotiable,
    from: review.salaryFrom,
    to: review.salaryTo,
    period: optionalLabel(
      ref,
      type: DictionaryType.paymentPeriod,
      id: review.salaryPeriodId,
    ),
  );

  /// The work window (§6.3, UAT-10), or null when neither date is set.
  ///
  /// A start with no end is its own sentence rather than an open-ended range:
  /// "from 1 June –" reads as a missing value.
  String? _window(AppL10n l10n) {
    final start = review.startsOn;
    final end = review.endsOn;

    if (start != null && end != null) return l10n.vacancyWorkWindow(start, end);
    if (start != null) return l10n.vacancyStartsOn(start);

    return null;
  }

  Future<void> _decide(
    BuildContext context,
    WidgetRef ref,
    ModerationDecision decision,
  ) async {
    final l10n = AppL10n.of(context);
    final navigator = Navigator.of(context);

    final outcome = await showAdminDecisionSheet(
      context,
      title: decision == ModerationDecision.approve
          ? l10n.adminPublishTitle
          : l10n.adminSendBackTitle,
      subject: review.title ?? l10n.vacancyUntitled,
      body: decision == ModerationDecision.approve
          ? l10n.adminPublishBody
          : l10n.adminSendBackBody,
      confirmLabel: decision == ModerationDecision.approve
          ? l10n.adminPublish
          : l10n.adminSendBack,
      needsReason: decision.needsReason,
      send: (input) => ref
          .read(adminRepositoryProvider)
          .moderateVacancy(vacancyId, decision, reason: input.reason),
    );

    if (outcome == AdminDecisionOutcome.dismissed) return;

    // The row leaves on a 409 as well as on success — the vacancy is out of
    // moderation either way — and §10.1's counter moved with it.
    ref.read(moderationQueueProvider.notifier).remove(vacancyId);
    ref.invalidate(adminDashboardProvider);

    // Back to the queue rather than staying on a review of a vacancy that is
    // no longer under moderation: reloading this screen would 404, and the next
    // decision is one row down.
    if (outcome == AdminDecisionOutcome.sent && context.mounted) {
      HhToast.show(context, message: l10n.adminDecisionRecorded);
    }
    await navigator.maybePop();
  }
}

/// Whose vacancy this is, and how to reach them (§10.2).
///
/// Placed above the description rather than beside the buttons: a moderator
/// looking for a phone number is usually looking because something in the
/// posting needs asking about, and that happens while reading it.
///
/// ## Two numbers, and the labels are the point
///
/// The server sends the **published** company number and the **account**
/// number as separate fields rather than one `COALESCE`, because they can
/// differ and a moderator about to dial should know which they have. So the
/// published one leads — §6.1 makes it mandatory, it is what the employer
/// chose to be reached on, and calling somebody's login identity about a job
/// posting is the wrong number to have picked.
///
/// The account number stays rather than being hidden, because it is §10.4's
/// user-search key: a moderator who wants this employer's whole history has
/// the string to paste. When the two agree — a sole trader who published the
/// number they signed up with — only one is drawn, because one number under two
/// labels reads as a data error.
///
/// Only the fields that arrived are drawn, and there is no "not provided" row:
/// an employer whose profile is incomplete is a real state, and reporting it
/// as a gap in the response would be reporting our own backlog.
class _Employer extends StatelessWidget {
  const _Employer({required this.review});

  final VacancyReview review;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return HhCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The employer's own name, never translated (§2.4).
          if (review.employerName case final name?)
            Text(name, style: HhTypography.body),

          if (review.employerContactPhone case final phone?) ...[
            const SizedBox(height: HhSpace.sm),
            Text(
              l10n.adminVacancyEmployerContactPhone,
              style: HhTypography.label,
            ),
            // Rendered, not dialled. A `tel:` link needs url_launcher, and the
            // one native capability this app has is the FileProvider channel —
            // see ARCHITECTURE.md §9 before adding a plugin to reach the
            // platform.
            Text(phone, style: HhTypography.body),
          ],

          if (!review.employerPhonesAgree)
            if (review.employerPhone case final phone?) ...[
              const SizedBox(height: HhSpace.sm),
              Text(l10n.adminVacancyEmployerPhone, style: HhTypography.label),
              Text(phone, style: HhTypography.body),
            ],
        ],
      ),
    );
  }
}

/// §10.2's BR-12 restriction, and what a moderator is being asked to judge.
class _Restriction extends StatelessWidget {
  const _Restriction({required this.restriction});

  final VacancyRestriction restriction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return HhCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HhBadge(
            label: l10n.vacancyRestrictionTitle,
            tone: HhTone.warning,
            iconPath: HhIconPath.alertTriangle,
          ),
          const SizedBox(height: HhSpace.sm),
          Text(
            l10n.adminRestrictionJudge,
            style: HhTypography.body.copyWith(color: HhColors.inkMuted),
          ),

          if (_ageRange case final range?) ...[
            const SizedBox(height: HhSpace.md),
            Text(l10n.adminRestrictionAge, style: HhTypography.label),
            Text(range, style: HhTypography.body),
          ],

          if (restriction.genderId case final genderId?) ...[
            const SizedBox(height: HhSpace.md),
            Text(l10n.adminRestrictionGender, style: HhTypography.label),
            DictionaryLabel(
              type: DictionaryType.gender,
              id: genderId,
              style: HhTypography.body,
            ),
          ],

          if (restriction.justificationId case final justificationId?) ...[
            const SizedBox(height: HhSpace.md),
            Text(l10n.adminRestrictionReason, style: HhTypography.label),
            DictionaryLabel(
              type: DictionaryType.restrictionJustification,
              id: justificationId,
              style: HhTypography.body,
            ),
          ],

          if (restriction.justificationNote case final note?) ...[
            const SizedBox(height: HhSpace.md),
            Text(l10n.adminRestrictionNote, style: HhTypography.label),
            // The employer's argument, verbatim (§2.4). A moderator judging a
            // paraphrase would be judging something the employer did not say.
            Text(note, style: HhTypography.body),
          ],
        ],
      ),
    );
  }

  /// The age bound as one line, with an open end where only one was set.
  String? get _ageRange {
    final min = restriction.ageMin;
    final max = restriction.ageMax;

    if (min != null && max != null) return '$min – $max';
    if (min != null) return '$min +';
    if (max != null) return '– $max';

    return null;
  }
}
