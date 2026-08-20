import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/files/attachment_opener.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/applications/domain/candidate_for_employer.dart';
import 'package:jobbridge_app/src/features/applications/presentation/exposure_explanation.dart';
import 'package:jobbridge_app/src/features/candidate_search/data/candidate_search_repository.dart';
import 'package:jobbridge_app/src/features/candidate_search/presentation/protected_contact_card.dart';
import 'package:jobbridge_app/src/features/chat/presentation/open_conversation.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_type.dart';
import 'package:jobbridge_app/src/features/dictionaries/presentation/dictionary_label.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invite_outcome.dart';
import 'package:jobbridge_app/src/features/invitations/presentation/compose_invitation_screen.dart';
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

  /// Whether §7.3's "Send invitation" is worth offering on this profile.
  ///
  /// Excluded on exactly the two reasons a send would fail rather than merely
  /// be declined:
  ///
  /// - `not_verified_employer` — BR-03, which the server enforces on
  ///   `POST /invitations` too. The exposure notice already routes to
  ///   verification, so a button that 403s would be a worse second route there.
  /// - `hidden_by_candidate` — the candidate left search, and BR-02 means the
  ///   server will not accept an invitation to somebody the employer could not
  ///   have found.
  ///
  /// Everything else is invitable, including a candidate who has already
  /// applied: an employer may well want to invite them to a *different*
  /// vacancy, and §8.2 puts no interaction condition on sending.
  bool get _canInvite => !const {
    'not_verified_employer',
    'hidden_by_candidate',
  }.contains(_candidate.exposureReason);

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
                surfaceColor: HhColors.surfaceMuted,
              ),

              const SizedBox(height: HhSpace.xl),
              ProtectedContactCard(
                phone: _candidate.phone,
                // No e-mail on the DTO yet; the row renders masked, which is
                // the truthful state either way.
                email: null,
                unlockCoins: canOfferUnlock ? coins : null,
                onMessage: _message,
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

        // §3.1's sticky action area. Two actions can live here and they are
        // ordered by consequence rather than by price: the unlock is primary
        // where it is offered because it is the decision that costs something
        // and §6.6 wants the cost visible at the moment of choosing, and the
        // invitation is primary where there is nothing to unlock, because then
        // it is the only thing an employer can do from this screen.
        _ActionBar(
          children: [
            // §6.6 and UAT-17 both want the cost visible before the decision,
            // and it comes from the wallet rather than a constant — §10.5 can
            // reprice an unlock while the app is installed. No price means no
            // button, rather than one labelled with a guess.
            if (canOfferUnlock && wallet != null)
              HhButton(
                label: l10n.unlockContact(coins),
                onPressed: () => _unlock(wallet),
              ),

            // Free (§7.3, and the client's 2026-08-19 answer), so it is offered
            // regardless of the balance and regardless of whether an unlock is
            // available. **Not offered to an unverified employer**: BR-03 makes
            // the server refuse it, and `not_verified_employer` is the code
            // that says so — the notice above already routes them to
            // verification, so a button that 403s would be a second, worse
            // route to the same place. A candidate who left search is not
            // invitable either.
            if (_canInvite)
              if (canOfferUnlock)
                HhButton.secondary(
                  label: l10n.invitationSendTitle,
                  onPressed: _invite,
                )
              else
                HhButton(
                  label: l10n.invitationSendTitle,
                  onPressed: _invite,
                ),
          ],
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

  /// Opens §8.2's compose form, and refreshes what the server will now say.
  ///
  /// The profile is refetched on a successful send for the same reason the
  /// unlock refetches it: acceptance is what opens contact, so the *server*
  /// decides what this screen shows next, and an invitation that is merely sent
  /// changes `exposureReason` not at all. Refetching costs one request and
  /// cannot disagree with the rule.
  Future<void> _invite() async {
    final outcome = await showComposeInvitation(
      context,
      candidateUserId: _candidate.candidateUserId,
      candidateName: _candidate.fullName,
    );

    if (outcome is! InviteSent || !mounted) return;

    ref.invalidate(searchCandidateProvider(_candidate.candidateUserId));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppL10n.of(context).invitationSentConfirm)),
    );
  }

  /// BR-03's destination.
  ///
  /// The employer profile is a shell tab rather than a pushed route, so this
  /// pops back to it instead of stacking a second copy on top of a candidate.
  /// Opens §9.1's thread with this candidate and goes to it.
  ///
  /// The router is captured **before** the pop, the same rule
  /// `_openVerification` follows: this screen is pushed on the root navigator,
  /// so after popping the context that could find the router is gone. And the
  /// pop comes first because the Messages tab is a shell branch — going there
  /// while a candidate profile sits on top of the root navigator would leave
  /// the thread hidden underneath it.
  Future<void> _message() async {
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);

    final id = await openConversationWith(
      context,
      ref,
      counterpartUserId: _candidate.candidateUserId,
    );

    // Null means §9.1 refused or the request failed, and either way the user
    // has already been told in the server's own words. Nothing to go to.
    if (id == null || !mounted) return;

    navigator.popUntil((r) => r.isFirst);
    router.go('${Routes.employerMessages}/$id');
  }

  void _goToVerification() {
    // The router is captured before popping: this screen is pushed on the root
    // navigator, so by the time the pop lands its own context is gone.
    _openVerification(context);
  }
}

/// The sticky action area, at the design's 52px control height (§3.1).
///
/// Was `_UnlockBar` and held one priced button. It holds a list now because a
/// free action landed beside the paid one, and hiding the free one behind an
/// app-bar icon would have made §7.3's "Send invitation" the least discoverable
/// of the three actions that section lists.
class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // Nothing to offer means no bar at all, rather than an empty strip with a
    // shadow — which reads as a rendering failure at the bottom of the screen.
    if (children.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(HhSpace.gutter),
      decoration: const BoxDecoration(
        color: HhColors.white,
        boxShadow: HhElevation.sheet,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, child) in children.indexed) ...[
              if (i > 0) const SizedBox(height: HhSpace.sm),
              child,
            ],
          ],
        ),
      ),
    );
  }
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
            child: _FileRow(file: file),
          ),
      ],
    );
  }
}

/// One attachment, downloaded on tap and handed to the OS.
///
/// ## Every tap re-downloads
///
/// BR-09 is re-evaluated on **every** download, which is why the file's
/// `downloadPath` is server-built in the first place: holding a path is not
/// holding permission. So there is no "already fetched" shortcut here — a
/// candidate who withdraws has to stop being readable mid-session, and
/// answering from a copy on disk would defeat the only check that notices.
class _FileRow extends ConsumerStatefulWidget {
  const _FileRow({required this.file});

  final CandidateFile file;

  @override
  ConsumerState<_FileRow> createState() => _FileRowState();
}

class _FileRowState extends ConsumerState<_FileRow> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final file = widget.file;

    return HhCard(
      onTap: _busy ? null : _open,
      child: Row(
        children: [
          SizedBox.square(
            dimension: 20,
            child: _busy
                ? const CircularProgressIndicator(strokeWidth: 2.2)
                : const HhIcon(
                    HhIconPath.document,
                    size: 20,
                    color: HhColors.inkMuted,
                  ),
          ),
          const SizedBox(width: HhSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.fileName, style: HhTypography.body),
                // The purpose is a dictionary id like any other, so it reads as
                // a word in all four interface variants rather than as `cv`
                // (BR-13).
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
          const HhIcon(
            HhIconPath.chevronRight,
            size: 18,
            color: HhColors.inkDisabled,
          ),
        ],
      ),
    );
  }

  Future<void> _open() async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    try {
      await ref.read(attachmentOpenerProvider).open(
        // Verbatim, never constructed: the path is scoped to whichever
        // interaction currently entitles this employer — application, accepted
        // invitation or unlock — and only the server knows which.
        downloadPath: widget.file.downloadPath,
        fileId: widget.file.id,
        fileName: widget.file.fileName,
      );
    } on NoViewerException {
      // The bytes arrived and the phone has nothing that reads them. Its own
      // message, because "check your connection" would send an employer looking
      // in the wrong place.
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.fileNoViewer)),
      );
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
