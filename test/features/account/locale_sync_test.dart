/// §3.2's language, on the account rather than on the install.
///
/// The behaviour worth pinning is **who wins at sign-in**, because both answers
/// are defensible in isolation and only one of them is right:
///
/// - a choice made on this device wins, because §3.2 lets somebody pick a
///   language *before* registering and overwriting that would undo the last
///   thing they did;
/// - a device that has never been asked takes the account's value, because the
///   alternative is pushing a guess made from the phone's system language over
///   a choice made deliberately somewhere else.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/core/auth/app_role.dart';
import 'package:jobbridge_app/src/core/auth/session_controller.dart';
import 'package:jobbridge_app/src/core/auth/session_state.dart';
import 'package:jobbridge_app/src/core/l10n/app_locale.dart';
import 'package:jobbridge_app/src/core/l10n/locale_controller.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/account/data/account_repository.dart';
import 'package:jobbridge_app/src/features/account/data/locale_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAccount implements AccountRepository {
  _FakeAccount({this.stored, this.readFails = false});

  /// What the account holds, as a tag.
  String? stored;

  bool readFails;

  final pushed = <String>[];

  @override
  Future<String?> accountLocale() async {
    if (readFails) throw const ApiException('offline');

    return stored;
  }

  @override
  Future<void> updateLocale(String tag) async => pushed.add(tag);

  @override
  Never noSuchMethod(Invocation invocation) => throw UnsupportedError(
    'This suite must not call ${invocation.memberName}.',
  );
}

/// A session in whichever state the case needs.
class _Session extends SessionController {
  _Session({required this.active});

  final bool active;

  @override
  SessionState build() => active
      ? const SessionActive(roles: {AppRole.candidate})
      : const SessionUnauthenticated();
}

Future<ProviderContainer> _container({
  required _FakeAccount account,
  Map<String, Object> prefs = const {},
  bool signedIn = true,
}) async {
  SharedPreferences.setMockInitialValues(prefs);

  final container = ProviderContainer(
    retry: (retryCount, error) => null,
    overrides: [
      accountRepositoryProvider.overrideWithValue(account),
      sessionControllerProvider.overrideWith(() => _Session(active: signedIn)),
    ],
  );
  addTearDown(container.dispose);

  // The controller reads preferences asynchronously; nothing below is
  // meaningful until it has.
  await container.read(localeControllerProvider.future);

  return container;
}

void main() {
  test('a device never asked adopts the account language', () async {
    final account = _FakeAccount(stored: 'ru');
    final c = await _container(account: account);

    await c.read(localeSyncProvider).reconcile();

    expect(c.read(activeLocaleProvider), AppLocale.ru);
    // Nothing is pushed: the account already holds this, and writing it back
    // would be a request whose only effect is to look busy.
    expect(account.pushed, isEmpty);
  });

  test('a choice made here wins, and travels to the account', () async {
    final account = _FakeAccount(stored: 'ru');
    final c = await _container(
      prefs: {'locale.tag': 'uz-Cyrl'},
      account: account,
    );

    await c.read(localeSyncProvider).reconcile();

    // Not overwritten by the account's Russian: §3.2 lets somebody choose
    // before registering, and this is the more recent statement of intent.
    expect(c.read(activeLocaleProvider), AppLocale.uzCyrl);
    expect(account.pushed, ['uz-Cyrl']);
  });

  test('selecting a language stores it locally and on the account', () async {
    final account = _FakeAccount();
    final c = await _container(account: account);

    await c.read(localeSyncProvider).select(AppLocale.ru);

    expect(c.read(activeLocaleProvider), AppLocale.ru);
    expect(account.pushed, ['ru']);
  });

  test('selecting before there is an account pushes nothing', () async {
    final account = _FakeAccount();
    final c = await _container(account: account, signedIn: false);

    await c.read(localeSyncProvider).select(AppLocale.ru);

    // §3.2's whole point: the language is selectable before an account exists,
    // so this is not a failure to report — there is nowhere to push to.
    expect(c.read(activeLocaleProvider), AppLocale.ru);
    expect(account.pushed, isEmpty);
  });

  test('a failed read leaves the language already showing', () async {
    final account = _FakeAccount(readFails: true);
    final c = await _container(account: account);

    final before = c.read(activeLocaleProvider);
    await c.read(localeSyncProvider).reconcile();

    // The app is usable in whatever language it already shows. A screen about a
    // request the user never asked to make would be worse than the silence.
    expect(c.read(activeLocaleProvider), before);
  });

  test('an account language the app does not have is ignored', () async {
    final account = _FakeAccount(stored: 'fr');
    final c = await _container(account: account);

    final before = c.read(activeLocaleProvider);
    await c.read(localeSyncProvider).reconcile();

    // Four interface variants, and a fifth tag is a server that knows something
    // this build does not. Falling back is right; throwing would take the app
    // down over a preference.
    expect(c.read(activeLocaleProvider), before);
  });

  group('MT-025: it outlives the awaits its own methods make', () {
    /// The turn in which an auto-disposing provider nothing listens to is
    /// collected.
    ///
    /// Every method here spans one: [LocaleSync.select] writes locally, waits
    /// for that, and only then pushes; [LocaleSync.reconcile] is launched from
    /// a session listener and dropped. Both used to run their second half on a
    /// dead `Ref` — logging *"Cannot use the Ref of localeSyncProvider after it
    /// has been disposed"* and changing nothing on screen, so the language
    /// switched and never reached the account, and a clean sign-in opened in
    /// the phone's language rather than the account's.
    Future<void> collectionTurn() => Future<void>.delayed(Duration.zero);

    test('a choice still reaches the account after that turn', () async {
      final account = _FakeAccount();
      final c = await _container(account: account);

      final sync = c.read(localeSyncProvider);
      await collectionTurn();

      await sync.select(AppLocale.ru);

      expect(c.read(activeLocaleProvider), AppLocale.ru);
      // The half that went missing. The screen translated either way, which is
      // why nobody saw it: what was lost was the *other* device.
      expect(account.pushed, ['ru']);
    });

    test('sign-in still restores the account language after it', () async {
      final account = _FakeAccount(stored: 'uz-Latn');
      final c = await _container(account: account);

      final sync = c.read(localeSyncProvider);
      await collectionTurn();

      await sync.reconcile();

      expect(c.read(activeLocaleProvider), AppLocale.uzLatn);
    });

    test('the provider hands out the same instance across it', () async {
      final c = await _container(account: _FakeAccount());

      final first = c.read(localeSyncProvider);
      await collectionTurn();

      // The mechanism itself, stated once so a future `@riverpod` on this
      // provider fails here rather than in the two behavioural cases above.
      expect(identical(first, c.read(localeSyncProvider)), isTrue);
    });
  });
}
