import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';

/// What `POST /auth/otp/send` (and `/resend`) returns: a code is now waiting on
/// the phone, and these are its two deadlines.
///
/// Mirrors `OtpSentResponseDto` in headhunter-backend — **change both
/// together.**
///
/// Hand-written rather than `json_serializable`, unlike `AuthSession`: both
/// fields are [ZonedTimestamp], which is not a type the generator knows. A
/// `JsonConverter` would be more machinery than the two lines it replaces.
class OtpChallenge {
  const OtpChallenge({
    required this.expiresAt,
    required this.resendAvailableAt,
    required this.receivedAt,
    this.codeLength = defaultCodeLength,
    this.maxAttempts = defaultMaxAttempts,
    this.devCode,
  });

  /// [receivedAt] defaults to now, which is what every real caller wants — it
  /// is injectable only so tests can pin the countdown.
  ///
  /// [codeLength] and [maxAttempts] fall back to the defaults when absent,
  /// because a server older than 2026-08-26 does not send them. That is a
  /// deliberate tolerance rather than an oversight: the app is on phones and
  /// the two deploys are not simultaneous.
  factory OtpChallenge.fromJson(
    Map<String, dynamic> json, {
    DateTime? receivedAt,
  }) => OtpChallenge(
    expiresAt: ZonedTimestamp.parse(json['expiresAt'] as String),
    resendAvailableAt: ZonedTimestamp.parse(
      json['resendAvailableAt'] as String,
    ),
    receivedAt: receivedAt ?? DateTime.now().toUtc(),
    codeLength: switch (json['codeLength']) {
      final int value when value > 0 => value,
      _ => defaultCodeLength,
    },
    maxAttempts: switch (json['maxAttempts']) {
      final int value when value > 0 => value,
      _ => defaultMaxAttempts,
    },
    devCode: json['devCode'] as String?,
  );

  /// After this the code is dead and the user must request another (§4.2).
  final ZonedTimestamp expiresAt;

  /// Earliest moment the server will accept a resend (§4.2). Sending before it
  /// is a 429.
  final ZonedTimestamp resendAvailableAt;

  /// When this client received the response. The countdown is anchored here
  /// rather than recomputed against the wall clock on every tick — see
  /// [resendIn].
  final DateTime receivedAt;

  /// Digits in the code the server just sent (`OTP_LENGTH`, §4.2).
  ///
  /// The field used to be a constant on the screen with a comment admitting it
  /// was an assumption. It was: changing `OTP_LENGTH` would have given every
  /// installed app an input that refuses the code it was sent, and nothing
  /// would have said why.
  final int codeLength;

  /// Wrong guesses this code allows before lockout (`OTP_MAX_ATTEMPTS`, §4.2).
  ///
  /// **The limit, not the number remaining, and the difference is a security
  /// decision the backend made rather than an omission.** `/auth/otp/verify`
  /// answers `auth.otp_invalid` identically for "no code", "expired" and "wrong
  /// code", so probing a number cannot reveal whether one is pending. A
  /// remaining-attempt count on that refusal would be exactly that oracle.
  ///
  /// So the countdown is the *client's* own: it knows how many times it has
  /// submitted since this challenge was issued, which is accurate for the
  /// person actually typing — the only party a countdown is for. The server
  /// stays authoritative and answers `auth.otp_too_many_attempts` whatever this
  /// side believed.
  final int maxAttempts;

  /// What the client assumes when the server does not say.
  ///
  /// Matches the backend's own defaults (`OTP_LENGTH`, `OTP_MAX_ATTEMPTS`), so
  /// an app talking to a server that predates the fields behaves as it always
  /// did rather than differently.
  static const defaultCodeLength = 6;
  static const defaultMaxAttempts = 5;

  /// **Development only.** The code itself, echoed by the backend when
  /// `OTP_ECHO_IN_RESPONSE` is on. Absent in production: the backend refuses to
  /// boot with that flag set there.
  ///
  /// Show it only behind `AppFlavor.allowsDevelopmentTools`.
  final String? devCode;

  /// How long until a resend is allowed, measured at [receivedAt].
  ///
  /// Clamped at both ends because this is the one place two clocks meet: the
  /// server chose `resendAvailableAt`, the device chose [receivedAt]. A device
  /// whose clock is a day fast would otherwise produce a negative wait (a
  /// resend button that is live immediately and earns a 429), and one a day
  /// slow a countdown measured in hours. [maxResendWait] is well above any
  /// resend delay §4.2 would plausibly configure, so clamping only bites on
  /// skew.
  Duration get resendIn {
    final remaining = resendAvailableAt.instant.difference(receivedAt);
    if (remaining.isNegative) return Duration.zero;
    return remaining > maxResendWait ? maxResendWait : remaining;
  }

  /// Ceiling for [resendIn]. Guards against device clock skew, not against
  /// server configuration.
  static const maxResendWait = Duration(minutes: 5);

  /// Never include [devCode]: it is a live credential for one phone number, and
  /// these strings reach log lines. Same rule as `AuthSession.toString`.
  @override
  String toString() =>
      'OtpChallenge(expiresAt: ${expiresAt.wallClock}, '
      'resendIn: $resendIn, '
      'devCode: ${devCode == null ? 'none' : '<redacted>'})';
}
