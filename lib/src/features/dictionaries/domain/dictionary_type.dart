/// The dictionary types the server serves (§3.3, §10.3).
///
/// A constant list rather than an enum, deliberately: **administrators add
/// dictionary *items* at runtime, and the set of *types* is still the server's
/// to decide.** An enum would make an unknown type a deserialization crash;
/// these are plain strings, so a type this app version does not know about is
/// simply one it never asks for.
///
/// The named constants exist so a call site cannot misspell one — the server
/// answers an unknown type with 404 rather than an empty list, precisely so a
/// typo is loud, but finding out at runtime is worse than not compiling.
abstract final class DictionaryType {
  /// Job titles (§2.1). Carries `category`, so the options depend on the work
  /// category being filled in.
  static const occupation = 'occupation';

  /// Carries `category` for the same reason as [occupation].
  static const skill = 'skill';

  static const industry = 'industry';

  /// Regions **and** districts in one type: a district is an item whose
  /// `parentId` is its region. That is what the cascading picker walks.
  static const region = 'region';

  static const language = 'language';
  static const employmentType = 'employment_type';
  static const workFormat = 'work_format';
  static const shift = 'shift';

  /// §6.3 additional structured requirements. Grouped by `group`.
  static const attribute = 'attribute';

  /// Ordered scale — items carry `rank` (§7.4).
  static const skillLevel = 'skill_level';

  /// Ordered scale — CEFR A1–C2 plus native (§5.1). Items carry `rank`.
  static const languageLevel = 'language_level';

  static const educationLevel = 'education_level';
  static const paymentPeriod = 'payment_period';
  static const filePurpose = 'file_purpose';

  /// Every type this app version knows how to prefetch.
  ///
  /// Used for the warm-up sweep, not for validation: the server remains the
  /// authority on what exists.
  static const all = <String>[
    occupation,
    skill,
    industry,
    region,
    language,
    employmentType,
    workFormat,
    shift,
    attribute,
    skillLevel,
    languageLevel,
    educationLevel,
    paymentPeriod,
    filePurpose,
  ];
}
