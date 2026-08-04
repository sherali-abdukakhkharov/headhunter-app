import 'package:flutter/material.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/core/router/shell_tabs.dart';

/// Stands in for a tab whose real screen belongs to a later milestone.
///
/// ## Why the body is not localized
///
/// The **title is** - it is the tab's own localized label, so a language switch
/// visibly changes it and the shell can be checked in all four variants, which
/// is the point of having the shell before the screens.
///
/// The body is deliberately English scaffolding copy naming the milestone. It
/// is not product text: it will not exist by M11, the designer owns the copy,
/// and adding ARB keys for it in all four variants would mean asking for
/// certified translations of strings whose purpose is to be deleted. Same
/// reasoning as the design gallery's sample copy.
///
/// **Every one of these must be gone before a build leaves the development
/// flavor.** `router_test.dart` counts them, so the number cannot quietly grow.
class ShellPlaceholderScreen extends StatelessWidget {
  const ShellPlaceholderScreen({required this.tab, super.key});

  final ShellTab tab;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(tab.label(l10n))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(HhSpace.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HhEmptyState(
                title: tab.label(l10n),
                message:
                    'This screen arrives in ${tab.milestone}. '
                    'The shell, navigation and redirects around it are done.',
              ),
              const SizedBox(height: HhSpace.sectionGap),
              // A live skeleton, so the tab is not merely a blank card: it also
              // shows the shell's padding and the bottom bar's inset against
              // real content geometry at whatever text scale is set.
              const HhVacancyCardSkeleton(),
            ],
          ),
        ),
      ),
    );
  }
}
