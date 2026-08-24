import 'package:flutter/foundation.dart';

/// One dictionary type, as `GET /dictionaries/manifest` describes it.
///
/// Mirrors `TypeVersionDto` in headhunter-backend — change both together.
@immutable
class DictionaryTypeVersion {
  const DictionaryTypeVersion({
    required this.type,
    required this.version,
    required this.count,
  });

  factory DictionaryTypeVersion.fromJson(Map<String, dynamic> json) =>
      DictionaryTypeVersion(
        type: json['type'] as String,
        version: (json['version'] as num).toInt(),
        count: (json['count'] as num).toInt(),
      );

  /// The wire code — `employment_type`. Never shown raw where a name exists
  /// (BR-13, §3.2), but shown rather than hidden for a type this build has no
  /// name for: §10.3 lets an administrator extend the platform at runtime, and
  /// a type that did not appear in the list would be one nobody could reach.
  final String type;

  final int version;

  /// **Active items only** — what a picker would show. So a type whose items
  /// have all been retired reads as 0 here and still opens onto its list.
  final int count;
}

/// The manifest: every type the server has, and what revision each is at.
///
/// Locale-independent, which is why it can be read once for a screen that
/// lists types rather than labels.
@immutable
class DictionaryManifest {
  const DictionaryManifest({required this.version, required this.types});

  factory DictionaryManifest.fromJson(Map<String, dynamic> json) =>
      DictionaryManifest(
        version: (json['version'] as num?)?.toInt() ?? 0,
        types: [
          for (final row in json['types'] as List? ?? const [])
            if (row is Map<String, dynamic>)
              DictionaryTypeVersion.fromJson(row),
        ],
      );

  /// The newest revision anywhere in the dictionaries.
  final int version;

  /// **The authority on what types exist**, and the reason this screen reads
  /// the manifest rather than `DictionaryType.all`: that constant is the
  /// client's prefetch list, explicitly "not for validation", so a type added
  /// server-side would be invisible to an administrator until a client
  /// release.
  final List<DictionaryTypeVersion> types;
}
