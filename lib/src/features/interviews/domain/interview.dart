import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';
import 'package:jobbridge_app/src/features/interviews/domain/interview_status.dart';

/// The instant an employer means when they pick a date and a time (§8.3).
///
/// The inverse of `ZonedTimestamp`'s `wallClock = instant + offset`, and it
/// exists because scheduling is the one place this app has to run that
/// conversion **backwards**.
///
/// [wallClock] carries the picked fields — year, month, day, hour, minute — as
/// though they were UTC, which is how they arrive from a date and a time picker
/// once the device's own zone is kept out of it. [platformOffset] must come
/// from a timestamp the **server** sent; every `ZonedTimestamp` carries one. A
/// `+05:00` written into Dart would be a second source of truth for the
/// platform zone: wrong the day Uzbekistan reintroduces daylight saving, and
/// wrong in the direction that moves every interview by an hour.
///
/// Why the *platform's* clock and not the device's: the candidate's card
/// renders the platform wall clock, so that is the only reading on which the
/// two sides agree. An employer scheduling from abroad means "14:00 as my
/// candidate will read it", not 14:00 where they happen to be standing.
DateTime instantForPlatformWallClock({
  required DateTime wallClock,
  required Duration platformOffset,
}) => DateTime.utc(
  wallClock.year,
  wallClock.month,
  wallClock.day,
  wallClock.hour,
  wallClock.minute,
).subtract(platformOffset);

/// One scheduled interview (§8.3).
///
/// Mirrors `InterviewDto` in headhunter-backend — change both together.
///
/// ## [scheduledAt] is the field this whole type exists to get right
///
/// It is a `ZonedTimestamp`, so it is rendered from [ZonedTimestamp.wallClock]
/// and never `.toLocal()`. Every machine on this project sits at UTC+5, which
/// means a `.toLocal()` bug prints the correct time all through development and
/// then shows a candidate who opens the app in Moscow an interview **two hours
/// early**. That is the one bug in this feature that costs somebody a job, and
/// it is why the parse refuses a timestamp with no explicit offset rather than
/// guessing.
///
/// ## The type decides which detail exists
///
/// [location] is present only on an `in_person` interview and [meetingLink]
/// only on an `external_link` one; the server enforces both directions, so a
/// phone interview cannot arrive carrying a link nobody meant the candidate to
/// use. The client therefore renders whichever field is there rather than
/// switching on [type] a second time — but [type] is still shown, because
/// "phone" is information the candidate needs and no field carries it.
@immutable
class Interview {
  const Interview({
    required this.id,
    required this.applicationId,
    required this.type,
    required this.scheduledAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.location,
    this.meetingLink,
    this.instructions,
    this.responseNote,
    this.respondedAt,
  });

  factory Interview.fromJson(Map<String, dynamic> json) => Interview(
    id: json['id'] as String,
    applicationId: json['applicationId'] as String,
    type: json['type'] as String,
    scheduledAt: ZonedTimestamp.parse(json['scheduledAt'] as String),
    status: json['status'] as String,
    createdAt: ZonedTimestamp.parse(json['createdAt'] as String),
    updatedAt: ZonedTimestamp.parse(json['updatedAt'] as String),
    location: json['location'] as String?,
    meetingLink: json['meetingLink'] as String?,
    instructions: json['instructions'] as String?,
    responseNote: json['responseNote'] as String?,
    respondedAt: switch (json['respondedAt']) {
      final String at => ZonedTimestamp.parse(at),
      _ => null,
    },
  );

  final String id;

  /// The application this interview belongs to. §8.3 hangs an interview off an
  /// application rather than off a vacancy, which is what lets a candidate see
  /// it beside the application it came from.
  final String applicationId;

  /// One of [InterviewType]'s three codes, or something newer.
  final String type;

  final ZonedTimestamp scheduledAt;

  /// Where to go. `in_person` only.
  final String? location;

  /// Somebody else's meeting URL. `external_link` only, and a plain string:
  /// §2.4 puts a built-in video engine out of scope.
  final String? meetingLink;

  /// §8.3's "documents or preparation notes". The employer's own words, never
  /// translated (§2.4).
  final String? instructions;

  /// One of [InterviewStatus]'s four codes, or something newer.
  final String status;

  /// What the candidate said when they answered. Their own words.
  final String? responseNote;

  final ZonedTimestamp? respondedAt;

  final ZonedTimestamp createdAt;
  final ZonedTimestamp updatedAt;

  /// §8.3's two actions, minus the ones this interview cannot take.
  ///
  /// Rendered from this rather than as a fixed pair, so a confirmed interview
  /// offers only "another time" and one already asking offers only "confirm".
  /// The server refuses both of the missing cases, and offering a refusal is
  /// worse than offering nothing.
  List<String> get availableResponses =>
      InterviewStatus.responsesFor(status);

  /// Whether the interview is over as a decision.
  bool get isCancelled => InterviewStatus.terminal.contains(status);

  /// Whether the scheduled moment is in the past.
  ///
  /// Compares **instants**, never wall clocks: the wall clock is a display
  /// value carrying the platform's offset, and comparing it to `DateTime.now()`
  /// would be five hours out for a candidate abroad — in the direction that
  /// hides an interview that has not happened yet.
  bool get hasPassed => scheduledAt.instant.isBefore(DateTime.now().toUtc());
}
