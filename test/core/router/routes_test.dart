import 'package:flutter_test/flutter_test.dart';
import 'package:headhunter_app/src/core/auth/app_role.dart';
import 'package:headhunter_app/src/core/router/routes.dart';
import 'package:headhunter_app/src/core/router/shell_tabs.dart';

void main() {
  group('shell paths agree with AppRole.pathPrefix', () {
    // The paths in Routes are string literals, because
    // `AppRole.candidate.pathPrefix` is an instance getter and cannot appear in
    // a `const`. So nothing but this test connects the two, and the failure it
    // catches is quiet: a tab whose path stops matching its role's prefix still
    // renders, still navigates from the bar, and becomes unreachable only via a
    // deep link - which is the path nobody exercises by hand.
    for (final role in AppRole.values) {
      test('every ${role.name} tab sits under ${role.pathPrefix}', () {
        for (final tab in ShellTabs.forRole(role)) {
          expect(
            tab.path,
            startsWith('${role.pathPrefix}/'),
            reason: '${tab.path} would be invisible to AppRole.fromLocation',
          );
          expect(AppRole.fromLocation(tab.path), role);
        }
      });
    }

    test('homeFor points at the first tab of that role', () {
      for (final role in AppRole.values) {
        expect(Routes.homeFor(role), ShellTabs.forRole(role).first.path);
      }
    });
  });

  group('AppRole.fromLocation', () {
    test('claims the prefix itself and anything under it', () {
      expect(AppRole.fromLocation('/employer'), AppRole.employer);
      expect(AppRole.fromLocation('/employer/vacancies'), AppRole.employer);
      expect(
        AppRole.fromLocation('/employer/vacancies/42/edit'),
        AppRole.employer,
      );
    });

    test('does not claim a path that merely starts with the same letters', () {
      // '/admin' must not swallow '/administration-notice'. A `startsWith` with
      // no separator check is the obvious way to write this function and the
      // obvious way to get it wrong.
      expect(AppRole.fromLocation('/adminesque'), isNull);
      expect(AppRole.fromLocation('/candidate-terms'), isNull);
    });

    test('returns null for every non-shell route', () {
      for (final path in [
        Routes.splash,
        Routes.onboarding,
        Routes.roleSelection,
        Routes.blocked,
        Routes.developerTools,
        Routes.designGallery,
        Routes.health,
      ]) {
        expect(AppRole.fromLocation(path), isNull, reason: path);
      }
    });
  });

  group('development paths', () {
    test('are exactly the underscore-prefixed ones', () {
      expect(Routes.isDevelopmentPath(Routes.developerTools), isTrue);
      expect(Routes.isDevelopmentPath(Routes.designGallery), isTrue);
      expect(Routes.isDevelopmentPath(Routes.health), isTrue);
    });

    test('do not accidentally include a product route', () {
      // If this ever fails, a product screen has been placed outside the
      // redirect chain - an unauthenticated user could reach it.
      for (final path in [
        Routes.splash,
        Routes.onboarding,
        Routes.roleSelection,
        Routes.blocked,
        ...AppRole.values.expand(
          (r) => ShellTabs.forRole(r).map((t) => t.path),
        ),
      ]) {
        expect(Routes.isDevelopmentPath(path), isFalse, reason: path);
      }
    });
  });

  group('shell tabs', () {
    test("every role has five, the design's cap", () {
      for (final role in AppRole.values) {
        expect(ShellTabs.forRole(role), hasLength(5), reason: role.name);
      }
    });

    test('paths are unique across all three shells', () {
      final all = AppRole.values
          .expand((r) => ShellTabs.forRole(r).map((t) => t.path))
          .toList();
      expect(all.toSet(), hasLength(all.length));
    });
  });
}
