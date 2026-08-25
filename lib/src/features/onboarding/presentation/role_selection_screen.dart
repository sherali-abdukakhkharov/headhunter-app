import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/auth/app_role.dart';
import 'package:jobbridge_app/src/core/auth/session_controller.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';

/// Where an account with no role is held (§2.3).
///
/// ## This is the last step of registration, and the only one with a choice in
/// it
///
/// There is no separate sign-up: `POST /auth/otp/verify` creates the account
/// when the phone is new, and a new account deliberately holds **no role** — so
/// the redirect chain lands here, and `POST /auth/roles` is what finishes
/// registering. The screen therefore has to explain two nouns, because a
/// first-time reader has no reason to know what either means *in this app*:
/// §2.2's capabilities are the explanation, one line each.
///
/// **What each role can do is stated; what it costs is not.** The employer line
/// says nothing about Coins or unlocks (§6.6), even though they are real: a
/// price quoted before anything has been offered reads as a paywall standing in
/// front of registration, and the wallet screen explains itself perfectly well
/// once there is something to spend it on.
///
/// **Picking both is encouraged rather than merely permitted.** §2.3 allows it
/// and keeps the two data sets separate, and the thing that stops people is the
/// fear that a personal job search will end up inside a company account — so
/// the screen says the spaces stay apart, in the place where the worry occurs.
///
/// **Candidate and employer are offered; administrator is not.** An admin role
/// is granted by another administrator (§10), never self-selected — offering it
/// here would be a privilege-escalation control that happens to be a button.
///
/// Nothing navigates on success: the granted roles change the session and the
/// redirect chain moves into the shell on its own.
class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  /// §2.3 allows both at once, so this is a set rather than a single choice.
  final _selected = <AppRole>{};

  bool _submitting = false;

  /// Localized by the server, already. Null when there is nothing to report.
  String? _error;

  static const List<AppRole> _selectable = [
    AppRole.candidate,
    AppRole.employer,
  ];

  Future<void> _submit() async {
    // `onPressed` is decided during build, and `setState` only schedules one —
    // so two taps inside a single frame both see the button as enabled and both
    // reach here. `POST /auth/roles` is idempotent server-side, but the second
    // call would still race the first through the state transition below
    // (MT-021), and the audit reproduced this by tapping fast.
    if (_submitting) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .selectRoles(Set.of(_selected));
      // Deliberately no navigation: the granted roles change the session, and
      // the redirect chain moves into the shell on its own.
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final canSubmit = _selected.isNotEmpty && !_submitting;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(HhSpace.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: HhSpace.xxl),
              Text(l10n.roleSelectionTitle, style: HhTypography.title),
              const SizedBox(height: HhSpace.sm),
              Text(
                l10n.roleSelectionSubtitle,
                style: HhTypography.body.copyWith(color: HhColors.inkMuted),
              ),
              const SizedBox(height: HhSpace.sectionGap),

              if (_error case final message?) ...[
                HhErrorState(
                  title: l10n.stateErrorTitle,
                  message: message,
                  retryLabel: l10n.commonRetry,
                  onRetry: canSubmit ? _submit : null,
                ),
                const SizedBox(height: HhSpace.lg),
              ],

              for (final role in _selectable)
                Padding(
                  padding: const EdgeInsets.only(bottom: HhSpace.md),
                  child: HhCard(
                    child: HhCheckboxRow(
                      label: switch (role) {
                        AppRole.candidate => l10n.roleCandidate,
                        AppRole.employer => l10n.roleEmployer,
                        AppRole.admin => l10n.roleAdmin,
                      },
                      // §2.2's capabilities. The role name alone is a word;
                      // this is what makes it a choice.
                      description: switch (role) {
                        AppRole.candidate => l10n.roleCandidateDescription,
                        AppRole.employer => l10n.roleEmployerDescription,
                        AppRole.admin => null,
                      },
                      value: _selected.contains(role),
                      onChanged: _submitting
                          ? null
                          : (checked) => setState(() {
                              if (checked) {
                                _selected.add(role);
                              } else {
                                _selected.remove(role);
                              }
                            }),
                    ),
                  ),
                ),

              // Only once both are ticked. Said earlier it would be advice
              // nobody asked for; said here it answers the question the second
              // tick raises — "does this mix my job search into the company?"
              //
              // A caption rather than an `HhNotice`: the notices carry a state
              // (pending, restricted, expired) and this is neither a state nor
              // a warning. Toning it as one would make choosing both look like
              // the risky option.
              if (_selected.length == _selectable.length) ...[
                const SizedBox(height: HhSpace.xs),
                Text(l10n.roleSelectionBoth, style: HhTypography.caption),
              ],

              const SizedBox(height: HhSpace.lg),
              HhButton(
                label: l10n.commonNext,
                loading: _submitting,
                // Disabled until something is chosen: an empty selection would
                // send an empty role set, and the redirect chain would bounce
                // straight back here - a button that looks broken.
                onPressed: canSubmit ? _submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
