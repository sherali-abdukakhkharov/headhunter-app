import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/features/candidate_search/domain/search_filters.dart';

/// §7.1's filter set as a value: what reaches the wire, and what does not.
///
/// The filter builder edits this by **wire key** rather than through a typed
/// `copyWith` (see [FilterKey] for why), which trades the compiler's help for
/// a hundred fewer lines. This file is where that trade is paid for: the
/// round-trip test below is the thing standing between a mistyped key and a
/// filter that is silently dropped on the way to the server.
void main() {
  group('what reaches the wire', () {
    test('an untouched filter set constrains nothing', () {
      expect(const CandidateSearchFilters().toJson(), isEmpty);
      expect(const CandidateSearchFilters().isEmpty, isTrue);
    });

    test('a false toggle is omitted, not sent as false', () {
      // The server tests these for truth, so `willingToRelocate: false` is not
      // "must not relocate" — it is noise that reads like a constraint, and
      // the day someone implements it literally it becomes one.
      final json = const CandidateSearchFilters().toJson();

      expect(json.containsKey(FilterKey.willingToRelocate), isFalse);
      expect(json.containsKey(FilterKey.willingToTravel), isFalse);
      expect(json.containsKey(FilterKey.primaryOnly), isFalse);
      expect(json.containsKey(FilterKey.availableImmediately), isFalse);
    });

    test('an empty list is omitted rather than sent as []', () {
      // The path this actually arrives by: a prefill (UAT-06) or a stored set
      // that names a group with nothing in it. `[]` would be a filter matching
      // nobody the day anyone implemented it literally.
      final filters = CandidateSearchFilters.fromJson(const {
        'occupationIds': <String>[],
        'skillIds': <String>[],
      });

      expect(filters.toJson(), isEmpty);
    });

    test('a match mode without its group is not sent', () {
      // `skillsMatchMode: all` with no skills asks a question with no subject.
      // Sending it would be harmless today and confusing in a request log.
      const filters = CandidateSearchFilters(skillsMatchMode: MatchMode.all);

      expect(filters.toJson(), isEmpty);
    });

    test('a match mode travels with its group', () {
      const filters = CandidateSearchFilters(
        skillIds: ['s1'],
        skillsMatchMode: MatchMode.all,
      );

      expect(filters.toJson()[FilterKey.skillsMatchMode], 'all');
    });

    test('a language row omits a floor it does not have', () {
      const row = LanguageFilter(itemId: 'lang-1');

      expect(row.toJson(), {'itemId': 'lang-1'});
    });

    test('a language row carries its floor as a rank, not an id', () {
      // The one deliberate exception to BR-13's bind-the-id rule: "B2 or
      // better" is a comparison, and ids are unordered.
      const row = LanguageFilter(
        itemId: 'lang-1',
        minLevelRank: 40,
        requireCertificate: true,
      );

      expect(row.toJson(), {
        'itemId': 'lang-1',
        'minLevelRank': 40,
        'requireCertificate': true,
      });
    });
  });

  group('every filter survives the round trip', () {
    /// One value per key, chosen so nothing collides and every type is
    /// exercised.
    const full = <String, dynamic>{
      FilterKey.occupationIds: ['occ-1', 'occ-2'],
      FilterKey.primaryOnly: true,
      FilterKey.category: 'professional',
      FilterKey.occupationLevelIds: ['lvl-1'],
      FilterKey.skillIds: ['skill-1'],
      FilterKey.skillsMatchMode: 'all',
      FilterKey.skillMinLevelRank: 30,
      FilterKey.experienceYearsMin: 3,
      FilterKey.occupationExperienceYearsMin: 2,
      FilterKey.currentOccupationIds: ['occ-3'],
      FilterKey.languages: [
        {'itemId': 'lang-1', 'minLevelRank': 40, 'requireCertificate': true},
      ],
      FilterKey.educationLevelIds: ['edu-1'],
      FilterKey.specializationIds: ['spec-1'],
      FilterKey.regionId: 'region-1',
      FilterKey.districtIds: ['district-1'],
      FilterKey.willingToRelocate: true,
      FilterKey.willingToTravel: true,
      FilterKey.proximityDistrictId: 'district-2',
      FilterKey.employmentTypeIds: ['emp-1'],
      FilterKey.workFormatIds: ['fmt-1'],
      FilterKey.shiftIds: ['shift-1'],
      FilterKey.salaryMin: 3000000,
      FilterKey.salaryMax: 8000000,
      FilterKey.availableBy: '2026-09-01',
      FilterKey.availableImmediately: true,
      FilterKey.attributeIds: ['attr-1'],
      FilterKey.attributesMatchMode: 'all',
      FilterKey.crewSizeMin: 4,
      FilterKey.minCompleteness: 80,
      FilterKey.updatedSince: '2026-07-01',
      FilterKey.ageMin: 21,
      FilterKey.ageMax: 45,
      FilterKey.genderId: 'gender-1',
      FilterKey.restrictionJustificationId: 'just-1',
    };

    test('the fixture covers every key FilterKey names', () {
      // Guards the test itself: adding a filter to the model without adding it
      // here would leave the round-trip below passing while covering less.
      expect(full.keys.toSet(), FilterKey.all.toSet());
    });

    test('fromJson then toJson is the identity', () {
      // This is the one that catches a mistyped key in the filter builder: a
      // key the model does not read is dropped here, loudly.
      expect(CandidateSearchFilters.fromJson(full).toJson(), full);
    });

    test('a whole config round-trips, sort and all', () {
      final config = SearchConfig.fromJson(const {
        'filters': full,
        'sort': 'proximity',
      });

      expect(config.sort, CandidateSearchSort.proximity);
      expect(config.toJson(), {'filters': full, 'sort': 'proximity'});
    });

    test('an unknown sort degrades to match rather than throwing', () {
      // A saved config from a newer build must not brick the screen it was
      // saved on.
      expect(
        SearchConfig.fromJson(const {'sort': 'whatever'}).sort,
        CandidateSearchSort.match,
      );
      expect(
        CandidateSearchSort.fromWire(null),
        CandidateSearchSort.match,
      );
    });

    test('junk in a stored set is ignored rather than fatal', () {
      final filters = CandidateSearchFilters.fromJson(const {
        'occupationIds': ['ok', 42, null],
        'languages': [
          {'itemId': 'lang-1'},
          {'noItemId': true},
          'nonsense',
        ],
        'unknownFilterFromTheFuture': 'ignored',
      });

      expect(filters.occupationIds, ['ok']);
      expect(filters.languages.map((l) => l.itemId), ['lang-1']);
      expect(filters.toJson().containsKey('unknownFilterFromTheFuture'), false);
    });
  });

  group('removing a group takes its dependents with it', () {
    test('dropping the occupation drops years in that occupation', () {
      // Otherwise the chip the employer tapped appears to do nothing, while an
      // error arrives about a filter they did not touch:
      // `search.occupation_required`.
      const filters = CandidateSearchFilters(
        occupationIds: ['occ-1'],
        occupationExperienceYearsMin: 3,
        experienceYearsMin: 5,
      );

      final next = filters.removing(FilterKey.occupationIds);

      expect(next.occupationIds, isEmpty);
      expect(next.occupationExperienceYearsMin, isNull);
      // Total experience is not "in an occupation" and survives.
      expect(next.experienceYearsMin, 5);
    });

    test('dropping the region drops its districts', () {
      const filters = CandidateSearchFilters(
        regionId: 'region-1',
        districtIds: ['district-1', 'district-2'],
        proximityDistrictId: 'district-3',
      );

      final next = filters.removing(FilterKey.regionId);

      expect(next.regionId, isNull);
      expect(next.districtIds, isEmpty);
      expect(next.proximityDistrictId, isNull);
    });

    test('dropping the justification drops what it justified (BR-12)', () {
      // The set must never be left holding an age or gender filter with no
      // declared reason — that is a request the server refuses.
      const filters = CandidateSearchFilters(
        ageMin: 21,
        ageMax: 45,
        genderId: 'gender-1',
        restrictionJustificationId: 'just-1',
        skillIds: ['skill-1'],
      );

      final next = filters.removing(FilterKey.restrictionJustificationId);

      expect(next.usesRestriction, isFalse);
      expect(next.restrictionIsJustified, isTrue);
      expect(next.skillIds, ['skill-1']);
    });

    test('dropping the skills drops their mode and floor', () {
      const filters = CandidateSearchFilters(
        skillIds: ['skill-1'],
        skillsMatchMode: MatchMode.all,
        skillMinLevelRank: 30,
      );

      final next = filters.removing(FilterKey.skillIds);

      expect(next.toJson(), isEmpty);
    });
  });

  group('rules the client enforces before the server does', () {
    test('BR-12: an age filter alone is not runnable', () {
      const filters = CandidateSearchFilters(ageMin: 21);

      expect(filters.usesRestriction, isTrue);
      expect(filters.restrictionIsJustified, isFalse);
      expect(filters.isRunnable, isFalse);
    });

    test('BR-12: a gender filter alone is not runnable', () {
      const filters = CandidateSearchFilters(genderId: 'gender-1');

      expect(filters.restrictionIsJustified, isFalse);
    });

    test('BR-12: a justified restriction is runnable', () {
      const filters = CandidateSearchFilters(
        ageMin: 21,
        restrictionJustificationId: 'just-1',
      );

      expect(filters.restrictionIsJustified, isTrue);
      expect(filters.isRunnable, isTrue);
    });

    test('a justification with no restriction is harmless', () {
      // The server ignores it, and refusing it here would block a set that is
      // merely over-declared.
      const filters = CandidateSearchFilters(
        restrictionJustificationId: 'just-1',
      );

      expect(filters.usesRestriction, isFalse);
      expect(filters.isRunnable, isTrue);
    });

    test('occupation experience without an occupation is not runnable', () {
      const filters = CandidateSearchFilters(occupationExperienceYearsMin: 3);

      expect(filters.occupationExperienceIsAnswerable, isFalse);
      expect(filters.isRunnable, isFalse);
    });
  });

  group('the chips describe the active groups', () {
    test('nothing set means no chips', () {
      expect(const CandidateSearchFilters().activeKeys, isEmpty);
    });

    test('a match mode is not a chip of its own', () {
      // Removing "Any" would leave the employer staring at skills that did not
      // change — the mode modifies a group rather than being one.
      const filters = CandidateSearchFilters(
        skillIds: ['skill-1'],
        skillsMatchMode: MatchMode.all,
        attributeIds: ['attr-1'],
        attributesMatchMode: MatchMode.all,
      );

      expect(filters.activeKeys, [
        FilterKey.skillIds,
        FilterKey.attributeIds,
      ]);
    });

    test('chips come out in the order the builder presents them', () {
      const filters = CandidateSearchFilters(
        ageMin: 21,
        restrictionJustificationId: 'just-1',
        occupationIds: ['occ-1'],
        regionId: 'region-1',
      );

      expect(filters.activeKeys, [
        FilterKey.occupationIds,
        FilterKey.regionId,
        FilterKey.ageMin,
        FilterKey.restrictionJustificationId,
      ]);
    });
  });
}
