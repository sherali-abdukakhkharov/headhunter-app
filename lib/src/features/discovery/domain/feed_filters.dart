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
/// ## Three of §5.5's nine filters have no query parameter
///
/// §5.5 lists "occupation, region, employment type, work format, shift,
/// salary/payment range, experience, language, and publication date".
/// `FeedQueryDto` accepts six of them plus the lower half of the range, and
/// has nothing for **experience**, **language**, or the range's upper bound.
/// They are deliberately absent here rather than modelled and dropped at the
/// boundary: a filter a candidate can set and the server ignores is worse than
/// one never offered, because the result list looks like an answer. Recorded as
/// a backend ask in TODO.md.
@immutable
class FeedFilters {
  const FeedFilters({
    this.occupationIds = const {},
    this.employmentTypeIds = const {},
    this.workFormatIds = const {},
    this.shiftIds = const {},
    this.regionId,
    this.districtId,
    this.salaryFrom,
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
    regionId: _text(json['regionId']),
    districtId: _text(json['districtId']),
    salaryFrom: switch (json['salaryFrom']) {
      final num value => value.toInt(),
      _ => null,
    },
    publishedFrom: _text(json['publishedFrom']),
  );

  final Set<String> occupationIds;
  final Set<String> employmentTypeIds;
  final Set<String> workFormatIds;
  final Set<String> shiftIds;

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
      regionId == null &&
      districtId == null &&
      salaryFrom == null &&
      publishedFrom == null;

  /// How many distinct filters are set, for a badge on the filter control.
  ///
  /// A **set** counts once however many ids it holds: three occupations is one
  /// narrowing decision, and a badge reading "5" for one row of chips tells
  /// nobody anything useful.
  int get count => [
    occupationIds.isNotEmpty,
    employmentTypeIds.isNotEmpty,
    workFormatIds.isNotEmpty,
    shiftIds.isNotEmpty,
    regionId != null,
    districtId != null,
    salaryFrom != null,
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
    'regionId': ?regionId,
    'districtId': ?districtId,
    'salaryFrom': ?salaryFrom,
    'publishedFrom': ?publishedFrom,
  };

  Map<String, dynamic> toJson() => {
    'occupationIds': occupationIds.toList(),
    'employmentTypeIds': employmentTypeIds.toList(),
    'workFormatIds': workFormatIds.toList(),
    'shiftIds': shiftIds.toList(),
    'regionId': ?regionId,
    'districtId': ?districtId,
    'salaryFrom': ?salaryFrom,
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
    String? regionId,
    String? districtId,
    int? salaryFrom,
    String? publishedFrom,
    bool clearRegion = false,
    bool clearDistrict = false,
    bool clearSalary = false,
    bool clearPublished = false,
  }) => FeedFilters(
    occupationIds: occupationIds ?? this.occupationIds,
    employmentTypeIds: employmentTypeIds ?? this.employmentTypeIds,
    workFormatIds: workFormatIds ?? this.workFormatIds,
    shiftIds: shiftIds ?? this.shiftIds,
    regionId: clearRegion ? null : regionId ?? this.regionId,
    districtId: clearDistrict ? null : districtId ?? this.districtId,
    salaryFrom: clearSalary ? null : salaryFrom ?? this.salaryFrom,
    publishedFrom: clearPublished ? null : publishedFrom ?? this.publishedFrom,
  );

  /// A non-empty string, or null for anything else.
  static String? _text(Object? raw) => switch (raw) {
    final String value when value.isNotEmpty => value,
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
      other.regionId == regionId &&
      other.districtId == districtId &&
      other.salaryFrom == salaryFrom &&
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
    regionId,
    districtId,
    salaryFrom,
    publishedFrom,
  );
}
