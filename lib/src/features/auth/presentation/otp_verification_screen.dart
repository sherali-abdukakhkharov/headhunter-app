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

  /// Digits in a code, when the challenge does not say.
  ///
  /// It used to be the app's standing assumption, with a comment admitting that
  /// the send response did not carry the length. **It does now** — the backend
  /// publishes `codeLength` and `maxAttempts` on the challenge as of
  /// 2026-08-26 — so this is only the fallback for a server that predates that,
  /// and `OtpChallenge.codeLength` is what the screen actually reads.
  static const int codeLength = OtpChallenge.defaultCodeLength;

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

  /// The challenge's own rules, not the app's assumption about them (§4.2).
  int get _codeLength => _challenge.codeLength;

  bool get _isComplete => _code.length == _codeLength;

  /// Confirm is offered only for a code that could succeed.
  bool get _canVerify => _isComplete && !_busy && !_lockedOut;

  /// Wrong codes submitted since this challenge was issued.
  ///
  /// **Counted here rather than reported by the server, and that is a security
  /// decision rather than a shortcut.** `/auth/otp/verify` answers
  /// `auth.otp_invalid` identically for "no code", "expired" and "wrong code",
  /// so probing a number cannot reveal whether one is pending — and a
  /// remaining-attempt count attached to that refusal would be exactly that
  /// oracle. The *limit* travels on the send, where it reveals nothing.
  ///
  /// Local counting is accurate for the person actually typing, which is the
  /// only party a countdown is for. It can undercount — a code entered on a
  /// second device, an app restart — and the server remains authoritative
  /// either way, answering `auth.otp_too_many_attempts` whatever this side
  /// believed. Undercounting shows a smaller number than the truth, which errs
  /// toward warning early.
  int _wrongAttempts = 0;

  /// The code this screen sent without being asked, so it cannot send the same
  /// one twice.
  ///
  /// The field submits itself the moment it holds a full code — which is what
  /// makes an autofilled SMS a zero-tap sign-in — and a refusal leaves those
  /// digits in the box. Without this, the listener would fire again on the next
  /// rebuild and spend the attempt budget on its own.
  ///
  /// Confirm stays enabled either way, so retrying the *same* code after a
  /// timeout is still one tap. Automatic once, manual afterwards.
  String? _autoSubmitted;

  /// True once the *server* has said this code is finished.
  ///
  /// Not derived from [_wrongAttempts]: the client's count is advisory and
  /// disabling the button on it would refuse an attempt the server would have
  /// accepted.
  bool _lockedOut = false;

  /// How many the user has left, or null once there is no point saying.
  ///
  /// Held back until the last two, deliberately. "5 attempts left" on a first
  /// mistype is nagging; "1 attempt left" is the one a person needs, and a
  /// warning that appears only when it matters is one they read.
  int? get _attemptsLeft {
    final left = _challenge.maxAttempts - _wrongAttempts;
    return left > 0 && left <= 2 ? left : null;
  }

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

  void _onCodeChanged() {
    setState(() => _error = null);

    // §4.2's code has a known length and there is nothing else on this screen
    // to do with it. Waiting for a tap after the sixth digit — or after Android
    // has filled all six from the message — is a step that asks the user to
    // confirm what they have already said.
    if (!_canVerify || _autoSubmitted == _code) return;

    _autoSubmitted = _code;
    unawaited(_verify());
  }

  /// Guidance on the field while the code is short. Held back on an empty
  /// field: the user has just arrived and has been told nothing yet.
  String? _codeError(AppL10n l10n) => _code.isEmpty || _isComplete
      ? null
      : l10n.authCodeInvalid(_codeLength);

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

      if (mounted) {
        setState(() {
          // **401 only.** A 5xx, a timeout or an offline failure never reached
          // the code, so counting them would burn attempts the server has not
          // taken — and would tell somebody on a bad connection they were one
          // guess from being locked out.
          if (e.statusCode == 401) _wrongAttempts += 1;
          // 429 on *this* route is the lockout (§4.2), not the resend delay:
          // resend has its own handler below. The server has finished with
          // this code, so the only way forward is a new one.
          if (e.statusCode == 429) _lockedOut = true;
        });
      }
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
        // A new code is a new challenge, with its own attempt budget — so the
        // count restarts and the lockout lifts. Carrying either across would
        // leave somebody who did the one thing the app told them to do still
        // looking at "1 attempt left".
        _wrongAttempts = 0;
        _lockedOut = false;
        // The previous code is dead the moment a new one is issued - the
        // backend supersedes it. Leaving the old digits in the box invites the
        // user to submit them and be told they are wrong.
        _controller.clear();
        // A new challenge may legitimately arrive at the same six digits, and
        // it deserves the same automatic send as the first one.
        _autoSubmitted = null;
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
                  // The server's refusal, then what to do about it. Once the
                  // code is locked out the refusal alone is a dead end: it
                  // says this attempt failed, not that the only way on is a
                  // new code.
                  message: _lockedOut
                      ? '$message\n\n${l10n.authAttemptsExhausted}'
                      : message,
                  retryLabel: l10n.commonRetry,
                  onRetry: _canVerify ? _verify : null,
                ),
                const SizedBox(height: HhSpace.lg),
              ],

              // §4.2's budget, counted here and shown only once it is nearly
              // spent. A caption rather than a notice: it is a fact about how
              // many tries are left, not a state the account is in, and toning
              // it as a warning on every mistype is how a warning stops being
              // read.
              if (_attemptsLeft case final left? when !_lockedOut) ...[
                Text(
                  l10n.authAttemptsLeft(left),
                  style: HhTypography.caption.copyWith(
                    color: HhColors.warning,
                  ),
                ),
                const SizedBox(height: HhSpace.md),
              ],

              // `AutofillGroup` is what lets the platform act on the hint
              // below; a field declaring one outside a group is ignored.
              AutofillGroup(
                child: HhTextField(
                  label: l10n.authCodeLabel,
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  // The only thing on this screen to do. Arriving with the
                  // caret in the box and the number pad already up removes a
                  // tap from every sign-in, and it is safe here in a way it
                  // would not be on a form: there is no second field for it to
                  // steal focus from.
                  autofocus: true,
                  // Android reads the code out of the message and offers it
                  // above the keyboard. Nothing is read without the user
                  // choosing it, and the app never sees the SMS.
                  autofillHints: const [AutofillHints.oneTimeCode],
                  // Inline, where the problem is — not the page-level error
                  // state, whose heading says "Something went wrong" (MT-013).
                  errorText: _codeError(l10n),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: _codeLength,
                  textInputAction: TextInputAction.done,
                  enabled: !_busy,
                  onSubmitted: (_) {
                    if (_canVerify) unawaited(_verify());
                  },
                  // No onChanged: the controller listener from initState clears
                  // the server's message, rebuilds for the button, and sends a
                  // complete code on its own.
                ),
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
