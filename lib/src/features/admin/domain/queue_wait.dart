import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';

/// Whole days between [submitted] and now, floored at zero.
///
/// **Instants, never wall clocks.** A submitted timestamp carries the
/// platform's `+05:00`, so subtracting its wall clock from a local `now` is
/// five hours out for an administrator abroad — in the direction that
/// *understates* how long somebody has been waiting, which is the wrong
/// direction for the one number a FIFO queue exists to make visible. The same
/// rule §8.3's `Interview.hasPassed` follows, and for the same reason.
///
/// Floored because a clock skew of a few seconds should read as "today" rather
/// than as a negative wait.
int daysWaiting(ZonedTimestamp submitted) {
  final elapsed = DateTime.now().toUtc().difference(submitted.instant).inDays;
  return elapsed < 0 ? 0 : elapsed;
}
