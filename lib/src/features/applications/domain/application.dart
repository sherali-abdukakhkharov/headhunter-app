import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'application.g.dart';

/// One application and the stage it has reached (§8.1).
@JsonSerializable(createToJson: false)
@immutable
class Application {
  const Application({
    required this.id,
    required this.vacancyId,
    required this.candidateUserId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.coverNote,
    this.rejectionReason,
  });

  factory Application.fromJson(Map<String, dynamic> json) =>
      _$ApplicationFromJson(json);

  final String id;
  final String vacancyId;
  final String candidateUserId;

  /// A §8.1 stage: `submitted`, `viewed`, `shortlisted`, `interview`,
  /// `offer`, `hired`, `rejected`, `withdrawn`.
  final String status;

  final String? coverNote;

  /// The employer's reason on a rejection, visible to the candidate (§8.1).
  /// Their own words, never translated (§2.4).
  final String? rejectionReason;

  final String createdAt;
  final String updatedAt;

  /// Whether the candidate may still withdraw.
  ///
  /// Withdrawing is the candidate's own transition and theirs alone, but only
  /// while the application is live: a finished one has nothing to withdraw
  /// from, and offering the action would be offering a refusal.
  bool get canWithdraw => !const {
    'hired',
    'rejected',
    'withdrawn',
  }.contains(status);
}
