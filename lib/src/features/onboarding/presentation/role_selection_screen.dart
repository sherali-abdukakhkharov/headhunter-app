import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/auth/app_role.dart';
import 'package:headhunter_app/src/core/auth/session_controller.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';

/// Where an account with no role is held (§2.3). **M1** owns the finished
/// screen, with the copy explaining what each role can do.
///
/// The mechanism is real, because the redirect chain needs a working exit: the
/// choice goes to `setGrantedRoles` and the router moves into that role's shell
/// on its own. Only the presentation is provisional.
///
/// **Candidate and employer are offered; administrator is not.** An admin role
/// is granted by another administrator (§10), never self-selected - offering it
/// here would be an privilege-escalation control that happens to be a button.
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
              // Scaffolding copy - M1 replaces it with the designer's text.
              const HhNotice.pending(
                title: 'Role selection arrives in M1',
                message:
                    'The choice below is live: it grants the role and the '
                    'router moves into that shell. Only the copy is temporary.',
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
                  padding: const EdgeInsets.only(bottom: HhSpace.sm),
                  child: HhCheckboxRow(
                    label: switch (role) {
                      AppRole.candidate => l10n.roleCandidate,
                      AppRole.employer => l10n.roleEmployer,
                      AppRole.admin => l10n.roleAdmin,
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
