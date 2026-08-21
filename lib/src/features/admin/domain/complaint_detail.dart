import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/features/admin/domain/complaint.dart';
import 'package:jobbridge_app/src/features/admin/domain/complaint_action.dart';

/// Enough of the reported thing to judge it (§10.2).
///
/// ## It is a row, and the keys are the column names
///
/// `ComplaintDetailDto.target` is typed `Record<string, unknown>` and
/// `resolveTarget` selects a handful of columns per kind, unchanged — so the
/// keys are **snake_case**, exactly like `VacancyReviewDto.vacancy`. Read
/// through the accessors and both spellings work, so the day either route
/// grows a typed DTO this build is already correct. Same idiom, same reason.
///
/// The shapes, per kind, are small on purpose — this is a review screen, not a
/// second copy of the resource:
///
/// | kind | columns |
/// |---|---|
/// | `vacancy` | `id`, `title`, `status`, `employer_user_id` |
/// | `message` | `id`, `body`, `sender_user_id`, `conversation_id`, |
/// | | `created_at` |
/// | `user` / `profile` | `id`, `status`, `created_at`, `full_name` |
///
/// ## There is no timestamp here, and that is the interesting part
///
/// Two of those rows carry a `created_at`, and **it is not safe to parse**.
/// The controller runs the complaint's own `createdAt` through
/// `formatWithOffset`; the target is spread in untouched, so its `created_at`
/// arrives however the driver serialises a `timestamptz` — with a `Z`.
/// `ZonedTimestamp.parse` refuses `Z` by contract, so a `createdAt` getter
/// here would throw a `FormatException` at the repository boundary and take
/// the whole review with it.
///
/// So it is not exposed. That costs nothing to read: a moderator judging a
/// complaint needs *when it was reported*, which the complaint carries
/// correctly, not when the reported message was sent. **Do not add a
/// timestamp here** without an offset from the server first.
@immutable
class ComplaintTargetDetail {
  const ComplaintTargetDetail(this.row);

  final Map<String, dynamic> row;

  /// The reported thing's own id, which equals `Complaint.targetId`.
  String? get id => _string('id', 'id');

  /// A vacancy's title, as the employer wrote it (§2.4).
  String? get title => _string('title', 'title');

  /// A vacancy's `active`/`paused`/`closed`, **or** an account's
  /// `active`/`restricted`/`blocked`. One column name, two vocabularies — the
  /// kind comes from the complaint, so the caller always knows which it has.
  String? get status => _string('status', 'status');

  /// The employer behind a reported vacancy.
  String? get employerUserId => _string('employer_user_id', 'employerUserId');

  /// The reported message, verbatim (§2.4). The whole point of the kind.
  String? get body => _string('body', 'body');

  /// Who sent it — the person a message complaint is really about.
  String? get senderUserId => _string('sender_user_id', 'senderUserId');

  String? get conversationId => _string('conversation_id', 'conversationId');

  /// A candidate's name. Null for an employer account: the join is against
  /// `candidate_profiles`, so an employer resolves to a row with a status and
  /// no name.
  String? get fullName => _string('full_name', 'fullName');

  String? _string(String stored, String dto) {
    final value = row[dto] ?? row[stored];
    return value is String && value.isNotEmpty ? value : null;
  }
}

/// A complaint and the thing it is about, as §10.2's review reads them.
///
/// The pairing questions live here rather than on the screen because they are
/// the same three questions for every kind — is the target still there, is
/// there a vacancy to act on, is there a person to warn — and answering them
/// in the widget tree is how the message kind ends up with no remedy.
@immutable
class ComplaintDetail {
  const ComplaintDetail({required this.complaint, this.target});

  factory ComplaintDetail.fromJson(Map<String, dynamic> json) =>
      ComplaintDetail(
        complaint: Complaint.fromJson(
          json['complaint'] as Map<String, dynamic>,
        ),
        target: switch (json['target']) {
          final Map<String, dynamic> row => ComplaintTargetDetail(row),
          _ => null,
        },
      );

  final Complaint complaint;

  /// Null when the reported thing is gone — a vacancy deleted, an account
  /// purged. **A normal state, not a failure**: the server's own words are
  /// that "a complaint outlives its target on purpose", because the record of
  /// a decision has to survive whatever the decision was about. The review
  /// says so and offers no action.
  final ComplaintTargetDetail? target;

  bool get targetIsGone => target == null;

  /// The vacancy §10.2's pause-or-remove applies to, or null.
  ///
  /// Only a `vacancy` complaint has one, and only while the vacancy exists.
  String? get vacancyId =>
      complaint.targetType == ComplaintTarget.vacancy ? target?.id : null;

  /// The person a warning would go to, or null where the complaint is not
  /// about one.
  ///
  /// For a reported **message** that is its *sender*, not the message: there
  /// is no route that edits or removes a message, and there should not be —
  /// §7's chat history is evidence. So the remedy for an abusive message is
  /// the same remedy as for an abusive person, which is why `resolveTarget`
  /// selects `sender_user_id` at all.
  String? get subjectUserId => switch (complaint.targetType) {
    ComplaintTarget.user || ComplaintTarget.profile => target?.id,
    ComplaintTarget.message => target?.senderUserId,
    ComplaintTarget.vacancy || ComplaintTarget.unknown => null,
  };

  /// The status changes §10.2 offers for a reported vacancy, given where that
  /// vacancy currently is. Empty for every other kind.
  ///
  /// A `closed` vacancy yields none — `closed` is terminal — so an upheld
  /// complaint about one leaves only the resolution to record, which is the
  /// honest answer rather than a button that answers 409.
  List<VacancyAdminStatus> get vacancyActions => vacancyId == null
      ? const []
      : VacancyAdminStatus.availableFor(target?.status);

  /// Whether anything can be done to the target from this screen.
  bool get hasTargetAction =>
      subjectUserId != null || vacancyActions.isNotEmpty;
}
