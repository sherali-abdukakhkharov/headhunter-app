import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/features/discovery/domain/vacancy_card.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vacancy_detail.g.dart';

/// One structured requirement on a vacancy (§6.3).
///
/// ## Five value slots, one of which is filled
///
/// A requirement is whatever its schema field says it is — a dictionary item, a
/// levelled pair, a yes/no, a number or free text — so the server sends one row
/// shape with a slot per kind and fills the one that applies. Reading it is
/// therefore a matter of asking which slot is non-null, in an order that cannot
/// mistake one for another: [itemId] first, because a levelled row also carries
/// an item, and text last, because it is the only slot with no other meaning.
///
/// [fieldCode] is the schema field this came from (`languages`, `skills`, …).
/// It is a **grouping key, not a label** — the label comes from the vacancy
/// schema, which is where an admin's wording lives (§10.3).
@JsonSerializable(createToJson: false)
@immutable
class VacancyRequirement {
  const VacancyRequirement({
    required this.fieldCode,
    required this.isMandatory,
    this.itemId,
    this.levelId,
    this.valueBool,
    this.valueInt,
    this.valueText,
  });

  factory VacancyRequirement.fromJson(Map<String, dynamic> json) =>
      _$VacancyRequirementFromJson(json);

  final String fieldCode;

  /// §6.3's mandatory / preferred split. **Preferred is not a weaker
  /// mandatory** — a preference that excluded candidates would not be a
  /// preference — so the two must never render the same.
  final bool isMandatory;

  final String? itemId;
  final String? levelId;
  final bool? valueBool;
  final int? valueInt;
  final String? valueText;
}

/// A vacancy as a candidate reads it before applying (§5.6).
///
/// The list card and the detail share [item] rather than duplicating its
/// fields: the same title, salary, deadline and `applicationStatus` drive both,
/// and a second copy is a second thing to keep in step with the feed.
///
/// **Visible only while the vacancy is** (BR-04, BR-11). A moderated-away or
/// closed vacancy answers 404 rather than rendering greyed out, which is why
/// this screen's error state has to read as an ordinary outcome.
@JsonSerializable(createToJson: false)
@immutable
class VacancyDetail {
  const VacancyDetail({
    required this.item,
    required this.requirements,
    this.description,
    this.address,
    this.startsOn,
    this.endsOn,
  });

  factory VacancyDetail.fromJson(Map<String, dynamic> json) =>
      _$VacancyDetailFromJson(json);

  final VacancyCard item;

  /// Free text the employer wrote. **Never translated** (§2.4) — it is
  /// displayed exactly as entered, in whatever language that was.
  final String? description;

  final String? address;

  /// The work window, for seasonal and fixed-date assignments (§6.3, UAT-10).
  final String? startsOn;
  final String? endsOn;

  final List<VacancyRequirement> requirements;

  /// Requirements grouped by their schema field, mandatory ones first within
  /// each group.
  ///
  /// Grouping is the client's job because the server sends a flat list — one
  /// row per requirement — and a screen that rendered it flat would put
  /// "Russian" and "forklift licence" in the same undifferentiated column.
  Map<String, List<VacancyRequirement>> get byField {
    final grouped = <String, List<VacancyRequirement>>{};
    for (final requirement in requirements) {
      (grouped[requirement.fieldCode] ??= []).add(requirement);
    }

    for (final rows in grouped.values) {
      rows.sort((a, b) {
        if (a.isMandatory == b.isMandatory) return 0;
        return a.isMandatory ? -1 : 1;
      });
    }

    return grouped;
  }
}
