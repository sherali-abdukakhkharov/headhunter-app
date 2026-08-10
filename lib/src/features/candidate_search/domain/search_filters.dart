import 'package:flutter/foundation.dart';

/// §7.3's result ordering.
///
/// `proximity` is tiered — same district, then same region, then the rest —
/// measured against whatever location the request filters on. With no location
/// filter there is nothing to be near and the server falls through to recency,
/// which is why the option is never disabled: it degrades rather than fails.
enum CandidateSearchSort {
  match('match'),
  recent('recent'),
  experience('experience'),
  salary('salary'),
  proximity('proximity');

  const CandidateSearchSort(this.wire);

  final String wire;

  /// Unknown values fall back to [match] rather than throwing: a sort is a
  /// preference, and a saved one from a newer build must not brick the screen.
  static CandidateSearchSort fromWire(Object? wire) =>
      values.firstWhere((s) => s.wire == wire, orElse: () => match);
}

/// How a multi-value group combines: every item, or any of them (§7.1).
enum MatchMode {
  any('any'),
  all('all');

  const MatchMode(this.wire);

  final String wire;

  static MatchMode fromWire(Object? wire) =>
      values.firstWhere((m) => m.wire == wire, orElse: () => any);
}

/// One row of §7.1's language filter: a language, optionally at a floor.
///
/// [minLevelRank] is a **rank, not a `language_level` id**, and that is the one
/// deliberate exception to BR-13's bind-the-id rule in this file — see
/// [CandidateSearchFilters.skillMinLevelRank] for why.
@immutable
class LanguageFilter {
  const LanguageFilter({
    required this.itemId,
    this.minLevelRank,
    this.requireCertificate = false,
  });

  factory LanguageFilter.fromJson(Map<String, dynamic> json) => LanguageFilter(
    itemId: json['itemId'] as String,
    minLevelRank: (json['minLevelRank'] as num?)?.toInt(),
    requireCertificate: json['requireCertificate'] as bool? ?? false,
  );

  /// A `language` dictionary id.
  final String itemId;

  /// The rank of the lowest acceptable `language_level`, or null for "any
  /// level".
  final int? minLevelRank;

  /// §7.1's "certificate availability".
  final bool requireCertificate;

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    if (minLevelRank != null) 'minLevelRank': minLevelRank,
    if (requireCertificate) 'requireCertificate': true,
  };

  LanguageFilter withLevel(int? rank) =>
      LanguageFilter(itemId: itemId, minLevelRank: rank);

  LanguageFilter withCertificate({required bool required}) => LanguageFilter(
    itemId: itemId,
    minLevelRank: minLevelRank,
    requireCertificate: required,
  );

  /// Identity is the language: a filter set never holds the same language
  /// twice, and re-adding one is a corrected floor rather than a duplicate.
  @override
  bool operator ==(Object other) =>
      other is LanguageFilter && other.itemId == itemId;

  @override
  int get hashCode => itemId.hashCode;
}

/// The wire keys of [CandidateSearchFilters], named once.
///
/// The filter builder edits a filter set by key — `_set(FilterKey.regionId,
/// id)` — because a typed `copyWith` over thirty-four optional fields, half of
/// which must be *clearable*, is a sentinel per field and a hundred lines that
/// nothing reads. Going through keys costs the compiler's help, so it is bought
/// back here: a misspelling is a missing constant rather than a filter that is
/// silently dropped on the way to the server.
abstract final class FilterKey {
  static const occupationIds = 'occupationIds';
  static const primaryOnly = 'primaryOnly';
  static const category = 'category';
  static const occupationLevelIds = 'occupationLevelIds';
  static const skillIds = 'skillIds';
  static const skillsMatchMode = 'skillsMatchMode';
  static const skillMinLevelRank = 'skillMinLevelRank';
  static const experienceYearsMin = 'experienceYearsMin';
  static const occupationExperienceYearsMin = 'occupationExperienceYearsMin';
  static const currentOccupationIds = 'currentOccupationIds';
  static const languages = 'languages';
  static const educationLevelIds = 'educationLevelIds';
  static const specializationIds = 'specializationIds';
  static const regionId = 'regionId';
  static const districtIds = 'districtIds';
  static const willingToRelocate = 'willingToRelocate';
  static const willingToTravel = 'willingToTravel';
  static const proximityDistrictId = 'proximityDistrictId';
  static const employmentTypeIds = 'employmentTypeIds';
  static const workFormatIds = 'workFormatIds';
  static const shiftIds = 'shiftIds';
  static const salaryMin = 'salaryMin';
  static const salaryMax = 'salaryMax';
  static const availableBy = 'availableBy';
  static const availableImmediately = 'availableImmediately';
  static const attributeIds = 'attributeIds';
  static const attributesMatchMode = 'attributesMatchMode';
  static const crewSizeMin = 'crewSizeMin';
  static const minCompleteness = 'minCompleteness';
  static const updatedSince = 'updatedSince';
  static const ageMin = 'ageMin';
  static const ageMax = 'ageMax';
  static const genderId = 'genderId';
  static const restrictionJustificationId = 'restrictionJustificationId';

  /// Every key, in the order the filter builder presents them — which is also
  /// the order the applied-filter chips appear in, so the two read the same way
  /// round.
  static const all = <String>[
    occupationIds,
    primaryOnly,
    category,
    occupationLevelIds,
    skillIds,
    skillsMatchMode,
    skillMinLevelRank,
    experienceYearsMin,
    occupationExperienceYearsMin,
    currentOccupationIds,
    languages,
    educationLevelIds,
    specializationIds,
    regionId,
    districtIds,
    willingToRelocate,
    willingToTravel,
    proximityDistrictId,
    employmentTypeIds,
    workFormatIds,
    shiftIds,
    salaryMin,
    salaryMax,
    availableBy,
    availableImmediately,
    attributeIds,
    attributesMatchMode,
    crewSizeMin,
    minCompleteness,
    updatedSince,
    ageMin,
    ageMax,
    genderId,
    restrictionJustificationId,
  ];
}

/// §7.1's filter set, as one immutable value.
///
/// ## Field names are the wire names
///
/// Deliberately mechanical: [toJson] is a transcription of the fields, so a
/// filter that exists here and not on `CandidateSearchFiltersDto` is a compile
/// error waiting on the server rather than a request that is quietly ignored.
/// Change this and `dto/candidate-search.dto.ts` together.
///
/// ## Absent means "no constraint"
///
/// [toJson] omits every unset filter rather than sending null. The server reads
/// an absent key as no constraint; it has no reading at all for a key that is
/// present and empty, and `[]` for a list would be a filter matching nobody if
/// anyone ever implemented it literally.
///
/// The four booleans are omitted when false for the same reason: the server
/// tests them for truth, so `willingToRelocate: false` is not "must not
/// relocate" — it is noise that looks like a constraint.
///
/// ## Two levels are ranks, not ids
///
/// [skillMinLevelRank] and [LanguageFilter.minLevelRank] carry a **rank**,
/// which is the only place in this app that binds something other than a
/// dictionary id (BR-13). §7.1 asks for "B2 or better", and *better* is a
/// comparison: ids are opaque and unordered, so a floor cannot be expressed as
/// one. `rank` is the ordered field the dictionary carries for exactly this
/// (§7.4), and it stays stable when a level is inserted between two others —
/// which `sortOrder` does not.
///
/// The **picker still shows the level's label and the user still chooses an
/// item**; only the value stored from that choice is its rank.
@immutable
class CandidateSearchFilters {
  const CandidateSearchFilters({
    this.occupationIds = const [],
    this.primaryOnly = false,
    this.category,
    this.occupationLevelIds = const [],
    this.skillIds = const [],
    this.skillsMatchMode = MatchMode.any,
    this.skillMinLevelRank,
    this.experienceYearsMin,
    this.occupationExperienceYearsMin,
    this.currentOccupationIds = const [],
    this.languages = const [],
    this.educationLevelIds = const [],
    this.specializationIds = const [],
    this.regionId,
    this.districtIds = const [],
    this.willingToRelocate = false,
    this.willingToTravel = false,
    this.proximityDistrictId,
    this.employmentTypeIds = const [],
    this.workFormatIds = const [],
    this.shiftIds = const [],
    this.salaryMin,
    this.salaryMax,
    this.availableBy,
    this.availableImmediately = false,
    this.attributeIds = const [],
    this.attributesMatchMode = MatchMode.any,
    this.crewSizeMin,
    this.minCompleteness,
    this.updatedSince,
    this.ageMin,
    this.ageMax,
    this.genderId,
    this.restrictionJustificationId,
  });

  /// Reads the shape the server sends — which is what
  /// `GET /candidate-search/prefill/:vacancyId` returns (UAT-06), and what this
  /// screen persists between sessions.
  ///
  /// Every field is defensive: a prefill from a newer server, or a stored set
  /// from an older build, must degrade to a usable filter rather than throw.
  factory CandidateSearchFilters.fromJson(Map<String, dynamic> json) =>
      CandidateSearchFilters(
        occupationIds: _ids(json['occupationIds']),
        primaryOnly: json['primaryOnly'] as bool? ?? false,
        category: json['category'] as String?,
        occupationLevelIds: _ids(json['occupationLevelIds']),
        skillIds: _ids(json['skillIds']),
        skillsMatchMode: MatchMode.fromWire(json['skillsMatchMode']),
        skillMinLevelRank: (json['skillMinLevelRank'] as num?)?.toInt(),
        experienceYearsMin: (json['experienceYearsMin'] as num?)?.toInt(),
        occupationExperienceYearsMin:
            (json['occupationExperienceYearsMin'] as num?)?.toInt(),
        currentOccupationIds: _ids(json['currentOccupationIds']),
        languages: [
          for (final row in json['languages'] as List? ?? const [])
            if (row is Map<String, dynamic> && row['itemId'] is String)
              LanguageFilter.fromJson(row),
        ],
        educationLevelIds: _ids(json['educationLevelIds']),
        specializationIds: _ids(json['specializationIds']),
        regionId: json['regionId'] as String?,
        districtIds: _ids(json['districtIds']),
        willingToRelocate: json['willingToRelocate'] as bool? ?? false,
        willingToTravel: json['willingToTravel'] as bool? ?? false,
        proximityDistrictId: json['proximityDistrictId'] as String?,
        employmentTypeIds: _ids(json['employmentTypeIds']),
        workFormatIds: _ids(json['workFormatIds']),
        shiftIds: _ids(json['shiftIds']),
        salaryMin: (json['salaryMin'] as num?)?.toInt(),
        salaryMax: (json['salaryMax'] as num?)?.toInt(),
        availableBy: json['availableBy'] as String?,
        availableImmediately: json['availableImmediately'] as bool? ?? false,
        attributeIds: _ids(json['attributeIds']),
        attributesMatchMode: MatchMode.fromWire(json['attributesMatchMode']),
        crewSizeMin: (json['crewSizeMin'] as num?)?.toInt(),
        minCompleteness: (json['minCompleteness'] as num?)?.toInt(),
        updatedSince: json['updatedSince'] as String?,
        ageMin: (json['ageMin'] as num?)?.toInt(),
        ageMax: (json['ageMax'] as num?)?.toInt(),
        genderId: json['genderId'] as String?,
        restrictionJustificationId:
            json['restrictionJustificationId'] as String?,
      );

  // --- occupation and category ---------------------------------------------
  final List<String> occupationIds;
  final bool primaryOnly;
  final String? category;
  final List<String> occupationLevelIds;

  // --- skills ---------------------------------------------------------------
  final List<String> skillIds;
  final MatchMode skillsMatchMode;

  /// A `skill_level` **rank** floor — see the class doc for why not an id.
  final int? skillMinLevelRank;

  // --- experience -----------------------------------------------------------
  final int? experienceYearsMin;

  /// Years in the occupations named by [occupationIds], which this therefore
  /// requires — the server answers `search.occupation_required` without them,
  /// and [occupationExperienceIsAnswerable] is the client-side reading of it.
  final int? occupationExperienceYearsMin;

  final List<String> currentOccupationIds;

  // --- languages ------------------------------------------------------------
  final List<LanguageFilter> languages;

  // --- education ------------------------------------------------------------
  final List<String> educationLevelIds;
  final List<String> specializationIds;

  // --- location -------------------------------------------------------------
  final String? regionId;
  final List<String> districtIds;
  final bool willingToRelocate;
  final bool willingToTravel;

  /// Where to be near, for [CandidateSearchSort.proximity] — a district id.
  ///
  /// Separate from [districtIds] on purpose: filtering *by* district excludes
  /// everyone else, which leaves a proximity sort nothing to order.
  final String? proximityDistrictId;

  // --- work preferences -----------------------------------------------------
  final List<String> employmentTypeIds;
  final List<String> workFormatIds;
  final List<String> shiftIds;
  final int? salaryMin;

  /// The employer's ceiling: a candidate expecting more is filtered out, and a
  /// candidate whose expectation is negotiable still passes.
  final int? salaryMax;

  // --- availability ---------------------------------------------------------
  /// `YYYY-MM-DD`.
  final String? availableBy;
  final bool availableImmediately;

  // --- attributes -----------------------------------------------------------
  final List<String> attributeIds;
  final MatchMode attributesMatchMode;
  final int? crewSizeMin;

  // --- profile status -------------------------------------------------------
  final int? minCompleteness;

  /// `YYYY-MM-DD` — §7.1's "recently updated".
  final String? updatedSince;

  // --- conditional filters (BR-12) -----------------------------------------
  final int? ageMin;
  final int? ageMax;
  final String? genderId;

  /// A `restriction_justification` id, required as soon as an age or gender
  /// filter is used. See [restrictionIsJustified].
  final String? restrictionJustificationId;

  Map<String, dynamic> toJson() => {
    if (occupationIds.isNotEmpty) 'occupationIds': occupationIds,
    if (primaryOnly) 'primaryOnly': true,
    if (category != null) 'category': category,
    if (occupationLevelIds.isNotEmpty)
      'occupationLevelIds': occupationLevelIds,
    if (skillIds.isNotEmpty) ...{
      'skillIds': skillIds,
      'skillsMatchMode': skillsMatchMode.wire,
    },
    if (skillMinLevelRank != null) 'skillMinLevelRank': skillMinLevelRank,
    if (experienceYearsMin != null) 'experienceYearsMin': experienceYearsMin,
    if (occupationExperienceYearsMin != null)
      'occupationExperienceYearsMin': occupationExperienceYearsMin,
    if (currentOccupationIds.isNotEmpty)
      'currentOccupationIds': currentOccupationIds,
    if (languages.isNotEmpty)
      'languages': [for (final row in languages) row.toJson()],
    if (educationLevelIds.isNotEmpty) 'educationLevelIds': educationLevelIds,
    if (specializationIds.isNotEmpty) 'specializationIds': specializationIds,
    if (regionId != null) 'regionId': regionId,
    if (districtIds.isNotEmpty) 'districtIds': districtIds,
    if (willingToRelocate) 'willingToRelocate': true,
    if (willingToTravel) 'willingToTravel': true,
    if (proximityDistrictId != null)
      'proximityDistrictId': proximityDistrictId,
    if (employmentTypeIds.isNotEmpty) 'employmentTypeIds': employmentTypeIds,
    if (workFormatIds.isNotEmpty) 'workFormatIds': workFormatIds,
    if (shiftIds.isNotEmpty) 'shiftIds': shiftIds,
    if (salaryMin != null) 'salaryMin': salaryMin,
    if (salaryMax != null) 'salaryMax': salaryMax,
    if (availableBy != null) 'availableBy': availableBy,
    if (availableImmediately) 'availableImmediately': true,
    if (attributeIds.isNotEmpty) ...{
      'attributeIds': attributeIds,
      'attributesMatchMode': attributesMatchMode.wire,
    },
    if (crewSizeMin != null) 'crewSizeMin': crewSizeMin,
    if (minCompleteness != null) 'minCompleteness': minCompleteness,
    if (updatedSince != null) 'updatedSince': updatedSince,
    if (ageMin != null) 'ageMin': ageMin,
    if (ageMax != null) 'ageMax': ageMax,
    if (genderId != null) 'genderId': genderId,
    if (restrictionJustificationId != null)
      'restrictionJustificationId': restrictionJustificationId,
  };

  /// No constraint at all — the state the screen starts in, and the state
  /// "Reset" returns to.
  bool get isEmpty => toJson().isEmpty;

  /// BR-12: an age or gender filter is a restriction and needs a declared
  /// reason.
  bool get usesRestriction =>
      ageMin != null || ageMax != null || genderId != null;

  /// BR-12's client-side reading. The server refuses an unjustified
  /// restriction with `search.restriction_not_justified`, and refusing it here
  /// too is not belt-and-braces: it is the difference between an employer being
  /// told *why* before they search and a 403 after.
  bool get restrictionIsJustified =>
      !usesRestriction || restrictionJustificationId != null;

  /// The server's `search.occupation_required`: years *in an occupation* is
  /// meaningless without naming the occupation.
  bool get occupationExperienceIsAnswerable =>
      occupationExperienceYearsMin == null || occupationIds.isNotEmpty;

  /// Whether the server will accept this set at all.
  bool get isRunnable =>
      restrictionIsJustified && occupationExperienceIsAnswerable;

  /// Drops one filter group, named by its **wire key**, and anything that
  /// cannot stand without it.
  ///
  /// The dependent clears are the point. Removing an occupation chip while
  /// "3 years in that occupation" is still set would leave a set the server
  /// refuses, so the chip the user *did* tap would appear to do nothing while
  /// an error appeared about a filter they did not touch. Three dependencies
  /// exist and all three are here:
  ///
  /// - `occupationIds` → `occupationExperienceYearsMin`
  /// - `regionId` → `districtIds`, which are that region's children
  /// - `restrictionJustificationId` → the age and gender filters it justified
  CandidateSearchFilters removing(String key) {
    final next = {...toJson()}..remove(key);

    switch (key) {
      case FilterKey.occupationIds:
        next.remove(FilterKey.occupationExperienceYearsMin);
      case FilterKey.regionId:
        next
          ..remove(FilterKey.districtIds)
          ..remove(FilterKey.proximityDistrictId);
      case FilterKey.restrictionJustificationId:
        next
          ..remove(FilterKey.ageMin)
          ..remove(FilterKey.ageMax)
          ..remove(FilterKey.genderId);
      case FilterKey.skillIds:
        next
          ..remove(FilterKey.skillsMatchMode)
          ..remove(FilterKey.skillMinLevelRank);
      case FilterKey.attributeIds:
        next.remove(FilterKey.attributesMatchMode);
    }

    return CandidateSearchFilters.fromJson(next);
  }

  /// The keys currently constraining the search, in [FilterKey.all] order.
  ///
  /// Drives the applied-filter chips. `skillsMatchMode` and
  /// `attributesMatchMode` are excluded: they modify a group rather than being
  /// one, and a chip removing "Any" would leave the user staring at skills that
  /// did not change.
  List<String> get activeKeys {
    final json = toJson();
    return [
      for (final key in FilterKey.all)
        if (json.containsKey(key) &&
            key != FilterKey.skillsMatchMode &&
            key != FilterKey.attributesMatchMode)
          key,
    ];
  }

  static List<String> _ids(Object? value) => [
    if (value is List)
      for (final item in value)
        if (item is String) item,
  ];
}

/// A whole search configuration: what to match, and how to order it.
///
/// One value rather than two loose fields because the two travel together
/// everywhere — into the request body, into the filter builder, and into local
/// storage. [toJson] **is** the request body for `POST /candidate-search` and
/// `POST /candidate-search/count`; the repository adds only paging.
@immutable
class SearchConfig {
  const SearchConfig({
    this.filters = const CandidateSearchFilters(),
    this.sort = CandidateSearchSort.match,
    this.vacancyId,
  });

  factory SearchConfig.fromJson(Map<String, dynamic> json) => SearchConfig(
    filters: CandidateSearchFilters.fromJson(
      json['filters'] as Map<String, dynamic>? ?? const {},
    ),
    sort: CandidateSearchSort.fromWire(json['sort']),
    vacancyId: json['vacancyId'] as String?,
  );

  final CandidateSearchFilters filters;
  final CandidateSearchSort sort;

  /// The vacancy the search was opened from (UAT-06).
  ///
  /// **Not a filter.** It decides `isShortlisted` on each card and nothing
  /// else — the server explicitly does *not* re-apply the vacancy's own
  /// requirements from it, because the client already holds them as filters and
  /// may have edited them. A stale id costs an empty shortlist, not an error.
  final String? vacancyId;

  /// The request body. `filters` is always present, even empty: the endpoint
  /// reads an absent one as "no constraint" too, but an explicit empty object
  /// is the honest description of "every searchable candidate".
  Map<String, dynamic> toJson() => {
    'filters': filters.toJson(),
    'sort': sort.wire,
    if (vacancyId != null) 'vacancyId': vacancyId,
  };

  SearchConfig withFilters(CandidateSearchFilters next) =>
      SearchConfig(filters: next, sort: sort, vacancyId: vacancyId);

  SearchConfig withSort(CandidateSearchSort next) =>
      SearchConfig(filters: filters, sort: next, vacancyId: vacancyId);
}
