import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'token_store.g.dart';

/// A session's token pair.
class TokenPair {
  const TokenPair({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  /// Never include token material in a string representation - these end up in
  /// crash reports and log lines.
  @override
  String toString() => 'TokenPair(access: <redacted>, refresh: <redacted>)';
}

/// Persistent, platform-encrypted storage for the session tokens.
///
/// §12.5 requires secure storage for secrets. On Android this is the Keystore
/// via `EncryptedSharedPreferences`; on iOS the Keychain. Tokens must never
/// touch `shared_preferences`, which is a world-readable XML file on a rooted
/// device.
class TokenStore {
  const TokenStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessKey = 'auth.access_token';
  static const _refreshKey = 'auth.refresh_token';

  Future<String?> readAccessToken() => _storage.read(key: _accessKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> save(TokenPair tokens) async {
    // Written sequentially rather than concurrently: the Android
    // EncryptedSharedPreferences editor is not safe to drive from two
    // simultaneous writes, and a torn pair is worse than a slow one.
    await _storage.write(key: _accessKey, value: tokens.accessToken);
    await _storage.write(key: _refreshKey, value: tokens.refreshToken);
  }

  /// Drops both tokens. Called on sign-out and on a failed refresh.
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}

@Riverpod(keepAlive: true)
TokenStore tokenStore(Ref ref) => const TokenStore(
  FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      // `first_unlock` rather than the `unlocked` default. The default makes
      // the token unreadable whenever the device is locked, which breaks any
      // background refresh - a platform difference that only shows up on a
      // real locked device, never in a simulator during development.
      accessibility: KeychainAccessibility.first_unlock,
    ),
  ),
);
