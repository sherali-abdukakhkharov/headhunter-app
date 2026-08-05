import 'package:headhunter_app/src/core/time/zoned_timestamp.dart';

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
    this.devCode,
  });

  /// [receivedAt] defaults to now, which is what every real caller wants — it
  /// is injectable only so tests can pin the countdown.
  factory OtpChallenge.fromJson(
    Map<String, dynamic> json, {
    DateTime? receivedAt,
  }) => OtpChallenge(
    expiresAt: ZonedTimestamp.parse(json['expiresAt'] as String),
    resendAvailableAt: ZonedTimestamp.parse(
      json['resendAvailableAt'] as String,
    ),
    receivedAt: receivedAt ?? DateTime.now().toUtc(),
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
