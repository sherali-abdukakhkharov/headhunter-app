import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/auth/session_controller.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/account/data/account_repository.dart';
import 'package:jobbridge_app/src/features/account/domain/user_session.dart';
import 'package:jobbridge_app/src/shared/widgets/refreshable_fill.dart';

/// Opens the account screen.
Future<void> showAccount(BuildContext context) =>
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(builder: (_) => const AccountScreen()),
    );

/// Signed-in devices (§4.2), signing out, and asking for deletion (BR-14).
///
/// ## Why these three belong together
///
/// They are the only screen in the product where somebody acts on **the account
/// rather than on the work**. Until now sign-out existed in two places — the
/// dev tools screen and the blocked-account screen — and in neither could an
/// ordinary signed-in user reach it, which meant the app had no way out. That
/// is also a store requirement rather than a nicety: an app that lets people
/// create an account has to let them delete it from inside the app.
///
/// ## Revoking the current device is offered, not hidden
///
/// The list marks which row is this phone, and revoking it is allowed — it is
/// the same thing as signing out, and hiding it would leave somebody looking at
/// a list of their devices unable to act on the one in their hand. It is
/// confirmed like the others, and the session controller notices the tokens are
/// gone.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final sessions = ref.watch(userSessionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(userSessionsProvider),
          child: switch (sessions) {
            // Error before any loading arm: retry is off app-wide, so a failure
            // is terminal and a spinner over it would be permanent.
            AsyncValue(hasError: true, :final error?) => RefreshableFill(
              child: Padding(
                padding: const EdgeInsets.all(HhSpace.gutter),
                child: Column(
                  children: [
                    HhErrorState(
                      title: l10n.stateErrorTitle,
                      message: error is ApiException
                          ? error.message
                          : l10n.stateErrorBody,
                      retryLabel: l10n.commonRetry,
                      onRetry: () => ref.invalidate(userSessionsProvider),
                    ),
                    const SizedBox(height: HhSpace.sectionGap),
                    // Offered even when the list failed: signing out of *this*
                    // device needs no list, and a screen that can only fail is
                    // a screen that traps somebody who came here to leave.
                    const _SignOut(),
                  ],
                ),
              ),
            ),
            AsyncData(:final value) => _Body(sessions: value),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.sessions});

  final List<UserSession> sessions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return ListView(
      padding: const EdgeInsets.all(HhSpace.gutter),
      children: [
        Text(l10n.accountDevices, style: HhTypography.subtitle),
        const SizedBox(height: HhSpace.xs),
        Text(
          l10n.accountDevicesBody,
          style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
        ),
        const SizedBox(height: HhSpace.md),

        for (final session in sessions)
          Padding(
            padding: const EdgeInsets.only(bottom: HhSpace.sm),
            child: _SessionRow(session: session),
          ),

        if (sessions.length > 1) ...[
          const SizedBox(height: HhSpace.sm),
          const _RevokeAll(),
        ],

        const SizedBox(height: HhSpace.sectionGap),
        const _SignOut(),

        const SizedBox(height: HhSpace.sectionGap),
        Text(l10n.accountDelete, style: HhTypography.subtitle),
        const SizedBox(height: HhSpace.md),
        const _DeleteAccount(),
      ],
    );
  }
}

/// One device, and the control that ends it.
class _SessionRow extends ConsumerStatefulWidget {
  const _SessionRow({required this.session});

  final UserSession session;

  @override
  ConsumerState<_SessionRow> createState() => _SessionRowState();
}

class _SessionRowState extends ConsumerState<_SessionRow> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final session = widget.session;

    return HhCard(
      child: Row(
        children: [
          HhIcon(
            HhIconPath.phone,
            size: 20,
            color: session.isCurrent ? HhColors.brand600 : HhColors.inkMuted,
            strokeWidth: 2,
          ),
          const SizedBox(width: HhSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // A row that cannot name its device still has to say what it
                  // is, or it reads as a rendering failure.
                  session.label ?? l10n.accountDeviceUnknown,
                  style: HhTypography.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  // The wall clock the platform recorded, never `.toLocal()`:
                  // a session opened abroad would otherwise be dated in the
                  // wrong zone (§8.3).
                  l10n.accountLastUsed(
                    _stamp(session.lastUsedAt.wallClock),
                  ),
                  style: HhTypography.caption.copyWith(
                    color: HhColors.inkMuted,
                  ),
                ),
                if (session.isCurrent) ...[
                  const SizedBox(height: 4),
                  HhBadge.applicationViewed(label: l10n.accountThisDevice),
                ],
              ],
            ),
          ),
          if (_busy)
            const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            )
          else
            HhButton.text(label: l10n.accountRevoke, onPressed: _revoke),
        ],
      ),
    );
  }

  Future<void> _revoke() async {
    final l10n = AppL10n.of(context);
    final confirmed = await _confirm(
      context,
      title: widget.session.isCurrent
          ? l10n.accountRevokeCurrentTitle
          : l10n.accountRevokeTitle,
      message: widget.session.isCurrent
          ? l10n.accountRevokeCurrentBody
          : l10n.accountRevokeBody,
      action: l10n.accountRevoke,
    );
    if (!confirmed || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    try {
      await ref
          .read(accountRepositoryProvider)
          .revokeSession(widget.session.id);

      if (widget.session.isCurrent) {
        // Revoking this device is signing out, and the tokens on disk are now
        // worthless. Clearing them locally is what moves the redirect chain to
        // onboarding; leaving them would keep a signed-in shell on screen until
        // the next request failed.
        await ref.read(sessionControllerProvider.notifier).signOut();
        return;
      }

      ref.invalidate(userSessionsProvider);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// §4.2's "terminate all".
class _RevokeAll extends ConsumerStatefulWidget {
  const _RevokeAll();

  @override
  ConsumerState<_RevokeAll> createState() => _RevokeAllState();
}

class _RevokeAllState extends ConsumerState<_RevokeAll> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return HhButton.secondary(
      label: l10n.accountRevokeAll,
      loading: _busy,
      onPressed: _busy ? null : _revokeAll,
    );
  }

  Future<void> _revokeAll() async {
    final l10n = AppL10n.of(context);
    final confirmed = await _confirm(
      context,
      title: l10n.accountRevokeAllTitle,
      // Says plainly that it includes this phone: "every device" is the kind of
      // phrase people read as "every *other* device".
      message: l10n.accountRevokeAllBody,
      action: l10n.accountRevokeAll,
    );
    if (!confirmed || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    try {
      await ref.read(accountRepositoryProvider).revokeAll();
      await ref.read(sessionControllerProvider.notifier).signOut();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// Sign out of this device only.
class _SignOut extends ConsumerWidget {
  const _SignOut();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    return HhButton.secondary(
      label: l10n.commonSignOut,
      iconPath: HhIconPath.arrowLeft,
      onPressed: () => ref.read(sessionControllerProvider.notifier).signOut(),
    );
  }
}

/// BR-14's deletion **request**.
class _DeleteAccount extends ConsumerStatefulWidget {
  const _DeleteAccount();

  @override
  ConsumerState<_DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends ConsumerState<_DeleteAccount> {
  bool _busy = false;
  bool _requested = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    if (_requested) {
      // No date, because the server sends none: `purgeAfter` is null while the
      // retention period is an open client question, and inventing one would be
      // promising something nobody has agreed to.
      return HhNotice.pending(
        title: l10n.accountDeleteRequestedTitle,
        message: l10n.accountDeleteRequestedBody,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.accountDeleteBody,
          style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
        ),
        const SizedBox(height: HhSpace.md),
        HhButton.destructive(
          label: l10n.accountDeleteAction,
          loading: _busy,
          onPressed: _busy ? null : _request,
        ),
      ],
    );
  }

  Future<void> _request() async {
    final l10n = AppL10n.of(context);
    final confirmed = await _confirm(
      context,
      title: l10n.accountDeleteConfirmTitle,
      message: l10n.accountDeleteConfirmBody,
      action: l10n.accountDeleteAction,
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    try {
      await ref.read(accountRepositoryProvider).requestDeletion();
      if (mounted) setState(() => _requested = true);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// A confirmation the user has to read.
///
/// Every action on this screen is irreversible from the client's side — a
/// revoked session cannot be un-revoked and a deletion request cannot be
/// withdrawn here — so none of them happens on one tap. The action word is the
/// verb rather than "OK", because a dialog whose buttons say OK and Cancel
/// makes the reader work out which one does the thing.
Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String message,
  required String action,
  bool destructive = false,
}) async {
  final l10n = AppL10n.of(context);

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: HhColors.white,
      title: Text(title, style: HhTypography.subtitle),
      content: Text(message, style: HhTypography.body),
      actions: [
        HhButton.text(
          label: l10n.commonCancel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        if (destructive)
          HhButton.destructive(
            label: action,
            expand: false,
            onPressed: () => Navigator.of(context).pop(true),
          )
        else
          HhButton(
            label: action,
            expand: false,
            onPressed: () => Navigator.of(context).pop(true),
          ),
      ],
    ),
  );

  return result ?? false;
}

/// A timestamp as the platform recorded it, ISO-ordered.
///
/// The same treatment `invitationStamp` gives §8.2's dates, and for the same
/// reason: §8.3's display policy is still open, so a wrong-looking date beats a
/// plausible wrong one.
String _stamp(DateTime wallClock) =>
    '${wallClock.year.toString().padLeft(4, '0')}-'
    '${wallClock.month.toString().padLeft(2, '0')}-'
    '${wallClock.day.toString().padLeft(2, '0')} '
    '${wallClock.hour.toString().padLeft(2, '0')}:'
    '${wallClock.minute.toString().padLeft(2, '0')}';
