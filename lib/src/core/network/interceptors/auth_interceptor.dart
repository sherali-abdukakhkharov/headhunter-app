import 'dart:async';

import 'package:dio/dio.dart';
import 'package:headhunter_app/src/core/auth/token_store.dart';

/// Exchanges a refresh token for a new pair, or returns null if the server
/// refused.
///
/// Injected rather than called directly so the single-flight behaviour can be
/// tested without a server, and so the *shape* of the auth endpoints - not yet
/// frozen in the backend's `docs/API_CONTRACTS.md` - stays isolated to one
/// implementation instead of spreading through the interceptor.
typedef RefreshCallback = Future<TokenPair?> Function(String refreshToken);

/// Attaches the access token and recovers from expiry with a **single-flight**
/// refresh.
///
/// The reason this is not merely an optimization: the backend rotates refresh
/// tokens and detects reuse at the session-family level. Presenting a refresh
/// token whose row has already been superseded reads as theft and revokes
/// **every session in the family**. So two concurrent 401s that each start
/// their own refresh produce one winner and one reuse detection - and the user
/// is signed out by their own retry, on a perfectly healthy account.
///
/// Therefore: concurrent 401s await one shared refresh and then replay. See
/// ARCHITECTURE.md §7.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenStore,
    required this.refresh,
    required this.retryClient,
    required this.onAuthFailure,
  });

  final TokenStore tokenStore;
  final RefreshCallback refresh;

  /// Used to replay the original request. Deliberately a separate [Dio] with no
  /// auth interceptor, so a replay cannot recurse back into this class.
  final Dio retryClient;

  /// Invoked when the session is definitively gone and the user must sign in
  /// again.
  final Future<void> Function() onAuthFailure;

  /// The in-flight refresh, or null when none is running.
  ///
  /// This is the whole mechanism. Assignment happens synchronously inside
  /// [_refreshOnce] with no `await` between the null check and the store, so
  /// two callers in the same event-loop turn cannot both start a refresh.
  Future<TokenPair?>? _inFlight;

  /// Marks a request already replayed once, so a second 401 surfaces to the
  /// caller instead of looping.
  static const _retriedFlag = 'auth.retried';

  /// Marks requests that must never trigger a refresh - the refresh call itself
  /// and the sign-in endpoints (`/auth/telegram`, and the deferred OTP pair),
  /// where a 401 means bad credentials rather than an expired session.
  static const skipAuthFlag = 'auth.skip';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuthFlag] == true) {
      handler.next(options);
      return;
    }

    final token = await tokenStore.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;

    final shouldAttemptRefresh =
        err.response?.statusCode == 401 &&
        options.extra[skipAuthFlag] != true &&
        options.extra[_retriedFlag] != true;

    if (!shouldAttemptRefresh) {
      handler.next(err);
      return;
    }

    final refreshToken = await tokenStore.readRefreshToken();
    if (refreshToken == null) {
      // Nothing to refresh with: this was an unauthenticated request that
      // needed auth, not an expired session.
      await _failAuth();
      handler.next(err);
      return;
    }

    final TokenPair? tokens;
    try {
      tokens = await _refreshOnce(refreshToken);
    } on Object {
      // A refresh that threw (network down, server error) is not proof the
      // session is invalid, so the tokens stay and the original error
      // surfaces. Clearing here would sign users out on every tunnel.
      handler.next(err);
      return;
    }

    if (tokens == null) {
      await _failAuth();
      handler.next(err);
      return;
    }

    try {
      handler.resolve(await _replay(options, tokens.accessToken));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// Runs at most one refresh at a time; concurrent callers await the same
  /// future and all replay against its result.
  Future<TokenPair?> _refreshOnce(String refreshToken) {
    return _inFlight ??= _performRefresh(refreshToken).whenComplete(() {
      _inFlight = null;
    });
  }

  Future<TokenPair?> _performRefresh(String refreshToken) async {
    final tokens = await refresh(refreshToken);
    if (tokens != null) {
      await tokenStore.save(tokens);
    }
    return tokens;
  }

  Future<Response<dynamic>> _replay(
    RequestOptions options,
    String accessToken,
  ) {
    return retryClient.fetch<dynamic>(
      options
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..extra[_retriedFlag] = true,
    );
  }

  Future<void> _failAuth() async {
    await tokenStore.clear();
    await onAuthFailure();
  }
}
