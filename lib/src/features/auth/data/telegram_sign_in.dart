import 'package:jobbridge_app/src/core/config/app_config.dart';
import 'package:jobbridge_app/src/core/config/app_flavor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telegram_login/telegram_login.dart';

part 'telegram_sign_in.g.dart';

/// Obtains a Telegram OIDC **ID token**, and nothing else.
///
/// An interface with one method, deliberately: `telegram_login` is a very small
/// package wrapping a *community fork* of Telegram's official Android SDK
/// (docs/TELEGRAM_LOGIN.md §4.1). Keeping the surface to `Future<String>` means
/// replacing it with a platform channel over the official SDKs is a change to
/// one class, not to the repository, the session controller and the UI.
///
/// It returns a token rather than a session on purpose: **the app never decides
/// who the user is.** The token is a signed assertion from Telegram, and only
/// the backend — which verifies it against Telegram's JWKS — turns it into a
/// session.
// one_member_abstracts: the single method is the point. This is a seam for
// substituting the SDK (and for injecting a fake in tests), not an interface
// waiting to grow - a top-level function could do neither.
// ignore: one_member_abstracts
abstract interface class TelegramSignIn {
  /// Runs the Telegram consent flow and returns the raw `id_token`.
  ///
  /// Throws [TelegramSignInCancelled] if the user backed out, and
  /// [TelegramSignInFailure] for everything else.
  Future<String> obtainIdToken();
}

/// The user dismissed Telegram without authorising.
///
/// Separate from [TelegramSignInFailure] because it is **not an error**: the UI
/// must return to the sign-in screen silently. Showing "login failed" to
/// somebody who chose to press back is how an app feels broken.
class TelegramSignInCancelled implements Exception {
  const TelegramSignInCancelled();

  @override
  String toString() => 'TelegramSignInCancelled()';
}

/// Why a Telegram sign-in could not be completed, at the granularity the UI
/// needs to choose a message.
enum TelegramSignInFailureKind {
  /// No network while talking to Telegram.
  network,

  /// This build has no registered redirect URI — see
  /// [AppFlavor.telegramRedirectUri].
  notConfigured,

  /// Telegram refused, or the SDK failed for a reason we cannot act on.
  telegram,
}

/// A Telegram sign-in failure.
///
/// Carries a [kind] rather than a message: the copy is ours, so it belongs in
/// the ARB files and is resolved by the widget that has a `BuildContext`.
/// (Contrast `ApiException`, whose message arrives already localized from the
/// server thanks to `x-lang`.)
class TelegramSignInFailure implements Exception {
  const TelegramSignInFailure(this.kind, {this.detail});

  final TelegramSignInFailureKind kind;

  /// Diagnostic text for logs only — never rendered.
  final String? detail;

  @override
  String toString() =>
      'TelegramSignInFailure($kind${detail == null ? '' : ': $detail'})';
}

/// [TelegramSignIn] backed by the `telegram_login` plugin.
class PluginTelegramSignIn implements TelegramSignIn {
  PluginTelegramSignIn({
    required this.clientId,
    required this.redirectUri,
    required this.scopes,
    TelegramLogin? plugin,
  }) : _plugin = plugin ?? TelegramLogin();

  final String clientId;
  final String redirectUri;
  final List<String> scopes;

  final TelegramLogin _plugin;

  @override
  Future<String> obtainIdToken() async {
    if (redirectUri.isEmpty) {
      throw const TelegramSignInFailure(
        TelegramSignInFailureKind.notConfigured,
        detail: 'No redirect URI registered for this flavor',
      );
    }

    try {
      // `configure` is idempotent but not free, and the plugin exposes the flag
      // for exactly this.
      if (!_plugin.isConfigured) {
        await _plugin.configure(
          TelegramLoginConfiguration(
            clientId: clientId,
            redirectUri: redirectUri,
            scopes: scopes,
          ),
        );
      }

      final result = await _plugin.login();
      return result.idToken;
    } on Object catch (error) {
      // `on Object`, and this is not laziness. `TelegramLoginError` extends
      // `Equatable` — it does **not** implement `Exception` — so the plugin
      // throws something that `on Exception catch` silently does not catch,
      // and the failure would surface as an unhandled async error with no UI
      // feedback at all. Verified in the plugin's source, v1.2.1.
      throw _translate(error);
    }
  }

  Exception _translate(Object error) {
    if (error is TelegramSignInFailure || error is TelegramSignInCancelled) {
      return error as Exception;
    }
    if (error is! TelegramLoginError) {
      return TelegramSignInFailure(
        TelegramSignInFailureKind.telegram,
        detail: error.toString(),
      );
    }

    return switch (error.code) {
      TelegramLoginErrorCode.cancelled => const TelegramSignInCancelled(),
      TelegramLoginErrorCode.networkError => TelegramSignInFailure(
        TelegramSignInFailureKind.network,
        detail: error.message,
      ),
      TelegramLoginErrorCode.notConfigured => TelegramSignInFailure(
        TelegramSignInFailureKind.notConfigured,
        detail: error.message,
      ),
      // Everything else is Telegram's side or the SDK's, and none of it is
      // something the user can act on beyond retrying. `error.message` is kept
      // as diagnostic detail only - it is English SDK text, never shown.
      _ => TelegramSignInFailure(
        TelegramSignInFailureKind.telegram,
        detail: '${error.code}: ${error.message}',
      ),
    };
  }
}

@Riverpod(keepAlive: true)
TelegramSignIn telegramSignIn(Ref ref) => PluginTelegramSignIn(
  clientId: AppConfig.telegramClientId,
  redirectUri: AppConfig.flavor.telegramRedirectUri,
  scopes: AppConfig.telegramScopes,
);
