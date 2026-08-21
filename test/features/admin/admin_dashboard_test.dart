import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_dashboard.dart';
import 'package:jobbridge_app/src/features/admin/presentation/admin_dashboard_screen.dart';
import 'admin_fake.dart';

/// §10.1's dashboard.
///
/// The fixture disagrees with itself on purpose in two places, which is what
/// makes this file able to fail:
///
/// - `total` and `new` are different numbers on both count pairs, so a parser
///   reading the wrong key lands on a figure the assertions do not expect
///   rather than on a plausible one;
/// - `period.to` is a **fixed date well away from today**, so any preset that
///   counts back from `DateTime.now()` produces a range these tests reject.
class _FakeAdmin extends FakeAdminBase {
  _FakeAdmin({required this.data, this.error});

  AdminDashboard data;
  ApiException? error;

  /// Every `(from, to)` pair the screen asked for, in order. Null entries are
  /// the deliberate "send nothing and take the server's default" first load.
  final requested = <(String?, String?)>[];

  @override
  Future<AdminDashboard> dashboard({String? from, String? to}) async {
    requested.add((from, to));
    if (error case final failure?) throw failure;

    return data;
  }

  // The dashboard has no business reading a queue itself — it renders counters
  // the same response already carried. These throw so that a screen which
  // started fanning out fails here loudly.
  // The dashboard fetches no queue and decides nothing: every counter comes
  // from the one `/admin/dashboard` request, and tapping a row navigates. Both
  // halves of that are asserted by [FakeAdminBase] refusing the rest.
}

AdminDashboard _dashboard({
  String from = '2026-06-10',
  String to = '2026-07-09',
  int candidatesTotal = 1420,
  int candidatesNew = 96,
  int employersTotal = 260,
  int employersNew = 14,
  int awaitingVerification = 7,
  int awaitingModeration = 3,
  int openComplaints = 2,
  int activeVacancies = 88,
  int applications = 412,
  int restrictedUsers = 3,
  int blockedUsers = 4,
}) => AdminDashboard.fromJson({
  'period': {'from': from, 'to': to},
  'candidates': {'total': candidatesTotal, 'new': candidatesNew},
  'employers': {'total': employersTotal, 'new': employersNew},
  'awaitingVerification': awaitingVerification,
  'awaitingModeration': awaitingModeration,
  'activeVacancies': activeVacancies,
  'applications': applications,
  'openComplaints': openComplaints,
  'restrictedUsers': restrictedUsers,
  'blockedUsers': blockedUsers,
});

void main() {
  Future<_FakeAdmin> pump(
    WidgetTester tester, {
    AdminDashboard? data,
    ApiException? error,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _FakeAdmin(data: data ?? _dashboard(), error: error);

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [adminRepositoryProvider.overrideWithValue(fake)],
        child: MaterialApp(
          theme: HhTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const AdminDashboardScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    return fake;
  }

  Finder chevrons() => find.byWidgetPredicate(
    (w) => w is HhIcon && w.path == HhIconPath.chevronRight,
  );

  group('the response is parsed as the server spells it', () {
    test('the period count reads `new`, which is a Dart keyword', () {
      final pair = CountPair.fromJson(const {'total': 1420, 'new': 96});

      expect(pair.total, 1420);
      // The wire key is `new` and the field is `newInPeriod`. Reading
      // `json['newInPeriod']` would yield zero here, silently.
      expect(pair.newInPeriod, 96);
    });

    test('a period is inclusive at both ends', () {
      // 10 June to 9 July is thirty days when both ends count, which is what
      // the backend's own default period means.
      expect(_dashboard().period.days, 30);
      expect(
        _dashboard(from: '2026-05-01', to: '2026-05-01').period.days,
        1,
      );
    });

    test('a date is parsed as UTC, so day arithmetic cannot shift it', () {
      final date = DashboardPeriod.parseDate('2026-03-29');

      expect(date.isUtc, isTrue);
      // 29 March is a DST boundary in much of Europe. Subtracting a day from a
      // *local* midnight there can land at 23:00 on the 27th, which formats
      // back as the wrong date.
      expect(
        DashboardPeriod.formatDate(date.subtract(const Duration(days: 1))),
        '2026-03-28',
      );
    });

    test('a range counts back inclusively from the day it is given', () {
      final range = DashboardRange.lastDays(
        30,
        endingOn: DateTime.utc(2026, 8, 8),
      );

      expect(range.fromWire, '2026-07-10');
      expect(range.toWire, '2026-08-08');
    });
  });

  group('the first load asks for no period at all', () {
    testWidgets('because the server owns what "the last thirty days" means', (
      tester,
    ) async {
      final fake = await pump(tester);

      // Not `from: 30 days ago`. Today is a fact about PLATFORM_TIME_ZONE and
      // the device cannot compute it; the response is how the client learns
      // which thirty days it got.
      expect(fake.requested, [(null, null)]);
    });

    testWidgets('and the chip lit is the one the response describes', (
      tester,
    ) async {
      // A thirty-day period arrives without anything having been chosen.
      await pump(tester);

      final chip = tester.widget<HhFilterChip>(
        find.widgetWithText(HhFilterChip, '30 days'),
      );
      expect(chip.selected, isTrue);

      final week = tester.widget<HhFilterChip>(
        find.widgetWithText(HhFilterChip, '7 days'),
      );
      expect(week.selected, isFalse);
    });
  });

  group("a preset counts back from the server's date, never the device", () {
    testWidgets('so an administrator in another zone gets the same window', (
      tester,
    ) async {
      final fake = await pump(tester);

      await tester.tap(find.widgetWithText(HhFilterChip, '7 days'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The fixture's period ends on 2026-07-09, which is not today on any
      // machine that runs this. Seven days inclusive ends there and starts on
      // the 3rd — `DateTime.now()` would produce neither.
      expect(fake.requested.last, ('2026-07-03', '2026-07-09'));
    });
  });

  group('queue lengths are current state and metrics are not', () {
    testWidgets('both headings render, so one is not read as the other', (
      tester,
    ) async {
      await pump(tester);

      expect(find.text('Waiting on a decision'), findsOneWidget);
      expect(find.text('For the selected period'), findsOneWidget);
      // The period is stated, so "88 vacancies" is never a bare number.
      expect(find.text('2026-06-10 — 2026-07-09'), findsOneWidget);
    });

    testWidgets('every queue with a screen offers a way in', (tester) async {
      await pump(tester);

      expect(find.text('Employers awaiting verification'), findsOneWidget);
      expect(find.text('Vacancies awaiting moderation'), findsOneWidget);
      expect(find.text('Open complaints'), findsOneWidget);

      // Three chevrons now that the complaint queue has a screen. It was two
      // when this screen shipped, and the affordance follows the *destination*
      // rather than the row — which is what let the third one turn on by
      // passing an `onTap` and changing nothing else here. Kept as a count so
      // that a fourth counter without a screen cannot quietly grow a chevron
      // that leads to a placeholder.
      expect(chevrons(), findsNWidgets(3));
    });

    testWidgets('an empty set of queues is a sentence, not three zeros', (
      tester,
    ) async {
      await pump(
        tester,
        data: _dashboard(
          awaitingVerification: 0,
          awaitingModeration: 0,
          openComplaints: 0,
        ),
      );

      expect(find.text('Nothing is waiting on you.'), findsOneWidget);
      expect(find.text('Employers awaiting verification'), findsNothing);
    });

    testWidgets('one open complaint is still work, so the rows stay', (
      tester,
    ) async {
      await pump(
        tester,
        data: _dashboard(
          awaitingVerification: 0,
          awaitingModeration: 0,
          openComplaints: 1,
        ),
      );

      // §10.2 puts the complaint queue beside the other two. A dashboard that
      // said "nothing to do" over an open complaint would be actively hiding
      // work.
      expect(find.text('Nothing is waiting on you.'), findsNothing);
      expect(find.text('Open complaints'), findsOneWidget);
    });
  });

  group('restricted and blocked are two facts', () {
    testWidgets('never summed, because the remedies differ', (tester) async {
      // Two figures no other counter on the fixture shares, and a sum that is
      // likewise unique — so the assertions cannot be satisfied by a queue
      // length that happens to read the same.
      await pump(
        tester,
        data: _dashboard(restrictedUsers: 11, blockedUsers: 5),
      );

      expect(find.text('11'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      // A single "16 sanctioned accounts" would hide five people BR-10 has
      // shut out inside eleven whose accounts still work.
      expect(find.text('16'), findsNothing);
    });
  });

  group('a failure is terminal, and rendered', () {
    testWidgets('error before loading, because retry is off app-wide', (
      tester,
    ) async {
      await pump(tester, error: const ApiException('Dashboard unavailable.'));

      expect(find.text('Dashboard unavailable.'), findsOneWidget);
      // Not a spinner. With Riverpod's retry disabled an error is a terminal
      // state, so a loading arm matched first would spin forever.
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
