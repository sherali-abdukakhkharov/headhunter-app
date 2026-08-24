import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/l10n/app_locale.dart';

/// A dictionary item being created (§10.3).
///
/// ## All four labels are typed here, and that is the one place they can be
///
/// §3.2 requires every item to carry a label in all four interface variants,
/// and the database refuses to *activate* one that does not. Creating is the
/// only screen in this app that can honestly collect them: the read side
/// resolves a label through §3.2's fallback chain, so an item missing its
/// Russian label reads back with the Uzbek one and a client cannot tell which
/// it is holding. Editing existing labels therefore waits on a contract change
/// — see docs/BACKEND_ASKS.md — while creating does not, because nothing is
/// being read.
///
/// A partial set is still allowed on the wire and still useful: it makes a
/// draft that cannot be activated until it is finished, which is exactly the
/// state §10.3 needs when a translation is somebody else's job.
@immutable
class NewDictionaryItem {
  const NewDictionaryItem({
    required this.code,
    required this.labels,
    this.category,
    this.group,
    this.rank,
    this.sortOrder,
    this.parentId,
  });

  /// The stable machine code, unique within the type. **Never shown to a user**
  /// (BR-13) — it exists so a label can change in four languages without
  /// anything that stored the item breaking.
  final String code;

  /// Keyed by locale tag: `uz-Latn`, `uz-Cyrl`, `ru`, `en`.
  final Map<String, String> labels;

  /// §10.3's "assign category" — occupations and work types only.
  final String? category;

  /// A second grouping: attribute groups, skill families.
  final String? group;

  /// Ordered scales only, and uniform per type. This is the value a "≥ B2"
  /// comparison uses (§7.4), which is why a level without one cannot be
  /// compared against and a level with a duplicate one is a silent tie.
  final int? rank;

  final int? sortOrder;

  /// A district's region (§5.1) — the one hierarchy in the dictionaries.
  final String? parentId;

  /// Which of the four variants still have no label.
  ///
  /// Not a blocker on creating: an item with two labels is a legitimate draft.
  /// It is what the screen says before it offers to activate, because
  /// activation is what the missing ones refuse.
  List<AppLocale> get missingLocales => [
    for (final locale in AppLocale.values)
      if ((labels[locale.tag] ?? '').trim().isEmpty) locale,
  ];

  bool get isComplete => missingLocales.isEmpty;

  Map<String, dynamic> toJson() => {
    'code': code,
    'labels': {
      for (final entry in labels.entries)
        if (entry.value.trim().isNotEmpty) entry.key: entry.value.trim(),
    },
    'category': ?category,
    'group': ?group,
    'rank': ?rank,
    'sortOrder': ?sortOrder,
    'parentId': ?parentId,
    // Never true. The server defaults to inactive and this client keeps that:
    // it cannot know the four labels are complete until the database either
    // accepts an activation or refuses it, so it asks separately and reads the
    // answer. See `AdminRepository.createDictionaryItem`.
    'isActive': false,
  };
}
