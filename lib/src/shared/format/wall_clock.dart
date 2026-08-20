/// Rendering a `ZonedTimestamp.wallClock` — the one way this app writes a date.
///
/// ## Why the fields are formatted by hand
///
/// The input is a `ZonedTimestamp.wallClock`: a `DateTime` whose **fields** are
/// the wall clock in the platform zone and whose flag is UTC, so that a stray
/// `.toLocal()` is a shift of zero rather than a silent re-render in the
/// device's zone. These functions read those fields and nothing else. Never
/// `.toLocal()`, and never the raw `instant` — a candidate opening the app in
/// Moscow would be shown an interview two hours early, which is the one bug in
/// this area that costs somebody a job (§8.3).
///
/// ## Why ISO order rather than a localized pattern
///
/// §8.3's display policy is still open, and until it is settled a
/// wrong-*looking* date beats a plausible wrong one: `2026-08-20 14:05` cannot
/// be misread as August the twentieth or the twentieth of August by somebody
/// used to the other convention, and it cannot be mistaken for a time in their
/// own zone.
///
/// ## Why this lives in `shared/`
///
/// It was `invitationStamp` in the invitations feature and a private `_stamp`
/// in the account screen — two identical copies. §9.1's chat was the third
/// caller, which is the point CLAUDE.md names for extracting a repetition:
/// three copies of a date format is three ways to date one event.
library;

/// A date and time, e.g. `2026-08-20 14:05`.
String wallClockStamp(DateTime wallClock) =>
    '${wallClockDay(wallClock)} ${wallClockTime(wallClock)}';

/// The date alone, e.g. `2026-08-20`. Used where a run of items shares a day
/// and repeating it on each would be noise.
String wallClockDay(DateTime wallClock) =>
    '${wallClock.year.toString().padLeft(4, '0')}-'
    '${wallClock.month.toString().padLeft(2, '0')}-'
    '${wallClock.day.toString().padLeft(2, '0')}';

/// The time alone, e.g. `14:05`. Twenty-four hour, in every interface variant:
/// none of the four uses an am/pm convention, and inventing one for a language
/// that does not would be worse than plain.
String wallClockTime(DateTime wallClock) =>
    '${wallClock.hour.toString().padLeft(2, '0')}:'
    '${wallClock.minute.toString().padLeft(2, '0')}';

/// Whether two wall clocks fall on the same calendar day.
///
/// Compares fields rather than subtracting: a difference in hours would answer
/// "within 24 hours", which is not the same question and is wrong across
/// midnight.
bool isSameWallClockDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
