import 'package:headhunter_app/src/core/auth/app_role.dart';
import 'package:headhunter_app/src/core/auth/token_store.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_session.g.dart';

/// What the backend returns from any call that opens a session.
///
/// Mirrors `AuthTokensResponseDto` in headhunter-backend — **change both
/// together.** Both `/auth/telegram` and the deferred `/auth/otp/verify` return
/// this same shape, which is what lets the session model and the role-selection
/// redirect be written once.
@JsonSerializable(createToJson: false)
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresInSeconds,
    required this.roles,
    required this.activeRole,
    required this.isNewUser,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionFromJson(json);

  final String accessToken;
  final String refreshToken;
  final int expiresInSeconds;

  /// Wire values, kept as strings deliberately.
  ///
  /// A role this client version does not know about must not crash
  /// deserialization — the server can grow a role before the app ships support
  /// for it. [grantedRoles] drops unknown values instead.
  final List<String> roles;

  /// Null when the account holds several roles and has chosen none, or holds
  /// none yet. The client then calls `/auth/active-role` before acting.
  final String? activeRole;

  /// True when this sign-in created the account, so the client routes into role
  /// selection rather than a shell.
  final bool isNewUser;

  Set<AppRole> get grantedRoles => roles.map(AppRole.fromWire).nonNulls.toSet();

  AppRole? get active => AppRole.fromWire(activeRole);

  TokenPair get tokens =>
      TokenPair(accessToken: accessToken, refreshToken: refreshToken);

  /// Never include token material: these strings reach log lines and crash
  /// reports. Same rule as [TokenPair].
  @override
  String toString() =>
      'AuthSession(roles: $roles, activeRole: $activeRole, '
      'isNewUser: $isNewUser, tokens: <redacted>)';
}
