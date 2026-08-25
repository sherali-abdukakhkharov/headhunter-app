import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/auth/session_controller.dart';
import 'package:jobbridge_app/src/core/config/app_flavor.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/auth/data/auth_repository.dart';
import 'package:jobbridge_app/src/features/auth/domain/otp_challenge.dart';
import 'package:jobbridge_app/src/features/auth/domain/uz_phone.dart';

/// What the phone screen hands to the code screen through
/// `GoRouterState.extra`.
///
/// A record would do, but a named type is what the route's `redirect`
/// type-tests against to decide whether this screen can function at all — see
/// the route definition in `app_router.dart`.
class OtpVerificationArgs {
  const OtpVerificationArgs({required this.phone, required this.challenge});

  final UzPhone phone;

  /// The response to the send that got the user here. Supplies the resend
  /// countdown; §4.2 makes the delay server configuration, so it is never a
  /// constant on this side.
  final OtpChallenge challenge;
}

/// Code entry — the second step of sign-in (§4.1).
///
/// On success the session state changes and the router leaves on its own. This
/// screen never navigates to a shell, which is the rule the whole redirect
/// chain depends on. It *does* navigate backwards, because "change number" is
/// a real user intent and the back stack is the honest way to express it.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({required this.args, super.key});

  final OtpVerificationArgs args;

  /// Digits in a code, matching the backend's `OTP_LENGTH` default.
  ///
  /// A default, not a constant: §4.2 makes the length server configuration. The
  /// send response does not currently carry it, so this is the app's assumption
  /// — and it is only used for input length and a validation message, never to
  /// decide whether a code is correct. That decision is entirely the server's.
  static const codeLength = 6;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends ConsumerState<OtpVerificationScreen> {
  final _controller = TextEditingController();

  late OtpChallenge _challenge = widget.args.challenge;
  late Duration _resendIn = _challenge.resendIn;
  Timer? _ticker;

  bool _busy = false;

  /// **The server's** refusal — a wrong code, an expired one, a rate limit —
  /// already localized.
  ///
  /// Never a local validation result. An incomplete code is a fact about the
  /// field, and raising it as the page's error state put "Something went
  /// wrong" above a code the user had not finished entering (MT-013).
  String? _error;

  UzPhone get _phone => widget.args.phone;

  /// The digits entered so far, which is what both the button and the field's
  /// own guidance are derived from.
  String get _code => _controller.text.trim();

  bool get _isComplete => _code.length == OtpVerificationScreen.codeLength;

  /// Confirm is offered only for a code that could succeed.
  bool get _canVerify => _isComplete && !_busy;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Drives the Confirm button's enabled state, and clears the server's last
    // refusal the moment the user starts correcting the code — rather than
    // leaving a red box contradicting what they are typing.
    _controller.addListener(_onCodeChanged);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _controller
      ..removeListener(_onCodeChanged)
      ..dispose();
    super.dispose();
  }

  void _onCodeChanged() => setState(() => _error = null);

  /// Guidance on the field while the code is short. Held back on an empty
  /// field: the user has just arrived and has been told nothing yet.
  String? _codeError(AppL10n l10n) => _code.isEmpty || _isComplete
      ? null
      : l10n.authCodeInvalid(OtpVerificationScreen.codeLength);

  /// Ticks the countdown down locally rather than recomputing it from the wall
  /// clock each second.
  ///
  /// The comparison against the server's deadline happens exactly once, in
  /// [OtpChallenge.resendIn], where it is clamped for clock skew. Re-deriving
  /// it per tick would reintroduce that skew sixty times a minute and let a
  /// clock that jumps mid-countdown produce a timer that runs backwards.
  void _startCountdown() {
    _ticker?.cancel();
    if (_resendIn == Duration.zero) return;

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = _resendIn - const Duration(seconds: 1);
      if (next <= Duration.zero) {
        timer.cancel();
        setState(() => _resendIn = Duration.zero);
      } else {
        setState(() => _resendIn = next);
      }
    });
  }

  Future<void> _verify() async {
    final code = _code;

    // Defence only. [_canVerify] gates the button, the keyboard's done action
    // and the retry, so arriving here short would mean they had drifted apart.
    if (!_isComplete) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .signInWithOtp(phone: _phone.wire, code: code);
      // Deliberately no navigation: the session change drives the router.
    } on ApiException catch (e) {
      // Rendered directly - server messages arrive already localized via
      // `x-lang`. A 401 here is "wrong, expired or already used", and the
      // server will not say which: distinguishing them would tell an attacker
      // which numbers have a code pending.
      _report(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    final l10n = AppL10n.of(context);

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final challenge = await ref
          .read(authRepositoryProvider)
          .resendOtp(_phone.wire);

      if (!mounted) return;
      setState(() {
        _challenge = challenge;
        _resendIn = challenge.resendIn;
        // The previous code is dead the moment a new one is issued - the
        // backend supersedes it. Leaving the old digits in the box invites the
        // user to submit them and be told they are wrong.
        _controller.clear();
      });
      _startCountdown();
      // A resend's only other visible effect is the countdown restarting, which
      // is easy to miss and reads as "nothing happened".
      HhToast.show(context, message: l10n.authCodeResent);
    } on ApiException catch (e) {
      // Expected traffic, not a bug: a 429 is how §4.2's resend delay and the
      // per-phone rate limit are enforced, and its message says how long to
      // wait.
      _report(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _report(String message) {
    if (mounted) setState(() => _error = message);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final canResend = _resendIn == Duration.zero && !_busy;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authCodeTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(HhSpace.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.authCodeSentTo(_phone.display),
                style: HhTypography.body,
              ),
              const SizedBox(height: HhSpace.lg),

              if (_error case final message?) ...[
                HhErrorState(
                  title: l10n.stateErrorTitle,
                  message: message,
                  retryLabel: l10n.commonRetry,
                  onRetry: _canVerify ? _verify : null,
                ),
                const SizedBox(height: HhSpace.lg),
              ],

              HhTextField(
                label: l10n.authCodeLabel,
                controller: _controller,
                keyboardType: TextInputType.number,
                // Inline, where the problem is — not the page-level error
                // state, whose heading says "Something went wrong" (MT-013).
                errorText: _codeError(l10n),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: OtpVerificationScreen.codeLength,
                textInputAction: TextInputAction.done,
                enabled: !_busy,
                onSubmitted: (_) {
                  if (_canVerify) unawaited(_verify());
                },
                // No onChanged: the controller listener from initState clears
                // the server's message and rebuilds for the button.
              ),
              const SizedBox(height: HhSpace.lg),

              HhButton(
                label: l10n.authVerifyCode,
                loading: _busy,
                // An empty field cannot verify, so offering the action would
                // be a promise the next tap breaks.
                onPressed: _canVerify ? _verify : null,
              ),
              const SizedBox(height: HhSpace.md),

              HhButton.tertiary(
                label: canResend
                    ? l10n.authResendCode
                    : l10n.authResendIn(_resendIn.inSeconds),
                onPressed: canResend ? _resend : null,
              ),
              const SizedBox(height: HhSpace.sm),

              HhButton.tertiary(
                label: l10n.authChangePhone,
                onPressed: _busy ? null : () => context.pop(),
              ),

              if (AppFlavor.current.allowsDevelopmentTools &&
                  _challenge.devCode != null) ...[
                const SizedBox(height: HhSpace.sectionGap),
                // Only ever visible in a development build: the backend refuses
                // to boot with OTP_ECHO_IN_RESPONSE set in production, so
                // `devCode` is null there. The flavor gate is the second lock.
                HhNotice.pending(
                  title: 'Development',
                  message:
                      'No SMS provider is connected. The backend issued '
                      '${_challenge.devCode}.',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
