import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/storage/preferences_provider.dart';
import 'package:jobbridge_app/src/features/notifications/data/push_registration.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_primer.g.dart';

/// Whether the in-app explanation has been shown on this install.
///
/// ## Why the system dialog is not the first thing a new user sees
///
/// Registration used to open with `requestPermission()`, so Android's dialog
/// appeared the instant a code was verified — **before a new user had even
/// chosen a role**. The 1.29.0 audit's designer note is exact about what is
/// wrong with that: the interruption has no rationale a user can see, it is
/// worded by the OS in whatever language the *phone* is set to rather than the
/// one they just picked, and Android asks **once**. A "no" given to a question
/// nobody explained is a permanent no, repairable only in system settings.
///
/// So the app explains first, in its own four languages, and asks only when
/// somebody says yes. Declining here costs nothing: the device is registered
/// either way (§9.2's in-app centre is the record), and the settings sheet
/// offers the same button afterwards.
///
/// ## Stored locally, and that is the right scope
///
/// This is a fact about *this install* — whether this phone has been asked —
/// not about the account. Putting it on the account would mean a second device
/// never sees the explanation, and it is that device's permission that is being
/// asked for.
@Riverpod(keepAlive: true)
class NotificationPrimer extends _$NotificationPrimer {
  static const _storageKey = 'notifications.primer_seen';

  @override
  Future<bool> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);

    return prefs.getBool(_storageKey) ?? false;
  }

  /// Records that the explanation has been shown, whatever the answer was.
  ///
  /// **Whatever the answer**: the point is not to re-ask. Somebody who tapped
  /// Later meant later, and a sheet that returns at every launch is the same
  /// interruption this exists to remove.
  Future<void> markSeen() async {
    state = const AsyncData(true);

    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(_storageKey, true);
  }
}

/// Explains §9.2's notifications, then asks the platform if the answer is yes.
///
/// Returns whether the OS granted permission — false for a decline here, which
/// is a legitimate answer and not a failure.
Future<bool> showNotificationPrimer(BuildContext context, WidgetRef ref) async {
  await ref.read(notificationPrimerProvider.notifier).markSeen();

  if (!context.mounted) return false;

  final wants = await showHhSheet<bool>(
    context,
    builder: (_) => const _Primer(),
  );

  if (wants != true || !context.mounted) return false;

  return ref.read(pushRegistrationProvider.notifier).requestDisplayPermission();
}

class _Primer extends StatelessWidget {
  const _Primer();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: HhColors.white,
        borderRadius: HhRadius.sheetTop,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(HhSpace.gutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HhIcon(
                HhIconPath.bell,
                size: 28,
                color: HhColors.brand600,
                strokeWidth: 2,
              ),
              const SizedBox(height: HhSpace.md),
              Text(l10n.notificationsPrimerTitle, style: HhTypography.subtitle),
              const SizedBox(height: HhSpace.xs),
              Text(
                // Named events rather than "stay up to date": the value of a
                // notification is which one, and §9.2's list is short enough
                // to say.
                l10n.notificationsPrimerBody,
                style: HhTypography.body.copyWith(color: HhColors.inkMuted),
              ),
              const SizedBox(height: HhSpace.lg),
              HhButton(
                label: l10n.notificationsPrimerEnable,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: HhSpace.sm),
              HhButton.text(
                label: l10n.notificationsPrimerLater,
                expand: true,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
