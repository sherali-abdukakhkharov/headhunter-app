import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/auth/session_controller.dart';
import 'package:jobbridge_app/src/core/auth/session_state.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/app_router.dart';
import 'package:jobbridge_app/src/features/discovery/presentation/vacancy_detail_screen.dart';
import 'package:jobbridge_app/src/features/notifications/data/notification_repository.dart';
import 'package:jobbridge_app/src/features/notifications/data/push_messaging.dart';
import 'package:jobbridge_app/src/features/notifications/data/push_platform.dart';
import 'package:jobbridge_app/src/features/notifications/presentation/notifications_screen.dart';

/// Wraps the app so a tapped push opens what it is about (§9.2).
///
/// Three jobs, all of which need something a provider does not have:
///
/// - **the notification channel**, whose name is a translated string and so
///   needs the active interface variant rather than the phone's locale;
/// - **a tapped notification**, which needs the router and the active role;
/// - **a push that arrived while the app was open**, which Android does not
///   display — the app is in front — so the badge is refreshed instead of
///   being left stale until something else invalidates it.
///
/// ## The launch tap has to wait for the session
///
/// A tap on a notification for a *closed* app is delivered as launch state,
/// once. At that moment the session is still [SessionUnknown] and the router is
/// on the splash screen, so navigating immediately loses the destination: the
/// redirect chain resolves a frame later and moves to the shell's home, over
/// the top of it. So the payload is held until the session has an answer, and
/// routed on the frame after that.
///
/// If the answer is "signed out" the payload is dropped rather than kept for a
/// later sign-in. The notification is still in the centre, which is where
/// somebody who has just signed in will look.
class PushHost extends ConsumerStatefulWidget {
  const PushHost({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<PushHost> createState() => _PushHostState();
}

class _PushHostState extends ConsumerState<PushHost> {
  StreamSubscription<PushPayload>? _opened;
  StreamSubscription<PushPayload>? _foreground;

  /// A tap that launched the app, waiting for the session to resolve.
  PushPayload? _pendingLaunch;

  @override
  void initState() {
    super.initState();

    final messaging = ref.read(pushMessagingProvider);
    _opened = messaging.opened().listen(_route);
    _foreground = messaging.foregroundMessages().listen(_onForegroundMessage);

    unawaited(_takeLaunchTap(messaging));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Depends on Localizations, so this re-runs when the interface variant
    // changes — which is exactly when the channel needs renaming. Creating a
    // channel that already exists updates its name and leaves the importance,
    // sound and vibration the user may have changed alone.
    final l10n = AppL10n.of(context);
    unawaited(
      ref.read(pushPlatformProvider).configureChannel(
        name: l10n.pushChannelName,
        description: l10n.pushChannelDescription,
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_opened?.cancel());
    unawaited(_foreground?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Not a watch: this widget wraps the whole app and must not rebuild it on
    // every session change. The listener exists only to release a launch tap
    // that arrived before the session had an answer.
    ref.listen(sessionControllerProvider, (_, _) => _releaseLaunchTap());

    return widget.child;
  }

  Future<void> _takeLaunchTap(PushMessaging messaging) async {
    final payload = await messaging.initialMessage();
    if (payload == null || !mounted) return;

    _pendingLaunch = payload;
    _releaseLaunchTap();
  }

  /// Routes the held launch tap once the session can say which role is active.
  void _releaseLaunchTap() {
    final payload = _pendingLaunch;
    if (payload == null) return;

    final session = ref.read(sessionControllerProvider);
    // Still restoring. The router is on splash and anything sent now is undone
    // by the redirect that follows.
    if (session is SessionUnknown) return;

    _pendingLaunch = null;
    if (session is! SessionActive) return;

    // After the frame in which the redirect chain moves off the splash screen,
    // so this lands on top of that move rather than under it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_route(payload));
    });
  }

  /// A push arrived while the app was open.
  ///
  /// Android shows nothing in this case, so the notification would otherwise be
  /// invisible until something else refetched. §9.2's badge is the thing that
  /// has to be right: a count that lags is worse than no count, because it is
  /// read as authoritative.
  void _onForegroundMessage(PushPayload payload) {
    ref
      ..invalidate(unreadNotificationCountProvider)
      ..invalidate(notificationsProvider);
  }

  /// Marks the notification read, then goes where it points.
  ///
  /// Read first and regardless of the destination, the same way the in-app row
  /// does it: tapping is having seen it, and a notification that leads nowhere
  /// is still one somebody has read.
  Future<void> _route(PushPayload payload) async {
    if (payload.notificationId case final id?) {
      try {
        await ref.read(notificationRepositoryProvider).markRead(id);
        ref
          ..invalidate(unreadNotificationCountProvider)
          ..invalidate(notificationsProvider);
      } on ApiException {
        // The tap was about the destination. A notification that cannot be
        // marked read costs a dot and nothing else.
      }
    }

    if (!mounted) return;

    // The session's own answer, which cannot name a role the account has since
    // lost — the same reading the in-app row uses.
    final role = switch (ref.read(sessionControllerProvider)) {
      SessionActive(:final effectiveRole) => effectiveRole,
      _ => null,
    };

    // The one table, shared with the in-app centre. A second copy here is the
    // bug where a push and the row announcing it lead to different screens.
    final destination = notificationTargetDestination(
      targetType: payload.targetType,
      targetId: payload.targetId,
      role: role,
    );
    if (destination == null) return;

    final router = ref.read(appRouterProvider);

    if (destination == pushVacancyDestination) {
      // A candidate's vacancy detail is pushed rather than routed, so it needs
      // a navigator. The root one is the router's own.
      final navigatorContext =
          router.routerDelegate.navigatorKey.currentContext;
      if (navigatorContext != null && navigatorContext.mounted) {
        // No feed: this did not come from one, so there is no list to
        // invalidate on the way back.
        await showVacancyDetail(navigatorContext, id: payload.targetId!);
      }
      return;
    }

    // A destination whose role the account no longer holds, or one reached
    // while signed out, is handled by the redirect chain rather than here —
    // that is the chain's whole job, and duplicating the check would give two
    // answers to one question.
    router.go(destination);
  }
}
