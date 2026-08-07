// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchBreakdown _$MatchBreakdownFromJson(Map<String, dynamic> json) =>
    MatchBreakdown(
      group: json['group'] as String,
      weight: json['weight'] as num,
      asked: (json['asked'] as num).toInt(),
      matched: (json['matched'] as num).toInt(),
    );

CandidateSkill _$CandidateSkillFromJson(Map<String, dynamic> json) =>
    CandidateSkill(
      itemId: json['itemId'] as String,
      levelId: json['levelId'] as String?,
    );

CandidateCard _$CandidateCardFromJson(Map<String, dynamic> json) =>
    CandidateCard(
      candidateUserId: json['candidateUserId'] as String,
      experienceYears: (json['experienceYears'] as num).toInt(),
      completenessPercent: (json['completenessPercent'] as num).toInt(),
      salaryIsNegotiable: json['salaryIsNegotiable'] as bool,
      isSaved: json['isSaved'] as bool,
      isShortlisted: json['isShortlisted'] as bool,
      matchScore: (json['matchScore'] as num).toInt(),
      skills: (json['skills'] as List<dynamic>)
          .map((e) => CandidateSkill.fromJson(e as Map<String, dynamic>))
          .toList(),
      languages: (json['languages'] as List<dynamic>)
          .map((e) => CandidateSkill.fromJson(e as Map<String, dynamic>))
          .toList(),
      matchBreakdown: (json['matchBreakdown'] as List<dynamic>)
          .map((e) => MatchBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
      fullName: json['fullName'] as String?,
      regionId: json['regionId'] as String?,
      districtId: json['districtId'] as String?,
      settlement: json['settlement'] as String?,
      category: json['category'] as String?,
      primaryOccupationId: json['primaryOccupationId'] as String?,
      occupationLevelId: json['occupationLevelId'] as String?,
      currentRoleTitle: json['currentRoleTitle'] as String?,
      currentOccupationId: json['currentOccupationId'] as String?,
      salaryFrom: (json['salaryFrom'] as num?)?.toInt(),
      salaryTo: (json['salaryTo'] as num?)?.toInt(),
      salaryPeriodId: json['salaryPeriodId'] as String?,
      availableFrom: json['availableFrom'] as String?,
      lastMeaningfulUpdateAt: json['lastMeaningfulUpdateAt'] as String?,
      photoPath: json['photoPath'] as String?,
      note: json['note'] as String?,
      applicationStatus: json['applicationStatus'] as String?,
    );

CandidateCount _$CandidateCountFromJson(Map<String, dynamic> json) =>
    CandidateCount(
      count: (json['count'] as num).toInt(),
      isExact: json['isExact'] as bool,
    );
