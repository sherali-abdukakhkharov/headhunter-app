import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/features/discovery/domain/feed_filters.dart';

/// §5.5's filters, at the boundary where they turn into a query.
///
/// The screen is not exercised here — the pickers each have their own suite.
/// What this pins is the part that fails **silently**: a filter that never
/// reaches the query returns a full list, which looks like a working screen
/// with nothing filtered rather than like a bug.
void main() {
  group('the query carries only what is set', () {
    test('an empty set sends nothing at all', () {
      expect(const FeedFilters().toQuery(), isEmpty);
      expect(const FeedFilters().isEmpty, isTrue);
    });

    test('empty id sets are omitted rather than sent blank', () {
      // `occupationIds=` would be parsed server-side as a one-element array
      // holding the empty string, and match nothing — a filter nobody set
      // silently emptying the feed. The sets are left at their empty default
      // here, which is the case under test.
      const filters = FeedFilters(salaryFrom: 100);

      expect(filters.toQuery().containsKey('occupationIds'), isFalse);
      expect(filters.toQuery()['salaryFrom'], 100);
    });

    test('id sets travel as lists, for the repository to join', () {
      const filters = FeedFilters(occupationIds: {'a', 'b'});

      // Comma-joining happens in one place, in the repository, because that is
      // where the DTO's parsing is documented. A model that pre-joined would
      // put the same knowledge in two files.
      expect(filters.toQuery()['occupationIds'], isA<List<String>>());
      expect(filters.toQuery()['occupationIds'], hasLength(2));
    });

    test('every parameter the feed query accepts is reachable', () {
      const filters = FeedFilters(
        occupationIds: {'occ'},
        employmentTypeIds: {'emp'},
        workFormatIds: {'fmt'},
        shiftIds: {'shift'},
        regionId: 'region',
        districtId: 'district',
        salaryFrom: 5000000,
        publishedFrom: '2026-08-01',
      );

      expect(filters.toQuery().keys, containsAll(<String>[
        'occupationIds',
        'employmentTypeIds',
        'workFormatIds',
        'shiftIds',
        'regionId',
        'districtId',
        'salaryFrom',
        'publishedFrom',
      ]));
    });

    test('the three §5.5 filters with no parameter are not modelled', () {
      // Experience, language and an upper pay bound have no query parameter, so
      // there is deliberately no field for them: a filter a candidate can set
      // and the server ignores is worse than one never offered, because the
      // result list looks like an answer.
      const filters = FeedFilters(salaryFrom: 1);
      final keys = filters.toQuery().keys.join(' ');

      expect(keys.contains('experience'), isFalse);
      expect(keys.contains('language'), isFalse);
      expect(keys.contains('salaryTo'), isFalse);
    });
  });

  group('the count is decisions, not ids', () {
    test('a set of three counts once', () {
      // Three occupations is one narrowing decision. A badge reading 5 for one
      // row of chips tells nobody anything useful.
      const filters = FeedFilters(occupationIds: {'a', 'b', 'c'});

      expect(filters.count, 1);
    });

    test('each distinct filter counts', () {
      const filters = FeedFilters(
        occupationIds: {'a'},
        regionId: 'r',
        salaryFrom: 100,
      );

      expect(filters.count, 3);
    });
  });

  group('clearing is as expressible as setting', () {
    test('copyWith leaves a null alone rather than clearing it', () {
      const filters = FeedFilters(regionId: 'r', salaryFrom: 100);

      // The usual copyWith problem: without the explicit flags below, there
      // would be no way to unset a filter at all.
      expect(filters.copyWith(salaryFrom: 200).regionId, 'r');
    });

    test('the clear flags unset', () {
      const filters = FeedFilters(
        regionId: 'r',
        districtId: 'd',
        salaryFrom: 100,
        publishedFrom: '2026-08-01',
      );

      final cleared = filters.copyWith(
        clearRegion: true,
        clearDistrict: true,
        clearSalary: true,
        clearPublished: true,
      );

      expect(cleared.isEmpty, isTrue);
      expect(cleared.toQuery(), isEmpty);
    });
  });

  group('equality is deep, because the feed watches it', () {
    test('two sets with the same ids in a different order are equal', () {
      // `vacancyFeedProvider` reads this through `ref.watch`. A shallow
      // comparison would leave it unable to tell a changed filter set from the
      // same one, so the feed would either never refresh or refresh forever.
      const a = FeedFilters(occupationIds: {'x', 'y'});
      const b = FeedFilters(occupationIds: {'y', 'x'});

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('a changed id set is not equal', () {
      const a = FeedFilters(occupationIds: {'x'});
      const b = FeedFilters(occupationIds: {'x', 'y'});

      expect(a, isNot(b));
    });

    test('a changed scalar is not equal', () {
      expect(
        const FeedFilters(salaryFrom: 100),
        isNot(const FeedFilters(salaryFrom: 200)),
      );
    });
  });

  group('storage survives a round trip', () {
    test('every field comes back', () {
      const original = FeedFilters(
        occupationIds: {'occ-1', 'occ-2'},
        employmentTypeIds: {'emp-1'},
        workFormatIds: {'fmt-1'},
        shiftIds: {'shift-1'},
        regionId: 'region-1',
        districtId: 'district-1',
        salaryFrom: 4500000,
        publishedFrom: '2026-08-01',
      );

      expect(FeedFilters.fromJson(original.toJson()), original);
    });

    test('a half-written or foreign payload degrades to empty', () {
      // A stored set written by another build is a convenience, not data
      // anybody can lose — so a wrong type reads as absent rather than throwing
      // and taking the feed screen with it.
      final parsed = FeedFilters.fromJson(const {
        'occupationIds': 'not-a-list',
        'salaryFrom': 'lots',
      });

      expect(parsed.occupationIds, isEmpty);
      // A cast would have thrown here and lost the whole set over one field.
      expect(parsed.salaryFrom, isNull);
      expect(parsed.isEmpty, isTrue);
    });

    test('empty strings inside an id list are dropped', () {
      final parsed = FeedFilters.fromJson(const {
        'occupationIds': ['a', '', 'b'],
      });

      expect(parsed.occupationIds, {'a', 'b'});
    });
  });
}
