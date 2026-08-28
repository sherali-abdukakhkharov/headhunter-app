/// §12.4's "offline state explicit", inside the shell rather than only at the
/// cold start.
///
/// Every screen in this app put **"Something went wrong"** over every failure.
/// That is a claim about the system, and on a bad connection it is both untrue
/// and unhelpful — it points at the app instead of at the one thing the reader
/// can actually fix.
///
/// The *message* never needed changing: `ApiException` already carries a
/// localized sentence about the connection for these kinds, because the server
/// was never reached and could not send one. Only the heading contradicted it.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';

Future<AppL10n> english() => AppL10n.delegate.load(const Locale('en'));

void main() {
  test('a connection failure says so, instead of blaming the app', () async {
    final l10n = await english();

    for (final kind in [ApiFailureKind.offline, ApiFailureKind.timeout]) {
      expect(
        failureTitle(ApiException('x', kind: kind), l10n),
        l10n.stateOfflineTitle,
        reason: '$kind is the connection, not the product',
      );
    }
  });

  test('a timeout counts as the connection', () {
    // From the server's side a timeout and a dead connection are different
    // events. From the reader's side they are one situation with one remedy,
    // and a heading saying "something went wrong" for a timeout blames the app
    // for a train tunnel.
    expect(ApiFailureKind.timeout.isConnection, isTrue);
  });

  test('a certificate failure does not claim there is no connection', () async {
    final l10n = await english();

    // Captive portals cause most of these, and on a network that is plainly
    // working "no connection" is a lie. The generic heading is the honest one.
    expect(ApiFailureKind.certificate.isConnection, isFalse);
    expect(
      failureTitle(
        const ApiException('x', kind: ApiFailureKind.certificate),
        l10n,
      ),
      l10n.stateErrorTitle,
    );
  });

  test('anything the server answered keeps the generic heading', () async {
    final l10n = await english();

    for (final kind in [
      ApiFailureKind.server,
      ApiFailureKind.unknown,
      ApiFailureKind.cancelled,
    ]) {
      expect(
        failureTitle(ApiException('x', kind: kind), l10n),
        l10n.stateErrorTitle,
      );
    }
  });

  test('a non-ApiException keeps the generic heading', () async {
    final l10n = await english();

    // A screen can be handed anything — a `StateError` from a bad cast, a
    // string. Guessing "no connection" about one of those would be worse than
    // saying nothing specific.
    expect(failureTitle(StateError('x'), l10n), l10n.stateErrorTitle);
    expect(failureTitle(null, l10n), l10n.stateErrorTitle);
  });
}
