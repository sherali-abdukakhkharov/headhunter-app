import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/auth/app_role.dart';

/// What the app knows about the current session.
///
/// A sealed hierarchy rather than one class with nullable fields, because the
/// router's redirect chain is a decision over exactly these cases, and an
/// exhaustive `switch` is what stops a fifth case being added without the
/// router noticing.
///
/// [SessionUnknown] is load-bearing: without it the first frame of a cold start
/// looks identical to "signed out", and the app flashes onboarding at a user
/// who is in fact signed in.
@immutable
sealed class SessionState {
  const SessionState();
}

/// Bootstrap has not finished - stored tokens are still being read.
///
/// The router must **not** redirect in this state. Treating it as signed-out is
/// the classic cold-start flash: onboarding appears for a frame or two and then
/// vanishes, which reads as a crash-and-recover.
final class SessionUnknown extends SessionState {
  const SessionUnknown();
}

/// No usable session.
final class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated({this.expired = false});

  /// True when a session existed and refresh failed, as opposed to a first
  /// launch. The difference is user-visible: an expired session owes the user
  /// an explanation (`sessionExpired`), a first launch does not.
  final bool expired;
}

/// A signed-in account.
///
/// Holds the granted role set and the active choice separately, per §2.3. The
/// two can disagree legitimately - a stored `activeRole` may name a role the
/// server has since revoked - so read [effectiveRole], which cannot.
final class SessionActive extends SessionState {
  const SessionActive({
    required this.roles,
    this.activeRole,
    this.status = AccountStatus.active,
    this.restrictionReason,
  });

  /// Roles the server has granted. May be empty: an account can exist before
  /// the user has chosen what they are here to do (§4, role selection).
  final Set<AppRole> roles;

  /// The role the user last switched to. Null until they choose, and possibly
  /// stale - see [effectiveRole].
  final AppRole? activeRole;

  final AccountStatus status;

  /// The administrator's stated reason for a restriction (§10.4).
  ///
  /// BR-10 requires the app to **explain** a restriction rather than fail
  /// mysteriously, so this is displayed verbatim. It is admin-authored content
  /// and therefore never translated client-side (§2.4) - the server returns it
  /// in the `x-lang` locale.
  final String? restrictionReason;

  /// Whether the user still has to choose a role.
  bool get needsRoleSelection => roles.isEmpty;

  /// The role to actually render, or null if none is granted.
  ///
  /// Falls back through [AppRole.preferenceOrder] when [activeRole] is unset or
  /// names a role that is no longer granted. That second case is the one worth
  /// having a getter for: `activeRole` is persisted locally while roles come
  /// from the server, so a revoked role would otherwise leave the user sitting
  /// in a shell they are no longer entitled to.
  AppRole? get effectiveRole {
    final active = activeRole;
    if (active != null && roles.contains(active)) return active;
    for (final role in AppRole.preferenceOrder) {
      if (roles.contains(role)) return role;
    }
    return null;
  }

  bool can(AppRole role) => roles.contains(role);

  SessionActive copyWith({
    Set<AppRole>? roles,
    AppRole? activeRole,
    AccountStatus? status,
    String? restrictionReason,
  }) => SessionActive(
    roles: roles ?? this.roles,
    activeRole: activeRole ?? this.activeRole,
    status: status ?? this.status,
    restrictionReason: restrictionReason ?? this.restrictionReason,
  );

  @override
  bool operator ==(Object other) =>
      other is SessionActive &&
      setEquals(other.roles, roles) &&
      other.activeRole == activeRole &&
      other.status == status &&
      other.restrictionReason == restrictionReason;

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(roles),
    activeRole,
    status,
    restrictionReason,
  );
}

/// Account standing, as the administrator actions of UAT-14 leave it.
///
/// The three are genuinely different in the UI, which is why they are not one
/// boolean:
enum AccountStatus {
  /// Normal.
  active,

  /// Specific actions are withheld, the rest of the app works. Enforced at each
  /// action with `HhNotice.restricted`, **not** by a redirect - bouncing a
  /// restricted user out of the whole app tells them less than blocking the one
  /// button they tried to press.
  restricted,

  /// No access beyond the explanatory notice (BR-10). This one *is* a redirect.
  blocked,
}
