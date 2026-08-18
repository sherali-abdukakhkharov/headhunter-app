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
import 'package:headhunter_app/src/features/wallet/data/wallet_repository.dart';
import 'package:headhunter_app/src/features/wallet/domain/wallet.dart';
import 'package:headhunter_app/src/features/wallet/presentation/unlock_sheet.dart';

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
///
/// ## The unlock control appears on one signal, and it is not a flag (§6.6)
///
/// "Unlock contact" is offered only where `exposureReason` is `unlock_required`
/// — see `unlockWouldOpenContact`. That code exists only on a server that
/// actually gates contact on the entitlement; a server that sells an unlock but
/// does not read it answers `no_interaction` instead, and the control stays
/// absent.
///
/// So this ships safely ahead of the backend: **nobody can be charged two Coins
/// for access that would not change**, the control turns itself on the day the
/// server starts sending the code, and there is no configuration anyone has to
/// remember to switch. The alternative — a build-time flag — would have been a
/// code path that takes money and is enabled by a constant.
class _Contact extends ConsumerWidget {
  const _Contact({required this.candidate});

  final CandidateForEmployer candidate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

            // Only where a purchase is what opened it. An employer who spent
            // Coins should be able to see that this is what they bought,
            // without going to the ledger to work it out.
            if (candidate.exposureReason == 'candidate_unlock')
              _UnlockedOn(candidateUserId: candidate.candidateUserId),

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

    final unlockable = unlockWouldOpenContact(candidate.exposureReason);
    final wallet = unlockable ? ref.watch(walletProvider).value : null;

    return HhNotice(
      title: l10n.candidatePhoneHidden,
      message: exposureExplanation(candidate.exposureReason, l10n),
      iconPath: HhIconPath.lock,
      tone: HhNoticeTone.neutral,
      // The price is on the button because §6.6 and UAT-17 both want the cost
      // visible before the decision, and it comes from the wallet rather than a
      // constant — §10.5 can reprice an unlock while the app is installed.
      //
      // No wallet yet means no price to name, so no action is offered rather
      // than one labelled with a guess.
      actionLabel: wallet == null
          ? null
          : l10n.unlockContact(
              l10n.walletCoins(wallet.pricing.candidateUnlockCoins),
            ),
      onAction: wallet == null
          ? null
          : () => _unlock(context, ref, wallet),
    );
  }

  /// Opens the confirmation sheet, and refreshes the profile if it succeeded.
  ///
  /// The profile is refetched rather than patched: the server decides what an
  /// entitlement reveals, so the phone number, the files and the reason all
  /// arrive together from the one place that evaluates BR-09. Writing the
  /// number into local state would be this screen's second copy of that rule.
  Future<void> _unlock(
    BuildContext context,
    WidgetRef ref,
    Wallet wallet,
  ) async {
    final unlock = await showUnlockSheet(
      context,
      candidateUserId: candidate.candidateUserId,
      wallet: wallet,
      pricing: wallet.pricing,
    );

    if (unlock == null) return;

    ref.invalidate(searchCandidateProvider(candidate.candidateUserId));
  }
}

/// When this candidate was unlocked, on a profile a purchase opened.
///
/// Its own widget so the request is made **only** on the profiles it is about.
/// An employer opens many candidates and pays for few, and asking every one of
/// them "did I unlock this?" would be a request per profile to answer what
/// `exposureReason` has already answered.
///
/// Deliberately not the unlock control's gate: this endpoint answers "do I hold
/// an entitlement", which today's ungated server answers honestly with `false`
/// while still not honouring the entitlement. Gating a purchase on it would put
/// the button back in front of employers it cannot help — see [_Contact].
class _UnlockedOn extends ConsumerWidget {
  const _UnlockedOn({required this.candidateUserId});

  final String candidateUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(unlockStateProvider(candidateUserId));

    // Silent while loading or on failure: it is a footnote on a contact block,
    // and a spinner or an error where a date belongs would draw more attention
    // than the fact deserves.
    if (state.value?.unlock case final unlock?) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          l10n.unlockUnlockedOn(_isoDate(unlock.createdAt.wallClock)),
          style: HhTypography.meta.copyWith(color: HhColors.inkMuted),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// The wall clock the server resolved, never `.toLocal()`.
  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
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
