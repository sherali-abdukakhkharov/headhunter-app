import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/config/app_flavor.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/l10n/app_locale.dart';
import 'package:jobbridge_app/src/core/l10n/locale_controller.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/auth/data/auth_repository.dart';
import 'package:jobbridge_app/src/features/auth/domain/uz_phone.dart';
import 'package:jobbridge_app/src/features/auth/presentation/otp_verification_screen.dart';

/// Language, consent, and **phone entry** — the first step of sign-in (§4.1).
///
/// ## Why phone + OTP and not Telegram
///
/// Telegram login shipped briefly in M0.5 and was deprecated on 2026-08-05. It
/// was chosen because its `phone` scope supplies a Telegram-verified number at
/// no SMS cost, but the user can decline that scope, which leaves an
/// authenticated account that **BR-01** will not let act — and §4.1 and UAT-01
/// both specify phone + OTP anyway. Verifying a code makes the number verified
/// by construction, so this path cannot produce that state. What remains of the
/// Telegram work, and why it was kept, is in docs/TELEGRAM_LOGIN.md.
///
/// The language picker is not a placeholder: §3.2 requires language to be
/// selectable **before** registration, and the choice persists locally. It also
/// decides the `x-lang` header, so server errors on the very next call come
/// back in the language chosen here.
///
/// This screen navigates exactly once — forward to code entry, carrying the
/// phone number and the send response. It never navigates into a shell; the
/// session change does that, which is the rule the whole redirect chain
/// follows.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _phoneController = TextEditingController();

  /// §4.1 step 2. Consent is a precondition, so it gates the button rather than
  /// being collected afterwards.
  bool _termsAccepted = false;

  bool _sending = false;

  /// **The server's** failure, already localized. Null when there is nothing to
  /// report.
  ///
  /// Deliberately never holds a local validation result. A number that is too
  /// short is a fact about the field, and answering it with the error state's
  /// "Something went wrong" heading blames the system for what the person is
  /// still in the middle of typing (MT-013). Incompleteness is [_phoneError],
  /// which renders on the field itself.
  String? _error;

  @override
  void initState() {
    super.initState();
    // The send button's enabled state is derived from the field, so the field
    // has to ask for a rebuild. Without this, "Get a code" enabled on consent
    // alone and two digits were enough to make an impossible action look
    // available — which is the first half of MT-013.
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController
      ..removeListener(_onPhoneChanged)
      ..dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    // A keystroke also clears whatever the server last said: it was about the
    // previous number.
    setState(() => _error = null);
  }

  UzPhone get _phone => UzPhone.parse(_phoneController.text);

  /// Guidance shown on the field while the number cannot be sent.
  ///
  /// Held back on an empty field: an untouched form that is already scolding
  /// the user has told them nothing, and the hint underneath already shows the
  /// shape being asked for.
  String? _phoneError(AppL10n l10n) =>
      _phoneController.text.isEmpty || _phone.isValid
      ? null
      : l10n.authPhoneInvalid;

  Future<void> _sendCode() async {
    final phone = _phone;

    // Defence only. [_canSend] gates both the button and the keyboard's done
    // action on exactly this, so reaching here with an invalid number would
    // mean the two had drifted apart.
    if (!phone.isValid) return;

    setState(() {
      _sending = true;
      _error = null;
    });

    try {
      final challenge = await ref
          .read(authRepositoryProvider)
          .sendOtp(phone.wire);

      if (!mounted) return;
      context.go(
        Routes.otpVerification,
        extra: OtpVerificationArgs(phone: phone, challenge: challenge),
      );
    } on ApiException catch (e) {
      // Rendered directly: server messages arrive already localized thanks to
      // `x-lang`. A 429 lands here and is expected traffic rather than a
      // failure - it is how §4.2's resend delay and the per-phone rate limit
      // are enforced, and the server's message says how long to wait.
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final activeLocale = ref.watch(activeLocaleProvider);
    // §4.1 step 2's consent, **and** a number the API could actually accept.
    // Both, because an enabled control is a promise that pressing it will do
    // something (MT-013).
    final canSend = _phone.isValid && _termsAccepted && !_sending;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(HhSpace.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: HhSpace.xxl),
              // The stacked lockup, not the app title as text: this is the
              // first thing anybody sees, and a logotype is what belongs
              // there. The mark also carries the product's one idea — two
              // people and the span between them — which `appTitle` cannot.
              const Center(
                child: HhBrandLockup(axis: HhBrandLockupAxis.stacked),
              ),
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
                  onRetry: canSend ? _sendCode : null,
                ),
                const SizedBox(height: HhSpace.lg),
              ],

              HhTextField(
                label: l10n.authPhoneLabel,
                controller: _phoneController,
                // The country code is fixed and shown as a prefix rather than
                // typed: the platform is Uzbekistan-only (§1), so a country
                // picker would be friction for a choice nobody has.
                prefix: '+${UzPhone.countryCode}',
                hintText: l10n.authPhoneHint,
                // Inline, where the problem is. This used to be raised as the
                // page-level error state, whose heading reads "Something went
                // wrong" — a system failure, for a number the user had not
                // finished typing (MT-013).
                errorText: _phoneError(l10n),
                keyboardType: TextInputType.phone,
                // A phone keyboard is a hint, not a restriction - every
                // platform still allows a paste.
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: UzPhone.nationalLength,
                textInputAction: TextInputAction.done,
                enabled: !_sending,
                onSubmitted: (_) {
                  if (canSend) unawaited(_sendCode());
                },
                // No onChanged: the controller listener installed in initState
                // covers both clearing the server's message and rebuilding for
                // the button's enabled state.
              ),
              const SizedBox(height: HhSpace.lg),

              HhCheckboxRow(
                label: l10n.authTermsAgree,
                value: _termsAccepted,
                onChanged: (accepted) =>
                    setState(() => _termsAccepted = accepted),
              ),
              const SizedBox(height: HhSpace.lg),

              HhButton(
                label: l10n.authSendCode,
                iconPath: HhIconPath.send,
                loading: _sending,
                // Disabled until consent is given (§4.1 step 2), and while a
                // send is in flight - a second tap would issue a second code
                // and supersede the first, which the user has already been
                // told to wait for.
                onPressed: canSend ? _sendCode : null,
              ),

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
