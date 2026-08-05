/// Strips credentials out of network log lines.
///
/// §12.1 requires logging without sensitive data, and the dio `LogInterceptor`
/// prints request headers and both bodies verbatim. Three things pass through
/// it that must not reach logcat:
///
/// - **the bearer token**, on every authenticated request once
///   `AuthInterceptor` is installed;
/// - **the token pair**, in the body of every sign-in and every refresh;
/// - **the one-time code and the phone number** (§4.2, §12.1).
///
/// This runs on the formatted line rather than on the request, because that is
/// the last point where all three are visible in one place — and because a
/// redactor that has to be remembered at each call site is one that will be
/// forgotten at the next.
///
/// ## Two spellings, and missing the second one is the easy mistake
///
/// A **response** body is logged as raw JSON: `{"accessToken":"eyJ..."}`. A
/// **request** body is logged as a Dart `Map`, so it comes out unquoted:
/// `{phone: +998901234567, code: 666666}`. Patterns written against JSON alone
/// look right, pass a JSON-only test, and silently let every outgoing secret
/// through — which is exactly what happened here before a real log was read.
/// Every rule below therefore treats the quotes as optional on both the key and
/// the value.
///
/// **Not a security boundary.** Logging is already off in release builds and in
/// the production flavor (`AppConfig.isNetworkLoggingEnabled`). This is defence
/// for the builds that *are* logging: a developer's logcat, a screen share, a
/// bug report with a log attached.
String redactSensitive(String line) => line
    .replaceAllMapped(_bearer, (m) => '${m[1]}$_mask')
    .replaceAllMapped(_tokenValue, (m) => '${_group(m, 'prefix')}$_mask')
    .replaceAllMapped(_otpCode, (m) => '${_group(m, 'prefix')}$_mask')
    .replaceAllMapped(
      _phone,
      (m) => '${_group(m, 'prefix')}${_maskPhone(_group(m, 'value'))}',
    );

/// `replaceAllMapped` hands back a [Match], which has no named-group access;
/// every pattern here is a [RegExpMatch], which does.
String _group(Match m, String name) =>
    (m as RegExpMatch).namedGroup(name) ?? '';

/// `Authorization: Bearer eyJ...` in a header dump.
final _bearer = RegExp(r'(Bearer\s+)[\w\-.~+/=]+', caseSensitive: false);

/// Token material, in a body going either direction.
final _tokenValue = RegExp(
  r'(?<prefix>"?(?:accessToken|refreshToken|idToken)"?\s*:\s*"?)'
  r'[^",}\s]+',
  caseSensitive: false,
);

/// The one-time code, on the way out and echoed back as `devCode`.
///
/// Matched on a run of 4-8 digits rather than on the key alone, because `code`
/// is *also* the backend's error-key field (`"code":"auth.otp_invalid"`) and
/// that one is not a secret — it is the single most useful thing in the log
/// when a call fails. The lookbehind keeps `statusCode` out of it.
final _otpCode = RegExp(
  r'(?<prefix>"?(?<![A-Za-z])(?:devCode|code)"?\s*:\s*"?)\d{4,8}(?!\d)',
  caseSensitive: false,
);

/// Phone numbers, masked rather than removed: the last two digits are enough to
/// tell two test accounts apart, and it matches how the backend logs them.
final _phone = RegExp(
  r'(?<prefix>"?phone"?\s*:\s*"?)(?<value>\+?[\d\s\-()]{3,})',
  caseSensitive: false,
);

String _maskPhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 2) return _mask;
  return '***${digits.substring(digits.length - 2)}';
}

const _mask = '<redacted>';
