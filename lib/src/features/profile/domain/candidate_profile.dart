import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';

/// A field the profile still needs before it can be searchable (BR-02).
@immutable
class MissingField {
  const MissingField({
    required this.code,
    required this.section,
    required this.required,
    this.label,
  });

  factory MissingField.fromJson(Map<String, dynamic> json) => MissingField(
    code: json['code'] as String,
    section: json['section'] as String? ?? '',
    required: json['required'] as bool? ?? false,
    label: json['label'] as String?,
  );

  /// A schema field code. §5.3 wants the completeness list to link straight to
  /// the editor, and this is what makes that possible.
  final String code;

  final String section;

  /// True when this blocks searchability, false when it merely lowers the
  /// completeness percentage.
  final bool required;

  final String? label;
}

/// `GET /candidates/me/profile`.
///
/// Mirrors `CandidateProfileDto` in headhunter-backend — change both together.
///
/// **Always succeeds for a candidate.** Before the first save every field is
/// present and empty and [isStarted] is false, so the form has one code path
/// rather than a "create" branch and an "edit" branch.
@immutable
class CandidateProfile {
  const CandidateProfile({
    required this.isStarted,
    required this.visibility,
    required this.completenessPercent,
    required this.isComplete,
    required this.isSearchable,
    required this.missingFields,
    required this.fields,
    this.category,
    this.lastMeaningfulUpdateAt,
  });

  factory CandidateProfile.fromJson(Map<String, dynamic> json) =>
      CandidateProfile(
        isStarted: json['isStarted'] as bool? ?? false,
        category: json['category'] as String?,
        visibility: json['visibility'] as String? ?? 'hidden',
        completenessPercent:
            (json['completenessPercent'] as num?)?.toInt() ?? 0,
        isComplete: json['isComplete'] as bool? ?? false,
        isSearchable: json['isSearchable'] as bool? ?? false,
        missingFields: (json['missingFields'] as List<dynamic>? ?? const [])
            .map((e) => MissingField.fromJson(e as Map<String, dynamic>))
            .toList(),
        fields: Map<String, dynamic>.from(
          json['fields'] as Map? ?? const <String, dynamic>{},
        ),
        lastMeaningfulUpdateAt: switch (json['lastMeaningfulUpdateAt']) {
          final String s => ZonedTimestamp.parse(s),
          _ => null,
        },
      );

  final bool isStarted;

  /// The work category derived from the primary occupation — **null until one
  /// is chosen**, which is why the form cannot be fetched before that.
  final String? category;

  /// `hidden` / `searchable` / `visible_after_apply` (UAT-12). Changed through
  /// its own endpoint, never as a field: it is the one write that must not
  /// refresh [lastMeaningfulUpdateAt], since a privacy toggle cannot be used to
  /// look freshly active.
  final String visibility;

  final int completenessPercent;
  final bool isComplete;
  final bool isSearchable;

  final List<MissingField> missingFields;

  /// Keyed by schema field code, **shaped exactly as `PATCH` accepts**. That
  /// symmetry is what lets the engine read a value, hand it to a widget, and
  /// send whatever comes back without a translation layer in either direction.
  final Map<String, dynamic> fields;

  /// §5.3. Null before the first meaningful edit.
  final ZonedTimestamp? lastMeaningfulUpdateAt;

  /// Only the codes that actually block searchability (BR-02).
  List<MissingField> get blockingFields =>
      missingFields.where((f) => f.required).toList();
}
