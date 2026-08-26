import 'package:flutter/foundation.dart';

/// §5.5's vacancy filters, as the feed endpoints accept them.
///
/// ## Ids, never labels (BR-13)
///
/// Every set here holds dictionary ids. The same occupation carries four
/// localized labels and one id, so a filter built from text returns nothing in
/// three of the four interface variants — silently, which is what makes it
/// worth restating on every model that holds one.
///
/// ## Two of the nine mean the opposite of what they look like
///
/// [experienceYearsMax] is a ceiling on what the **vacancy demands**, not a
/// floor on what the candidate has, so a vacancy that asks for no experience
/// passes it. The employer's candidate search uses the same word for the other
/// thing, over the people rather than over the work.
///
/// [languageIds] is the reverse: it matches vacancies that *require* one of
/// them, so a vacancy naming no language does **not** pass. "Show me work where
/// my Russian is wanted" is the question; hiding work the candidate is
/// unqualified for is a different one, and it is what the recommended feed's
/// ranking does.
///
/// Both directions are the server's, and `docs/API_CONTRACTS.md` states them
/// with the SQL.
@immutable
class FeedFilters {
  const FeedFilters({
    this.occupationIds = const {},
    this.employmentTypeIds = const {},
    this.workFormatIds = const {},
    this.shiftIds = const {},
    this.languageIds = const {},
    this.regionId,
    this.districtId,
    this.salaryFrom,
    this.salaryTo,
    this.experienceYearsMax,
    this.publishedFrom,
  });

  /// Reads a **locally stored** set, which is why every field is read
  /// defensively rather than cast.
  ///
  /// This is the one `fromJson` in the app that does not parse a server
  /// response: it reads what a previous run of *this app* wrote to
  /// preferences.
  /// So a field of the wrong type is not a contract violation — it is an older
  /// build's format, which is a normal thing to meet — and a cast that threw
  /// would lose the whole set over one renamed key.
  ///
  /// `FeedFilterController`
  /// catches the throw as a backstop, and this makes the backstop unnecessary
  /// for anything short of malformed JSON.
  factory FeedFilters.fromJson(Map<String, dynamic> json) => FeedFilters(
    occupationIds: _ids(json['occupationIds']),
    employmentTypeIds: _ids(json['employmentTypeIds']),
    workFormatIds: _ids(json['workFormatIds']),
    shiftIds: _ids(json['shiftIds']),
    languageIds: _ids(json['languageIds']),
    regionId: _text(json['regionId']),
    districtId: _text(json['districtId']),
    salaryFrom: _int(json['salaryFrom']),
    salaryTo: _int(json['salaryTo']),
    experienceYearsMax: _int(json['experienceYearsMax']),
    publishedFrom: _text(json['publishedFrom']),
  );

  final Set<String> occupationIds;
  final Set<String> employmentTypeIds;
  final Set<String> workFormatIds;
  final Set<String> shiftIds;

  /// `language` ids the vacancy must **require**, any one of them, at any
  /// level.
  ///
  /// Level is not sent: §5.5 asks for "language", and a vacancy wanting Russian
  /// at C1 is still a Russian vacancy to somebody filtering for Russian work.
  final Set<String> languageIds;

  /// Both are ids in the **`region`** dictionary: districts are its children
  /// (§5.1), not a type of their own.
  final String? regionId;
  final String? districtId;

  /// Minimum pay.
  ///
  /// **A negotiable vacancy passes this filter**, which is the server's
  /// behaviour and not an oversight: it has not said no to the figure, and
  /// excluding it would hide much of the seasonal work. The UI has to say so,
  /// because a candidate who sets a floor and sees "negotiable" cards will
  /// otherwise read it as a broken filter.
  final int? salaryFrom;

  /// Maximum pay, and **not the mirror** of [salaryFrom].
  ///
  /// A vacancy is excluded only when its *floor* is above this, so any
  /// overlapping range is in and a vacancy offering "up to 3,000,000" survives
  /// a ceiling of 2,000,000 — it might well pay it. Negotiable passes here too.
  final int? salaryTo;

  /// §5.5's "experience", as a ceiling on what the vacancy **demands**.
  ///
  /// A vacancy requiring more years than this is hidden; one that states no
  /// requirement passes, because it demands nothing. See the class comment for
  /// why this is the opposite direction to the employer's filter of the same
  /// name.
  final int? experienceYearsMax;

  /// `YYYY-MM-DD`, and published **on or after** it.
  ///
  /// A plain string rather than a `DateTime`: the server matches on the date it
  /// published in its own zone, so parsing this into an instant here would
  /// invite a `.toLocal()` that shifts the boundary by a day (§8.3).
  final String? publishedFrom;

  bool get isEmpty =>
      occupationIds.isEmpty &&
      employmentTypeIds.isEmpty &&
      workFormatIds.isEmpty &&
      shiftIds.isEmpty &&
      languageIds.isEmpty &&
      regionId == null &&
      districtId == null &&
      salaryFrom == null &&
      salaryTo == null &&
      experienceYearsMax == null &&
      publishedFrom == null;

  /// How many distinct filters are set, for a badge on the filter control.
  ///
  /// A **set** counts once however many ids it holds: three occupations is one
  /// narrowing decision, and a badge reading "5" for one row of chips tells
  /// nobody anything useful.
  ///
  /// **The pay range counts once too, for both bounds.** §5.5 lists it as one
  /// of its nine filters — "salary/payment range" — and a candidate who types
  /// two numbers into one labelled pair has made one decision about pay.
  int get count => [
    occupationIds.isNotEmpty,
    employmentTypeIds.isNotEmpty,
    workFormatIds.isNotEmpty,
    shiftIds.isNotEmpty,
    languageIds.isNotEmpty,
    regionId != null,
    districtId != null,
    salaryFrom != null || salaryTo != null,
    experienceYearsMax != null,
    publishedFrom != null,
  ].where((set) => set).length;

  /// The query the feed endpoints take.
  ///
  /// Empty sets and nulls are left out entirely rather than sent as blanks: the
  /// repository drops nulls, and an empty `occupationIds=` would be parsed as a
  /// one-element array containing the empty string and match nothing.
  Map<String, dynamic> toQuery() => {
    if (occupationIds.isNotEmpty) 'occupationIds': occupationIds.toList(),
    if (employmentTypeIds.isNotEmpty)
      'employmentTypeIds': employmentTypeIds.toList(),
    if (workFormatIds.isNotEmpty) 'workFormatIds': workFormatIds.toList(),
    if (shiftIds.isNotEmpty) 'shiftIds': shiftIds.toList(),
    if (languageIds.isNotEmpty) 'languageIds': languageIds.toList(),
    'regionId': ?regionId,
    'districtId': ?districtId,
    'salaryFrom': ?salaryFrom,
    'salaryTo': ?salaryTo,
    'experienceYearsMax': ?experienceYearsMax,
    'publishedFrom': ?publishedFrom,
  };

  Map<String, dynamic> toJson() => {
    'occupationIds': occupationIds.toList(),
    'employmentTypeIds': employmentTypeIds.toList(),
    'workFormatIds': workFormatIds.toList(),
    'shiftIds': shiftIds.toList(),
    'languageIds': languageIds.toList(),
    'regionId': ?regionId,
    'districtId': ?districtId,
    'salaryFrom': ?salaryFrom,
    'salaryTo': ?salaryTo,
    'experienceYearsMax': ?experienceYearsMax,
    'publishedFrom': ?publishedFrom,
  };

  /// Replaces named fields. Pass `clear*: true` to unset a nullable one, since
  /// null means "leave alone" here — the usual copyWith problem, and the reason
  /// clearing a filter needs to be as expressible as setting it.
  FeedFilters copyWith({
    Set<String>? occupationIds,
    Set<String>? employmentTypeIds,
    Set<String>? workFormatIds,
    Set<String>? shiftIds,
    Set<String>? languageIds,
    String? regionId,
    String? districtId,
    int? salaryFrom,
    int? salaryTo,
    int? experienceYearsMax,
    String? publishedFrom,
    bool clearRegion = false,
    bool clearDistrict = false,
    bool clearSalaryFrom = false,
    bool clearSalaryTo = false,
    bool clearExperience = false,
    bool clearPublished = false,
  }) => FeedFilters(
    occupationIds: occupationIds ?? this.occupationIds,
    employmentTypeIds: employmentTypeIds ?? this.employmentTypeIds,
    workFormatIds: workFormatIds ?? this.workFormatIds,
    shiftIds: shiftIds ?? this.shiftIds,
    languageIds: languageIds ?? this.languageIds,
    regionId: clearRegion ? null : regionId ?? this.regionId,
    districtId: clearDistrict ? null : districtId ?? this.districtId,
    salaryFrom: clearSalaryFrom ? null : salaryFrom ?? this.salaryFrom,
    salaryTo: clearSalaryTo ? null : salaryTo ?? this.salaryTo,
    experienceYearsMax: clearExperience
        ? null
        : experienceYearsMax ?? this.experienceYearsMax,
    publishedFrom: clearPublished ? null : publishedFrom ?? this.publishedFrom,
  );

  /// A non-empty string, or null for anything else.
  static String? _text(Object? raw) => switch (raw) {
    final String value when value.isNotEmpty => value,
    _ => null,
  };

  static int? _int(Object? raw) => switch (raw) {
    final num value => value.toInt(),
    _ => null,
  };

  static Set<String> _ids(Object? raw) => switch (raw) {
    final List<dynamic> list => {
      for (final item in list)
        if (item is String && item.isNotEmpty) item,
    },
    _ => const {},
  };

  @override
  bool operator ==(Object other) =>
      other is FeedFilters &&
      setEquals(other.occupationIds, occupationIds) &&
      setEquals(other.employmentTypeIds, employmentTypeIds) &&
      setEquals(other.workFormatIds, workFormatIds) &&
      setEquals(other.shiftIds, shiftIds) &&
      setEquals(other.languageIds, languageIds) &&
      other.regionId == regionId &&
      other.districtId == districtId &&
      other.salaryFrom == salaryFrom &&
      other.salaryTo == salaryTo &&
      other.experienceYearsMax == experienceYearsMax &&
      other.publishedFrom == publishedFrom;

  /// Deep, because the sets are part of the identity. `vacancyFeedProvider`
  /// reaches this through `ref.watch`, and a shallow hash would leave it unable
  /// to tell a changed filter set from the same one — so the feed would either
  /// never refresh or refresh on every rebuild.
  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(occupationIds),
    Object.hashAllUnordered(employmentTypeIds),
    Object.hashAllUnordered(workFormatIds),
    Object.hashAllUnordered(shiftIds),
    Object.hashAllUnordered(languageIds),
    regionId,
    districtId,
    salaryFrom,
    salaryTo,
    experienceYearsMax,
    publishedFrom,
  );
}
