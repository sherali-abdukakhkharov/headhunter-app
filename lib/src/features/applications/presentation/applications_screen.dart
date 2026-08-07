import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/features/applications/data/application_repository.dart';
import 'package:headhunter_app/src/features/applications/domain/application.dart';
import 'package:headhunter_app/src/features/discovery/data/discovery_repository.dart';

/// The word for one of §8.1's eight application stages.
///
/// Separate from [stageBadge] because the employer view needs the label
/// without the badge — in a stage-move button and in §6.5's per-stage counts —
/// and two spellings of the same stage is how a vocabulary stops being one.
String stageLabel(String status, AppL10n l10n) => switch (status) {
  'viewed' => l10n.stageViewed,
  'shortlisted' => l10n.stageShortlisted,
  'interview' => l10n.stageInterview,
  'offer' => l10n.stageOffer,
  'hired' => l10n.stageHired,
  'rejected' => l10n.stageRejected,
  'withdrawn' => l10n.stageWithdrawn,
  _ => l10n.stageSubmitted,
};

/// The badge for one of §8.1's eight application stages.
///
/// One function, because the design system's named constructors *are* the
/// vocabulary. An unrecognised stage falls back to `submitted` rather than
/// throwing — the same rule as an unknown field kind.
Widget stageBadge(String status, AppL10n l10n) => switch (status) {
  'viewed' => HhBadge.applicationViewed(label: l10n.stageViewed),
  'shortlisted' => HhBadge.applicationShortlisted(
    label: l10n.stageShortlisted,
  ),
  'interview' => HhBadge.applicationInterview(label: l10n.stageInterview),
  'offer' => HhBadge.applicationOffer(label: l10n.stageOffer),
  'hired' => HhBadge.applicationHired(label: l10n.stageHired),
  'rejected' => HhBadge.applicationRejected(label: l10n.stageRejected),
  'withdrawn' => HhBadge.applicationWithdrawn(label: l10n.stageWithdrawn),
  _ => HhBadge.applicationSubmitted(label: l10n.stageSubmitted),
};

/// The candidate's own applications and their stages (§8.1).
class ApplicationsScreen extends ConsumerWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final applications = ref.watch(myApplicationsProvider);

    return Scaffold(
      body: SafeArea(
        child: switch (applications) {
          AsyncValue(hasError: true, :final error?) => Padding(
            padding: const EdgeInsets.all(HhSpace.gutter),
            child: HhErrorState(
              title: l10n.stateErrorTitle,
              message: error is ApiException
                  ? error.message
                  : l10n.stateErrorBody,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(myApplicationsProvider),
            ),
          ),
          AsyncData(:final value) when value.isEmpty => HhEmptyState(
            title: l10n.stateEmptyTitle,
            message: l10n.applicationsEmpty,
          ),
          AsyncData(:final value) => ListView.builder(
            padding: const EdgeInsets.all(HhSpace.gutter),
            itemCount: value.length,
            itemBuilder: (context, index) => _Row(application: value[index]),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _Row extends ConsumerStatefulWidget {
  const _Row({required this.application});

  final Application application;

  @override
  ConsumerState<_Row> createState() => _RowState();
}

class _RowState extends ConsumerState<_Row> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final application = widget.application;

    return Padding(
      padding: const EdgeInsets.only(bottom: HhSpace.sm),
      child: HhCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            stageBadge(application.status, l10n),

            if (application.rejectionReason case final reason?
                when reason.isNotEmpty) ...[
              const SizedBox(height: HhSpace.md),
              // The employer's own words, shown to the candidate (§8.1) and
              // never translated (§2.4).
              Text(reason, style: HhTypography.body),
            ],

            // Only while the application is live: withdrawing is the
            // candidate's own transition, but a finished one has nothing to
            // withdraw from and the server would refuse.
            if (application.canWithdraw) ...[
              const SizedBox(height: HhSpace.sm),
              HhButton.text(
                label: l10n.applicationWithdraw,
                onPressed: _busy ? null : _withdraw,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _withdraw() async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.applicationWithdrawTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.applicationWithdraw),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;

    setState(() => _busy = true);
    try {
      final repository = await ref.read(applicationRepositoryProvider.future);
      await repository.withdraw(widget.application.id);

      ref.invalidate(myApplicationsProvider);
      // Withdrawing frees the candidate to apply again (BR-07), so every feed
      // that shows an Apply button is now wrong.
      for (final feed in Feed.values) {
        ref.invalidate(vacancyFeedProvider(feed));
      }
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
