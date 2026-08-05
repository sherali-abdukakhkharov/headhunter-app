import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_events.g.dart';

/// A one-way channel for "the session is gone", from the network layer to the
/// session layer.
///
/// ## Why this exists rather than a direct call
///
/// `AuthInterceptor` needs to tell `SessionController` that a refresh was
/// refused. It cannot simply read the controller: the controller reads
/// `AuthRepository`, which reads the `Dio` that owns the interceptor. That is a
/// provider cycle, and Riverpod refuses it.
///
/// This breaks the cycle by depending on nothing. `dioProvider` reports into it
/// and `SessionController` listens to it, so the arrow only ever points one way
/// and neither side knows about the other.
///
/// Deliberately not a general event bus. One signal, one direction — a bus with
/// several message types is the thing that makes "what changed my state?"
/// unanswerable.
class AuthEvents {
  final _lost = StreamController<void>.broadcast();

  /// Emits when the server has definitively refused the session — a refresh
  /// that came back 401/403, not a network failure.
  ///
  /// Broadcast so a listener arriving late does not throw; events emitted
  /// before anyone subscribes are dropped, which is correct here because the
  /// session state they describe is already recorded in the token store.
  Stream<void> get sessionLost => _lost.stream;

  /// Matches `AuthInterceptor.onAuthFailure`'s signature, so it can be passed
  /// as a tear-off.
  Future<void> reportSessionLost() async {
    if (!_lost.isClosed) _lost.add(null);
  }

  void dispose() => _lost.close();
}

@Riverpod(keepAlive: true)
AuthEvents authEvents(Ref ref) {
  final events = AuthEvents();
  ref.onDispose(events.dispose);
  return events;
}
