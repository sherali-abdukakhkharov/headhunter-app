/// The three roles of §2.2, one of which is active at a time (§2.3).
///
/// Administrator is a **role in this app**, not a separate surface: §2.4
/// excludes a web admin panel outright, so there is no "we will build the admin
/// screens on the web later" option available to this project.
///
/// One account may hold several roles and switch between them at runtime
/// without a second account (§2.3), which is why the granted set and the active
/// choice are separate pieces of state - see `SessionState`.
enum AppRole {
  /// Someone looking for work.
  candidate(wire: 'candidate', pathPrefix: '/candidate'),

  /// Someone posting vacancies - a company or an individual (§6.1).
  employer(wire: 'employer', pathPrefix: '/employer'),

  /// Platform moderator (§10).
  admin(wire: 'admin', pathPrefix: '/admin');

  const AppRole({required this.wire, required this.pathPrefix});

  /// The value exchanged with the API. Fixed by the contract, so it is written
  /// out rather than derived from [name] - renaming an enum value must not
  /// change what goes on the wire.
  final String wire;

  /// Root of this role's navigation shell.
  ///
  /// Each role owns a path namespace, which is what keeps their navigation
  /// stacks separate: a candidate tab cannot appear under the employer shell
  /// because it is not reachable from the employer's paths.
  final String pathPrefix;

  /// Parses a wire value, returning null for anything unrecognized.
  ///
  /// Null rather than a guess: a role the client does not know about must not
  /// silently become `candidate`, which would grant the wrong shell.
  static AppRole? fromWire(String? wire) => switch (wire) {
    'candidate' => candidate,
    'employer' => employer,
    'admin' => admin,
    _ => null,
  };

  /// The role that owns [location], or null if the path belongs to no shell
  /// (onboarding, role selection, the blocked notice, the design gallery).
  ///
  /// This is what lets a deep link activate the right role before navigating
  /// (ARCHITECTURE.md §3) - the target path itself says which role it needs, so
  /// the rule lives in the router in one place instead of in every caller that
  /// might produce a link.
  static AppRole? fromLocation(String location) {
    for (final role in values) {
      if (location == role.pathPrefix ||
          location.startsWith('${role.pathPrefix}/')) {
        return role;
      }
    }
    return null;
  }

  /// Preference order when a user holds several roles and has chosen none.
  ///
  /// Candidate first: it is the role the great majority of accounts hold, and
  /// the one whose onboarding is the shortest path to something useful.
  static const List<AppRole> preferenceOrder = [candidate, employer, admin];
}
