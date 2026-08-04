// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthSession _$AuthSessionFromJson(Map<String, dynamic> json) => AuthSession(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  expiresInSeconds: (json['expiresInSeconds'] as num).toInt(),
  roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
  activeRole: json['activeRole'] as String?,
  isNewUser: json['isNewUser'] as bool,
);
