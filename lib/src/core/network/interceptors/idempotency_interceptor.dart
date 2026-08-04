import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// Attaches an idempotency key to every mutating request (§12.4, BR-07).
///
/// **The key must outlive the attempt.** A key regenerated per attempt gives no
/// protection at all: the retry looks like a brand-new request and the server
/// happily creates a second application. So the durable key is minted by the
/// repository when the user commits the action, persisted alongside the pending
/// action, and passed in via [keyExtra].
///
/// The mint-on-absence path below is a floor, not the design. It keeps a key
/// stable across *transport-level* replays of one `RequestOptions` - notably
/// the auth interceptor's post-refresh replay - but it cannot survive process
/// death, because nothing wrote it down. Anything a user would be upset to see
/// twice supplies its own persisted key.
class IdempotencyInterceptor extends Interceptor {
  const IdempotencyInterceptor({this.uuid = const Uuid()});

  final Uuid uuid;

  /// Header name. Not yet frozen in the backend's `docs/API_CONTRACTS.md` -
  /// this is the conventional spelling and needs confirming before M3 ships a
  /// write path.
  static const headerName = 'Idempotency-Key';

  /// `RequestOptions.extra` slot a caller uses to supply a persisted key.
  static const keyExtra = 'idempotency.key';

  static const _mutatingMethods = {'POST', 'PUT', 'PATCH', 'DELETE'};

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (!_mutatingMethods.contains(options.method.toUpperCase())) {
      handler.next(options);
      return;
    }

    final existing = options.extra[keyExtra];
    final key = existing is String && existing.isNotEmpty
        ? existing
        : uuid.v4();

    // Written back so a replay of this same RequestOptions reuses it rather
    // than minting a second key.
    options.extra[keyExtra] = key;
    options.headers[headerName] = key;

    handler.next(options);
  }
}
