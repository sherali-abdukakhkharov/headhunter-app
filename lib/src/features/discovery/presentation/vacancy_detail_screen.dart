import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/applications/data/application_repository.dart';
import 'package:jobbridge_app/src/features/applications/presentation/applications_screen.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_type.dart';
import 'package:jobbridge_app/src/features/dictionaries/presentation/dictionary_label.dart';
import 'package:jobbridge_app/src/features/discovery/data/discovery_repository.dart';
import 'package:jobbridge_app/src/features/discovery/domain/vacancy_detail.dart';
import 'package:jobbridge_app/src/features/profile/domain/field_schema.dart';

/// Opens one vacancy in full (§5.6).
///
/// Root navigator and no route, like the other detail surfaces: a vacancy id is
/// linkable in principle, but deep links are M8's — introducing a path here
/// would create one nothing yet redirects or role-switches for.
Future<void> showVacancyDetail(
  BuildContext context, {
  required String id,
  required Feed feed,
}) => Navigator.of(context, rootNavigator: true).push<void>(
  MaterialPageRoute(builder: (_) => VacancyDetailScreen(id: id, feed: feed)),
);

/// A vacancy as a candidate reads it before deciding (§5.6).
///
/// ## Gone is a normal answer here (UAT-15)
///
/// A vacancy is visible only while it is (BR-04, BR-11), so one that closed,
/// expired or was moderated away between the feed being drawn and this screen
/// opening answers 404. That is not a fault and must not read as one — the
/// candidate tapped something that was on screen a second ago, and "something
/// went wrong" would tell them the app is broken rather than that the job is
/// gone. It gets its own notice, and the feed is invalidated on the way out so
/// the card they tapped stops being offered.
class VacancyDetailScreen extends ConsumerStatefulWidget {
  const VacancyDetailScreen({required this.id, required this.feed, super.key});

  final String id;

  /// The feed this was opened from, so applying or saving invalidates the list
  /// the candidate returns to rather than leaving a stale card behind it.
  final Feed feed;

  @override
  ConsumerState<VacancyDetailScreen> createState() =>
      _VacancyDetailScreenState();
}

class _VacancyDetailScreenState extends ConsumerState<VacancyDetailScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final detail = ref.watch(vacancyDetailProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.vacancyDetailTitle),
        actions: [
          if (detail.value case final loaded?)
            TextButton(
              onPressed: _busy ? null : () => _report(loaded),
              child: Text(l10n.vacancyReport),
            ),
        ],
      ),
      body: SafeArea(
        child: switch (detail) {
          // hasError before loading, and 404 handled apart from the rest:
          // "this vacancy is no longer available" and "the network failed" are
          // different sentences and only one of them suggests trying again.
          AsyncValue(hasError: true, :final error?) => Padding(
            padding: const EdgeInsets.all(HhSpace.gutter),
            child: _isGone(error)
                ? HhNotice.expired(
                    title: l10n.vacancyGoneTitle,
                    message: l10n.vacancyGoneBody,
                    actionLabel: l10n.commonBack,
                    onAction: () => Navigator.of(context).pop(),
                  )
                : HhErrorState(
                    title: l10n.stateErrorTitle,
                    message: error is ApiException
                        ? error.message
                        : l10n.stateErrorBody,
                    retryLabel: l10n.commonRetry,
                    onRetry: () =>
                        ref.invalidate(vacancyDetailProvider(widget.id)),
                  ),
          ),
          AsyncData(:final value) => _body(l10n, value),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  /// Whether the vacancy is simply no longer on offer.
  ///
  /// The server says `vacancy.not_found` for unknown, closed, expired and
  /// moderated-away alike — deliberately, because telling a candidate *which*
  /// would leak the existence of vacancies they may not see. So the client can
  /// only distinguish "gone" from "broken", which is the distinction that
  /// matters to the person holding the phone.
  bool _isGone(Object error) =>
      error is ApiException && error.statusCode == 404;

  Widget _body(AppL10n l10n, VacancyDetail detail) {
    final card = detail.item;

    return ListView(
      padding: const EdgeInsets.all(HhSpace.gutter),
      children: [
        Text(card.title ?? l10n.vacancyUntitled, style: HhTypography.title),

        if (card.employer.name case final name? when name.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            name,
            style: HhTypography.body.copyWith(color: HhColors.inkMuted),
          ),
        ],

        // §5.6 puts verification on the vacancy itself, so it is weighed
        // before the employer is opened rather than after.
        if (card.employer.isVerified) ...[
          const SizedBox(height: HhSpace.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: HhBadge.verificationVerified(
              label: l10n.vacancyVerifiedEmployer,
            ),
          ),
        ],

        const SizedBox(height: HhSpace.lg),
        _facts(l10n, detail),

        if (detail.description case final text? when text.isNotEmpty) ...[
          const SizedBox(height: HhSpace.xl),
          Text(l10n.vacancyDescription, style: HhTypography.subtitle),
          const SizedBox(height: HhSpace.sm),
          // Displayed exactly as entered (§2.4). The platform does not
          // translate user-written content and must not appear to.
          Text(text, style: HhTypography.body),
        ],

        if (detail.requirements.isNotEmpty) ...[
          const SizedBox(height: HhSpace.xl),
          Text(l10n.vacancyRequirements, style: HhTypography.subtitle),
          const SizedBox(height: HhSpace.sm),
          _RequirementGroups(detail: detail),
        ],

        const SizedBox(height: HhSpace.xl),
        _actions(l10n, detail),
        const SizedBox(height: HhSpace.xl),
      ],
    );
  }

  /// The structured facts, as chips rather than a table.
  ///
  /// Everything here resolves to a plain string with no dictionary lookup
  /// except the two locations, which get their own rows underneath for the
  /// reason `HhMetaChip` cannot hold a widget.
  Widget _facts(AppL10n l10n, VacancyDetail detail) {
    final card = detail.item;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: HhSpace.sm,
          runSpacing: HhSpace.sm,
          children: [
            HhMetaChip(label: _pay(detail, l10n), iconPath: HhIconPath.wallet),
            if (card.workerCount case final count? when count > 0)
              HhMetaChip(
                label: l10n.vacancyOpenings(count),
                iconPath: HhIconPath.people,
              ),
            if (card.deadlineOn case final deadline?)
              HhMetaChip(
                label: l10n.vacancyDeadline(deadline),
                iconPath: HhIconPath.clock,
              ),
            // The work window, which is what makes a seasonal or fixed-date
            // assignment legible at all (§6.3, UAT-10). A start with no end is
            // a real combination — day work advertised as "from the 3rd" —
            // so it reads as an open range rather than as a missing field.
            if (detail.startsOn case final start?)
              HhMetaChip(
                label: switch (detail.endsOn) {
                  final end? => l10n.vacancyWorkWindow(start, end),
                  _ => l10n.vacancyStartsOn(start),
                },
                iconPath: HhIconPath.calendar,
              ),
          ],
        ),

        if (card.regionId case final regionId?) ...[
          const SizedBox(height: HhSpace.md),
          Row(
            children: [
              const HhIcon(
                HhIconPath.location,
                size: 16,
                color: HhColors.inkMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: DictionaryLabel(
                  type: DictionaryType.region,
                  id: card.districtId ?? regionId,
                  style: HhTypography.caption.copyWith(
                    color: HhColors.inkMuted,
                  ),
                ),
              ),
            ],
          ),
        ],

        if (detail.address case final address? when address.isNotEmpty) ...[
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 22),
            child: Text(
              address,
              style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
            ),
          ),
        ],
      ],
    );
  }

  Widget _actions(AppL10n l10n, VacancyDetail detail) {
    final card = detail.item;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // BR-07 read straight off the server's answer: the caller's own stage
        // comes back with the vacancy, so Apply is offered exactly when there
        // is no live application and the stage is named when there is.
        if (card.hasApplied)
          HhNotice(
            title: l10n.vacancyApplied,
            message: stageLabel(card.applicationStatus!, l10n),
            iconPath: HhIconPath.checkCircle,
          )
        else
          HhButton(
            label: l10n.vacancyApply,
            loading: _busy,
            onPressed: _busy ? null : () => _apply(detail),
          ),

        const SizedBox(height: HhSpace.sm),
        HhButton.secondary(
          label: card.isSaved ? l10n.vacancySaved : l10n.vacancySave,
          iconPath: HhIconPath.bookmark,
          onPressed: _busy ? null : () => _toggleSaved(detail),
        ),
      ],
    );
  }

  String _pay(VacancyDetail detail, AppL10n l10n) {
    final card = detail.item;
    if (card.salaryIsNegotiable) return l10n.vacancyNegotiablePay;

    final from = card.salaryFrom;
    final to = card.salaryTo;
    if (from == null && to == null) return l10n.vacancyNegotiablePay;
    if (from != null && to != null) return '$from – $to';

    return '${from ?? to}';
  }

  Future<void> _apply(VacancyDetail detail) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    try {
      final repository = await ref.read(applicationRepositoryProvider.future);
      await repository.apply(detail.item.id);

      ref
        ..invalidate(vacancyDetailProvider(widget.id))
        ..invalidate(vacancyFeedProvider(widget.feed))
        ..invalidate(myApplicationsProvider);
    } on ApiException catch (e) {
      // BR-06's deadline refusal and BR-07's duplicate both land here, in the
      // server's words — which name which rule refused.
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleSaved(VacancyDetail detail) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    try {
      await ref
          .read(discoveryRepositoryProvider)
          .setSaved(detail.item.id, saved: !detail.item.isSaved);

      ref
        ..invalidate(vacancyDetailProvider(widget.id))
        ..invalidate(vacancyFeedProvider(widget.feed))
        ..invalidate(vacancyFeedProvider(Feed.saved));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _report(VacancyDetail detail) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final reason = await showDialog<String>(
      context: context,
      builder: (context) => const _ReportDialog(),
    );
    if (reason == null) return;

    setState(() => _busy = true);
    try {
      await ref
          .read(discoveryRepositoryProvider)
          .report(detail.item.id, reason);
      messenger.showSnackBar(SnackBar(content: Text(l10n.vacancyReported)));
    } on ApiException catch (e) {
      // `complaint.already_reported` arrives here — tapping Report twice is
      // not two complaints, and the server says so in words worth showing.
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// §5.6's report reason.
///
/// Free text with no preset list, matching the endpoint: a candidate reporting
/// a fake vacancy should not have to find their objection on somebody else's
/// menu. The 5-character floor is the server's, applied here so the refusal
/// arrives before the round trip.
class _ReportDialog extends StatefulWidget {
  const _ReportDialog();

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final reason = _controller.text.trim();

    return AlertDialog(
      backgroundColor: HhColors.white,
      title: Text(l10n.vacancyReport, style: HhTypography.subtitle),
      content: HhTextField(
        label: l10n.vacancyReportReason,
        hintText: l10n.vacancyReportHint,
        controller: _controller,
        maxLines: 4,
        maxLength: 1000,
        onChanged: (_) => setState(() {}),
      ),
      actions: [
        HhButton.text(
          label: l10n.commonCancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        HhButton.text(
          label: l10n.vacancyReportSend,
          onPressed: reason.length >= 5
              ? () => Navigator.of(context).pop(reason)
              : null,
        ),
      ],
    );
  }
}

/// The structured requirements, grouped by schema field (§6.3).
///
/// **Mandatory and preferred are told apart by a badge, never by order alone.**
/// A preference that looked like a requirement would stop candidates applying,
/// which is the opposite of what a preference is for — and the design system's
/// rule is that status is never colour alone.
///
/// ## The group heading comes from the vacancy schema
///
/// A requirement arrives carrying `fieldCode` — `employment_type_ids` — and the
/// wording for it lives in the schema the vacancy form was built from, already
/// localized by the server. The first version of this screen rendered the code
/// and it read as a bug on a device. A code-to-string table in Dart would be
/// worse: administrators add fields at runtime (§10.3), so it would go stale
/// silently and in one language at a time.
///
/// The schema load is deliberately **not** allowed to hold up the requirements:
/// while it is in flight, or if it fails, the code is shown. A heading that
/// arrives a moment late is better than a screen that waits for one.
class _RequirementGroups extends ConsumerWidget {
  const _RequirementGroups({required this.detail});

  final VacancyDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final groups = detail.byField;

    final schema = switch (detail.item.category) {
      final category? => ref.watch(vacancyFieldSchemaProvider(category)),
      _ => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in groups.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: HhSpace.md),
            child: HhCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _heading(schema, entry.key),
                    style: HhTypography.label.copyWith(
                      color: HhColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: HhSpace.sm),

                  for (final requirement in entry.value)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _value(context, requirement, l10n)),
                          const SizedBox(width: HhSpace.sm),
                          HhBadge(
                            label: requirement.isMandatory
                                ? l10n.vacancyMandatory
                                : l10n.vacancyPreferred,
                            tone: requirement.isMandatory
                                ? HhTone.warning
                                : HhTone.neutral,
                            iconPath: requirement.isMandatory
                                ? HhIconPath.alertTriangle
                                : HhIconPath.checkCircle,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// The schema's label for a field code, or the code itself.
  ///
  /// Loading and failure both fall through to the code, and that is the point:
  /// the requirement below the heading is the information the candidate came
  /// for, and it must never be withheld waiting on a word.
  static String _heading(AsyncValue<FieldSchema>? schema, String fieldCode) =>
      switch (schema) {
        AsyncData(:final value) =>
          value.fieldByCode(fieldCode)?.label ?? fieldCode,
        _ => fieldCode,
      };

  /// One requirement's value, from whichever slot is filled.
  ///
  /// The order is not arbitrary: a levelled row carries **both** an item and a
  /// level, so the item must be tested first and the level rendered beside it;
  /// text is last because it is the only slot that means nothing else.
  Widget _value(
    BuildContext context,
    VacancyRequirement requirement,
    AppL10n l10n,
  ) {
    if (requirement.itemId case final itemId?) {
      return Row(
        children: [
          Flexible(
            child: DictionaryLabel(
              type: _typeFor(requirement.fieldCode),
              id: itemId,
              style: HhTypography.body,
            ),
          ),
          if (requirement.levelId case final levelId?) ...[
            const SizedBox(width: 6),
            Text('·', style: HhTypography.caption),
            const SizedBox(width: 6),
            Flexible(
              child: DictionaryLabel(
                type: _levelTypeFor(requirement.fieldCode),
                id: levelId,
                style: HhTypography.caption.copyWith(
                  color: HhColors.inkMuted,
                ),
              ),
            ),
          ],
        ],
      );
    }

    if (requirement.valueInt case final number?) {
      return Text('$number', style: HhTypography.body);
    }

    if (requirement.valueBool case final flag?) {
      return Text(
        flag ? l10n.commonYes : l10n.commonNo,
        style: HhTypography.body,
      );
    }

    return Text(requirement.valueText ?? '—', style: HhTypography.body);
  }

  /// The dictionary a requirement's item belongs to, inferred from its field.
  ///
  /// An inference, and it is worth saying why it is acceptable: an unknown
  /// field resolves against `attribute`, and a miss there renders the
  /// picker's "unknown value" rather than a UUID or a crash. The alternative —
  /// fetching the vacancy schema to read `dictionaryType` per field — is a
  /// second request for wording this screen already shows honestly.
  static String _typeFor(String fieldCode) => switch (fieldCode) {
    'languages' => DictionaryType.language,
    'skills' => DictionaryType.skill,
    'occupation' || 'occupations' => DictionaryType.occupation,
    'education_level' || 'educationLevel' => DictionaryType.educationLevel,
    'employment_type' || 'employmentType' => DictionaryType.employmentType,
    'work_format' || 'workFormat' => DictionaryType.workFormat,
    'shift' || 'shifts' => DictionaryType.shift,
    _ => DictionaryType.attribute,
  };

  static String _levelTypeFor(String fieldCode) => switch (fieldCode) {
    'languages' => DictionaryType.languageLevel,
    _ => DictionaryType.skillLevel,
  };
}
