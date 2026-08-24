import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/auth/app_role.dart';
import 'package:jobbridge_app/src/core/auth/session_controller.dart';
import 'package:jobbridge_app/src/core/auth/session_state.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/discovery/presentation/vacancy_detail_screen.dart';
import 'package:jobbridge_app/src/features/notifications/data/notification_repository.dart';
import 'package:jobbridge_app/src/features/notifications/domain/app_notification.dart';
import 'package:jobbridge_app/src/shared/format/wall_clock.dart';

/// Opens §9.2's notification centre.
///
/// Pushed rather than routed, the same way the account screen is, and for the
/// same reason: every shell path has to begin with a role's prefix so a deep
/// link can say which role it needs, and this screen belongs to all three. A
/// route per role would be three registrations of one screen.
Future<void> showNotifications(BuildContext context) =>
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );

/// §9.2's in-app notification centre.
///
/// ## The sentence comes from the server
///
/// A notification stores a message key and its parameters, and the server
/// renders it in the language of the request — so a user who switches language
/// reads their whole history in the new one. The client shows the text as given
/// and **branches on `event` and `targetType`**, never on the words.
///
/// ## A row leads somewhere, or it does not pretend to
///
/// The destination depends on the target *and* on the role reading it: a
/// conversation opens in whichever shell has a Messages tab, and an
/// application opens the candidate's list because the employer's applicants
/// live under a vacancy this notification does not name. Where there is no
/// honest destination the row is still shown — it is a record — and simply
/// does not offer one. See [notificationDestination].
///
/// ## Push is not here
///
/// The records exist server-side whether or not a push was delivered, which is
/// what lets the in-app half ship on its own. The device-token half waits on
/// `google-services.json`, which still names the pre-rename package.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _unreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final page = ref.watch(notificationsProvider(unreadOnly: _unreadOnly));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          IconButton(
            tooltip: l10n.notificationsSettings,
            icon: const HhIcon(HhIconPath.filters, size: 20),
            onPressed: () => showNotificationPreferences(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(HhSpace.gutter),
            child: Row(
              children: [
                Expanded(
                  child: HhSegmented(
                    labels: [
                      l10n.notificationsAll,
                      l10n.notificationsUnread,
                    ],
                    selectedIndex: _unreadOnly ? 1 : 0,
                    // Screen state, not the location: this screen is pushed
                    // rather than routed, so there is no branch for a `go` to
                    // land in the wrong half of.
                    onChanged: (index) =>
                        setState(() => _unreadOnly = index == 1),
                  ),
                ),
                const SizedBox(width: HhSpace.sm),
                HhButton.text(
                  label: l10n.notificationsMarkAllRead,
                  onPressed: () => _markAllRead(context),
                ),
              ],
            ),
          ),

          Expanded(
            // Error first: with retry disabled app-wide a failing provider is
            // terminal, and matching the loading arm first spins over it.
            child: switch (page) {
              AsyncValue(hasError: true, :final error?) => Padding(
                padding: const EdgeInsets.all(HhSpace.gutter),
                child: HhErrorState(
                  title: l10n.stateErrorTitle,
                  message: error is ApiException
                      ? error.message
                      : l10n.stateErrorBody,
                  retryLabel: l10n.commonRetry,
                  onRetry: () => ref.invalidate(
                    notificationsProvider(unreadOnly: _unreadOnly),
                  ),
                ),
              ),
              AsyncData(:final value) => _List(
                page: value,
                unreadOnly: _unreadOnly,
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }

  Future<void> _markAllRead(BuildContext context) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final marked = await ref
          .read(notificationsProvider(unreadOnly: _unreadOnly).notifier)
          .markAllRead();

      // Says what happened rather than confirming an action that changed
      // nothing: marking an already-read list succeeds and marks zero.
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            marked == 0
                ? l10n.notificationsNothingUnread
                : l10n.notificationsMarkedRead(marked),
          ),
        ),
      );
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

class _List extends ConsumerWidget {
  const _List({required this.page, required this.unreadOnly});

  final NotificationPage page;
  final bool unreadOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    if (page.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(HhSpace.gutter),
        child: HhEmptyState(
          title: unreadOnly
              ? l10n.notificationsNoUnread
              : l10n.notificationsEmpty,
          message: unreadOnly
              ? l10n.notificationsNoUnreadBody
              : l10n.notificationsEmptyBody,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        HhSpace.gutter,
        0,
        HhSpace.gutter,
        HhSpace.gutter,
      ),
      children: [
        for (final item in page.items) ...[
          _Row(item: item, unreadOnly: unreadOnly),
          const SizedBox(height: HhSpace.sm),
        ],

        if (page.isLoadingMore)
          HhLoadingMore(label: l10n.commonLoadingMore)
        else if (page.hasMore)
          HhButton.text(
            label: l10n.commonShowMore,
            onPressed: () => _loadMore(context, ref),
          ),
      ],
    );
  }

  Future<void> _loadMore(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(notificationsProvider(unreadOnly: unreadOnly).notifier)
          .loadMore();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

class _Row extends ConsumerWidget {
  const _Row({required this.item, required this.unreadOnly});

  final AppNotification item;
  final bool unreadOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    // The session's own answer, which cannot name a role the account has
    // since lost — `effectiveRole` exists for exactly that.
    final role = switch (ref.watch(sessionControllerProvider)) {
      SessionActive(:final effectiveRole) => effectiveRole,
      _ => null,
    };
    final destination = notificationDestination(item, role);

    return HhCard(
      onTap: () => _open(context, ref, destination),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unread is a dot **and** a weight, never colour alone — the same
          // rule the badges follow.
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: SizedBox(
              width: 8,
              child: item.isRead
                  ? null
                  : const DecoratedBox(
                      decoration: BoxDecoration(
                        color: HhColors.brand600,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(width: 8, height: 8),
                    ),
            ),
          ),
          const SizedBox(width: HhSpace.sm),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // The server's sentence, already in this reader's language.
                  item.text,
                  style: item.isRead
                      ? HhTypography.body
                      : HhTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                ),
                const SizedBox(height: HhSpace.xs),
                // A Wrap, not a Row: two unconstrained `Text`s in a Row
                // overflow the card as soon as either is long, and a category
                // name is longer in Russian than in English. Wrapping to a
                // second line is the one failure mode that loses nothing.
                Wrap(
                  spacing: HhSpace.sm,
                  children: [
                    Text(
                      categoryLabel(item.category, l10n),
                      style: HhTypography.caption.copyWith(
                        color: HhColors.inkSubtle,
                      ),
                    ),
                    Text(
                      wallClockStamp(item.createdAt.wallClock),
                      style: HhTypography.caption.copyWith(
                        color: HhColors.inkSubtle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (destination != null) ...[
            const SizedBox(width: HhSpace.sm),
            const HhIcon(
              HhIconPath.chevronRight,
              size: 18,
              color: HhColors.inkSubtle,
            ),
          ],
        ],
      ),
    );
  }

  /// Marks it read, then goes where it points.
  ///
  /// Read first and regardless of the destination: tapping is having seen it,
  /// and a notification that leads nowhere is still one somebody has read.
  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    String? destination,
  ) async {
    final navigator = Navigator.of(context);

    if (!item.isRead) {
      try {
        await ref
            .read(notificationsProvider(unreadOnly: unreadOnly).notifier)
            .markRead(item.id);
      } on ApiException {
        // A notification that cannot be marked read is still one somebody
        // wants to follow. Swallowed rather than shown: the failure costs a
        // dot, and the tap was about the destination.
      }
    }

    if (destination == null) return;

    // The centre is pushed on top of the shell, so it has to come off before
    // a shell path can be shown — otherwise the destination renders behind
    // this screen and the back gesture returns to a notification list the
    // user has finished with.
    navigator.pop();

    if (destination == _pushVacancy) {
      if (context.mounted) {
        // No feed: this did not come from one, so there is no list to
        // invalidate on the way back.
        await showVacancyDetail(context, id: item.targetId!);
      }
      return;
    }

    // Read after the null check: a notification that leads nowhere must not
    // require a router to be tapped.
    if (context.mounted) GoRouter.of(context).go(destination);
  }
}

/// Sentinel for the one destination that is pushed rather than routed: a
/// candidate's vacancy detail has no path of its own.
const _pushVacancy = 'push:vacancy';

/// Where a notification leads, for the role reading it — or null.
///
/// ## The role decides, because the same event has two readers
///
/// A `conversation` opens under whichever shell has a Messages tab, and an
/// `application` opens the candidate's list because an employer reaches
/// applicants *through a vacancy* the notification does not name. Guessing a
/// vacancy id from an application id is a request this has no business making,
/// so the employer's application rows lead nowhere and the row says so by
/// having no chevron.
///
/// ## Null is a real answer
///
/// A row with no destination is still worth showing: §9.2's account notices
/// are the record of something that happened, and BR-10's restriction notice
/// in particular has nowhere to go — the explanation is the notification.
String? notificationDestination(AppNotification item, AppRole? role) =>
    switch ((item.targetType, role)) {
      // §9.1's thread, in the shell that has one. The administrator has no
      // Messages tab, so an admin reading their own notification gets no link.
      ('conversation', AppRole.candidate) when item.targetId != null =>
        '${Routes.candidateMessages}/${item.targetId}',
      ('conversation', AppRole.employer) when item.targetId != null =>
        '${Routes.employerMessages}/${item.targetId}',

      // The candidate's own applications, invitations and interviews all live
      // behind one tab (§8.1, §8.2) — which is also why none of the three
      // needs an id here.
      ('application' || 'invitation' || 'interview', AppRole.candidate) =>
        Routes.candidateApplications,

      // An employer's vacancy is addressable; their applicants are not, from
      // an application id alone.
      ('vacancy', AppRole.employer) when item.targetId != null =>
        '${Routes.employerVacancies}/${item.targetId}',
      ('vacancy', AppRole.candidate) when item.targetId != null =>
        _pushVacancy,

      // §6.1's verification decision, which is about the company profile.
      ('employer', AppRole.employer) => Routes.employerCompany,

      // §10.4's account screen, for an administrator reading about somebody.
      // For a candidate or an employer a `user` target is *themselves*, and
      // the notice is the whole of it — see the doc above.
      ('user', AppRole.admin) when item.targetId != null =>
        Routes.adminUserFor(item.targetId!),

      _ => null,
    };

/// §9.2's category, as a word.
String categoryLabel(NotificationCategory category, AppL10n l10n) =>
    switch (category) {
      NotificationCategory.applications => l10n.notificationsApplications,
      NotificationCategory.invitations => l10n.notificationsInvitations,
      NotificationCategory.messages => l10n.notificationsMessages,
      NotificationCategory.interviews => l10n.notificationsInterviews,
      NotificationCategory.account => l10n.notificationsAccount,
      // A category added after this build shipped. The sentence still reads,
      // so the row is worth drawing without a name for its group.
      NotificationCategory.unknown => l10n.notificationsOther,
    };

/// §9.2's per-category switches.
Future<void> showNotificationPreferences(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _Preferences(),
    );

class _Preferences extends ConsumerWidget {
  const _Preferences();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final preferences = ref.watch(notificationPreferencesProvider);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: HhColors.white,
        borderRadius: HhRadius.sheetTop,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(HhSpace.gutter),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.notificationsSettings,
                  style: HhTypography.subtitle,
                ),
                const SizedBox(height: HhSpace.xs),
                Text(
                  // Worth saying before a switch is thrown: a disabled
                  // category stores nothing at all, so what is missed is
                  // missed rather than hidden.
                  l10n.notificationsSettingsBody,
                  style: HhTypography.caption.copyWith(
                    color: HhColors.inkMuted,
                  ),
                ),
                const SizedBox(height: HhSpace.lg),

                switch (preferences) {
                  AsyncValue(hasError: true, :final error?) => HhErrorState(
                    title: l10n.stateErrorTitle,
                    message: error is ApiException
                        ? error.message
                        : l10n.stateErrorBody,
                    retryLabel: l10n.commonRetry,
                    onRetry: () =>
                        ref.invalidate(notificationPreferencesProvider),
                  ),
                  AsyncData(:final value) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final row in value)
                        HhSwitchRow(
                          label: categoryLabel(row.category, l10n),
                          value: row.enabled,
                          description: row.canDisable
                              ? null
                              : l10n.notificationsAlwaysOn,
                          // §9.2 keeps security and account notices on. A null
                          // handler is how this component says "not yours to
                          // change", and the row is **shown rather than
                          // omitted**: a user who cannot find a switch assumes
                          // it is off.
                          onChanged: row.canDisable
                              ? (enabled) => _set(
                                  context,
                                  ref,
                                  row.category,
                                  enabled: enabled,
                                )
                              : null,
                        ),
                    ],
                  ),
                  _ => const Center(child: CircularProgressIndicator()),
                },

                const SizedBox(height: HhSpace.lg),
                HhButton.text(
                  label: l10n.commonBack,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _set(
    BuildContext context,
    WidgetRef ref,
    NotificationCategory category, {
    required bool enabled,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(notificationPreferencesProvider.notifier)
          .set(category, enabled: enabled);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

/// The way in to §9.2, with its badge.
///
/// A row rather than a nav-bar item: the shell is capped at five destinations
/// for every role and all five are spoken for — the same cap that keeps the
/// wallet off the employer's bar and the audit log off the administrator's. It
/// carries the count because an unread badge nobody can see is not a badge.
class NotificationsEntryRow extends ConsumerWidget {
  const NotificationsEntryRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    // `.value` and not a switch: a failed count is simply not drawn. The row
    // still opens the centre, which reports the failure properly.
    final unread = ref.watch(unreadNotificationCountProvider).value ?? 0;

    return HhCard(
      onTap: () => showNotifications(context),
      child: Row(
        children: [
          const HhIcon(
            HhIconPath.bell,
            size: 20,
            color: HhColors.inkMuted,
            strokeWidth: 2,
          ),
          const SizedBox(width: HhSpace.md),
          Expanded(
            child: Text(l10n.notificationsTitle, style: HhTypography.body),
          ),
          if (unread > 0) ...[
            HhMetaChip(label: '$unread'),
            const SizedBox(width: HhSpace.sm),
          ],
          const HhIcon(
            HhIconPath.chevronRight,
            size: 18,
            color: HhColors.inkDisabled,
          ),
        ],
      ),
    );
  }
}
