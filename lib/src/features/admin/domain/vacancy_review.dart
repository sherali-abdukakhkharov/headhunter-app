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
///
/// It stays a row on purpose, and that was the server's answer rather than a
/// backlog item: §10.2 reviews **what was submitted**, and a camelCase DTO over
/// thirty columns means either hand-writing a second copy of the column list or
/// a generic converter with one caller. The either-spelling readers below mean
/// nothing is waiting on it.
///
/// ## Its timestamps are safe now, and were not
///
/// Four columns on this row — `published_at`, `closed_at`, `created_at`,
/// `updated_at` — were serialised straight from `timestamptz` and arrived with
/// a `Z`, which API_CONTRACTS.md §2 forbids and `ZonedTimestamp.parse` refuses.
/// Nothing here read them, so nothing broke; the hazard was that the first
/// person to add a `publishedAt` getter would have taken the screen down at the
/// repository boundary. Fixed server-side 2026-08-22 (`formatRowTimestamps`),
/// so such a getter is safe to add now — see `ComplaintTargetDetail` for the
/// instance that led to it being found.
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

  /// Whose vacancy this is. The only identification the row carries today.
  String? get employerUserId => _string('employer_user_id', 'employerUserId');

  /// The employer's name (§10.2), the same resolution the moderation queue
  /// shows: a company's public name, else the individual's own.
  ///
  /// Written here before the server sent it, which is why the card lit up on
  /// the next fetch rather than in the next release — the
  /// `Invitation.candidateName` idiom, and it paid for itself the same day
  /// (asked 2026-08-21, shipped 2026-08-22). **Same expression as
  /// `ModerationQueueItemDto.employerName`, with a server-side test asserting
  /// the two agree**, so tapping a queue row cannot land on a review naming
  /// somebody else.
  String? get employerName => _string('employer_name', 'employerName');

  /// The number the employer **published for their company** (§6.1) — the one
  /// to call.
  ///
  /// A different field from [employerPhone] and possibly a different number,
  /// which is why the server sends both rather than one `COALESCE`: a
  /// moderator dialling should know which of the two they are looking at.
  /// §6.1 makes it mandatory for a complete profile, so BR-03 guarantees any
  /// vacancy that reached review has one.
  String? get employerContactPhone =>
      _string('employer_contact_phone', 'employerContactPhone');

  /// The **account** number — the login identity (§4.1), not a contact detail.
  ///
  /// Kept beside the published one rather than hidden, because it is §10.4's
  /// user-search key: a moderator who wants this employer's whole history has
  /// the thing to paste into it.
  String? get employerPhone => _string('employer_phone', 'employerPhone');

  /// Whether anything at all identifies the employer beyond their id.
  ///
  /// **There is no e-mail, and this is answered rather than deferred**: the
  /// product has no e-mail column anywhere, because login is phone + OTP
  /// (§4.1) and every contact field in it is a phone number. An
  /// `employerEmail` getter was written here on 2026-08-22 in the hope the
  /// join would carry one, and removed the same day. Do not add it back.
  ///
  /// Showing either phone to an *administrator* is BR-09's admin branch and
  /// not a hole in it: §11.1 releases contact data to this role and logs every
  /// read. The candidate rule — nothing before a paid unlock — is about the
  /// employer role (§6.6).
  bool get hasEmployerContact =>
      employerName != null ||
      employerContactPhone != null ||
      employerPhone != null;

  /// Whether the two numbers are the same, which they are for a sole trader
  /// who published the number they signed up with. Drawn once when so, because
  /// one number under two labels reads as a data error.
  bool get employerPhonesAgree =>
      employerContactPhone != null && employerContactPhone == employerPhone;

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
