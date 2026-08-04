import 'package:flutter/material.dart';

import 'package:headhunter_app/src/core/design/components/hh_button.dart';
import 'package:headhunter_app/src/core/design/hh_colors.dart';
import 'package:headhunter_app/src/core/design/hh_icons.dart';
import 'package:headhunter_app/src/core/design/hh_metrics.dart';
import 'package:headhunter_app/src/core/design/hh_typography.dart';

/// The UI states the design treats as **deliverables, not implementation
/// details** — each is drawn in the specification and each must exist before a
/// screen is considered done.
///
/// Reach for these rather than inventing a one-off `CircularProgressIndicator`
/// or a bare "Error" string: the states are where a product feels either
/// trustworthy or unfinished, and this is a product that asks people for
/// identity documents.

/// A single skeleton block. Sizes should mirror the real content's geometry so
/// nothing jumps when data lands.
class HhSkeletonBlock extends StatelessWidget {
  const HhSkeletonBlock({
    super.key,
    this.width,
    this.height = 12,
    this.light = false,
  });

  final double? width;
  final double height;

  /// Use for secondary lines, so a skeleton card has visual hierarchy rather
  /// than reading as a grey slab.
  final bool light;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: light ? HhColors.skeletonLight : HhColors.skeleton,
      borderRadius: BorderRadius.circular(5),
    ),
  );
}

/// **State 01 — first load.** A skeleton shaped like the vacancy card, shown
/// instead of a blank screen.
class HhVacancyCardSkeleton extends StatelessWidget {
  const HhVacancyCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: const BoxDecoration(
      borderRadius: HhRadius.cardAll,
      border: Border.fromBorderSide(HhBorders.faint),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: HhSkeletonBlock(height: 15)),
            SizedBox(width: HhSpace.lg),
            HhSkeletonBlock(width: 18, height: 18, light: true),
          ],
        ),
        SizedBox(height: 10),
        HhSkeletonBlock(width: 120, light: true),
        SizedBox(height: 10),
        HhSkeletonBlock(width: 150, height: 15),
        SizedBox(height: 10),
        Row(
          children: [
            HhSkeletonBlock(width: 66, height: 22, light: true),
            SizedBox(width: 6),
            HhSkeletonBlock(width: 54, height: 22, light: true),
          ],
        ),
      ],
    ),
  );
}

/// **State 02 — loading more.** Footer spinner for pagination. Keeps the
/// already loaded rows visible, which a full-screen loader would not.
class HhLoadingMore extends StatelessWidget {
  const HhLoadingMore({required this.label, super.key});

  /// Localized, e.g. "Loading 12 more…".
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: HhSpace.lg),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 17,
          height: 17,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: HhTypography.caption.copyWith(fontSize: 13.5),
        ),
      ],
    ),
  );
}

/// **State 03 — empty.** Illustration, what is missing, why it matters, and one
/// action that resolves it.
///
/// The body text should explain how the list *fills up*, not merely restate
/// that it is empty.
class HhEmptyState extends StatelessWidget {
  const HhEmptyState({
    required this.title,
    required this.message,
    super.key,
    this.actionLabel,
    this.onAction,
    this.illustration,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? illustration;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
    decoration: const BoxDecoration(
      color: HhColors.white,
      borderRadius: HhRadius.cardAll,
      border: Border.fromBorderSide(HhBorders.card),
    ),
    child: Column(
      children: [
        SizedBox(
          width: 110,
          height: 80,
          child:
              illustration ??
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: HhColors.sand50,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
        ),
        const SizedBox(height: HhSpace.md),
        Text(
          title,
          style: HhTypography.subtitle.copyWith(fontSize: 15),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          message,
          style: HhTypography.caption.copyWith(fontSize: 13.5, height: 1.5),
          textAlign: TextAlign.center,
        ),
        if (actionLabel != null) ...[
          const SizedBox(height: HhSpace.md),
          HhButton(
            label: actionLabel!,
            onPressed: onAction,
            expand: false,
            compact: true,
          ),
        ],
      ],
    ),
  );
}

/// **State 04 — offline.** Warning-toned, and explicitly reassuring: entered
/// data is retained and will be sent when the connection returns.
///
/// Saying so is not decoration. Without it users re-submit, which is exactly
/// the duplicate-write problem idempotency keys exist to prevent.
class HhOfflineBanner extends StatelessWidget {
  const HhOfflineBanner({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: HhColors.warningBg,
      borderRadius: BorderRadius.circular(11),
      border: Border.all(color: HhColors.warningBorder),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: HhIcon(
            HhIconPath.wifiOff,
            size: 18,
            color: HhColors.warningFg,
            strokeWidth: 2,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: HhTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: HhColors.warningFg,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: HhTypography.caption.copyWith(
                  fontSize: 12.5,
                  height: 1.45,
                  color: HhColors.warningFg,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// **State 05 — server error**, and the general failure surface.
///
/// Always offers a retry. A dead end with no action is the state users
/// screenshot and send to support.
class HhErrorState extends StatelessWidget {
  const HhErrorState({
    required this.title,
    required this.message,
    super.key,
    this.retryLabel,
    this.onRetry,
  });

  final String title;
  final String message;
  final String? retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: HhColors.errorBg,
      borderRadius: HhRadius.cardAll,
      border: Border.all(color: HhColors.errorBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const HhIcon(
              HhIconPath.alertTriangle,
              size: 20,
              color: HhColors.errorFg,
              strokeWidth: 2,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: HhTypography.subtitle.copyWith(
                  fontSize: 15,
                  color: HhColors.errorFg,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: HhSpace.sm),
        Text(
          message,
          style: HhTypography.caption.copyWith(
            fontSize: 13.5,
            height: 1.5,
            color: HhColors.errorFg,
          ),
        ),
        if (retryLabel != null) ...[
          const SizedBox(height: HhSpace.md),
          HhButton.tertiary(
            label: retryLabel!,
            onPressed: onRetry,
            iconPath: HhIconPath.refresh,
            compact: true,
          ),
        ],
      ],
    ),
  );
}

/// **States 06-08, 10 — informational notices.**
///
/// One component covers permission-denied, awaiting-moderation,
/// restricted-action and expired-content: each is "here is a condition, here is
/// what you can do about it", differing only in tone.
class HhNotice extends StatelessWidget {
  const HhNotice({
    required this.title,
    required this.message,
    required this.iconPath,
    super.key,
    this.tone = HhNoticeTone.info,
    this.actionLabel,
    this.onAction,
  });

  /// Location permission not granted.
  const HhNotice.permission({
    required this.title,
    required this.message,
    super.key,
    this.actionLabel,
    this.onAction,
  }) : tone = HhNoticeTone.info,
       iconPath = HhIconPath.location;

  /// Awaiting moderation or verification — nothing for the user to do but wait.
  const HhNotice.pending({
    required this.title,
    required this.message,
    super.key,
    this.actionLabel,
    this.onAction,
  }) : tone = HhNoticeTone.warning,
       iconPath = HhIconPath.clock;

  /// Action blocked — a restricted or blocked account (BR-10), which must
  /// always state the reason rather than silently failing.
  const HhNotice.restricted({
    required this.title,
    required this.message,
    super.key,
    this.actionLabel,
    this.onAction,
  }) : tone = HhNoticeTone.error,
       iconPath = HhIconPath.lock;

  /// Deadline passed, vacancy closed.
  const HhNotice.expired({
    required this.title,
    required this.message,
    super.key,
    this.actionLabel,
    this.onAction,
  }) : tone = HhNoticeTone.neutral,
       iconPath = HhIconPath.clock;

  final String title;
  final String message;
  final String iconPath;
  final HhNoticeTone tone;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (tone) {
      HhNoticeTone.info => (
        HhColors.infoBg,
        HhColors.infoFg,
        HhColors.brand200,
      ),
      HhNoticeTone.warning => (
        HhColors.warningBg,
        HhColors.warningFg,
        HhColors.warningBorder,
      ),
      HhNoticeTone.error => (
        HhColors.errorBg,
        HhColors.errorFg,
        HhColors.errorBorder,
      ),
      HhNoticeTone.neutral => (
        HhColors.neutralBg,
        HhColors.inkMuted,
        HhColors.borderSubtle,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: HhIcon(
                  iconPath,
                  size: 18,
                  color: fg,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: HhTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: fg,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      message,
                      style: HhTypography.caption.copyWith(
                        fontSize: 12.5,
                        height: 1.45,
                        color: fg,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: HhSpace.md),
            HhButton.tertiary(
              label: actionLabel!,
              onPressed: onAction,
              compact: true,
            ),
          ],
        ],
      ),
    );
  }
}

enum HhNoticeTone { info, warning, error, neutral }

/// **State 11 — success toast.** Dark surface, success glyph, and an optional
/// action on the right.
///
/// Show with [show] so it is consistently positioned and timed.
class HhToast extends StatelessWidget {
  const HhToast({
    required this.message,
    super.key,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Presents the toast over the current scaffold.
  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: HhToast(
          message: message,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
    decoration: BoxDecoration(
      color: HhColors.brand900,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Row(
      children: [
        const HhIcon(
          HhIconPath.checkCircle,
          size: 19,
          color: HhColors.successOnDark,
          strokeWidth: 2.1,
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            message,
            style: HhTypography.caption.copyWith(
              fontSize: 13.5,
              height: 1.4,
              color: HhColors.white,
            ),
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Padding(
              padding: const EdgeInsets.only(left: HhSpace.md),
              child: Text(
                actionLabel!,
                style: HhTypography.caption.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: HhColors.accentOnDark,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

/// **State 09 — destructive confirmation.**
///
/// Names the consequence in the body and puts the destructive verb on the
/// button, so the confirm button never just says "OK".
class HhConfirmDialog extends StatelessWidget {
  const HhConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    super.key,
    this.destructive = true,
  });

  final String title;
  final String message;

  /// The verb, e.g. "Delete account" — never "OK".
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  /// Returns true when confirmed.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    bool destructive = true,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => HhConfirmDialog(
          title: title,
          message: message,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          destructive: destructive,
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Row(
      children: [
        HhIcon(
          destructive ? HhIconPath.alertTriangle : HhIconPath.infoCircle,
          size: 22,
          color: destructive ? HhColors.error : HhColors.brand600,
          strokeWidth: 2,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: HhTypography.subtitle)),
      ],
    ),
    content: Text(
      message,
      style: HhTypography.body.copyWith(color: HhColors.inkMuted),
    ),
    actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    actions: [
      Column(
        children: [
          if (destructive)
            HhButton.destructive(
              label: confirmLabel,
              onPressed: () => Navigator.of(context).pop(true),
            )
          else
            HhButton(
              label: confirmLabel,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          const SizedBox(height: HhSpace.sm),
          HhButton.text(
            label: cancelLabel,
            onPressed: () => Navigator.of(context).pop(false),
            expand: true,
          ),
        ],
      ),
    ],
  );
}
