import 'package:dio/dio.dart';
import 'package:headhunter_app/src/core/l10n/app_locale.dart';

/// Attaches the active interface language to every request.
///
/// §3.2 requires server-produced text - dictionary labels, validation
/// messages, notifications - to match the UI language. Doing that per call
/// site guarantees someone forgets, so it is an interceptor.
///
/// The header value is [AppLocale.tag]: the canonical BCP-47 form with the
/// script code intact (`uz-Latn`, `uz-Cyrl`, `ru`, `en`). Never
/// `locale.languageCode`, which collapses the two Uzbek scripts and would
/// silently serve Latin labels to a Cyrillic user.
class LangInterceptor extends Interceptor {
  const LangInterceptor(this._activeLocale);

  /// Read per request rather than captured once: the user can change language
  /// mid-session and the next request must carry the new value.
  final AppLocale Function() _activeLocale;

  static const headerName = 'x-lang';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.headers[headerName] = _activeLocale().tag;
    handler.next(options);
  }
}
