import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/src/app.dart';

void main() {
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
      child: const HeadhunterApp(),
    ),
  );
}
