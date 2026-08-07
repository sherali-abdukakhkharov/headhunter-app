import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vacancy_card.g.dart';

/// The employer as a candidate sees them on a vacancy (§5.6).
///
/// [name] is a company's **public** name or an individual's own name — never
/// the legal name, which §6.1 keeps separately because the two differ and only
/// one of them is meant to be read by candidates.
@JsonSerializable(createToJson: false)
@immutable
class FeedEmployer {
  const FeedEmployer({required this.isVerified, this.name});

  factory FeedEmployer.fromJson(Map<String, dynamic> json) =>
      _$FeedEmployerFromJson(json);

  final String? name;

  /// §5.6 puts verification on the vacancy itself, so a candidate can weigh it
  /// without opening the employer.
  final bool isVerified;
}

/// One vacancy in a candidate-facing list (§5.6).
///
/// ## `applicationStatus` is why the card needs no second request
///
/// It carries **the caller's own** application stage for this vacancy, or
/// null. That is BR-07 — one active application per vacancy — rendered
/// directly: the card shows Apply or the stage it is already at, and the
/// client never has to decide which by cross-referencing a second list.
@JsonSerializable(createToJson: false)
@immutable
class VacancyCard {
  const VacancyCard({
    required this.id,
    required this.employer,
    required this.isSaved,
    required this.salaryIsNegotiable,
    this.title,
    this.category,
    this.occupationId,
    this.regionId,
    this.districtId,
    this.workerCount,
    this.salaryFrom,
    this.salaryTo,
    this.salaryPeriodId,
    this.deadlineOn,
    this.publishedAt,
    this.applicationStatus,
  });

  factory VacancyCard.fromJson(Map<String, dynamic> json) =>
      _$VacancyCardFromJson(json);

  final String id;
  final String? title;
  final String? category;
  final String? occupationId;
  final String? regionId;
  final String? districtId;
  final int? workerCount;

  final int? salaryFrom;
  final int? salaryTo;
  final String? salaryPeriodId;
  final bool salaryIsNegotiable;

  final String? deadlineOn;
  final String? publishedAt;

  final FeedEmployer employer;
  final bool isSaved;

  /// The caller's own stage, or null if they have not applied.
  final String? applicationStatus;

  /// Whether this candidate has an application on this vacancy (BR-07).
  ///
  /// A withdrawn one does not count: withdrawing is what frees the candidate
  /// to apply again, and treating it as "already applied" would strand them.
  bool get hasApplied =>
      applicationStatus != null && applicationStatus != 'withdrawn';
}
