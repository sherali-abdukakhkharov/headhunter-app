import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';

/// One vacancy waiting on §10.2's moderation decision (BR-04).
///
/// Mirrors `ModerationQueueItemDto` in headhunter-backend — change both
/// together.
///
/// Unlike the verification queue, **the item is not the whole review.** §10.2
/// asks for the vacancy's details, its requirements and its contact information
/// as well, and a title with an employer's name beside it is not enough to
/// approve a job posting on. So this is a list row that opens a review, and the
/// row carries the one thing that decides *how urgently* it needs opening: the
/// BR-12 restriction.
@immutable
class ModerationQueueItem {
  const ModerationQueueItem({
    required this.vacancyId,
    required this.employerUserId,
    required this.submittedAt,
    this.employerName,
    this.title,
    this.restriction,
  });

  factory ModerationQueueItem.fromJson(Map<String, dynamic> json) =>
      ModerationQueueItem(
        vacancyId: json['vacancyId'] as String,
        employerUserId: json['employerUserId'] as String,
        submittedAt: ZonedTimestamp.parse(json['submittedAt'] as String),
        employerName: json['employerName'] as String?,
        title: json['title'] as String?,
        restriction: switch (json['restriction']) {
          final Map<String, dynamic> row => VacancyRestriction.fromJson(row),
          _ => null,
        },
      );

  final String vacancyId;
  final String employerUserId;

  /// The employer's public name (§5.6), or null where there is none on file.
  final String? employerName;

  /// The vacancy title as the employer wrote it (§2.4).
  final String? title;

  /// When it was submitted. The queue is oldest-first.
  final ZonedTimestamp submittedAt;

  /// Present only when the vacancy carries a BR-12 age or gender restriction.
  ///
  /// Which is the reason this queue is not an optimisation: a restricted
  /// vacancy **cannot publish any other way**, because §10.2 requires the
  /// restriction to be reviewed by a person.
  final VacancyRestriction? restriction;

  /// Whether this row needs the BR-12 conversation rather than a normal read.
  bool get isRestricted => restriction != null;
}

/// A vacancy's BR-12 age or gender restriction, and the reason given for it.
///
/// Mirrors `RestrictionDto`. Every field is nullable independently: §6.3 lets
/// an employer restrict on age alone, on gender alone, or on both.
@immutable
class VacancyRestriction {
  const VacancyRestriction({
    this.ageMin,
    this.ageMax,
    this.genderId,
    this.justificationId,
    this.justificationNote,
  });

  factory VacancyRestriction.fromJson(Map<String, dynamic> json) =>
      VacancyRestriction(
        ageMin: (json['ageMin'] as num?)?.toInt(),
        ageMax: (json['ageMax'] as num?)?.toInt(),
        genderId: json['genderId'] as String?,
        justificationId: json['justificationId'] as String?,
        justificationNote: json['justificationNote'] as String?,
      );

  final int? ageMin;
  final int? ageMax;

  /// A dictionary **id** (BR-13), resolved to a label for display.
  final String? genderId;

  /// The BR-12 reason the employer picked from the enumerated list — also a
  /// dictionary id, and the thing §10.2 actually asks a moderator to judge.
  final String? justificationId;

  /// Their own elaboration, if any. Shown **verbatim** (§2.4): it is the
  /// employer's argument, and a moderator paraphrasing it would be judging
  /// something the employer did not say.
  final String? justificationNote;

  /// Whether an age range was set at all.
  bool get hasAgeRange => ageMin != null || ageMax != null;
}
