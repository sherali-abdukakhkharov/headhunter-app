import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vacancy.g.dart';

/// One vacancy (§6.3, §6.4).
///
/// ## The same form engine as the candidate profile
///
/// [fields] is "current values by field code, in the same shape `PATCH`
/// accepts", and `GET /schemas/vacancy` returns the same `FieldSchema` the
/// candidate profile renders. That is deliberate on both sides: one engine
/// draws both forms and one declaration validates both, so a sixth work
/// category costs no client change.
///
/// ## What the server decides, and this only reports
///
/// [missingForSubmit], [isOpenForApplications] and the legal transitions are
/// all computed server-side. In particular `isOpenForApplications` is BR-06 in
/// one field — active, and either no deadline or one that has not passed — and
/// re-deriving it here would be a second implementation of the rule that
/// decides whether an application is accepted at all.
@JsonSerializable(createToJson: false)
@immutable
class Vacancy {
  const Vacancy({
    required this.id,
    required this.status,
    required this.fields,
    required this.missingForSubmit,
    required this.isOpenForApplications,
    required this.hiredCount,
    this.category,
    this.moderationReason,
    this.publishedAt,
    this.closedAt,
    this.closureReason,
    this.updatedAt,
  });

  factory Vacancy.fromJson(Map<String, dynamic> json) =>
      _$VacancyFromJson(json);

  final String id;

  /// Derived from the chosen occupation, and null until one is picked — the
  /// same relationship the candidate profile has with its category.
  final String? category;

  /// `draft`, `under_moderation`, `active`, `paused`, `closed`, `rejected`.
  final String status;

  /// The moderator's reason for a rejection, **as written**. Human text, never
  /// a translatable key (§2.4).
  final String? moderationReason;

  final Map<String, dynamic> fields;

  /// Required codes still unfilled. `POST /submit` refuses while this is
  /// non-empty, one 422 violation per code — so showing it beforehand turns a
  /// refusal into a checklist.
  final List<String> missingForSubmit;

  /// BR-06, computed server-side.
  final bool isOpenForApplications;

  /// §6.5: hires counted against `worker_count`.
  final int hiredCount;

  final String? publishedAt;
  final String? closedAt;
  final String? closureReason;
  final String? updatedAt;

  /// Whether the employer may edit the fields right now.
  ///
  /// The server answers `vacancy.under_moderation` or `vacancy.not_editable`
  /// otherwise. Mirrored here so the form can be read-only rather than
  /// accepting keystrokes it will fail to save.
  bool get isEditable => status != 'under_moderation' && status != 'closed';

  /// Whether `POST /submit` is worth offering.
  ///
  /// Only from a state that can reach moderation. A rejected vacancy qualifies
  /// — editing one returns it to draft, which is exactly the correction path
  /// §6.4 describes.
  bool get isSubmittable => status == 'draft' || status == 'rejected';

  /// The statuses §6.4 lets an employer move to from here.
  ///
  /// **Closing is terminal (BR-11)** and therefore never offered as something
  /// to come back from: a closed vacancy leaves discovery and stays in
  /// history. Listing the transitions here rather than at the call site keeps
  /// one answer to "what may I do now", which is what the buttons render.
  List<String> get employerTransitions => switch (status) {
    'active' => const ['paused', 'closed'],
    'paused' => const ['active', 'closed'],
    _ => const [],
  };
}
