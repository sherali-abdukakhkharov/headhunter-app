import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';

void main() {
  group('ZonedTimestamp', () {
    // The bug this whole type exists to prevent. Documented as an executable
    // demonstration rather than a comment, because the naive version passes on
    // every development machine on this project.
    test('DateTime.parse discards the offset - the trap being avoided', () {
      final naive = DateTime.parse('2026-08-12T14:00:00+05:00');

      expect(naive.isUtc, isTrue);
      expect(
        naive.hour,
        9,
        reason: 'parse() normalises to UTC; the +05:00 is gone, not retained',
      );
    });

    test('recovers the wall clock the server intended', () {
      final ts = ZonedTimestamp.parse(
        '2026-08-12T14:00:00+05:00',
        zoneName: 'Asia/Tashkent',
      );

      expect(ts.wallClock.hour, 14);
      expect(ts.wallClock.minute, 0);
      expect(ts.wallClock.day, 12);
      expect(ts.wallClock.month, 8);
      expect(ts.wallClock.year, 2026);
      expect(ts.zoneName, 'Asia/Tashkent');
      expect(ts.offset, const Duration(hours: 5));
    });

    test('the instant is preserved independently of the display clock', () {
      final ts = ZonedTimestamp.parse('2026-08-12T14:00:00+05:00');

      expect(ts.instant, DateTime.utc(2026, 8, 12, 9));
    });

    // The case that actually costs someone a job. A device in Moscow (UTC+3)
    // must still see 14:00 - the platform zone's clock - not 12:00.
    //
    // wallClock is UTC-flagged precisely so this holds: toLocal() on a UTC
    // DateTime in a non-UTC test environment would shift it, and it does not,
    // because the fields are already the intended wall clock.
    test('renders the platform zone, not the device zone', () {
      final ts = ZonedTimestamp.parse(
        '2026-08-12T14:00:00+05:00',
        zoneName: 'Asia/Tashkent',
      );

      // What the naive implementation would show on a UTC+3 device: the
      // instant re-rendered at +03:00.
      final whatDeviceZoneWouldShow = ts.instant.add(const Duration(hours: 3));
      expect(whatDeviceZoneWouldShow.hour, 12);

      // What we actually show, regardless of where the device is.
      expect(ts.wallClock.hour, 14);
    });

    test('handles negative and half-hour offsets', () {
      expect(
        ZonedTimestamp.parse('2026-08-12T14:00:00-05:00').wallClock.hour,
        14,
      );
      expect(
        ZonedTimestamp.parse('2026-08-12T14:00:00-05:00').instant.hour,
        19,
      );

      final india = ZonedTimestamp.parse('2026-08-12T14:00:00+05:30');
      expect(india.wallClock.hour, 14);
      expect(india.wallClock.minute, 0);
      expect(india.offset, const Duration(hours: 5, minutes: 30));
    });

    test('accepts the compact +HHMM spelling', () {
      expect(
        ZonedTimestamp.parse('2026-08-12T14:00:00+0500').wallClock.hour,
        14,
      );
    });

    group('rejects timestamps it cannot place', () {
      // The backend froze "never Z, never offsetless" as a contract clause with
      // a test behind it. If that regresses we want a loud parse failure, not a
      // plausible wrong time on screen.
      test('Z suffix', () {
        expect(
          () => ZonedTimestamp.parse('2026-08-12T09:00:00Z'),
          throwsFormatException,
        );
      });

      test('no offset at all', () {
        expect(
          () => ZonedTimestamp.parse('2026-08-12T14:00:00'),
          throwsFormatException,
        );
      });
    });
  });
}
