import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'candidate_card.g.dart';

/// One scoring group and how much of it a candidate satisfied (§7.3).
@JsonSerializable(createToJson: false)
@immutable
class MatchBreakdown {
  const MatchBreakdown({
    required this.group,
    required this.weight,
    required this.asked,
    required this.matched,
  });

  factory MatchBreakdown.fromJson(Map<String, dynamic> json) =>
      _$MatchBreakdownFromJson(json);

  final String group;
  final num weight;

  /// How many items this group asked for.
  final int asked;

  /// How many of them the candidate has.
  final int matched;
}

/// A skill or language on a candidate card, with its level.
@JsonSerializable(createToJson: false)
@immutable
class CandidateSkill {
  const CandidateSkill({required this.itemId, this.levelId});

  factory CandidateSkill.fromJson(Map<String, dynamic> json) =>
      _$CandidateSkillFromJson(json);

  final String itemId;
  final String? levelId;
}

/// A candidate in employer search results (§7.1, §7.3).
///
/// ## There is no phone here, and that is the point
///
/// BR-09 and §11.1: **a card is not a hiring interaction**, so the rule never
/// opens for one. The server's DTO has no phone field at all — the omission is
/// structural rather than a filter that could be forgotten — and this model
/// mirrors that. Nothing on this type could render a number, which is what
/// makes the guarantee checkable rather than merely intended.
///
/// [photoPath] is the one candidate file a card may carry: a photo uploaded to
/// be found by is not §5.4's authorized CV.
@JsonSerializable(createToJson: false)
@immutable
class CandidateCard {
  const CandidateCard({
    required this.candidateUserId,
    required this.experienceYears,
    required this.completenessPercent,
    required this.salaryIsNegotiable,
    required this.isSaved,
    required this.isShortlisted,
    required this.matchScore,
    required this.skills,
    required this.languages,
    required this.matchBreakdown,
    this.fullName,
    this.regionId,
    this.districtId,
    this.settlement,
    this.category,
    this.primaryOccupationId,
    this.occupationLevelId,
    this.currentRoleTitle,
    this.currentOccupationId,
    this.salaryFrom,
    this.salaryTo,
    this.salaryPeriodId,
    this.availableFrom,
    this.lastMeaningfulUpdateAt,
    this.photoPath,
    this.note,
    this.applicationStatus,
  });

  factory CandidateCard.fromJson(Map<String, dynamic> json) =>
      _$CandidateCardFromJson(json);

  final String candidateUserId;
  final String? fullName;
  final String? regionId;
  final String? districtId;
  final String? settlement;
  final String? category;
  final String? primaryOccupationId;
  final String? occupationLevelId;
  final String? currentRoleTitle;
  final String? currentOccupationId;

  /// Summed from the experience rows. Overlapping jobs count twice, which the
  /// contract calls a known roughness rather than a hidden one.
  final int experienceYears;

  /// The strongest ten (§7.3).
  final List<CandidateSkill> skills;
  final List<CandidateSkill> languages;

  final int? salaryFrom;
  final int? salaryTo;
  final String? salaryPeriodId;
  final bool salaryIsNegotiable;
  final String? availableFrom;
  final int completenessPercent;
  final String? lastMeaningfulUpdateAt;

  /// A path on this API, or null. Never a storage URL (§11.1).
  final String? photoPath;

  final bool isSaved;

  /// §7.3's private employer note. Never visible to the candidate.
  final String? note;

  /// False unless the request named a `vacancyId`.
  final bool isShortlisted;

  /// This candidate's stage on any of the employer's vacancies, or null.
  final String? applicationStatus;

  /// §7.3's overall requirement match, 0–100.
  final int matchScore;
  final List<MatchBreakdown> matchBreakdown;
}

/// §7.2's count-before-results.
@JsonSerializable(createToJson: false)
@immutable
class CandidateCount {
  const CandidateCount({required this.count, required this.isExact});

  factory CandidateCount.fromJson(Map<String, dynamic> json) =>
      _$CandidateCountFromJson(json);

  /// Capped at 200 — §7.2's "where technically reasonable".
  final int count;

  /// False when the cap was hit, which is what "200+" is rendered from.
  ///
  /// The client must not decide the cap itself: reading `count == 200` as
  /// inexact would be wrong the day the server raises it, and wrong now for a
  /// search that genuinely returns exactly 200.
  final bool isExact;
}
