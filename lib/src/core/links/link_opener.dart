import 'package:flutter/services.dart';
import 'package:jobbridge_app/src/core/config/app_flavor.dart';
import 'package:jobbridge_app/src/core/l10n/app_locale.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'link_opener.g.dart';

/// No installed application can open a web page.
///
/// Its own type, like `NoViewerException`: nothing failed on a server, and the
/// remedy — enabling a browser — is on the device.
class NoBrowserException implements Exception {
  const NoBrowserException();
}

/// Hands an https page to the browser.
///
/// ## Why there is no plugin behind this
///
/// `url_launcher` is the usual answer, and it is written in Kotlin and so
/// **applies the Kotlin Gradle Plugin** — the build warning future Flutter
/// versions will refuse, whose list this app keeps from growing. The app's own
/// Kotlin is not on that list, so this is a dozen lines in `MainActivity.kt`
/// behind a channel, exactly as the attachment hand-off is.
///
/// The Android side accepts **https and nothing else**: an `ACTION_VIEW`
/// intent opens whatever a URI names, and every link this app shows is a web
/// page. The assertion here is the same rule, stated where a caller will meet
/// it first.
class LinkOpener {
  const LinkOpener({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  final MethodChannel _channel;

  /// Must match the name `MainActivity.kt` registers.
  static const channelName = 'com.jobbridge.app/links';

  /// Opens [url] in the browser.
  ///
  /// Throws [NoBrowserException] when nothing on the device can show it.
  Future<void> open(Uri url) async {
    assert(url.scheme == 'https', 'Only https pages are opened: $url');

    try {
      await _channel.invokeMethod<void>('open', {'url': url.toString()});
    } on PlatformException catch (e) {
      if (e.code == 'no_browser') throw const NoBrowserException();
      // Anything else is a bug in the channel rather than a condition to
      // render, so it keeps its stack.
      rethrow;
    }
  }
}

@riverpod
LinkOpener linkOpener(Ref ref) => const LinkOpener();

/// The operator's public legal pages.
///
/// Served by the API host (`headhunter-backend`'s `LegalController`) because
/// it is the one host the operator runs — and always the **production** host,
/// whatever flavor this build is: there is one privacy policy, and the page a
/// development build links to is the one a user of the store build reads.
/// These are also the URLs the Play listing gives.
abstract final class LegalLinks {
  /// The privacy policy, in the reader's language.
  ///
  /// The pages exist in Uzbek (Latin), Russian and English, so Uzbek Cyrillic
  /// is given the Latin page: it is the same language, and Russian would be a
  /// different one.
  static Uri privacyPolicy(AppLocale locale) => Uri.parse(
    '${AppFlavor.production.apiBaseUrl}/privacy?lang=${_language(locale)}',
  );

  static String _language(AppLocale locale) => switch (locale) {
    AppLocale.uzLatn || AppLocale.uzCyrl => 'uz',
    AppLocale.ru => 'ru',
    AppLocale.en => 'en',
  };
}
