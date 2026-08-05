import 'package:flutter/foundation.dart';

/// The 13 field kinds of API_CONTRACTS.md §4.2, plus [unknown].
///
/// **[unknown] is the whole reason this is an enum with a fallback rather than
/// a parse that throws.** The contract says an unrecognised kind must be
/// skipped and logged, never crash the form — precisely what lets the server
/// add a field type without a lockstep app release. A client that throws
/// turns a server-side addition into a fleet-wide outage for everyone who has
/// not updated.
enum FieldKind {
  text,
  longText,
  int_,
  decimal,
  bool_,
  date,
  dateRange,
  url,
  phone,
  moneyRange,
  dictionarySingle,
  dictionaryMulti,
  dictionaryLeveled,

  /// A kind this app version does not know. Rendered as nothing.
  unknown;

  static FieldKind fromWire(String wire) => switch (wire) {
    'text' => text,
    'long_text' => longText,
    'int' => int_,
    'decimal' => decimal,
    'bool' => bool_,
    'date' => date,
    'date_range' => dateRange,
    'url' => url,
    'phone' => phone,
    'money_range' => moneyRange,
    'dictionary_single' => dictionarySingle,
    'dictionary_multi' => dictionaryMulti,
    'dictionary_leveled' => dictionaryLeveled,
    _ => unknown,
  };
}

/// Advisory client-side rules. **The server enforces these regardless** (§4.2
/// rule 3), so failing to apply one costs a round trip, not correctness.
@immutable
class FieldValidation {
  const FieldValidation({
    this.min,
    this.max,
    this.minLength,
    this.maxLength,
    this.maxItems,
    this.requireFromLteTo,
  });

  factory FieldValidation.fromJson(Map<String, dynamic> json) =>
      FieldValidation(
        min: (json['min'] as num?)?.toDouble(),
        max: (json['max'] as num?)?.toDouble(),
        minLength: json['minLength'] as int?,
        maxLength: json['maxLength'] as int?,
        maxItems: json['maxItems'] as int?,
        requireFromLteTo: json['requireFromLteTo'] as bool?,
      );

  final double? min;
  final double? max;
  final int? minLength;
  final int? maxLength;
  final int? maxItems;

  /// `money_range` only: `from` must not exceed `to` (§4.3).
  final bool? requireFromLteTo;
}

/// One field in a section.
@immutable
class SchemaField {
  const SchemaField({
    required this.code,
    required this.kind,
    required this.label,
    required this.required,
    this.dictionaryType,
    this.group,
    this.parentFieldCode,
    this.levelDictionaryType,
    this.currency,
    this.periodDictionaryType,
    this.allowNegotiable,
    this.validation,
  });

  factory SchemaField.fromJson(Map<String, dynamic> json) => SchemaField(
    code: json['code'] as String,
    kind: FieldKind.fromWire(json['kind'] as String),
    label: json['label'] as String,
    required: json['required'] as bool? ?? false,
    dictionaryType: json['dictionaryType'] as String?,
    group: json['group'] as String?,
    parentFieldCode: json['parentFieldCode'] as String?,
    levelDictionaryType: json['levelDictionaryType'] as String?,
    currency: json['currency'] as String?,
    periodDictionaryType: json['periodDictionaryType'] as String?,
    allowNegotiable: json['allowNegotiable'] as bool?,
    validation: json['validation'] == null
        ? null
        : FieldValidation.fromJson(json['validation'] as Map<String, dynamic>),
  );

  /// The key in the `PATCH` body's `fields` object (§4.6), and the key the
  /// profile's `fields` map is read by. Renaming one is a contract change.
  final String code;

  final FieldKind kind;

  /// Already resolved for the request's `x-lang`.
  final String label;

  /// Required before the profile may become **searchable** (BR-02) — for this
  /// category only.
  ///
  /// **Not required to save.** A candidate must be able to clear something they
  /// entered by mistake; the profile then simply stops being complete. Treating
  /// this as a save gate is the most tempting misreading of the contract.
  final bool required;

  /// The dictionary to load options from, for the three `dictionary_*` kinds.
  final String? dictionaryType;

  /// `attribute` items only: offer just this group (§3.4).
  final String? group;

  /// **The cascade, declared by the server rather than hardcoded.** When set,
  /// this field's options are the children of whatever the named field holds —
  /// a district within the chosen region.
  ///
  /// This is why the engine needs no knowledge that districts belong to
  /// regions: the schema says so, and a second hierarchy costs no client
  /// change.
  final String? parentFieldCode;

  /// `dictionary_leveled` only: the ordered scale (§4.4).
  final String? levelDictionaryType;

  /// `money_range` only. **Never hardcode this** — the contract says so
  /// explicitly, and a hardcoded `UZS` is a wrong number on screen the day a
  /// second currency appears.
  final String? currency;

  final String? periodDictionaryType;
  final bool? allowNegotiable;
  final FieldValidation? validation;
}

/// A group of fields, or a hand-off to a purpose-built editor.
@immutable
class SchemaSection {
  const SchemaSection({
    required this.code,
    required this.label,
    required this.repeating,
    required this.editor,
    required this.fields,
    this.endpoint,
  });

  factory SchemaSection.fromJson(Map<String, dynamic> json) => SchemaSection(
    code: json['code'] as String,
    label: json['label'] as String,
    repeating: json['repeating'] as bool? ?? false,
    editor: json['editor'] as String,
    endpoint: json['endpoint'] as String?,
    fields: (json['fields'] as List<dynamic>? ?? const [])
        .map((e) => SchemaField.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final String code;
  final String label;

  /// Several rows of the same shape — work history, education.
  final bool repeating;

  /// `engine` renders [fields]; `bespoke` hands the section to a purpose-built
  /// widget and [fields] is empty.
  ///
  /// Kept as a string rather than an enum for the same reason as [FieldKind]'s
  /// fallback: a new editor mode must not crash an old client.
  final String editor;

  /// Bespoke sections only: the sub-resource that owns the rows.
  final String? endpoint;

  final List<SchemaField> fields;

  bool get isEngine => editor == 'engine';

  /// Fields this app version can actually draw. An unknown kind is dropped
  /// here, once, rather than guarded at every use site.
  List<SchemaField> get renderableFields =>
      fields.where((f) => f.kind != FieldKind.unknown).toList();

  /// Codes this app version had to skip. Logged by the engine so a
  /// server-side addition is visible in a bug report rather than silent.
  List<String> get unknownFieldCodes => fields
      .where((f) => f.kind == FieldKind.unknown)
      .map((f) => f.code)
      .toList();
}

/// A declarative attachment slot (§4.5).
///
/// Files sit outside the field union deliberately: an upload needs progress,
/// cancel, retry and per-viewer authorization, which a dynamic form field
/// cannot carry.
@immutable
class SchemaAttachment {
  const SchemaAttachment({
    required this.purposeId,
    required this.code,
    required this.label,
    required this.required,
    required this.accept,
    required this.maxSizeBytes,
    required this.maxCount,
  });

  factory SchemaAttachment.fromJson(Map<String, dynamic> json) =>
      SchemaAttachment(
        purposeId: json['purposeId'] as String,
        code: json['code'] as String,
        label: json['label'] as String,
        required: json['required'] as bool? ?? false,
        accept: (json['accept'] as List<dynamic>? ?? const [])
            .cast<String>()
            .toList(),
        maxSizeBytes: (json['maxSizeBytes'] as num?)?.toInt() ?? 0,
        maxCount: (json['maxCount'] as num?)?.toInt() ?? 1,
      );

  final String purposeId;
  final String code;
  final String label;
  final bool required;
  final List<String> accept;
  final int maxSizeBytes;
  final int maxCount;
}

/// The whole form for one work category (§5.2).
///
/// Fetched rather than shipped, because §5.2 requires the profile to adapt to
/// the occupation category and "irrelevant fields shall not be mandatory".
/// Hardcoding five variants means the field set can only change with a
/// release — and the server validates writes against this same declaration, so
/// a client that had it wrong would produce clean 422s it could not explain.
@immutable
class FieldSchema {
  const FieldSchema({
    required this.category,
    required this.schemaVersion,
    required this.locale,
    required this.sections,
    required this.attachments,
    required this.requiredForSearchable,
  });

  factory FieldSchema.fromJson(Map<String, dynamic> json) => FieldSchema(
    category: json['category'] as String,
    schemaVersion: (json['schemaVersion'] as num).toInt(),
    locale: json['locale'] as String,
    sections: (json['sections'] as List<dynamic>)
        .map((e) => SchemaSection.fromJson(e as Map<String, dynamic>))
        .toList(),
    attachments: (json['attachments'] as List<dynamic>? ?? const [])
        .map((e) => SchemaAttachment.fromJson(e as Map<String, dynamic>))
        .toList(),
    requiredForSearchable:
        (json['requiredForSearchable'] as List<dynamic>? ?? const [])
            .cast<String>()
            .toList(),
  );

  final String category;
  final int schemaVersion;
  final String locale;
  final List<SchemaSection> sections;
  final List<SchemaAttachment> attachments;

  /// Codes that must be filled before the profile can be searchable (BR-02).
  /// Every one resolves to a field in [sections], so a completeness prompt can
  /// always focus one.
  final List<String> requiredForSearchable;

  /// Looks up a field across every section — the engine needs this to follow
  /// [SchemaField.parentFieldCode], which may name a field in another section.
  SchemaField? fieldByCode(String code) {
    for (final section in sections) {
      for (final field in section.fields) {
        if (field.code == code) return field;
      }
    }
    return null;
  }
}
