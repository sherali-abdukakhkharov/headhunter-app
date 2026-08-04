import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/config/app_flavor.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/core/l10n/app_locale.dart';
import 'package:headhunter_app/src/core/l10n/locale_controller.dart';
import 'package:headhunter_app/src/core/router/routes.dart';

/// Entry point for an account with no session. **M1** replaces the body with
/// the real flow: phone entry, terms and privacy acceptance, and OTP (§4).
///
/// The language picker below is not a placeholder - §3.2 requires language to
/// be selectable **before** registration, and the locale controller that backs
/// it already persists the choice locally. Building it here now also means the
/// four-variant check has a home from the first screen, rather than being
/// retrofitted once there are screens to retrofit it through.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final active = ref.watch(activeLocaleProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(HhSpace.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: HhSpace.xxl),
              Text(l10n.appTitle, style: HhTypography.display),
              const SizedBox(height: HhSpace.xl),
              Text(l10n.settingsLanguage, style: HhTypography.subtitle),
              const SizedBox(height: HhSpace.md),
              for (final option in AppLocale.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: HhSpace.sm),
                  child: HhRadioRow<AppLocale>(
                    // nativeName, never a translated language name: a picker
                    // rendering every option in the *current* language is
                    // unusable to the one person who needs it - someone who
                    // cannot read the current language.
                    label: option.nativeName,
                    value: option,
                    groupValue: active,
                    onChanged: (_) => ref
                        .read(localeControllerProvider.notifier)
                        .select(option),
                  ),
                ),
              const SizedBox(height: HhSpace.sectionGap),
              // Scaffolding copy, deliberately unlocalized - it is replaced in
              // M1 and the designer owns the real onboarding text.
              const HhNotice.pending(
                title: 'Registration arrives in M1',
                message:
                    'Phone entry, terms acceptance and OTP (§4). The language '
                    'choice above is already live and survives a restart.',
              ),
              if (AppFlavor.current.allowsDevelopmentTools) ...[
                const SizedBox(height: HhSpace.sectionGap),
                HhButton(
                  label: 'Developer tools',
                  iconPath: HhIconPath.filters,
                  onPressed: () => context.go(Routes.developerTools),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
