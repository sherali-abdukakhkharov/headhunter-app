import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/src/app.dart';
import 'package:jobbridge_app/src/core/logging/crash_handlers.dart';

void main() {
  // Before `runApp`, so an error thrown while the first frame is being built
  // is caught by this rather than by the default handler that says nothing in
  // a release build.
  installCrashHandlers();

  runApp(
    ProviderScope(
      // Riverpod 3 retries failing providers automatically with exponential
      // backoff. While retrying, the provider's state is AsyncLoading that
      // merely *carries* the error - so a UI that renders AsyncLoading as a
      // spinner shows an endless spinner instead of the failure, and the
      // request is re-sent forever.
      //
      // Returning null disables that: an error is a terminal state the UI can
      // render, and the user retries explicitly (pull-to-refresh / refresh
      // button). Return a Duration here instead if a screen ever genuinely
      // wants automatic backoff.
      retry: (retryCount, error) => null,
      child: const JobBridgeApp(),
    ),
  );
}
