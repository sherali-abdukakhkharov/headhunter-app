import 'package:flutter_test/flutter_test.dart';
import 'package:headhunter_app/src/features/auth/data/telegram_sign_in.dart';
import 'package:telegram_login/telegram_login.dart';

/// Stands in for the plugin, so no platform channel is involved.
///
/// Subclasses `TelegramLogin` rather than swapping
/// `TelegramLoginPlatform.instance`: the platform interface guards assignment
/// with a private token, and going through the public entry point is both
/// simpler and closer to how production calls it.
class _FakeTelegramLogin extends TelegramLogin {
  _FakeTelegramLogin({this.result, this.error});

  final TelegramLoginResult? result;

  /// Deliberately `Object?`: the plugin throws `TelegramLoginError`, which is
  /// **not** an `Exception`. Typing this as `Exception?` would make the test
  /// unable to reproduce the exact hazard it exists to cover.
  final Object? error;

  int configureCalls = 0;
  TelegramLoginConfiguration? lastConfig;
  bool _configured = false;

  @override
  bool get isConfigured => _configured;

  @override
  Future<void> configure(TelegramLoginConfiguration config) async {
    configureCalls++;
    lastConfig = config;
    _configured = true;
  }

  @override
  Future<TelegramLoginResult> login() async {
    final failure = error;
    if (failure != null) {
      // Throwing a non-Error, non-Exception object is the exact hazard under
      // test: the real plugin throws `TelegramLoginError`, which implements
      // neither. Obeying only_throw_errors here would make the fake unable to
      // reproduce it.
      // ignore: only_throw_errors
      throw failure;
    }
    return result!;
  }
}

void main() {
  ({PluginTelegramSignIn signIn, _FakeTelegramLogin plugin}) build({
    TelegramLoginResult? result,
    Object? error,
    String redirectUri = 'https://app1562839855-login.tg.dev/tglogin',
  }) {
    final plugin = _FakeTelegramLogin(result: result, error: error);
    return (
      signIn: PluginTelegramSignIn(
        clientId: '8565299674',
        redirectUri: redirectUri,
        scopes: const ['openid', 'profile', 'phone'],
        plugin: plugin,
      ),
      plugin: plugin,
    );
  }

  group('a successful sign-in', () {
    test('returns the raw id token', () async {
      final h = build(
        result: const TelegramLoginResult(idToken: 'header.payload.signature'),
      );

      expect(await h.signIn.obtainIdToken(), 'header.payload.signature');
    });

    test('configures the plugin with the values we were given', () async {
      final h = build(result: const TelegramLoginResult(idToken: 't'));
      await h.signIn.obtainIdToken();

      expect(h.plugin.lastConfig?.clientId, '8565299674');
      expect(
        h.plugin.lastConfig?.redirectUri,
        'https://app1562839855-login.tg.dev/tglogin',
        reason: 'must match BotFather byte for byte, /tglogin path included',
      );
      // `phone` is not optional: BR-01 requires a verified phone number and the
      // backend refuses a login without one. Dropping this scope would mint
      // tokens that always fail server-side - a confusing way to break.
      expect(h.plugin.lastConfig?.scopes, contains('phone'));
      expect(h.plugin.lastConfig?.scopes, contains('openid'));
    });

    test('does not reconfigure on a second sign-in', () async {
      final h = build(result: const TelegramLoginResult(idToken: 't'));

      await h.signIn.obtainIdToken();
      await h.signIn.obtainIdToken();

      expect(h.plugin.configureCalls, 1);
    });
  });

  group('error translation', () {
    // Why this group exists: `TelegramLoginError` extends Equatable and does
    // **not** implement Exception, so `on Exception catch` does not catch it.
    // Without the `on Object` catch in PluginTelegramSignIn, every case here
    // would escape as an unhandled async error and the UI would show nothing.
    test('the plugin really does throw a non-Exception', () {
      expect(TelegramLoginError.serverError(502), isNot(isA<Exception>()));
    });

    test('a plugin error is translated, not leaked', () async {
      final h = build(error: TelegramLoginError.serverError(502));

      await expectLater(
        h.signIn.obtainIdToken(),
        throwsA(isA<TelegramSignInFailure>()),
      );
    });

    test('cancellation is its own type, not a failure', () async {
      // The UI must show nothing for this. Telling somebody who pressed back
      // that login "failed" is how an app reads as broken.
      final h = build(error: TelegramLoginError.cancelled());

      await expectLater(
        h.signIn.obtainIdToken(),
        throwsA(isA<TelegramSignInCancelled>()),
      );
    });

    test('a network error is distinguishable, so the UI can say so', () async {
      final h = build(error: TelegramLoginError.networkError('offline'));

      await expectLater(
        h.signIn.obtainIdToken(),
        throwsA(
          isA<TelegramSignInFailure>().having(
            (f) => f.kind,
            'kind',
            TelegramSignInFailureKind.network,
          ),
        ),
      );
    });

    test('an unexpected throwable still becomes a failure', () async {
      final h = build(error: StateError('boom'));

      await expectLater(
        h.signIn.obtainIdToken(),
        throwsA(isA<TelegramSignInFailure>()),
      );
    });
  });

  group('an unregistered flavor', () {
    test('fails before starting a login it cannot finish', () async {
      // staging and production have no BotFather registration, so their
      // redirect URI is empty. Failing here is the point: otherwise Telegram
      // refuses the redirect and the user gets a blank return trip.
      final h = build(
        result: const TelegramLoginResult(idToken: 't'),
        redirectUri: '',
      );

      await expectLater(
        h.signIn.obtainIdToken(),
        throwsA(
          isA<TelegramSignInFailure>().having(
            (f) => f.kind,
            'kind',
            TelegramSignInFailureKind.notConfigured,
          ),
        ),
      );
      expect(
        h.plugin.configureCalls,
        0,
        reason: 'must not even configure the SDK',
      );
    });
  });
}
