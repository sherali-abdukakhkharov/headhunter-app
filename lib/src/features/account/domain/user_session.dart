import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';

/// One signed-in device (§4.2).
///
/// Mirrors `SessionResponseDto` in headhunter-backend — change both together.
///
/// ## Every field except [isCurrent] can be absent
///
/// `deviceName`, `platform` and `appVersion` are whatever the client sent when
/// it signed in, and an older build sent nothing. So a row can legitimately
/// describe a device it cannot name, and the screen has to be readable in that
/// state rather than showing three blank lines — which is why [label] exists
/// here and not at the call site.
@immutable
class UserSession {
  const UserSession({
    required this.id,
    required this.createdAt,
    required this.lastUsedAt,
    required this.expiresAt,
    required this.isCurrent,
    this.deviceName,
    this.platform,
    this.appVersion,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
    id: json['id'] as String,
    createdAt: ZonedTimestamp.parse(json['createdAt'] as String),
    lastUsedAt: ZonedTimestamp.parse(json['lastUsedAt'] as String),
    expiresAt: ZonedTimestamp.parse(json['expiresAt'] as String),
    isCurrent: json['isCurrent'] as bool? ?? false,
    deviceName: json['deviceName'] as String?,
    platform: json['platform'] as String?,
    appVersion: json['appVersion'] as String?,
  );

  final String id;

  final ZonedTimestamp createdAt;
  final ZonedTimestamp lastUsedAt;
  final ZonedTimestamp expiresAt;

  /// The device asking the question.
  ///
  /// The server decides this by comparing the row against the *presented*
  /// token's session, so it is not derivable here — and it is the one field the
  /// screen cannot get wrong, because revoking this row signs the user out of
  /// the phone in their hand.
  final bool isCurrent;

  final String? deviceName;
  final String? platform;
  final String? appVersion;

  /// The best name this row can offer, or null when it has none.
  ///
  /// Falls back from the device's own name to its platform, because "Android"
  /// still tells somebody something and an unnamed row tells them nothing. The
  /// app version is deliberately **not** part of the fallback: a session
  /// identified only as "1.4.2" is not identified.
  String? get label {
    for (final candidate in [deviceName, platform]) {
      if (candidate != null && candidate.trim().isNotEmpty) return candidate;
    }
    return null;
  }
}
