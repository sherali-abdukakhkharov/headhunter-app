import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/features/applications/domain/candidate_for_employer.dart';
import 'package:headhunter_app/src/features/applications/presentation/exposure_explanation.dart';
import 'package:headhunter_app/src/features/candidate_search/data/candidate_search_repository.dart';
import 'package:headhunter_app/src/features/dictionaries/domain/dictionary_type.dart';
import 'package:headhunter_app/src/features/dictionaries/presentation/dictionary_label.dart';

/// Opens §7.3's "View profile" for one candidate.
///
/// Pushed on the root navigator rather than given a route, for the same reason
/// the filter builder is: **every open is a logged access to protected data**
/// (§11.1). A path would make it linkable, shareable and re-openable by
/// anything that holds the URL, and each of those is a read of somebody's
/// contact details that nobody deliberately asked for.
Future<void> showCandidateDetail(
  BuildContext context, {
  required String candidateUserId,
}) => Navigator.of(context, rootNavigator: true).push<void>(
  MaterialPageRoute(
    builder: (_) => CandidateDetailScreen(candidateUserId: candidateUserId),
  ),
);

/// One candidate, as much of them as BR-09 allows (§7.3, §11.1).
///
/// ## The client does not decide what is visible, and does not try
///
/// The server evaluates BR-09 once — the candidate's own privacy setting *and*
/// whether a hiring interaction exists — and sends `phone` only where both
/// allow it. There is no client-side branch that could disagree, because there
/// is no second copy of the rule to disagree with: `phone` is either in the
/// response or it is not.
///
/// What this screen adds is the *reason*. A blank where a phone number should
/// be reads as a bug; `exposureReason` turns it into a sentence explaining what
/// would change it, which is the difference between an employer thinking the
/// app is broken and an employer understanding that the candidate has not
/// applied yet.
class CandidateDetailScreen extends ConsumerWidget {
  const CandidateDetailScreen({required this.candidateUserId, super.key});

  final String candidateUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final candidate = ref.watch(searchCandidateProvider(candidateUserId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.candidateProfileTitle)),
      body: SafeArea(
        child: switch (candidate) {
          // hasError before loading: retry is off app-wide, so a refusal is
          // terminal. It is also the *normal* answer for a candidate who is no
          // longer findable and never interacted — 404, in the server's words.
          AsyncValue(hasError: true, :final error?) => Padding(
            padding: const EdgeInsets.all(HhSpace.gutter),
            child: HhErrorState(
              title: l10n.stateErrorTitle,
              message: error is ApiException
                  ? error.message
                  : l10n.stateErrorBody,
              retryLabel: l10n.commonRetry,
              onRetry: () =>
                  ref.invalidate(searchCandidateProvider(candidateUserId)),
            ),
          ),
          AsyncData(:final value) => _Profile(candidate: value),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({required this.candidate});

  final CandidateForEmployer candidate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return ListView(
      padding: const EdgeInsets.all(HhSpace.gutter),
      children: [
        if (candidate.fullName case final name? when name.isNotEmpty)
          Text(name, style: HhTypography.title),

        // Region and district read as text rather than as chips: `HhMetaChip`
        // takes a resolved label, and a dictionary id resolves asynchronously
        // — a chip cannot hold a widget, and hand-rolling one that could would
        // be a second metadata chip in the design system.
        if (candidate.districtId case final districtId?)
          DictionaryLabel(
            type: DictionaryType.region,
            id: districtId,
            style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
          ),
        if (candidate.regionId case final regionId?)
          DictionaryLabel(
            type: DictionaryType.region,
            id: regionId,
            style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
          ),

        if (candidate.availableFrom case final from? when from.isNotEmpty) ...[
          const SizedBox(height: HhSpace.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: HhMetaChip(
              label: l10n.candidateAvailableFrom(from),
              iconPath: HhIconPath.clock,
            ),
          ),
        ],

        const SizedBox(height: HhSpace.lg),
        HhCompletenessRing(
          percent: candidate.completenessPercent,
          title: l10n.candidateCompleteness(candidate.completenessPercent),
          // The ring's hole is painted, not transparent, so it has to be told
          // what it sits on — here the scaffold rather than a card.
          surfaceColor: HhColors.sand100,
        ),

        const SizedBox(height: HhSpace.xl),
        _Contact(candidate: candidate),

        const SizedBox(height: HhSpace.xl),
        _Files(candidate: candidate),
      ],
    );
  }
}

/// BR-09 on screen, with its reason.
///
/// Three states, and the third is the one that matters: a number, a stated
/// absence, or an absence *plus what would change it*. There is deliberately
/// nothing here that could reconstruct a number the server withheld — the only
/// action offered acts on a string that is already on screen.
class _Contact extends StatelessWidget {
  const _Contact({required this.candidate});

  final CandidateForEmployer candidate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    if (candidate.phone case final phone? when phone.isNotEmpty) {
      return HhCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.candidateContact,
              style: HhTypography.label.copyWith(color: HhColors.inkMuted),
            ),
            const SizedBox(height: HhSpace.sm),
            Text(phone, style: HhTypography.subtitle),

            const SizedBox(height: HhSpace.sm),
            HhButton.secondary(
              label: l10n.commonCopy,
              compact: true,
              expand: false,
              // Copy rather than dial. Placing a call needs `url_launcher`,
              // and a new package here would have to be weighed against
              // pubspec.yaml's load-bearing pins for an action the platform
              // dialler already does from the clipboard.
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: phone));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.commonCopied)),
                );
              },
            ),
          ],
        ),
      );
    }

    return HhNotice(
      title: l10n.candidatePhoneHidden,
      message: exposureExplanation(candidate.exposureReason, l10n),
      iconPath: HhIconPath.lock,
      tone: HhNoticeTone.neutral,
    );
  }
}

class _Files extends StatelessWidget {
  const _Files({required this.candidate});

  final CandidateForEmployer candidate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    // Not a client-side hide: when `canViewFiles` is false the server sends no
    // files at all, so there is nothing here to leak by mistake.
    if (!candidate.canViewFiles || candidate.files.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.candidateAttachments, style: HhTypography.subtitle),
          const SizedBox(height: HhSpace.sm),
          Text(
            candidate.canViewFiles
                ? l10n.candidateNoFiles
                : l10n.candidateFilesHidden,
            style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.candidateAttachments, style: HhTypography.subtitle),
        const SizedBox(height: HhSpace.sm),

        for (final file in candidate.files)
          Padding(
            padding: const EdgeInsets.only(bottom: HhSpace.sm),
            child: HhCard(
              child: Row(
                children: [
                  const HhIcon(
                    HhIconPath.document,
                    size: 20,
                    color: HhColors.inkMuted,
                  ),
                  const SizedBox(width: HhSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(file.fileName, style: HhTypography.body),
                        // The purpose is a dictionary id like any other, so it
                        // reads as a word in all four interface variants
                        // rather than as `cv` (BR-13).
                        DictionaryLabel(
                          type: DictionaryType.filePurpose,
                          id: file.purposeCode,
                          style: HhTypography.caption.copyWith(
                            color: HhColors.inkMuted,
                          ),
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
}
