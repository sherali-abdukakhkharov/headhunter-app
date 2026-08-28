/// M11's "loading states complete": a list screen must not open on a spinner.
///
/// The three card skeletons existed from the start and **no screen used one**.
/// Every list opened on a centred `CircularProgressIndicator`, which says
/// "something is happening" where a skeleton says *what* is coming — and which
/// is centred where the list is not, so the first frame of content jumps the
/// whole screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/core/design/design.dart';

Future<void> pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(theme: HhTheme.light, home: Scaffold(body: child)),
  );
  await tester.pump();
}

void main() {
  testWidgets('a page of rows, not one spinner', (tester) async {
    await pump(
      tester,
      const HhSkeletonList(item: HhVacancyCardSkeleton()),
    );

    expect(find.byType(HhVacancyCardSkeleton), findsNWidgets(4));
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('it occupies the space the rows will', (tester) async {
    await pump(
      tester,
      const HhSkeletonList(item: HhCandidateCardSkeleton()),
    );

    // The point of the skeleton is that content does not jump into place when
    // it arrives, so the placeholder has to start at the top of the list rather
    // than in the middle of the screen.
    final first = tester.getTopLeft(find.byType(HhCandidateCardSkeleton).first);
    expect(first.dy, lessThan(120));
  });

  testWidgets('it does not scroll', (tester) async {
    await pump(
      tester,
      const HhSkeletonList(item: HhApplicationCardSkeleton()),
    );

    final list = tester.widget<ListView>(find.byType(ListView));

    // There is nothing underneath to reach, and a list that bounces while it
    // is still loading reads as content that is already there.
    expect(list.physics, isA<NeverScrollableScrollPhysics>());
  });

  testWidgets('the count is settable for a shorter list', (tester) async {
    await pump(
      tester,
      const HhSkeletonList(item: HhVacancyCardSkeleton(), count: 2),
    );

    expect(find.byType(HhVacancyCardSkeleton), findsNWidgets(2));
  });
}
