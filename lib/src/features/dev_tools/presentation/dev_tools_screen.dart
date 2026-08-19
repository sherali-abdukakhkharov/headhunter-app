import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/auth/app_role.dart';
import 'package:jobbridge_app/src/core/auth/session_controller.dart';
import 'package:jobbridge_app/src/core/auth/session_state.dart';
import 'package:jobbridge_app/src/core/config/app_config.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/l10n/app_locale.dart';
import 'package:jobbridge_app/src/core/l10n/locale_controller.dart';
import 'package:jobbridge_app/src/core/router/role_navigation.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';

/// Developer tools: mint a session with hardcoded roles, switch language, and
/// reach the design catalogue and the health probe.
///
/// This is what makes M0.5 checkable before M1 exists - the role shells and the
/// redirect chain are finished, but nothing can sign in yet, so there would
/// otherwise be no way to see either of them.
///
/// **Not registered in the production flavor.** The router omits the route
/// entirely rather than hiding the screen behind a check, so it cannot be
/// reached in a store build by a deep link either.
class DevToolsScreen extends ConsumerWidget {
  const DevToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final locale = ref.watch(activeLocaleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Developer tools')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(HhSpace.gutter),
          children: [
            _Section(
              title: 'Build',
              child: _KeyValues({
                'Flavor': AppConfig.flavor.name,
                'Display name': AppConfig.flavor.displayName,
                'App id suffix': AppConfig.flavor.appIdSuffix.isEmpty
                    ? '(none)'
                    : AppConfig.flavor.appIdSuffix,
                'API base URL': AppConfig.apiBaseUrl,
                'URL source': AppConfig.isApiBaseUrlOverridden
                    ? '--dart-define=API_BASE_URL'
                    : 'flavor default',
              }),
            ),
            const SizedBox(height: HhSpace.sectionGap),
            _Section(
              title: 'Session',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _KeyValues({'State': _describe(session)}),
                  const SizedBox(height: HhSpace.md),
                  // Every combination the redirect chain has a branch for,
                  // including the ones that are easy to get wrong: two roles at
                  // once (§2.3), an account with no role yet, and a blocked one
                  // (BR-10).
                  for (final scenario in _scenarios)
                    Padding(
                      padding: const EdgeInsets.only(bottom: HhSpace.sm),
                      child: HhButton.secondary(
                        label: scenario.label,
                        onPressed: () async {
                          await ref
                              .read(sessionControllerProvider.notifier)
                              .signInAsDevelopmentRole(
                                scenario.roles,
                                status: scenario.status,
                                restrictionReason: scenario.reason,
                              );
                          if (context.mounted) context.go(Routes.splash);
                        },
                      ),
                    ),
                  HhButton.tertiary(
                    label: 'Sign out',
                    iconPath: HhIconPath.lock,
                    onPressed: () =>
                        ref.read(sessionControllerProvider.notifier).signOut(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: HhSpace.sectionGap),
            _Section(
              title: 'Active role',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final role in AppRole.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: HhSpace.sm),
                      child: HhButton.tertiary(
                        label: 'Switch to ${role.name}',
                        // Disabled rather than hidden when the role is not
                        // granted: seeing it greyed out is what demonstrates
                        // that the grant, not the button, is the gate.
                        onPressed: session is SessionActive && session.can(role)
                            ? () => switchRoleAndGo(context, ref, role)
                            : null,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: HhSpace.sectionGap),
            _Section(
              title: 'Interface variant',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final option in AppLocale.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: HhSpace.sm),
                      child: HhButton.tertiary(
                        // nativeName, so the four variants are distinguishable
                        // without already reading the current one.
                        label:
                            '${option.nativeName}  ·  ${option.tag}'
                            '${option == locale ? '  ✓' : ''}',
                        onPressed: () => ref
                            .read(localeControllerProvider.notifier)
                            .select(option),
                      ),
                    ),
                  const SizedBox(height: HhSpace.xs),
                  _KeyValues({
                    'appTitle': AppL10n.of(context).appTitle,
                    'navHome': AppL10n.of(context).navHome,
                    'navUsers': AppL10n.of(context).navUsers,
                  }),
                ],
              ),
            ),
            const SizedBox(height: HhSpace.sectionGap),
            _Section(
              title: 'Surfaces',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HhButton(
                    label: 'Design system catalogue',
                    iconPath: HhIconPath.filters,
                    onPressed: () => context.go(Routes.designGallery),
                  ),
                  const SizedBox(height: HhSpace.sm),
                  HhButton.secondary(
                    label: 'Dictionaries and pickers',
                    iconPath: HhIconPath.dictionary,
                    onPressed: () => context.go(Routes.dictionaryProbe),
                  ),
                  const SizedBox(height: HhSpace.sm),
                  HhButton.secondary(
                    label: 'Backend health probe',
                    iconPath: HhIconPath.refresh,
                    onPressed: () => context.go(Routes.health),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _describe(SessionState session) => switch (session) {
    SessionUnknown() => 'restoring…',
    SessionUnauthenticated(expired: true) => 'signed out (session expired)',
    SessionUnauthenticated() => 'signed out',
    SessionActive(:final roles, :final status) =>
      'roles: ${roles.isEmpty ? '(none)' : roles.map((r) => r.name).join(', ')}'
          ' · active: ${session.effectiveRole?.name ?? '(none)'}'
          ' · ${status.name}',
  };

  static const _scenarios = [
    _Scenario(label: 'Sign in as candidate', roles: {AppRole.candidate}),
    _Scenario(label: 'Sign in as employer', roles: {AppRole.employer}),
    _Scenario(label: 'Sign in as administrator', roles: {AppRole.admin}),
    _Scenario(
      label: 'Sign in with both roles',
      roles: {AppRole.candidate, AppRole.employer},
    ),
    _Scenario(label: 'Sign in with no role yet', roles: {}),
    _Scenario(
      label: 'Sign in blocked (BR-10)',
      roles: {AppRole.candidate},
      status: AccountStatus.blocked,
      reason:
          'Repeated false vacancy reports. Contact support to appeal. '
          '(Sample admin reason - shown verbatim, never translated.)',
    ),
  ];
}

@immutable
class _Scenario {
  const _Scenario({
    required this.label,
    required this.roles,
    this.status = AccountStatus.active,
    this.reason,
  });

  final String label;
  final Set<AppRole> roles;
  final AccountStatus status;
  final String? reason;
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(title, style: HhTypography.subtitle),
      const SizedBox(height: HhSpace.md),
      Container(
        padding: const EdgeInsets.all(HhSpace.cardPadding),
        decoration: const BoxDecoration(
          color: HhColors.white,
          borderRadius: HhRadius.cardAll,
          border: Border.fromBorderSide(HhBorders.card),
        ),
        child: child,
      ),
    ],
  );
}

class _KeyValues extends StatelessWidget {
  const _KeyValues(this.values);

  final Map<String, String> values;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final entry in values.entries)
        Padding(
          padding: const EdgeInsets.only(bottom: HhSpace.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.key, style: HhTypography.caption),
              // Stacked rather than a two-column row: these values are long
              // (URLs, role lists) and a fixed label column splits them
              // mid-word at large text scale.
              Text(entry.value, style: HhTypography.body),
            ],
          ),
        ),
    ],
  );
}
