import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/core/auth/app_role.dart';
import 'package:jobbridge_app/src/core/auth/session_state.dart';

void main() {
  group('effectiveRole', () {
    test('is the active role when it is still granted', () {
      const session = SessionActive(
        roles: {AppRole.candidate, AppRole.employer},
        activeRole: AppRole.employer,
      );
      expect(session.effectiveRole, AppRole.employer);
    });

    test('falls back when the active role has been revoked', () {
      // The case this getter exists for: activeRole is persisted locally, roles
      // come from the server. Reading activeRole directly would leave the user
      // in a shell the account no longer holds - and the shell would work,
      // because the widgets do not check.
      const session = SessionActive(
        roles: {AppRole.candidate},
        activeRole: AppRole.employer,
      );
      expect(session.effectiveRole, AppRole.candidate);
    });

    test('follows the stated preference order when nothing is chosen', () {
      const session = SessionActive(
        roles: {AppRole.admin, AppRole.employer, AppRole.candidate},
      );
      expect(session.effectiveRole, AppRole.candidate);
    });

    test('is null only when no role is granted', () {
      const session = SessionActive(roles: {});
      expect(session.effectiveRole, isNull);
      expect(session.needsRoleSelection, isTrue);
    });

    test('every non-empty role set resolves to something', () {
      // The router dereferences effectiveRole with `!` once
      // needsRoleSelection is false, so this must hold for every combination -
      // including ones only reachable by an admin granting a second role.
      for (final roles in [
        {AppRole.candidate},
        {AppRole.employer},
        {AppRole.admin},
        {AppRole.candidate, AppRole.employer},
        {AppRole.employer, AppRole.admin},
        {AppRole.candidate, AppRole.admin},
        {AppRole.candidate, AppRole.employer, AppRole.admin},
      ]) {
        final session = SessionActive(roles: roles);
        expect(session.needsRoleSelection, isFalse, reason: '$roles');
        expect(session.effectiveRole, isNotNull, reason: '$roles');
        expect(roles, contains(session.effectiveRole), reason: '$roles');
      }
    });
  });

  group('equality', () {
    // The router's refreshListenable fires on inequality. Value equality that
    // ignored the role set would mean a role grant never re-ran the redirect
    // chain, so the new shell would appear only after some unrelated rebuild.
    test('distinguishes role sets', () {
      expect(
        const SessionActive(roles: {AppRole.candidate}),
        isNot(const SessionActive(roles: {AppRole.candidate, AppRole.admin})),
      );
    });

    test('distinguishes the active role', () {
      expect(
        const SessionActive(
          roles: {AppRole.candidate, AppRole.employer},
          activeRole: AppRole.candidate,
        ),
        isNot(
          const SessionActive(
            roles: {AppRole.candidate, AppRole.employer},
            activeRole: AppRole.employer,
          ),
        ),
      );
    });

    test('distinguishes account status', () {
      expect(
        const SessionActive(roles: {AppRole.candidate}),
        isNot(
          const SessionActive(
            roles: {AppRole.candidate},
            status: AccountStatus.blocked,
          ),
        ),
      );
    });

    test('ignores role-set ordering', () {
      expect(
        const SessionActive(roles: {AppRole.candidate, AppRole.employer}),
        const SessionActive(roles: {AppRole.employer, AppRole.candidate}),
      );
    });
  });

  group('AppRole wire values', () {
    test('round-trip', () {
      for (final role in AppRole.values) {
        expect(AppRole.fromWire(role.wire), role);
      }
    });

    test('an unknown role is null, never a default', () {
      // A role the client does not know about must not silently become
      // `candidate`: that would grant a shell on the strength of a typo.
      expect(AppRole.fromWire('moderator'), isNull);
      expect(AppRole.fromWire(''), isNull);
      expect(AppRole.fromWire(null), isNull);
    });

    test('are unique', () {
      expect(
        AppRole.values.map((r) => r.wire).toSet(),
        hasLength(AppRole.values.length),
      );
    });
  });
}
