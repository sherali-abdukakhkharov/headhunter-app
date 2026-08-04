import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'preferences_provider.g.dart';

/// Non-secret key/value storage.
///
/// Use this for things that are merely *state*: the selected interface language
/// before sign-in, the last search configuration (§7.2), onboarding progress.
///
/// **Never for tokens or anything else secret.** §12.5 requires secrets in
/// platform-backed secure storage; `shared_preferences` is a plain XML file on
/// Android and readable on a rooted device. Tokens go through
/// `core/auth/token_store.dart`.
///
/// Overridden with `SharedPreferences.setMockInitialValues({})` in tests, which
/// is why this is a provider rather than a direct call at each use site.
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) =>
    SharedPreferences.getInstance();
