import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/auth/app_role.dart';
import 'package:headhunter_app/src/core/auth/session_controller.dart';
import 'package:headhunter_app/src/core/design/design.dart';

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

  static const List<AppRole> _selectable = [
    AppRole.candidate,
    AppRole.employer,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

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
                    onChanged: (checked) => setState(() {
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
                // Disabled until something is chosen: an empty selection would
                // set an empty role set, and the redirect chain would bounce
                // straight back here - a button that looks broken.
                onPressed: _selected.isEmpty
                    ? null
                    : () => ref
                          .read(sessionControllerProvider.notifier)
                          .setGrantedRoles(Set.of(_selected)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
