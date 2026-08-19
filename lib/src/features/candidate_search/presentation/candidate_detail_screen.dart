import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/applications/domain/candidate_for_employer.dart';
import 'package:jobbridge_app/src/features/applications/presentation/exposure_explanation.dart';
import 'package:jobbridge_app/src/features/candidate_search/data/candidate_search_repository.dart';
import 'package:jobbridge_app/src/features/candidate_search/presentation/protected_contact_card.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_type.dart';
import 'package:jobbridge_app/src/features/dictionaries/presentation/dictionary_label.dart';
import 'package:jobbridge_app/src/features/wallet/data/wallet_repository.dart';
import 'package:jobbridge_app/src/features/wallet/domain/unlock.dart';
import 'package:jobbridge_app/src/features/wallet/domain/wallet.dart';
import 'package:jobbridge_app/src/features/wallet/presentation/coin_balance_chip.dart';
import 'package:jobbridge_app/src/features/wallet/presentation/unlock_sheet.dart';

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
      appBar: AppBar(
        title: Text(l10n.candidateProfileTitle),
        // §06 puts the balance in the app bar of the surfaces where Coins get
        // spent, rather than behind a sixth tab the design does not have.
        actions: const [CoinBalanceChip()],
      ),
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

/// The profile body, and the sticky action bar §06 draws beneath it.
///
/// ## Why the unlock action is a sticky bar rather than a button in the card
///
/// The design puts it in a bar pinned to the bottom of the screen, and that is
/// load-bearing rather than decorative: §3.1 asks for sticky actions on long
/// content, and this screen is long — experience, skills, files. A priced
/// button halfway down a scroll is a button an employer has to go looking for,
/// and the price stops being visible at the moment of the decision.
///
/// ## Stateful for exactly one reason
///
/// The unlock-success banner reports something that happened on *this* screen —
/// Coins spent, balance left — and §06 keeps it in place until dismissed rather
/// than flashing it as a toast, because those are figures somebody may want to
/// read twice. So which screen it belongs to has to be remembered somewhere.
class _Profile extends ConsumerStatefulWidget {
  const _Profile({required this.candidate});

  final CandidateForEmployer candidate;

  @override
  ConsumerState<_Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<_Profile> {
  /// The purchase this screen just made, until the employer dismisses it.
  Unlock? _justUnlocked;

  CandidateForEmployer get _candidate => widget.candidate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    // Watched unconditionally: the app bar's balance chip on this very screen
    // already forces the fetch, so there is nothing to save by watching it
    // conditionally — and the success banner needs the *new* balance after the
    // reason code has stopped being `unlock_required`.
    final wallet = ref.watch(walletProvider).value;

    final unlockable = unlockWouldOpenContact(_candidate.exposureReason);
    // Whether this screen can actually *offer* the purchase. Not the same as
    // `unlockable`, and the two come apart: `unlock_required` with an
    // unreachable wallet is a lockable candidate with no price to put on a
    // button, which must still be explained rather than left silent.
    final coins = wallet == null
        ? null
        : l10n.walletCoins(wallet.pricing.candidateUnlockCoins);
    final canOfferUnlock = unlockable && coins != null;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(HhSpace.gutter),
            children: [
              if (_justUnlocked case final unlock?) ...[
                HhNotice.done(
                  title: unlock.charged ? l10n.unlockDone : l10n.unlockAlready,
                  message: unlock.charged
                      ? l10n.unlockChargedDetail(
                          l10n.walletCoins(unlock.costCoins),
                          l10n.walletCoins(wallet?.balanceCoins ?? 0),
                        )
                      : l10n.unlockWhatYouGet,
                  onDismiss: () => setState(() => _justUnlocked = null),
                ),
                const SizedBox(height: HhSpace.md),
              ],

              if (_candidate.fullName case final name? when name.isNotEmpty)
                Text(name, style: HhTypography.title),

              // Region and district read as text rather than as chips:
              // `HhMetaChip` takes a resolved label, and a dictionary id
              // resolves asynchronously — a chip cannot hold a widget, and
              // hand-rolling one that could would be a second metadata chip in
              // the design system.
              if (_candidate.districtId case final districtId?)
                DictionaryLabel(
                  type: DictionaryType.region,
                  id: districtId,
                  style: HhTypography.caption.copyWith(
                    color: HhColors.inkMuted,
                  ),
                ),
              if (_candidate.regionId case final regionId?)
                DictionaryLabel(
                  type: DictionaryType.region,
                  id: regionId,
                  style: HhTypography.caption.copyWith(
                    color: HhColors.inkMuted,
                  ),
                ),

              if (_candidate.availableFrom case final from?
                  when from.isNotEmpty) ...[
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
                percent: _candidate.completenessPercent,
                title: l10n.candidateCompleteness(
                  _candidate.completenessPercent,
                ),
                // The ring's hole is painted, not transparent, so it has to be
                // told what it sits on — here the scaffold rather than a card.
                surfaceColor: HhColors.sand100,
              ),

              const SizedBox(height: HhSpace.xl),
              ProtectedContactCard(
                phone: _candidate.phone,
                // No e-mail on the DTO yet; the row renders masked, which is
                // the truthful state either way.
                email: null,
                unlockCoins: canOfferUnlock ? coins : null,
              ),

              // Only where a purchase is what opened it. An employer who spent
              // Coins should be able to see that this is what they bought,
              // without going to the ledger to work it out.
              if (_candidate.exposureReason == 'candidate_unlock')
                _UnlockedOn(candidateUserId: _candidate.candidateUserId),

              // The reason, whenever contact is closed and this screen cannot
              // offer the remedy — an unverified employer, a code this build
              // does not know, or an unreachable wallet. Where the purchase
              // *can* be offered, the sticky bar and the card's own explainer
              // already say so, and a third sentence would only repeat them.
              if (_candidate.phone == null && !canOfferUnlock) ...[
                const SizedBox(height: HhSpace.md),
                _ExposureNotice(candidate: _candidate),
              ],

              const SizedBox(height: HhSpace.xl),
              _Files(candidate: _candidate),
            ],
          ),
        ),

        // §6.6 and UAT-17 both want the cost visible before the decision, and
        // it comes from the wallet rather than a constant — §10.5 can reprice
        // an unlock while the app is installed. No price means no bar, rather
        // than a bar labelled with a guess.
        if (canOfferUnlock && wallet != null)
          _UnlockBar(
            label: l10n.unlockContact(coins),
            onPressed: () => _unlock(wallet),
          ),
      ],
    );
  }

  /// Opens the confirmation sheet, and refreshes what the server will now say.
  ///
  /// The profile is refetched rather than patched: the server decides what an
  /// entitlement reveals, so the phone number, the files and the reason all
  /// arrive together from the one place that evaluates BR-09. Writing the
  /// number into local state would be this screen's second copy of that rule.
  Future<void> _unlock(Wallet wallet) async {
    final unlock = await showUnlockSheet(
      context,
      candidateUserId: _candidate.candidateUserId,
      wallet: wallet,
      pricing: wallet.pricing,
      candidateName: _candidate.fullName,
      onVerify: _goToVerification,
    );

    if (unlock == null || !mounted) return;

    setState(() => _justUnlocked = unlock);
    ref.invalidate(searchCandidateProvider(_candidate.candidateUserId));
  }

  /// BR-03's destination.
  ///
  /// The employer profile is a shell tab rather than a pushed route, so this
  /// pops back to it instead of stacking a second copy on top of a candidate.
  void _goToVerification() {
    // The router is captured before popping: this screen is pushed on the root
    // navigator, so by the time the pop lands its own context is gone.
    _openVerification(context);
  }
}

/// The sticky priced action, at the design's 52px control height.
class _UnlockBar extends StatelessWidget {
  const _UnlockBar({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(HhSpace.gutter),
    decoration: const BoxDecoration(
      color: HhColors.white,
      boxShadow: HhElevation.sheet,
    ),
    child: SafeArea(
      top: false,
      child: HhButton(
        label: label,
        iconPath: HhIconPath.coin,
        onPressed: onPressed,
      ),
    ),
  );
}

/// Why contact is closed, when spending Coins is not what would open it.
///
/// `not_verified_employer` gets an action, because it has a destination: §7
/// admits only a verified employer to candidates at all, so this is a
/// precondition rather than a paywall and Coins cannot buy past it. The backend
/// answers it with **200 and a readable profile**, not an error — so it belongs
/// in the page rather than in an error state.
class _ExposureNotice extends StatelessWidget {
  const _ExposureNotice({required this.candidate});

  final CandidateForEmployer candidate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final unverified = candidate.exposureReason == 'not_verified_employer';

    return HhNotice(
      title: l10n.candidatePhoneHidden,
      message: exposureExplanation(candidate.exposureReason, l10n),
      iconPath: unverified ? HhIconPath.shieldCheck : HhIconPath.lock,
      tone: unverified ? HhNoticeTone.warning : HhNoticeTone.neutral,
      actionLabel: unverified ? l10n.unlockGoToVerification : null,
      onAction: unverified ? () => _openVerification(context) : null,
    );
  }
}

/// Leaves the candidate and lands on the employer's own profile, where §6.1's
/// verification card lives.
///
/// The router is read **before** the pop, because this screen is pushed on the
/// root navigator: after popping, the context that could find it is gone. The
/// company tab is a shell branch rather than a pushed route, so this switches
/// to it rather than stacking a second copy above a candidate.
void _openVerification(BuildContext context) {
  final router = GoRouter.of(context);
  Navigator.of(context, rootNavigator: true).popUntil((r) => r.isFirst);
  router.go(Routes.employerCompany);
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
/// the button back in front of employers it cannot help — see [_Profile].
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
                        // reads as a word in all four interface variants rather
                        // than as `cv` (BR-13).
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
