import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/auth/session_controller.dart';
import 'package:headhunter_app/src/core/config/app_config.dart';
import 'package:headhunter_app/src/core/config/app_flavor.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/core/l10n/app_locale.dart';
import 'package:headhunter_app/src/core/l10n/locale_controller.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/core/router/routes.dart';
import 'package:headhunter_app/src/features/auth/data/telegram_sign_in.dart';

/// Language, consent, and **Log in with Telegram** (§4.1).
///
/// ## Why not phone + OTP
///
/// §4.1 describes phone entry and a one-time password, and the backend has that
/// flow built. The MVP signs in with Telegram instead: its `phone` scope gives
/// a number Telegram itself verified, satisfying **BR-01** with no SMS. OTP is
/// **deferred, not deleted** - it is the fallback for a user who declines to
/// share their number, since BR-01 admits no account without one. Full plan in
/// docs/TELEGRAM_LOGIN.md.
///
/// The language picker is not a placeholder: §3.2 requires language to be
/// selectable **before** registration, and the choice persists locally.
///
/// On success the session state changes and the router moves to role selection
/// or a shell on its own - this screen never navigates. That is the same rule
/// the whole redirect chain follows.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  /// §4.1 step 2. Consent is a precondition, so it gates the button rather than
  /// being collected afterwards - Telegram does not collect it for us.
  bool _termsAccepted = false;

  bool _signingIn = false;

  /// Localized, already resolved. Null when there is nothing to report.
  String? _error;

  Future<void> _signIn() async {
    // Resolved **before** the await, deliberately. Reading it in the catch
    // blocks would touch a BuildContext across an async gap, and the Telegram
    // flow leaves the app entirely - so the widget genuinely may be gone by the
    // time control returns. The strings are cheap; hold them, not the context.
    final l10n = AppL10n.of(context);

    setState(() {
      _signingIn = true;
      _error = null;
    });

    try {
      await ref.read(sessionControllerProvider.notifier).signInWithTelegram();
      // Deliberately no navigation: the session change drives the router.
    } on TelegramSignInCancelled {
      // Not an error. The user pressed back in Telegram; saying "login failed"
      // to somebody who chose to cancel is how an app feels broken.
    } on TelegramSignInFailure catch (failure) {
      _report(switch (failure.kind) {
        TelegramSignInFailureKind.network => l10n.authSignInNoConnection,
        TelegramSignInFailureKind.notConfigured => l10n.authSignInUnavailable,
        TelegramSignInFailureKind.telegram => l10n.authSignInFailed,
      });
    } on ApiException catch (e) {
      // Rendered directly: server messages arrive already localized thanks to
      // `x-lang`. This is the path a login with no Telegram-verified phone
      // number takes (BR-01), and the server's wording explains it better than
      // anything we could guess here.
      _report(e.message);
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  void _report(String message) {
    if (mounted) setState(() => _error = message);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final activeLocale = ref.watch(activeLocaleProvider);
    final canSignIn = _termsAccepted && !_signingIn;

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
                    groupValue: activeLocale,
                    onChanged: (_) => ref
                        .read(localeControllerProvider.notifier)
                        .select(option),
                  ),
                ),

              const SizedBox(height: HhSpace.sectionGap),
              Text(l10n.authSignInTitle, style: HhTypography.subtitle),
              const SizedBox(height: HhSpace.md),

              if (_error case final message?) ...[
                HhErrorState(
                  title: l10n.stateErrorTitle,
                  message: message,
                  retryLabel: l10n.commonRetry,
                  onRetry: canSignIn ? _signIn : null,
                ),
                const SizedBox(height: HhSpace.lg),
              ],

              HhCheckboxRow(
                label: l10n.authTermsAgree,
                value: _termsAccepted,
                onChanged: (accepted) =>
                    setState(() => _termsAccepted = accepted),
              ),
              const SizedBox(height: HhSpace.lg),

              HhButton(
                label: l10n.authTelegramSignIn,
                iconPath: HhIconPath.send,
                loading: _signingIn,
                // Disabled until consent is given (§4.1 step 2), and while a
                // login is in flight - a second tap would start a second
                // Telegram flow and the first result would be discarded.
                onPressed: canSignIn ? _signIn : null,
              ),

              if (!AppConfig.flavor.isTelegramSignInAvailable) ...[
                const SizedBox(height: HhSpace.md),
                // Development safety net: this build's application id has no
                // redirect URI registered with BotFather, so the button cannot
                // work. Saying so up front beats a failure after two taps.
                HhNotice.pending(
                  title: l10n.authSignInUnavailable,
                  message:
                      'Flavor "${AppConfig.flavor.name}" has no registered '
                      'Telegram redirect URI. See docs/TELEGRAM_LOGIN.md §7.',
                ),
              ],

              if (AppFlavor.current.allowsDevelopmentTools) ...[
                const SizedBox(height: HhSpace.sectionGap),
                HhButton.tertiary(
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
