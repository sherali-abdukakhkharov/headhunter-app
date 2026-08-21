import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/features/admin/domain/moderation_queue_item.dart';
import 'package:jobbridge_app/src/features/discovery/domain/vacancy_detail.dart';

/// A vacancy as a moderator reads it before deciding (§10.2).
///
/// Mirrors `VacancyReviewDto` in headhunter-backend.
///
/// ## The `vacancy` half arrives as the stored row, and that is worth knowing
///
/// `VacancyReviewDto.vacancy` is typed `Record<string, unknown>` and the
/// service puts the selected columns in it unchanged, so its keys are
/// **snake_case** while `requirements` beside it is camelCase and every other
/// vacancy route answers with a camelCase DTO.
///
/// This class reads **either spelling** for every field, which is not laziness:
/// it is what lets one build be correct against today's server *and* against
/// the DTO recorded as a backend ask in TODO.md, with no release in between.
/// The same idiom as `unlock_required` — a client that works before and after a
/// server change beats one that has to ship in lockstep with it.
///
/// The coupling is narrower than it looks, too. `VacancyDto.fields` is keyed by
/// **schema field code**, and the field codes *are* the column names — the
/// employer dashboard already reads `fields['worker_count']`. So `workerCount`
/// below reads the same key by the same name the rest of the app uses. What is
/// genuinely storage-shaped is the handful of columns that are *not* fields
/// (`employer_user_id`, `moderation_reason`, `published_at`), and those are
/// listed here rather than reached for ad hoc.
@immutable
class VacancyReview {
  const VacancyReview({required this.row, required this.requirements});

  factory VacancyReview.fromJson(Map<String, dynamic> json) => VacancyReview(
    row: switch (json['vacancy']) {
      final Map<String, dynamic> vacancy => vacancy,
      _ => const {},
    },
    requirements: switch (json['requirements']) {
      final List<dynamic> rows => rows
          .whereType<Map<String, dynamic>>()
          .map(VacancyRequirement.fromJson)
          .toList(),
      _ => const <VacancyRequirement>[],
    },
  );

  /// The vacancy, as stored. Read through the accessors below rather than
  /// directly, so a key appears in exactly one place.
  final Map<String, dynamic> row;

  /// Its structured requirements (§6.3), in the same shape §5.6's detail screen
  /// already parses — which is why `VacancyRequirement` is reused rather than
  /// re-declared.
  final List<VacancyRequirement> requirements;

  String? get id => _string('id', 'id');

  /// §2.1's work category, which is what selects the schema whose labels head
  /// the requirement groups. Null until an occupation is picked.
  String? get category => _string('category', 'category');

  /// `draft`, `under_moderation`, `active`, `paused`, `closed`, `rejected`.
  String? get status => _string('status', 'status');

  /// The employer's own words, never translated and never trimmed (§2.4).
  String? get title => _string('title', 'title');
  String? get description => _string('description', 'description');
  String? get address => _string('address', 'address');

  /// A previous moderator's reason, where this vacancy has been round the loop
  /// before. Worth showing: a second rejection for the same thing means the
  /// first reason did not land.
  String? get moderationReason =>
      _string('moderation_reason', 'moderationReason');

  int? get workerCount => _int('worker_count', 'workerCount');
  int? get ageMin => _int('age_min', 'ageMin');
  int? get ageMax => _int('age_max', 'ageMax');

  /// Dictionary **ids** (BR-13), every one resolved to a label for display.
  String? get occupationId => _string('occupation_id', 'occupationId');
  String? get regionId => _string('region_id', 'regionId');
  String? get districtId => _string('district_id', 'districtId');
  String? get salaryPeriodId => _string('salary_period_id', 'salaryPeriodId');
  String? get genderId => _string('gender_id', 'genderId');
  String? get justificationId =>
      _string('restriction_justification_id', 'restrictionJustificationId');

  String? get justificationNote => _string(
    'restriction_justification_note',
    'restrictionJustificationNote',
  );

  /// Pay, which Postgres stores as `numeric` — so it can arrive as a string.
  /// [_int] takes either rather than casting, because a `as int` here would
  /// throw on a perfectly valid `"5000000.00"`.
  int? get salaryFrom => _int('salary_from', 'salaryFrom');
  int? get salaryTo => _int('salary_to', 'salaryTo');

  bool get salaryIsNegotiable =>
      _bool('salary_is_negotiable', 'salaryIsNegotiable');

  /// The work window (§6.3, UAT-10) and the application deadline, as dates.
  String? get startsOn => _string('starts_on', 'startsOn');
  String? get endsOn => _string('ends_on', 'endsOn');
  String? get deadlineOn => _string('deadline_on', 'deadlineOn');

  /// The BR-12 restriction assembled from the row, or null where there is none.
  ///
  /// Rebuilt here rather than taken from the queue item, because the review is
  /// reachable without one — and because a screen that showed the restriction
  /// only when it had been listed would show nothing on a reload.
  VacancyRestriction? get restriction {
    final hasAge = ageMin != null || ageMax != null;
    if (!hasAge && genderId == null) return null;

    return VacancyRestriction(
      ageMin: ageMin,
      ageMax: ageMax,
      genderId: genderId,
      justificationId: justificationId,
      justificationNote: justificationNote,
    );
  }

  String? _string(String stored, String dto) {
    final value = row[dto] ?? row[stored];
    return value is String && value.isNotEmpty ? value : null;
  }

  int? _int(String stored, String dto) => switch (row[dto] ?? row[stored]) {
    final num value => value.toInt(),
    final String value =>
      int.tryParse(value) ?? double.tryParse(value)?.toInt(),
    _ => null,
  };

  bool _bool(String stored, String dto) => (row[dto] ?? row[stored]) == true;
}
