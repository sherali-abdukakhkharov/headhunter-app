/// A server timestamp with the zone it should be *displayed* in.
///
/// ## Why this type exists
///
/// `DateTime.parse('2026-08-12T14:00:00+05:00')` returns a **UTC** `DateTime`
/// (`isUtc == true`, `.hour == 9`). The offset is normalised away, not
/// retained.
/// Calling `.toLocal()` on it then renders in the **device** zone.
///
/// Every machine on this project sits at UTC+5, so `.toLocal()` prints the
/// correct wall clock during development and the bug is invisible. A candidate
/// who opens the app in Moscow sees an interview two hours early - the one bug
/// in this feature that costs someone a job (§8.3).
///
/// The platform zone is `Asia/Tashkent` and the backend resolves the offset for
/// that specific instant before sending, so the correct rendering is simply the
/// wall-clock components carried in the string. That needs no tz database: the
/// ~1MB `timezone` package would re-derive an answer the server already gave
/// us, and this stays correct if Uzbekistan ever reintroduces DST.
///
/// **Never call `.toLocal()` on an API timestamp. Render [wallClock].**
class ZonedTimestamp {
  const ZonedTimestamp({
    required this.wallClock,
    required this.offset,
    required this.instant,
    this.zoneName,
  });

  /// Parses an ISO-8601 timestamp carrying an explicit numeric offset.
  ///
  /// Throws [FormatException] on a `Z` suffix or a missing offset. That is
  /// deliberate rather than defensive: the backend froze "every timestamp
  /// carries an explicit numeric offset, never `Z`, never offsetless" as a
  /// contract clause with a test behind it, because `Date.toISOString()` emits
  /// `Z` and one stray call would shift every interview time for anyone outside
  /// Uzbekistan. If that regresses, a loud parse failure at the repository
  /// boundary is far better than a plausible wrong time on screen.
  factory ZonedTimestamp.parse(String value, {String? zoneName}) {
    final match = _offsetPattern.firstMatch(value);
    if (match == null) {
      throw FormatException(
        'Timestamp has no explicit numeric offset. The API contract requires '
        'one on every timestamp (never "Z", never offsetless) because the '
        'display zone cannot be recovered without it.',
        value,
      );
    }

    final sign = match.group(1) == '-' ? -1 : 1;
    final hours = int.parse(match.group(2)!);
    final minutes = int.parse(match.group(3)!);
    final offset = Duration(hours: sign * hours, minutes: sign * minutes);

    // DateTime.parse honours the offset when computing the instant - it is only
    // the *display* zone it discards. So the instant is correct as parsed, and
    // adding the offset back recovers the original wall clock.
    final instant = DateTime.parse(value).toUtc();

    return ZonedTimestamp(
      // Carried as a UTC-flagged DateTime so no formatter can be tempted to
      // shift it again; its fields are the wall clock, not an instant.
      wallClock: instant.add(offset),
      offset: offset,
      instant: instant,
      zoneName: zoneName,
    );
  }

  /// Matches a trailing `+HH:MM` / `-HH:MM` / `+HHMM` offset. A `Z` suffix
  /// deliberately does not match.
  static final _offsetPattern = RegExp(r'([+-])(\d{2}):?(\d{2})$');

  /// The date and time **as it should be shown**, in [zoneName].
  ///
  /// Flagged UTC so that a stray `.toLocal()` downstream is a no-op shift of
  /// zero rather than a silent re-render in the device zone. Read its fields,
  /// or format it with a `DateFormat`; do not treat it as an instant.
  final DateTime wallClock;

  /// The offset the server resolved for this instant.
  final Duration offset;

  /// The true instant, in UTC. Use this for ordering and elapsed-time maths,
  /// never for display.
  final DateTime instant;

  /// IANA zone name from the response, e.g. `Asia/Tashkent`. Shown alongside
  /// the time so a user outside the platform zone can tell which clock it
  /// refers to.
  final String? zoneName;

  @override
  String toString() =>
      'ZonedTimestamp($wallClock ${_formatOffset(offset)}'
      '${zoneName == null ? '' : ' $zoneName'})';

  static String _formatOffset(Duration offset) {
    final sign = offset.isNegative ? '-' : '+';
    final abs = offset.abs();
    final hh = abs.inHours.toString().padLeft(2, '0');
    final mm = (abs.inMinutes % 60).toString().padLeft(2, '0');
    return '$sign$hh:$mm';
  }
}
