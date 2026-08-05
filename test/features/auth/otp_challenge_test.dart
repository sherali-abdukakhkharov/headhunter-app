import 'package:flutter_test/flutter_test.dart';
import 'package:headhunter_app/src/features/auth/domain/otp_challenge.dart';

/// The countdown is the one place a server clock and a device clock meet, so
/// the clamping is what these tests are for.
void main() {
  OtpChallenge challenge({
    required String resendAvailableAt,
    required DateTime receivedAt,
    String expiresAt = '2026-08-05T12:05:00+05:00',
    String? devCode,
  }) => OtpChallenge.fromJson({
    'expiresAt': expiresAt,
    'resendAvailableAt': resendAvailableAt,
    if (devCode != null) 'devCode': devCode,
  }, receivedAt: receivedAt);

  test('parses the two deadlines and keeps their wall clock', () {
    final c = challenge(
      resendAvailableAt: '2026-08-05T12:01:00+05:00',
      receivedAt: DateTime.utc(2026, 8, 5, 7),
    );

    // 12:05 Tashkent, not 07:05 UTC re-rendered in the device zone.
    expect(c.expiresAt.wallClock.hour, 12);
    expect(c.expiresAt.wallClock.minute, 5);
    expect(c.resendIn, const Duration(minutes: 1));
  });

  test('a passed deadline is zero, not a negative countdown', () {
    // Device clock ahead of the server, or simply a slow round trip.
    final c = challenge(
      resendAvailableAt: '2026-08-05T12:01:00+05:00',
      receivedAt: DateTime.utc(2026, 8, 5, 8),
    );

    expect(c.resendIn, Duration.zero);
  });

  test('gross clock skew is clamped rather than shown', () {
    // A device a day slow would otherwise render "send again in 86460 s" and
    // leave the button dead for the rest of the session.
    final c = challenge(
      resendAvailableAt: '2026-08-05T12:01:00+05:00',
      receivedAt: DateTime.utc(2026, 8, 4, 7),
    );

    expect(c.resendIn, OtpChallenge.maxResendWait);
  });

  test('devCode is absent unless the backend echoed it', () {
    final c = challenge(
      resendAvailableAt: '2026-08-05T12:01:00+05:00',
      receivedAt: DateTime.utc(2026, 8, 5, 7),
    );

    expect(c.devCode, isNull);
  });

  test('toString never carries the code', () {
    // It is a live credential for one phone number, and toString reaches logs.
    final c = challenge(
      resendAvailableAt: '2026-08-05T12:01:00+05:00',
      receivedAt: DateTime.utc(2026, 8, 5, 7),
      devCode: '666666',
    );

    expect(c.devCode, '666666');
    expect(c.toString(), isNot(contains('666666')));
    expect(c.toString(), contains('redacted'));
  });

  test('a timestamp with no offset is refused at the boundary', () {
    // The API contract freezes "explicit numeric offset, never Z". A loud parse
    // failure here beats a plausible wrong deadline on screen.
    expect(
      () => OtpChallenge.fromJson(const {
        'expiresAt': '2026-08-05T12:05:00Z',
        'resendAvailableAt': '2026-08-05T12:01:00Z',
      }),
      throwsFormatException,
    );
  });
}
